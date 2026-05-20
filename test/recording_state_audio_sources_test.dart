import 'package:flutter_test/flutter_test.dart';
import 'package:speakr_app/features/live/recording_state.dart';

void main() {
  group('RecordingState audio-source fields', () {
    test('defaults at construction time', () {
      const s = RecordingState();
      expect(s.micEnabled, isTrue);
      expect(s.systemMode, SystemAudioMode.off);
      expect(s.systemEnabled, isFalse);
      expect(s.systemAudioSupported, isFalse);
      expect(s.processLoopbackSupported, isFalse);
      expect(s.micPending, isFalse);
      expect(s.systemPending, isFalse);
      expect(s.processSourceName, isNull);
      expect(s.processSourcePid, isNull);
    });

    test('backward-compat: missing fields decode to default values', () {
      // Simulates an older mini-window engine that doesn't know about the
      // new fields — `stateUpdate` JSON from a peer must still decode.
      final decoded = RecordingState.fromJson(const {
        'elapsedSeconds': 7,
        'paused': false,
        'started': true,
        'uploading': false,
        'speakers': 3,
        'activeTags': [],
        'miniOpen': false,
      });
      expect(decoded.micEnabled, isTrue);
      expect(decoded.systemMode, SystemAudioMode.off);
      expect(decoded.systemEnabled, isFalse);
      expect(decoded.systemAudioSupported, isFalse);
      expect(decoded.processLoopbackSupported, isFalse);
      expect(decoded.elapsedSeconds, 7);
      expect(decoded.started, isTrue);
    });

    test('full JSON round-trip preserves the new fields', () {
      const s = RecordingState(
        micEnabled: false,
        systemMode: SystemAudioMode.processOnly,
        systemAudioSupported: true,
        processLoopbackSupported: true,
        micPending: false,
        systemPending: true,
        processSourceName: 'Microsoft Teams',
        processSourcePid: 4242,
      );
      final r = RecordingState.fromJson(s.toJson());
      expect(r.micEnabled, isFalse);
      expect(r.systemMode, SystemAudioMode.processOnly);
      expect(r.systemEnabled, isTrue);
      expect(r.systemAudioSupported, isTrue);
      expect(r.processLoopbackSupported, isTrue);
      expect(r.systemPending, isTrue);
      expect(r.processSourceName, 'Microsoft Teams');
      expect(r.processSourcePid, 4242);
    });

    test('systemEnabled convenience tracks systemMode', () {
      expect(
        const RecordingState(systemMode: SystemAudioMode.off).systemEnabled,
        isFalse,
      );
      expect(
        const RecordingState(systemMode: SystemAudioMode.allSystem)
            .systemEnabled,
        isTrue,
      );
      expect(
        const RecordingState(systemMode: SystemAudioMode.processOnly)
            .systemEnabled,
        isTrue,
      );
    });
  });
}
