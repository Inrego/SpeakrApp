import 'package:flutter_test/flutter_test.dart';
import 'package:speakr_app/features/live/recording_state.dart';

void main() {
  group('RecordingState audio-source fields', () {
    test('defaults at construction time', () {
      const s = RecordingState();
      expect(s.micEnabled, isTrue);
      expect(s.systemEnabled, isFalse);
      expect(s.systemAudioSupported, isFalse);
      expect(s.micPending, isFalse);
      expect(s.systemPending, isFalse);
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
      expect(decoded.systemEnabled, isFalse);
      expect(decoded.systemAudioSupported, isFalse);
      expect(decoded.elapsedSeconds, 7);
      expect(decoded.started, isTrue);
    });

    test('full JSON round-trip preserves the new fields', () {
      const s = RecordingState(
        micEnabled: false,
        systemEnabled: true,
        systemAudioSupported: true,
        micPending: false,
        systemPending: true,
      );
      final r = RecordingState.fromJson(s.toJson());
      expect(r.micEnabled, isFalse);
      expect(r.systemEnabled, isTrue);
      expect(r.systemAudioSupported, isTrue);
      expect(r.systemPending, isTrue);
    });
  });
}
