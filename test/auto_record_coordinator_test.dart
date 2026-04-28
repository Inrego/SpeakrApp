import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speakr_app/features/live/recording_state.dart';
import 'package:speakr_app/services/auto_record/auto_record_coordinator.dart';
import 'package:speakr_app/services/auto_record/auto_record_settings.dart';
import 'package:speakr_app/services/auto_record/auto_record_settings_store.dart';
import 'package:speakr_app/services/auto_record/mic_monitor.dart';
import 'package:speakr_app/services/auto_record/mic_user.dart';
import 'package:speakr_app/services/auto_record/output_meter.dart';

class FakeMicMonitor implements MicMonitor {
  final ctrl = StreamController<List<MicUser>>.broadcast();
  List<MicUser> _last = const [];

  @override
  List<MicUser> get current => _last;

  @override
  Stream<List<MicUser>> get usersStream => ctrl.stream;

  @override
  Future<void> dispose() async => ctrl.close();

  void emit(List<MicUser> users) {
    _last = users;
    ctrl.add(users);
  }
}

class FakeOutputMeter implements OutputMeter {
  final ctrl = StreamController<double>.broadcast();
  @override
  Stream<double> get peaks => ctrl.stream;

  @override
  Future<void> dispose() async => ctrl.close();
}

/// Minimal stand-in for `RecordingController` — exposes the same
/// `StateNotifier<RecordingState>` surface plus start/stopAndUpload/
/// cancel methods that mirror state transitions, without instantiating
/// the real `AudioRecorder` / permission_handler / desktop_multi_window
/// stack.
class FakeRecordingController extends StateNotifier<RecordingState> {
  FakeRecordingController() : super(const RecordingState());

  bool startedCalled = false;
  bool stoppedCalled = false;
  bool cancelCalled = false;

  Future<void> start() async {
    startedCalled = true;
    state = state.copyWith(started: true);
  }

  Future<void> stopAndUpload() async {
    stoppedCalled = true;
    state = const RecordingState();
  }

  Future<void> cancel() async {
    cancelCalled = true;
    state = const RecordingState();
  }

  void setState(RecordingState s) {
    state = s;
  }
}

MicUser _u({
  required String key,
  required AllowlistKind kind,
  required bool inUse,
  Duration startAge = const Duration(seconds: 1),
  Duration stopAge = const Duration(seconds: 30),
}) {
  final now = DateTime.now();
  return MicUser(
    key: key,
    displayName: key,
    kind: kind,
    lastStart: now.subtract(startAge),
    lastStop: inUse
        ? now.subtract(const Duration(hours: 1))
        : now.subtract(stopAge),
  );
}

void main() {
  late FakeMicMonitor mic;
  late FakeOutputMeter meter;
  late FakeRecordingController rec;
  late AutoRecordSettingsStore store;
  late AutoRecordCoordinator coord;
  int settingsChangedCalls = 0;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    settingsChangedCalls = 0;
    mic = FakeMicMonitor();
    meter = FakeOutputMeter();
    rec = FakeRecordingController();
    store = await AutoRecordSettingsStore.open();
    coord = AutoRecordCoordinator(
      micMonitor: mic,
      outputMeter: meter,
      recording: rec,
      startRecording: rec.start,
      stopAndUpload: rec.stopAndUpload,
      cancelRecording: rec.cancel,
      store: store,
      onSettingsChanged: () => settingsChangedCalls++,
    );
    coord.start();
  });

  tearDown(() async {
    await coord.dispose();
    await mic.dispose();
    await meter.dispose();
    rec.dispose();
  });

  test('does not start when disabled', () async {
    await store.write(const AutoRecordSettings(enabled: false));
    mic.emit([
      _u(key: 'Teams.exe', kind: AllowlistKind.exeBasename, inUse: true),
    ]);
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(rec.startedCalled, isFalse);
  });

  test('does not start without an allowlist match', () async {
    await store.write(const AutoRecordSettings(
      enabled: true,
      allowlist: [
        AllowlistEntry(
          key: 'Zoom.exe',
          displayName: 'Zoom',
          kind: AllowlistKind.exeBasename,
        ),
      ],
    ));
    mic.emit([
      _u(key: 'Teams.exe', kind: AllowlistKind.exeBasename, inUse: true),
    ]);
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(rec.startedCalled, isFalse);
  });

  test('starts on allowlist match (exe basename, case-insensitive)',
      () async {
    await store.write(const AutoRecordSettings(
      enabled: true,
      allowlist: [
        AllowlistEntry(
          key: 'teams.exe',
          displayName: 'Teams',
          kind: AllowlistKind.exeBasename,
        ),
      ],
    ));
    mic.emit([
      _u(key: 'Teams.exe', kind: AllowlistKind.exeBasename, inUse: true),
    ]);
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(rec.startedCalled, isTrue);
    expect(coord.isAutoSession, isTrue);
    expect(coord.activeTriggerLabel, 'Teams');
  });

  test('starts on packaged prefix match (e.g. MSTeams_…)', () async {
    await store.write(const AutoRecordSettings(
      enabled: true,
      allowlist: [
        AllowlistEntry(
          key: 'MSTeams',
          displayName: 'Microsoft Teams',
          kind: AllowlistKind.packagedPrefix,
        ),
      ],
    ));
    mic.emit([
      _u(
        key: 'MSTeams_8wekyb3d8bbwe',
        kind: AllowlistKind.packagedPrefix,
        inUse: true,
      ),
    ]);
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(rec.startedCalled, isTrue);
  });

  test('does not auto-start while a manual recording is active', () async {
    await store.write(const AutoRecordSettings(
      enabled: true,
      allowlist: [
        AllowlistEntry(
          key: 'Teams.exe',
          displayName: 'Teams',
          kind: AllowlistKind.exeBasename,
        ),
      ],
    ));
    rec.setState(const RecordingState(started: true));
    // Let the listener flush the new state into the coordinator.
    await Future<void>.delayed(const Duration(milliseconds: 5));
    mic.emit([
      _u(key: 'Teams.exe', kind: AllowlistKind.exeBasename, inUse: true),
    ]);
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(rec.startedCalled, isFalse);
  });

  test('records every distinct mic-user as recently-seen', () async {
    await store.write(const AutoRecordSettings(enabled: false));
    mic.emit([
      _u(key: 'foo.exe', kind: AllowlistKind.exeBasename, inUse: true),
      _u(key: 'bar.exe', kind: AllowlistKind.exeBasename, inUse: false),
    ]);
    await Future<void>.delayed(const Duration(milliseconds: 20));
    final saved = store.read();
    final names = saved.recentlySeen.map((e) => e.key).toSet();
    expect(names.containsAll({'foo.exe', 'bar.exe'}), isTrue);
    expect(settingsChangedCalls, greaterThan(0));
  });

  test('skips entries whose lastStart is older than 12 h', () async {
    await store.write(const AutoRecordSettings(
      enabled: true,
      allowlist: [
        AllowlistEntry(
          key: 'Teams.exe',
          displayName: 'Teams',
          kind: AllowlistKind.exeBasename,
        ),
      ],
    ));
    final now = DateTime.now();
    mic.emit([
      MicUser(
        key: 'Teams.exe',
        displayName: 'Teams.exe',
        kind: AllowlistKind.exeBasename,
        // In use (start > stop) but stale.
        lastStart: now.subtract(const Duration(hours: 13)),
        lastStop: now.subtract(const Duration(hours: 14)),
      ),
    ]);
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(rec.startedCalled, isFalse);
  });

  test('stopAutoSession discards short clips via cancel', () async {
    await store.write(const AutoRecordSettings(
      enabled: true,
      minKeepSeconds: 10,
      allowlist: [
        AllowlistEntry(
          key: 'Teams.exe',
          displayName: 'Teams',
          kind: AllowlistKind.exeBasename,
        ),
      ],
    ));
    mic.emit([
      _u(key: 'Teams.exe', kind: AllowlistKind.exeBasename, inUse: true),
    ]);
    await Future<void>.delayed(const Duration(milliseconds: 20));
    rec.setState(const RecordingState(started: true, elapsedSeconds: 3));
    await Future<void>.delayed(const Duration(milliseconds: 5));
    await coord.stopAutoSession();
    expect(rec.cancelCalled, isTrue);
    expect(rec.stoppedCalled, isFalse);
  });

  test('stopAutoSession uploads when long enough', () async {
    await store.write(const AutoRecordSettings(
      enabled: true,
      minKeepSeconds: 10,
      allowlist: [
        AllowlistEntry(
          key: 'Teams.exe',
          displayName: 'Teams',
          kind: AllowlistKind.exeBasename,
        ),
      ],
    ));
    mic.emit([
      _u(key: 'Teams.exe', kind: AllowlistKind.exeBasename, inUse: true),
    ]);
    await Future<void>.delayed(const Duration(milliseconds: 20));
    rec.setState(const RecordingState(started: true, elapsedSeconds: 30));
    await Future<void>.delayed(const Duration(milliseconds: 5));
    await coord.stopAutoSession();
    expect(rec.stoppedCalled, isTrue);
    expect(rec.cancelCalled, isFalse);
  });
}
