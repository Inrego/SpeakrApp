import 'package:flutter_test/flutter_test.dart';
import 'package:speakr_app/features/auto_upload/auto_upload_settings.dart';

void main() {
  group('FolderUploadConfig treeUri', () {
    test('round-trips through JSON', () {
      const cfg = FolderUploadConfig(
        id: '1',
        enabled: true,
        folderPath: '/storage/emulated/0/Recordings/Call',
        treeUri: 'content://com.android.externalstorage.documents/tree/'
            'primary%3ARecordings%2FCall',
      );
      final back = FolderUploadConfig.fromJson(cfg.toJson());
      expect(back.treeUri, cfg.treeUri);
      expect(back.folderPath, cfg.folderPath);
      expect(back.hasFolder, isTrue);
    });

    test('legacy JSON without treeUri still loads with the raw path', () {
      final cfg = FolderUploadConfig.fromJson({
        'id': 'legacy',
        'enabled': true,
        'folderPath': '/storage/emulated/0/Recordings/Call',
        'tagId': 3,
      });
      expect(cfg.treeUri, isNull);
      expect(cfg.folderPath, '/storage/emulated/0/Recordings/Call');
      expect(cfg.hasFolder, isTrue);
      expect(cfg.tagId, 3);
    });

    test('hasFolder is true for a tree-only entry', () {
      const cfg = FolderUploadConfig(id: '1', treeUri: 'content://x/tree/y');
      expect(cfg.hasFolder, isTrue);
    });

    test('copyWith can clear the tree grant', () {
      const cfg = FolderUploadConfig(
        id: '1',
        folderPath: 'C:\\Recordings',
        treeUri: 'content://x/tree/y',
      );
      final next = cfg.copyWith(treeUri: null);
      expect(next.treeUri, isNull);
      expect(next.folderPath, 'C:\\Recordings');
    });

    test('needsAndroidGrant is false off Android', () {
      // Unit tests run on the host; this only guards the platform gate.
      const cfg = FolderUploadConfig(id: '1', folderPath: 'C:\\Recordings');
      expect(cfg.needsAndroidGrant, isFalse);
    });
  });
}
