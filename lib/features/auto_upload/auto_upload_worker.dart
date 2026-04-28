import 'dart:async';
import 'dart:io';

import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;

import '../../api/auth_interceptor.dart';
import '../../api/models.dart';
import '../../api/speakr_api.dart';
import '../../services/credentials_store.dart';
import 'auto_upload_settings.dart';
import 'auto_upload_settings_store.dart';
import 'datetime_parser.dart';

/// Audio extensions the watcher picks up. Lowercase, with leading dot.
const Set<String> kAutoUploadAudioExtensions = {
  '.m4a', '.mp3', '.wav', '.ogg', '.aac', '.opus', '.amr', '.3gp', '.flac',
};

/// Result of a single file's processing during a scan.
enum AutoUploadOutcome {
  uploaded,
  skippedStillWriting,
  skippedTooRecent,
  failed,
}

class AutoUploadResult {
  AutoUploadResult({required this.trigger});
  final String trigger;
  int uploaded = 0;
  int skipped = 0;
  int failed = 0;

  String? lastError;

  String get summary {
    final base = 'trigger=$trigger ok=$uploaded skipped=$skipped fail=$failed';
    return lastError == null ? base : '$base · $lastError';
  }
}

/// Build a fresh [SpeakrApi] for use inside a background isolate (no
/// Riverpod). The interceptor reads credentials from secure storage on
/// each request, so per-isolate construction is correct.
SpeakrApi buildBackgroundApi() {
  final dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 60),
    sendTimeout: const Duration(minutes: 10),
    contentType: 'application/json',
    responseType: ResponseType.json,
  ));
  dio.interceptors.add(AuthInterceptor(CredentialsStore()));
  return SpeakrApi(dio);
}

/// Lists eligible audio files in the configured folder. Used by both the
/// worker and the Library screen's "pending files" provider.
List<File> listCandidateFiles(String folderPath) {
  final dir = Directory(folderPath);
  if (!dir.existsSync()) return const [];
  return dir
      .listSync(followLinks: false)
      .whereType<File>()
      .where((f) => kAutoUploadAudioExtensions
          .contains(p.extension(f.path).toLowerCase()))
      .toList();
}

/// Decides whether a file is safe to upload right now. Skips files that
/// were modified within the last 30s (likely still being written) and
/// files whose size changes across a 5s re-stat (definitely still being
/// written — covers ongoing call recording).
Future<AutoUploadOutcome> _checkFileStable(
  File file, {
  Duration grace = const Duration(seconds: 30),
  Duration restatAfter = const Duration(seconds: 5),
}) async {
  final stat = await file.stat();
  final age = DateTime.now().difference(stat.modified);
  if (age < grace) return AutoUploadOutcome.skippedTooRecent;
  final firstSize = stat.size;
  await Future<void>.delayed(restatAfter);
  if (!await file.exists()) return AutoUploadOutcome.skippedStillWriting;
  final secondSize = (await file.stat()).size;
  if (firstSize != secondSize) return AutoUploadOutcome.skippedStillWriting;
  return AutoUploadOutcome.uploaded; // sentinel — caller does the actual upload
}

/// Outcome of a duration probe. Distinguishes "format not understood by
/// the metadata reader" (benign, fall back to uploading) from "format was
/// recognised but the parse threw" (surface as an error badge).
class _DurationProbe {
  const _DurationProbe._({this.duration, this.error});
  final Duration? duration;
  final String? error;

  /// Duration was successfully read.
  factory _DurationProbe.known(Duration d) => _DurationProbe._(duration: d);

  /// Format wasn't recognised, or the parser couldn't compute a duration.
  /// Treat as "unknown but not broken" — upload normally.
  factory _DurationProbe.unsupported() => const _DurationProbe._();

  /// Format was recognised but parsing threw. The user gets an error badge
  /// with this message.
  factory _DurationProbe.failed(String message) =>
      _DurationProbe._(error: message);

  bool get hasError => error != null;
  bool get isKnown => duration != null;
}

/// Probes the audio duration of [file]. Synchronous I/O is fine in the
/// background isolate where the worker runs. Never throws.
_DurationProbe _probeDuration(File file) {
  try {
    final metadata = readMetadata(file, getImage: false);
    final d = metadata.duration;
    if (d == null) return _DurationProbe.unsupported();
    return _DurationProbe.known(d);
  } on NoMetadataParserException {
    // Format isn't supported by audio_metadata_reader (e.g. raw .aac, .amr,
    // .3gp). Skip the duration check rather than spam error badges.
    return _DurationProbe.unsupported();
  } catch (e) {
    return _DurationProbe.failed(e.toString());
  }
}

/// Builds the user-facing error message stored against a file when its
/// duration couldn't be read. Includes the filename so the dialog text
/// makes sense without extra context.
String _durationErrorMessage(File file, String detail) {
  final name = p.basename(file.path);
  return "Couldn't read the duration of $name. The file may be corrupt or "
      'use an unsupported codec.\n\n$detail';
}

/// Uploads one file via [api], using [config] to derive datetime and
/// other multipart fields. Deletes the local file on success.
Future<Recording> _uploadAndDelete(
  File file,
  FolderUploadConfig config,
  SpeakrApi api,
) async {
  final dt = resolveDateTime(file, config);
  final tagIds = config.tagId == null ? const <int>[] : <int>[config.tagId!];
  final recording = await api.uploadRecording(
    file: file,
    language: config.language,
    minSpeakers: config.minSpeakers,
    maxSpeakers: config.maxSpeakers,
    tagIds: tagIds,
    fileLastModified: dt,
  );
  try {
    await file.delete();
  } catch (_) {
    // Mirror live_screen behaviour: a failed delete after a successful
    // upload is non-fatal; the next scan will re-check stability and skip.
  }
  return recording;
}

class AutoUploadStillWritingException implements Exception {
  AutoUploadStillWritingException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Single-file upload entry point used by the Library "Upload now" tap.
/// Returns the new server-side [Recording] on success. Throws on failure.
///
/// Acquires the same SharedPreferences lock as the batch worker so a
/// background scan and a manual tap can't race.
Future<Recording> uploadOneFile(File file, FolderUploadConfig config) async {
  final store = await AutoUploadSettingsStore.open();
  final acquired = await store.tryAcquireLock();
  if (!acquired) {
    throw AutoUploadStillWritingException(
        'A scan is already in progress. Try again in a moment.');
  }
  try {
    final stable = await _checkFileStable(file);
    if (stable != AutoUploadOutcome.uploaded) {
      throw AutoUploadStillWritingException(
          'This recording is still being written. Try again shortly.');
    }
    final api = buildBackgroundApi();
    return await _uploadAndDelete(file, config, api);
  } finally {
    await store.releaseLock();
  }
}

/// Top-level entry point used by every batch trigger: WorkManager
/// periodic, phone-state-fired one-off, "Scan now" button, Windows
/// foreground polling timer.
///
/// Returns true on a clean run. WorkManager treats a `false` return as a
/// retry signal, but we deliberately return `true` even when individual
/// files failed — failed files stay on disk and the next scan re-tries
/// them, so a `Result.retry()` would just double-schedule.
Future<bool> runAutoUploadScan({required String trigger}) async {
  final store = await AutoUploadSettingsStore.open();
  final configs = store
      .readAll()
      .where((c) => c.enabled && c.hasFolder)
      .toList(growable: false);
  if (configs.isEmpty) {
    await store.pruneFileErrors(const {});
    return true;
  }

  final acquired = await store.tryAcquireLock();
  if (!acquired) return true;

  final result = AutoUploadResult(trigger: trigger);
  try {
    final api = buildBackgroundApi();

    // Drop persisted errors for files the user has deleted or moved away
    // since the last scan, so stale badges don't linger.
    final seenPaths = <String>{
      for (final config in configs)
        for (final file in listCandidateFiles(config.folderPath!)) file.path,
    };
    await store.pruneFileErrors(seenPaths);

    for (final config in configs) {
      for (final file in listCandidateFiles(config.folderPath!)) {
        try {
          final stable = await _checkFileStable(file);
          if (stable != AutoUploadOutcome.uploaded) {
            result.skipped++;
            continue;
          }
          if (config.autoDeleteShorterThanSeconds != null) {
            final probe = _probeDuration(file);
            if (probe.hasError) {
              await store.setFileError(
                file.path,
                _durationErrorMessage(file, probe.error!),
              );
              result.failed++;
              result.lastError = probe.error;
              continue;
            }
            if (probe.isKnown &&
                probe.duration!.inSeconds <
                    config.autoDeleteShorterThanSeconds!) {
              try {
                await file.delete();
              } catch (_) {
                // Mirror the post-upload delete: a failed delete is
                // non-fatal; the next scan will retry.
              }
              await store.clearFileError(file.path);
              result.skipped++;
              continue;
            }
            // Format not supported by reader, or duration above threshold:
            // fall through to upload normally.
          }
          await _uploadAndDelete(file, config, api);
          await store.clearFileError(file.path);
          result.uploaded++;
        } catch (e) {
          result.failed++;
          result.lastError = e.toString();
        }
      }
    }
    await store.recordScanResult(result.summary);
    return true;
  } finally {
    await store.releaseLock();
  }
}
