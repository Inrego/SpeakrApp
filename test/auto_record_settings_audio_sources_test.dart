import 'package:flutter_test/flutter_test.dart';
import 'package:speakr_app/services/auto_record/auto_record_settings.dart';

void main() {
  group('AutoRecordSettings audio-source defaults', () {
    test('round-trips explicit false defaults', () {
      const s = AutoRecordSettings(
        defaultMicEnabled: false,
        defaultSystemEnabled: true,
      );
      final encoded = s.toJson();
      // Explicit false must survive — drop-on-null shouldn't kick in.
      expect(encoded.containsKey('defaultMicEnabled'), isTrue);
      expect(encoded['defaultMicEnabled'], isFalse);
      expect(encoded['defaultSystemEnabled'], isTrue);
      final decoded = AutoRecordSettings.fromJson(encoded);
      expect(decoded.defaultMicEnabled, isFalse);
      expect(decoded.defaultSystemEnabled, isTrue);
    });

    test('fromJson defaults to mic-on / system-off when keys missing', () {
      final decoded = AutoRecordSettings.fromJson(const {});
      expect(decoded.defaultMicEnabled, isTrue);
      expect(decoded.defaultSystemEnabled, isFalse);
    });

    test('copyWith updates only specified fields', () {
      const s = AutoRecordSettings(defaultMicEnabled: true);
      final next = s.copyWith(defaultMicEnabled: false);
      expect(next.defaultMicEnabled, isFalse);
      expect(next.defaultSystemEnabled, isFalse);
    });
  });

  group('AllowlistEntry source override sentinels', () {
    const entry = AllowlistEntry(
      key: 'Teams.exe',
      displayName: 'Teams',
      kind: AllowlistKind.exeBasename,
      micEnabled: true,
    );

    test('omitting a sentinel preserves the existing override', () {
      final next = entry.copyWith(systemEnabled: true);
      expect(next.micEnabled, isTrue);
      expect(next.systemEnabled, isTrue);
    });

    test('passing null clears the override (back to use-default)', () {
      final next = entry.copyWith(micEnabled: null);
      expect(next.micEnabled, isNull);
    });

    test('explicit false is preserved through JSON round-trip', () {
      const e = AllowlistEntry(
        key: 'Foo.exe',
        displayName: 'Foo',
        kind: AllowlistKind.exeBasename,
        micEnabled: false,
        systemEnabled: false,
      );
      final round = AllowlistEntry.fromJson(e.toJson());
      expect(round.micEnabled, isFalse);
      expect(round.systemEnabled, isFalse);
    });

    test('null overrides are dropped from JSON to keep the blob tidy', () {
      const e = AllowlistEntry(
        key: 'Bar.exe',
        displayName: 'Bar',
        kind: AllowlistKind.exeBasename,
      );
      final j = e.toJson();
      expect(j.containsKey('micEnabled'), isFalse);
      expect(j.containsKey('systemEnabled'), isFalse);
    });
  });
}
