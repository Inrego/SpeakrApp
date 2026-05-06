import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auto_upload_settings.dart';
import 'auto_upload_settings_store.dart';
import 'auto_upload_worker.dart';
import 'datetime_parser.dart';

final autoUploadStoreProvider =
    FutureProvider<AutoUploadSettingsStore>((ref) async {
  return AutoUploadSettingsStore.open();
});

/// All configured folder entries. Refreshed by writing through
/// [folderConfigsControllerProvider].
final folderConfigsProvider =
    FutureProvider<List<FolderUploadConfig>>((ref) async {
  final store = await ref.watch(autoUploadStoreProvider.future);
  return store.readAll();
});

/// Imperative controller used by the Auto-upload list screen and the
/// per-folder edit screen.
class FolderConfigsController {
  FolderConfigsController(this._ref);
  final Ref _ref;

  Future<List<FolderUploadConfig>> _read() =>
      _ref.read(folderConfigsProvider.future);

  Future<void> _writeAll(List<FolderUploadConfig> next) async {
    final store = await _ref.read(autoUploadStoreProvider.future);
    await store.writeAll(next);
    _ref.invalidate(folderConfigsProvider);
    _ref.invalidate(pendingFilesProvider);
    _ref.invalidate(pendingFileErrorsProvider);
  }

  Future<FolderUploadConfig> addFolder(String? path) async {
    final entry = FolderUploadConfig.newEntry(folderPath: path);
    final list = [...await _read(), entry];
    await _writeAll(list);
    return entry;
  }

  Future<void> removeFolder(String id) async {
    final list = (await _read()).where((c) => c.id != id).toList();
    await _writeAll(list);
  }

  Future<void> updateFolder(FolderUploadConfig next) async {
    final list = await _read();
    final out = [
      for (final c in list) c.id == next.id ? next : c,
    ];
    await _writeAll(out);
  }

  Future<void> _patch(
    String id,
    FolderUploadConfig Function(FolderUploadConfig) patch,
  ) async {
    final list = await _read();
    final out = [
      for (final c in list) c.id == id ? patch(c) : c,
    ];
    await _writeAll(out);
  }

  Future<void> setEnabled(String id, bool v) =>
      _patch(id, (c) => c.copyWith(enabled: v));

  Future<void> setFolder(String id, String? path) =>
      _patch(id, (c) => c.copyWith(folderPath: path));

  Future<void> setPreset(String id, String? presetId) =>
      _patch(id, (c) => c.copyWith(parsePresetId: presetId));

  Future<void> setCustomParse({
    required String id,
    required String regex,
    required int captureGroup,
    required String format,
  }) =>
      _patch(
        id,
        (c) => c.copyWith(
          parsePresetId: kCustomPresetId,
          customRegex: regex,
          customCaptureGroup: captureGroup,
          customFormat: format,
        ),
      );

  Future<void> setTagId(String id, int? tagId) =>
      _patch(id, (c) => c.copyWith(tagId: tagId));

  Future<void> setFolderId(String id, int? folderId) =>
      _patch(id, (c) => c.copyWith(folderId: folderId));

  Future<void> setLanguage(String id, String? lang) =>
      _patch(id, (c) => c.copyWith(language: lang));

  Future<void> setMinSpeakers(String id, int? n) =>
      _patch(id, (c) => c.copyWith(minSpeakers: n));

  Future<void> setMaxSpeakers(String id, int? n) =>
      _patch(id, (c) => c.copyWith(maxSpeakers: n));

  Future<void> setAutoDeleteShorterThanSeconds(String id, int? seconds) =>
      _patch(id, (c) => c.copyWith(autoDeleteShorterThanSeconds: seconds));
}

final folderConfigsControllerProvider = Provider<FolderConfigsController>(
  (ref) => FolderConfigsController(ref),
);

/// One pending file in the Library list, paired with the folder config
/// it was discovered under so per-folder defaults flow through to the
/// upload call.
class PendingFile {
  PendingFile({
    required this.file,
    required this.dateTime,
    required this.size,
    required this.config,
  });
  final File file;
  final DateTime dateTime;
  final int size;
  final FolderUploadConfig config;
}

/// Files in any enabled folder that haven't been uploaded yet. Lists
/// them sorted desc by parsed-or-mtime datetime. Cached briefly so the
/// Library screen doesn't hammer the disk on every rebuild. If two
/// configs share a path, files are deduplicated on absolute path
/// (first config wins).
/// Per-file errors recorded by the auto-upload worker (currently:
/// duration-read failures). Keyed by absolute file path. Watched by the
/// Library's pending tile to switch from the "not uploaded" badge to an
/// error badge with a Delete / Force-upload dialog.
final pendingFileErrorsProvider =
    FutureProvider<Map<String, String>>((ref) async {
  final store = await ref.watch(autoUploadStoreProvider.future);
  return store.readFileErrors();
});

final pendingFilesProvider = FutureProvider<List<PendingFile>>((ref) async {
  final configs = await ref.watch(folderConfigsProvider.future);
  final out = <PendingFile>[];
  final seen = <String>{};
  for (final config in configs) {
    if (!config.enabled || !config.hasFolder) continue;
    final files = listCandidateFiles(config.folderPath!);
    for (final f in files) {
      if (!seen.add(f.path)) continue;
      try {
        final stat = f.statSync();
        out.add(PendingFile(
          file: f,
          dateTime: resolveDateTime(f, config),
          size: stat.size,
          config: config,
        ));
      } catch (_) {
        // Permission error or transient filesystem issue — skip silently.
      }
    }
  }
  out.sort((a, b) => b.dateTime.compareTo(a.dateTime));
  return out;
});
