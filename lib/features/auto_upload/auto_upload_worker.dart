import 'dart:async';
import 'dart:io';

import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
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
  '.m4a',
  '.mp3',
  '.wav',
  '.ogg',
  '.aac',
  '.opus',
  '.amr',
  '.3gp',
  '.flac',
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

void _logAutoUpload(String message) {
  debugPrint('[auto-upload] $message');
}

/// Build a fresh [SpeakrApi] for use inside a background isolate (no
/// Riverpod). The interceptor reads credentials from secure storage on
/// each request, so per-isolate construction is correct.
SpeakrApi buildBackgroundApi() {
  final dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 60),
      sendTimeout: const Duration(minutes: 10),
      contentType: 'application/json',
      responseType: ResponseType.json,
    ),
  );
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
      .where(
        (f) => kAutoUploadAudioExtensions.contains(
          p.extension(f.path).toLowerCase(),
        ),
      )
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

Future<String?> _fileSignature(File file) async {
  try {
    final stat = await file.stat();
    return stat.size.toString();
  } catch (_) {
    return null;
  }
}

bool _signatureMatches(String? stored, String current) {
  return stored == current || (stored?.startsWith('$current:') ?? false);
}

String _deleteAfterUploadErrorMessage(File file, Object detail) {
  final name = p.basename(file.path);
  return '$name was uploaded to Speakr, but the app could not delete the '
      'local copy. Automatic scans will skip this exact file to avoid '
      'duplicate uploads.\n\nDelete it manually, or tap this item and choose '
      'Delete file.\n\n$detail';
}

Future<void> _clearWindowsReadOnlyAttribute(File file) async {
  if (!Platform.isWindows) return;
  try {
    final result = await Process.run('attrib', ['-R', file.path]);
    if (result.exitCode != 0) {
      _logAutoUpload(
        'could not clear read-only attribute for ${file.path}: '
        '${result.stderr}${result.stdout}',
      );
    }
  } catch (e) {
    _logAutoUpload('could not clear read-only attribute for ${file.path}: $e');
  }
}

Future<Object?> deleteLocalAutoUploadFile(
  File file, {
  int attempts = 5,
  Duration initialDelay = const Duration(milliseconds: 200),
}) async {
  Object? lastError;
  for (var attempt = 0; attempt < attempts; attempt++) {
    try {
      if (!await file.exists()) return null;
      await _clearWindowsReadOnlyAttribute(file);
      await file.delete();
      if (!await file.exists()) return null;
    } catch (e) {
      lastError = e;
    }
    if (attempt < attempts - 1) {
      await Future<void>.delayed(initialDelay * (attempt + 1));
    }
  }
  return lastError ?? 'File still exists after delete';
}

Future<File> _copyForUpload(File source) async {
  final tempDir = await Directory.systemTemp.createTemp('speakr_upload_');
  final target = File(p.join(tempDir.path, p.basename(source.path)));
  return source.copy(target.path);
}

Future<void> _deleteUploadCopy(File copy) async {
  try {
    final parent = copy.parent;
    if (await parent.exists()) {
      await parent.delete(recursive: true);
    } else if (await copy.exists()) {
      await copy.delete();
    }
  } catch (e) {
    _logAutoUpload('could not delete temp upload copy ${copy.path}: $e');
  }
}

class _UploadAndDeleteResult {
  const _UploadAndDeleteResult({
    required this.recording,
    required this.deleted,
    this.deleteError,
  });

  final Recording recording;
  final bool deleted;
  final Object? deleteError;
}

/// Uploads one file via [api], using [config] to derive datetime and
/// other multipart fields. Deletes the local file on success.
Future<_UploadAndDeleteResult> _uploadAndDelete(
  File file,
  FolderUploadConfig config,
  SpeakrApi api,
  AutoUploadSettingsStore? store,
) async {
  final signature = await _fileSignature(file);
  final dt = resolveDateTime(file, config);
  final tagIds = config.tagId == null ? const <int>[] : <int>[config.tagId!];
  final uploadCopy = await _copyForUpload(file);
  Recording recording;
  try {
    recording = await api.uploadRecording(
      file: uploadCopy,
      language: config.language,
      minSpeakers: config.minSpeakers,
      maxSpeakers: config.maxSpeakers,
      tagIds: tagIds,
      fileLastModified: dt,
    );
  } finally {
    await _deleteUploadCopy(uploadCopy);
  }
  try {
    await api.updateRecording(recording.id, {
      'meeting_date': dt.toUtc().toIso8601String(),
    });
  } catch (e) {
    _logAutoUpload('meeting_date PATCH failed for ${recording.id}: $e');
  }
  final deleteError = await deleteLocalAutoUploadFile(file);
  if (deleteError == null) {
    if (store != null) {
      await store.clearUploadedFile(file.path);
      await store.clearFileError(file.path);
    }
    _logAutoUpload('uploaded and deleted ${file.path}');
  } else if (store != null && signature != null) {
    await store.markUploadedFile(file.path, signature);
    await store.setFileError(
      file.path,
      _deleteAfterUploadErrorMessage(file, deleteError),
    );
    _logAutoUpload(
      'uploaded but could not delete ${file.path}; '
      'signature=$signature error=$deleteError',
    );
  }
  return _UploadAndDeleteResult(
    recording: recording,
    deleted: deleteError == null,
    deleteError: deleteError,
  );
}

class AutoUploadStillWritingException implements Exception {
  AutoUploadStillWritingException(this.message);
  final String message;
  @override
  String toString() => message;
}

Future<AutoUploadLock> _acquireAutoUploadLock(
  AutoUploadSettingsStore store, {
  Duration waitFor = Duration.zero,
}) async {
  final deadline = DateTime.now().add(waitFor);
  while (true) {
    final lock = await store.tryAcquireLock();
    if (lock != null) return lock;
    if (!DateTime.now().isBefore(deadline)) {
      throw AutoUploadStillWritingException(
        'A scan is already in progress. Try again in a moment.',
      );
    }
    await Future<void>.delayed(const Duration(milliseconds: 750));
  }
}

/// Single-file upload entry point used by the Library "Upload now" tap.
/// Returns the new server-side [Recording] on success. Throws on failure.
///
/// Acquires the same SharedPreferences lock as the batch worker so a
/// background scan and a manual tap can't race.
Future<Recording> uploadOneFile(File file, FolderUploadConfig config) async {
  final store = await AutoUploadSettingsStore.open();
  final lock = await _acquireAutoUploadLock(
    store,
    waitFor: const Duration(seconds: 20),
  );
  lock.startHeartbeat();
  try {
    final stable = await _checkFileStable(file);
    if (stable != AutoUploadOutcome.uploaded) {
      throw AutoUploadStillWritingException(
        'This recording is still being written. Try again shortly.',
      );
    }
    final api = buildBackgroundApi();
    final result = await _uploadAndDelete(file, config, api, store);
    return result.recording;
  } finally {
    await lock.release();
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
  await store.reload();
  final configs = store
      .readAll()
      .where((c) => c.enabled && c.hasFolder)
      .toList(growable: false);
  if (configs.isEmpty) {
    await store.pruneFileErrors(const {});
    return true;
  }

  final lock = await store.tryAcquireLock();
  if (lock == null) {
    _logAutoUpload('skip trigger=$trigger; scan already in progress');
    return true;
  }
  lock.startHeartbeat();

  final result = AutoUploadResult(trigger: trigger);
  try {
    await store.reload();
    final api = buildBackgroundApi();

    // Drop persisted errors for files the user has deleted or moved away
    // since the last scan, so stale badges don't linger.
    final seenPaths = <String>{
      for (final config in configs)
        for (final file in listCandidateFiles(config.folderPath!)) file.path,
    };
    final seenSignatures = <String, String>{};
    for (final config in configs) {
      for (final file in listCandidateFiles(config.folderPath!)) {
        final signature = await _fileSignature(file);
        if (signature != null) seenSignatures[file.path] = signature;
      }
    }
    await store.pruneFileErrors(seenPaths);
    await store.pruneUploadedFiles(seenSignatures);
    final uploadedFiles = store.readUploadedFiles();
    final processedPaths = <String>{};

    for (final config in configs) {
      for (final file in listCandidateFiles(config.folderPath!)) {
        if (!processedPaths.add(file.path)) continue;
        try {
          final signature = await _fileSignature(file);
          if (signature != null &&
              _signatureMatches(uploadedFiles[file.path], signature)) {
            final deleteError = await deleteLocalAutoUploadFile(file);
            if (deleteError == null) {
              await store.clearUploadedFile(file.path);
              await store.clearFileError(file.path);
              _logAutoUpload(
                'deleted already-uploaded local copy ${file.path}',
              );
              result.skipped++;
              continue;
            }
            _logAutoUpload(
              'skip already-uploaded local copy ${file.path}; '
              'signature=$signature deleteError=$deleteError',
            );
            result.skipped++;
            continue;
          }
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
              final deleteError = await deleteLocalAutoUploadFile(file);
              if (deleteError == null) {
                await store.clearFileError(file.path);
              } else {
                await store.setFileError(
                  file.path,
                  'Could not delete ${p.basename(file.path)} after the '
                  'auto-delete duration rule matched.\n\n$deleteError',
                );
                result.failed++;
                result.lastError = deleteError.toString();
                continue;
              }
              result.skipped++;
              continue;
            }
            // Format not supported by reader, or duration above threshold:
            // fall through to upload normally.
          }
          final upload = await _uploadAndDelete(file, config, api, store);
          result.uploaded++;
          if (!upload.deleted) {
            result.failed++;
            result.lastError =
                'Uploaded but could not delete '
                '${p.basename(file.path)}: ${upload.deleteError}';
          }
        } catch (e) {
          result.failed++;
          result.lastError = e.toString();
        }
      }
    }
    await store.recordScanResult(result.summary);
    _logAutoUpload(result.summary);
    return true;
  } finally {
    await lock.release();
  }
}
