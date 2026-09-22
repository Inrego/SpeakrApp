import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speakr_app/features/auto_upload/auto_upload_settings_store.dart';

const _tree =
    'content://com.android.externalstorage.documents/tree/primary%3ARecordings%2FCall';
String _doc(String name) =>
    '$_tree/document/primary%3ARecordings%2FCall%2F${Uri.encodeComponent(name)}';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<AutoUploadSettingsStore> openWith(Map<String, Object> initial) async {
    SharedPreferences.setMockInitialValues(initial);
    return AutoUploadSettingsStore.open();
  }

  group('legacy path → document URI key migration', () {
    test('remaps error and uploaded-file entries by basename', () async {
      final store = await openWith({
        'auto_upload.file_errors': jsonEncode({
          '/storage/emulated/0/Recordings/Call/a.m4a': 'bad duration',
          '/storage/emulated/0/Other/c.m4a': 'unrelated folder',
        }),
        'auto_upload.uploaded_files': jsonEncode({
          '/storage/emulated/0/Recordings/Call/b.mp3': '12345',
        }),
      });

      final remap = store.legacyKeyRemap(
        '/storage/emulated/0/Recordings/Call',
        {'a.m4a': _doc('a.m4a'), 'b.mp3': _doc('b.mp3'), 'z.wav': _doc('z.wav')},
      );
      expect(remap, {
        '/storage/emulated/0/Recordings/Call/a.m4a': _doc('a.m4a'),
        '/storage/emulated/0/Recordings/Call/b.mp3': _doc('b.mp3'),
      });

      await store.remapFileKeys(remap);

      expect(store.readFileErrors(), {
        _doc('a.m4a'): 'bad duration',
        '/storage/emulated/0/Other/c.m4a': 'unrelated folder',
      });
      // The already-uploaded marker survives with its signature, so the
      // migrated install will delete b.mp3 instead of uploading it twice.
      expect(store.readUploadedFiles(), {_doc('b.mp3'): '12345'});
    });

    test('tolerates a trailing slash and Windows separators', () async {
      final store = await openWith({
        'auto_upload.uploaded_files': jsonEncode({
          r'C:\Recordings\x.wav': '1',
        }),
      });
      final remap = store.legacyKeyRemap(
        r'C:\Recordings\',
        {'x.wav': 'new-key'},
      );
      expect(remap, {r'C:\Recordings\x.wav': 'new-key'});
    });

    test('leaves stores untouched when nothing matches', () async {
      final store = await openWith({
        'auto_upload.file_errors': jsonEncode({'/a/b.m4a': 'x'}),
      });
      final remap = store.legacyKeyRemap('/other', {'b.m4a': 'k'});
      expect(remap, isEmpty);
      await store.remapFileKeys(remap);
      expect(store.readFileErrors(), {'/a/b.m4a': 'x'});
    });
  });
}
