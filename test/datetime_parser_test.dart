import 'package:flutter_test/flutter_test.dart';
import 'package:speakr_app/features/auto_upload/auto_upload_settings.dart';
import 'package:speakr_app/features/auto_upload/datetime_parser.dart';

void main() {
  group('parseFromFilename — built-in presets', () {
    test('Samsung _yyMMdd_HHmmss', () {
      final preset = presetById('samsung_call_v1')!;
      final dt = parseFromFilename(
          'Call recording with John Doe (12345)_240501_142536.m4a', preset);
      expect(dt, DateTime(2024, 5, 1, 14, 25, 36));
    });

    test('Pixel yyyy-MM-dd HH-mm-ss', () {
      final preset = presetById('pixel_call_v1')!;
      final dt = parseFromFilename(
          'Call_+15551234567_2026-04-27 14-25-36.m4a', preset);
      expect(dt, DateTime(2026, 4, 27, 14, 25, 36));
    });

    test('Generic yyyyMMdd_HHmmss', () {
      final preset = presetById('generic_compact')!;
      final dt = parseFromFilename('rec_20260427_142536.wav', preset);
      expect(dt, DateTime(2026, 4, 27, 14, 25, 36));
    });

    test('ISO 8601', () {
      final preset = presetById('iso_basic')!;
      final dt =
          parseFromFilename('meeting_2026-04-27T14:25:36.m4a', preset);
      expect(dt, DateTime(2026, 4, 27, 14, 25, 36));
    });

    test('Unix epoch ms', () {
      final preset = presetById('unix_epoch_ms')!;
      final dt = parseFromFilename('speakr_1714572336000.m4a', preset);
      expect(dt, DateTime.fromMillisecondsSinceEpoch(1714572336000));
    });

    test('ColorOS yyMMddHHmm', () {
      final preset = presetById('coloros_compact_v1')!;
      final dt = parseFromFilename('Recording 2604271425.m4a', preset);
      expect(dt, DateTime(2026, 4, 27, 14, 25));
    });

    test('returns null when filename does not match', () {
      final preset = presetById('samsung_call_v1')!;
      expect(parseFromFilename('random_file.m4a', preset), isNull);
    });

    test('returns null on out-of-range capture group', () {
      const preset = DateTimePreset(
        id: 'broken',
        label: 'Broken',
        pattern: r'(\d+)',
        captureGroup: 5, // doesn't exist
        format: 'yyyy',
      );
      expect(parseFromFilename('123', preset), isNull);
    });

    test('returns null on unparseable date', () {
      final preset = presetById('iso_basic')!;
      expect(
          parseFromFilename('foo_2026-13-99T99:99:99.m4a', preset), isNull);
    });
  });

  group('activePreset', () {
    test('returns null when parsing is off', () {
      const s = FolderUploadConfig(id: 'a');
      expect(activePreset(s), isNull);
    });

    test('returns named preset by id', () {
      const s = FolderUploadConfig(id: 'a', parsePresetId: 'pixel_call_v1');
      expect(activePreset(s)?.id, 'pixel_call_v1');
    });

    test('returns null for unknown preset id', () {
      const s = FolderUploadConfig(id: 'a', parsePresetId: 'does_not_exist');
      expect(activePreset(s), isNull);
    });

    test('returns custom preset when fully configured', () {
      const s = FolderUploadConfig(
        id: 'a',
        parsePresetId: kCustomPresetId,
        customRegex: r'(\d{4})',
        customCaptureGroup: 1,
        customFormat: 'yyyy',
      );
      final preset = activePreset(s);
      expect(preset, isNotNull);
      expect(preset!.id, kCustomPresetId);
    });

    test('returns null when custom config is incomplete', () {
      const incomplete = FolderUploadConfig(
        id: 'a',
        parsePresetId: kCustomPresetId,
        customRegex: r'(\d{4})',
        customCaptureGroup: 1,
        // customFormat missing
      );
      expect(activePreset(incomplete), isNull);
    });
  });

  group('FolderUploadConfig.copyWith', () {
    test('preserves untouched fields', () {
      const s = FolderUploadConfig(
        id: 'a',
        enabled: true,
        folderPath: '/foo',
        tagId: 7,
        language: 'da',
      );
      final next = s.copyWith(enabled: false);
      expect(next.enabled, false);
      expect(next.folderPath, '/foo');
      expect(next.tagId, 7);
      expect(next.language, 'da');
    });

    test('clears nullable field via explicit null', () {
      const s = FolderUploadConfig(id: 'a', folderPath: '/foo');
      final next = s.copyWith(folderPath: null);
      expect(next.folderPath, isNull);
    });
  });
}
