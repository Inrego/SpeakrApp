import 'package:flutter_test/flutter_test.dart';
import 'package:speakr_app/services/auto_record/auto_record_settings.dart';

void main() {
  group('AllowlistEntry JSON round-trip', () {
    test('legacy JSON without overrides parses with no overrides', () {
      final entry = AllowlistEntry.fromJson(const {
        'key': 'Teams.exe',
        'displayName': 'Microsoft Teams',
        'kind': 'exeBasename',
      });
      expect(entry.key, 'Teams.exe');
      expect(entry.displayName, 'Microsoft Teams');
      expect(entry.kind, AllowlistKind.exeBasename);
      expect(entry.speakers, isNull);
      expect(entry.tagIds, isEmpty);
    });

    test('JSON with overrides round-trips intact', () {
      const original = AllowlistEntry(
        key: 'Teams.exe',
        displayName: 'Microsoft Teams',
        kind: AllowlistKind.exeBasename,
        speakers: 5,
        tagIds: [3, 7, 12],
      );
      final restored = AllowlistEntry.fromJson(original.toJson());
      expect(restored.key, original.key);
      expect(restored.displayName, original.displayName);
      expect(restored.kind, original.kind);
      expect(restored.speakers, 5);
      expect(restored.tagIds, [3, 7, 12]);
    });

    test('toJson omits speakers when null and tagIds when empty', () {
      const entry = AllowlistEntry(
        key: 'Zoom.exe',
        displayName: 'Zoom',
        kind: AllowlistKind.exeBasename,
      );
      final json = entry.toJson();
      expect(json.containsKey('speakers'), isFalse);
      expect(json.containsKey('tagIds'), isFalse);
    });

    test('copyWith can clear speakers override (set to null)', () {
      const entry = AllowlistEntry(
        key: 'Teams.exe',
        displayName: 'Teams',
        kind: AllowlistKind.exeBasename,
        speakers: 5,
        tagIds: [1, 2],
      );
      final cleared = entry.copyWith(speakers: null);
      expect(cleared.speakers, isNull);
      expect(cleared.tagIds, [1, 2]); // unchanged
    });

    test('copyWith leaves speakers untouched when not passed', () {
      const entry = AllowlistEntry(
        key: 'Teams.exe',
        displayName: 'Teams',
        kind: AllowlistKind.exeBasename,
        speakers: 5,
      );
      final updated = entry.copyWith(displayName: 'Teams (work)');
      expect(updated.speakers, 5);
      expect(updated.displayName, 'Teams (work)');
    });

    test('equality remains keyed on (key, kind) only', () {
      const a = AllowlistEntry(
        key: 'Teams.exe',
        displayName: 'Teams',
        kind: AllowlistKind.exeBasename,
        speakers: 5,
        tagIds: [1],
      );
      const b = AllowlistEntry(
        key: 'TEAMS.EXE',
        displayName: 'Microsoft Teams',
        kind: AllowlistKind.exeBasename,
        speakers: 2,
        tagIds: [],
      );
      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });
  });

  group('AutoRecordSettings JSON round-trip', () {
    test('preserves per-app overrides on entries within the allowlist', () {
      const settings = AutoRecordSettings(
        enabled: true,
        defaultSpeakers: 3,
        defaultTagIds: [42],
        allowlist: [
          AllowlistEntry(
            key: 'Teams.exe',
            displayName: 'Teams',
            kind: AllowlistKind.exeBasename,
            speakers: 5,
            tagIds: [1, 2],
          ),
          AllowlistEntry(
            key: 'Zoom.exe',
            displayName: 'Zoom',
            kind: AllowlistKind.exeBasename,
          ),
        ],
      );
      final restored = AutoRecordSettings.fromJson(settings.toJson());
      expect(restored.allowlist.length, 2);
      expect(restored.allowlist[0].speakers, 5);
      expect(restored.allowlist[0].tagIds, [1, 2]);
      expect(restored.allowlist[1].speakers, isNull);
      expect(restored.allowlist[1].tagIds, isEmpty);
      expect(restored.defaultSpeakers, 3);
      expect(restored.defaultTagIds, [42]);
    });
  });
}
