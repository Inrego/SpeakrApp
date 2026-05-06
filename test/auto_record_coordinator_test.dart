import 'dart:async';

import 'package:flutter_riverpod/legacy.dart';
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
  int startCallCount = 0;
  bool stoppedCalled = false;
  bool cancelCalled = false;

  Future<void> start() async {
    startedCalled = true;
    startCallCount++;
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
  // isInUse is `lastStart.isAfter(lastStop)`. Order the timestamps so the
  // result actually matches the [inUse] flag: in-use → start newer, not
  // in-use → stop newer.
  return MicUser(
    key: key,
    displayName: key,
    kind: kind,
    lastStart: inUse
        ? now.subtract(startAge)
        : now.subtract(stopAge + const Duration(seconds: 1)),
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
  int? appliedSpeakers;
  List<int>? appliedTagIds;
  int applyCallCount = 0;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    settingsChangedCalls = 0;
    appliedSpeakers = null;
    appliedTagIds = null;
    applyCallCount = 0;
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
      applyTriggerMetadata: (
          {required speakers, required tagIds, required folderId}) {
        appliedSpeakers = speakers;
        appliedTagIds = List<int>.from(tagIds);
        applyCallCount++;
      },
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

  test('does not auto-restart after user stops while trigger still in use',
      () async {
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
    // Meeting starts → auto-record fires.
    mic.emit([
      _u(key: 'Teams.exe', kind: AllowlistKind.exeBasename, inUse: true),
    ]);
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(rec.startCallCount, 1);
    expect(coord.isAutoSession, isTrue);

    // User stops/uploads (or discards) — recording state resets.
    await rec.stopAndUpload();
    await Future<void>.delayed(const Duration(milliseconds: 5));
    expect(coord.isAutoSession, isFalse);

    // Trigger app is still in the meeting; next poll must NOT restart.
    mic.emit([
      _u(key: 'Teams.exe', kind: AllowlistKind.exeBasename, inUse: true),
    ]);
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(rec.startCallCount, 1);
    expect(coord.isAutoSession, isFalse);
  });

  test('auto-restarts on next meeting after dismissal', () async {
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
    // First meeting → auto-record fires.
    mic.emit([
      _u(key: 'Teams.exe', kind: AllowlistKind.exeBasename, inUse: true),
    ]);
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(rec.startCallCount, 1);

    // User stops.
    await rec.cancel();
    await Future<void>.delayed(const Duration(milliseconds: 5));

    // Trigger app released the mic (meeting ended) — dismissal clears.
    mic.emit([
      _u(key: 'Teams.exe', kind: AllowlistKind.exeBasename, inUse: false),
    ]);
    await Future<void>.delayed(const Duration(milliseconds: 20));

    // New meeting begins → auto-record fires again.
    mic.emit([
      _u(key: 'Teams.exe', kind: AllowlistKind.exeBasename, inUse: true),
    ]);
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(rec.startCallCount, 2);
    expect(coord.isAutoSession, isTrue);
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

  test('applies per-app speakers override when entry has one', () async {
    await store.write(const AutoRecordSettings(
      enabled: true,
      defaultSpeakers: 2,
      allowlist: [
        AllowlistEntry(
          key: 'Teams.exe',
          displayName: 'Teams',
          kind: AllowlistKind.exeBasename,
          speakers: 5,
        ),
      ],
    ));
    mic.emit([
      _u(key: 'Teams.exe', kind: AllowlistKind.exeBasename, inUse: true),
    ]);
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(appliedSpeakers, 5);
    expect(appliedTagIds, isEmpty);
  });

  test('applies per-app tag IDs override when entry has them', () async {
    await store.write(const AutoRecordSettings(
      enabled: true,
      defaultTagIds: [99],
      allowlist: [
        AllowlistEntry(
          key: 'Teams.exe',
          displayName: 'Teams',
          kind: AllowlistKind.exeBasename,
          tagIds: [3, 7],
        ),
      ],
    ));
    mic.emit([
      _u(key: 'Teams.exe', kind: AllowlistKind.exeBasename, inUse: true),
    ]);
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(appliedTagIds, [3, 7]);
  });

  test('falls back to defaultSpeakers when entry has no override', () async {
    await store.write(const AutoRecordSettings(
      enabled: true,
      defaultSpeakers: 4,
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
    expect(appliedSpeakers, 4);
  });

  test('falls back to defaultTagIds when entry has no override', () async {
    await store.write(const AutoRecordSettings(
      enabled: true,
      defaultTagIds: [11, 22],
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
    expect(appliedTagIds, [11, 22]);
  });

  test('does not apply metadata if startRecording fails to start', () async {
    // Replace the setUp coordinator with one wired to a failing controller —
    // start() leaves `started: false`. Disposing the original first
    // ensures only the failing path observes the mic event.
    await coord.dispose();

    final failing = _FailingRecordingController();
    final coord2 = AutoRecordCoordinator(
      micMonitor: mic,
      outputMeter: meter,
      recording: failing,
      startRecording: failing.start,
      stopAndUpload: failing.stopAndUpload,
      cancelRecording: failing.cancel,
      store: store,
      onSettingsChanged: () {},
      applyTriggerMetadata: (
          {required speakers, required tagIds, required folderId}) {
        applyCallCount++;
      },
    );
    coord2.start();
    // Replace `coord` so the outer tearDown disposes the live one (the
    // failed-over `_FailingRecordingController` has no resources to clean
    // up beyond the coordinator subscription itself).
    coord = coord2;

    await store.write(const AutoRecordSettings(
      enabled: true,
      defaultSpeakers: 3,
      allowlist: [
        AllowlistEntry(
          key: 'Teams.exe',
          displayName: 'Teams',
          kind: AllowlistKind.exeBasename,
          speakers: 5,
        ),
      ],
    ));
    mic.emit([
      _u(key: 'Teams.exe', kind: AllowlistKind.exeBasename, inUse: true),
    ]);
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(applyCallCount, 0);
  });
}

/// A controller whose start() *appears* to succeed but never sets
/// `started: true` — mirrors the real "permission denied / recorder
/// error" path. Used to verify we don't seed metadata into a bogus
/// session.
class _FailingRecordingController extends StateNotifier<RecordingState> {
  _FailingRecordingController() : super(const RecordingState());

  Future<void> start() async {
    // Simulate failure: don't flip `started`.
  }

  Future<void> stopAndUpload() async {}
  Future<void> cancel() async {}
}
