import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auto_record_settings.dart';
import 'auto_record_settings_store.dart';
import 'mic_monitor.dart';
import 'mic_user.dart';
import 'output_meter.dart';

/// Async — opens shared_preferences. Cached for the app's lifetime.
final autoRecordStoreProvider =
    FutureProvider<AutoRecordSettingsStore>((ref) async {
  return AutoRecordSettingsStore.open();
});

/// Reactive view of the persisted settings. Re-read after every write
/// via `ref.invalidate(autoRecordSettingsProvider)`.
final autoRecordSettingsProvider =
    FutureProvider<AutoRecordSettings>((ref) async {
  final store = await ref.watch(autoRecordStoreProvider.future);
  return store.read();
});

final micMonitorProvider = Provider<MicMonitor>((ref) {
  final monitor = createMicMonitor();
  ref.onDispose(monitor.dispose);
  return monitor;
});

final micUsersProvider = StreamProvider<List<MicUser>>((ref) async* {
  final monitor = ref.watch(micMonitorProvider);
  yield monitor.current;
  yield* monitor.usersStream;
});

final outputMeterProvider = Provider<OutputMeter>((ref) {
  final meter = createOutputMeter();
  ref.onDispose(meter.dispose);
  return meter;
});

/// Imperative writer used by the settings screen. Reads through
/// [autoRecordStoreProvider]; invalidates [autoRecordSettingsProvider]
/// after each write so subscribed widgets rebuild.
class AutoRecordSettingsController {
  AutoRecordSettingsController(this._ref);
  final Ref _ref;

  Future<AutoRecordSettings> _read() =>
      _ref.read(autoRecordSettingsProvider.future);

  Future<void> _write(AutoRecordSettings next) async {
    final store = await _ref.read(autoRecordStoreProvider.future);
    await store.write(next);
    _ref.invalidate(autoRecordSettingsProvider);
  }

  Future<void> setEnabled(bool v) async {
    final s = await _read();
    await _write(s.copyWith(enabled: v));
  }

  Future<void> addToAllowlist(AllowlistEntry entry) async {
    final s = await _read();
    if (s.allowlist.contains(entry)) return;
    await _write(s.copyWith(allowlist: [...s.allowlist, entry]));
  }

  Future<void> removeFromAllowlist(AllowlistEntry entry) async {
    final s = await _read();
    final next = s.allowlist.where((e) => e != entry).toList(growable: false);
    await _write(s.copyWith(allowlist: next));
  }

  Future<void> setSilenceSeconds(int v) async {
    final s = await _read();
    await _write(s.copyWith(silenceSeconds: v.clamp(3, 120)));
  }

  Future<void> setMinKeepSeconds(int v) async {
    final s = await _read();
    await _write(s.copyWith(minKeepSeconds: v.clamp(0, 600)));
  }

  Future<void> setDefaultSpeakers(int v) async {
    final s = await _read();
    await _write(s.copyWith(defaultSpeakers: v.clamp(1, 12)));
  }

  Future<void> setDefaultTagIds(List<int> ids) async {
    final s = await _read();
    await _write(s.copyWith(defaultTagIds: ids));
  }

  Future<void> clearRecentlySeen() async {
    final s = await _read();
    await _write(s.copyWith(recentlySeen: const []));
  }
}

final autoRecordSettingsControllerProvider =
    Provider<AutoRecordSettingsController>(
  (ref) => AutoRecordSettingsController(ref),
);
