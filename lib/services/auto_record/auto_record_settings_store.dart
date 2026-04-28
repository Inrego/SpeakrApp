import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'auto_record_settings.dart';

/// SharedPreferences-backed persistence for the auto-record toggle,
/// allowlist, and the live "recently seen" suggestion bag. Mirrors the
/// pattern of [AutoUploadSettingsStore] — single JSON blob, async open.
class AutoRecordSettingsStore {
  AutoRecordSettingsStore(this._prefs);

  final SharedPreferences _prefs;

  static const _kSettings = 'auto_record.settings';
  static const _kLastTriggerLabel = 'auto_record.last_trigger_label';
  static const _kLastTriggerMs = 'auto_record.last_trigger_ms';

  static Future<AutoRecordSettingsStore> open() async =>
      AutoRecordSettingsStore(await SharedPreferences.getInstance());

  AutoRecordSettings read() {
    final raw = _prefs.getString(_kSettings);
    if (raw == null || raw.isEmpty) return const AutoRecordSettings();
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return const AutoRecordSettings();
      return AutoRecordSettings.fromJson(decoded);
    } catch (_) {
      return const AutoRecordSettings();
    }
  }

  Future<void> write(AutoRecordSettings next) async {
    await _prefs.setString(_kSettings, jsonEncode(next.toJson()));
  }

  Future<void> recordLastTrigger(String label) async {
    await _prefs.setString(_kLastTriggerLabel, label);
    await _prefs.setInt(_kLastTriggerMs, DateTime.now().millisecondsSinceEpoch);
  }

  String? get lastTriggerLabel => _prefs.getString(_kLastTriggerLabel);
  DateTime? get lastTriggerAt {
    final ms = _prefs.getInt(_kLastTriggerMs);
    return ms == null || ms == 0
        ? null
        : DateTime.fromMillisecondsSinceEpoch(ms);
  }
}
