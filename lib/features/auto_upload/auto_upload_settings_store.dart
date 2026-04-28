import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'auto_upload_settings.dart';

/// SharedPreferences-backed persistence for the list of
/// [FolderUploadConfig]s plus the worker's runtime bookkeeping
/// (concurrency lock, last-scan record).
///
/// All reads/writes are async and isolate-safe — the worker isolate
/// spawned by WorkManager and the UI isolate hit the same
/// shared_preferences file.
class AutoUploadSettingsStore {
  AutoUploadSettingsStore(this._prefs);

  final SharedPreferences _prefs;

  static Future<AutoUploadSettingsStore> open() async =>
      AutoUploadSettingsStore(await SharedPreferences.getInstance());

  // ── Settings ──────────────────────────────────────────────────────────────
  static const _kFolders = 'auto_upload.folders';

  // ── Runtime ───────────────────────────────────────────────────────────────
  static const _kLockMs = 'auto_upload.lock_ms';
  static const _kLastScanMs = 'auto_upload.last_scan_ms';
  static const _kLastScanResult = 'auto_upload.last_scan_result';
  static const _kFileErrors = 'auto_upload.file_errors';

  List<FolderUploadConfig> readAll() {
    final raw = _prefs.getString(_kFolders);
    if (raw == null || raw.isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(FolderUploadConfig.fromJson)
          .toList(growable: false);
    } catch (_) {
      return const [];
    }
  }

  Future<void> writeAll(List<FolderUploadConfig> configs) async {
    final encoded = jsonEncode(configs.map((c) => c.toJson()).toList());
    await _prefs.setString(_kFolders, encoded);
  }

  FolderUploadConfig? findById(String id) {
    for (final c in readAll()) {
      if (c.id == id) return c;
    }
    return null;
  }

  // ── Concurrency lock ──────────────────────────────────────────────────────
  /// Returns true if the lock was acquired. Stale (>10 min) locks are
  /// auto-released. Calls [release] whether or not the work succeeds.
  Future<bool> tryAcquireLock({Duration staleAfter = const Duration(minutes: 10)}) async {
    await _prefs.reload();
    final now = DateTime.now().millisecondsSinceEpoch;
    final held = _prefs.getInt(_kLockMs) ?? 0;
    if (held > 0 && now - held < staleAfter.inMilliseconds) return false;
    return _prefs.setInt(_kLockMs, now);
  }

  Future<void> releaseLock() async {
    await _prefs.setInt(_kLockMs, 0);
  }

  // ── Last-scan record ──────────────────────────────────────────────────────
  Future<void> recordScanResult(String summary) async {
    await _prefs.setInt(_kLastScanMs, DateTime.now().millisecondsSinceEpoch);
    await _prefs.setString(_kLastScanResult, summary);
  }

  DateTime? get lastScanAt {
    final ms = _prefs.getInt(_kLastScanMs);
    return ms == null || ms == 0
        ? null
        : DateTime.fromMillisecondsSinceEpoch(ms);
  }

  String? get lastScanResult => _prefs.getString(_kLastScanResult);

  // ── Per-file scan errors ──────────────────────────────────────────────────
  /// Errors that the worker recorded while scanning a folder. Keyed by
  /// absolute file path; value is a user-facing message. Used by the
  /// Library's pending tile to surface duration-read failures so the user
  /// can decide between deleting or force-uploading.
  Map<String, String> readFileErrors() {
    final raw = _prefs.getString(_kFileErrors);
    if (raw == null || raw.isEmpty) return const {};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return const {};
      return {
        for (final entry in decoded.entries)
          if (entry.key is String && entry.value is String)
            entry.key as String: entry.value as String,
      };
    } catch (_) {
      return const {};
    }
  }

  Future<void> _writeFileErrors(Map<String, String> errors) async {
    if (errors.isEmpty) {
      await _prefs.remove(_kFileErrors);
      return;
    }
    await _prefs.setString(_kFileErrors, jsonEncode(errors));
  }

  Future<void> setFileError(String path, String message) async {
    final next = Map<String, String>.from(readFileErrors());
    next[path] = message;
    await _writeFileErrors(next);
  }

  Future<void> clearFileError(String path) async {
    final current = readFileErrors();
    if (!current.containsKey(path)) return;
    final next = Map<String, String>.from(current)..remove(path);
    await _writeFileErrors(next);
  }

  /// Drops error entries whose path is no longer in [stillExisting].
  /// Called once at the start of each scan so deleted files don't leave
  /// orphan badges behind.
  Future<void> pruneFileErrors(Set<String> stillExisting) async {
    final current = readFileErrors();
    if (current.isEmpty) return;
    final next = <String, String>{
      for (final e in current.entries)
        if (stillExisting.contains(e.key)) e.key: e.value,
    };
    if (next.length == current.length) return;
    await _writeFileErrors(next);
  }
}
