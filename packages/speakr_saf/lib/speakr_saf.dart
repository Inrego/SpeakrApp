/// Dart side of the in-repo Android Storage Access Framework bridge.
///
/// Every call is Android-only; on other platforms the app never reaches
/// this API (the auto-upload storage layer is platform-split in
/// `lib/features/auto_upload/auto_upload_files.dart`).
library;

import 'package:flutter/services.dart';

/// A folder the user granted through `ACTION_OPEN_DOCUMENT_TREE`.
class SafTree {
  const SafTree({required this.uri, required this.displayPath});

  /// Persisted tree URI. This is the identity of the grant.
  final String uri;

  /// Best-effort filesystem-looking path for display only.
  final String displayPath;
}

/// One child document of a granted tree.
class SafDocument {
  const SafDocument({
    required this.uri,
    required this.name,
    required this.size,
    required this.lastModified,
    this.mimeType,
  });

  factory SafDocument.fromMap(Map<Object?, Object?> m) => SafDocument(
        uri: m['uri'] as String,
        name: m['name'] as String,
        size: (m['size'] as num?)?.toInt() ?? 0,
        lastModified: DateTime.fromMillisecondsSinceEpoch(
          (m['lastModified'] as num?)?.toInt() ?? 0,
        ),
        mimeType: m['mimeType'] as String?,
      );

  /// Document URI built against the tree the file was listed under. Stable
  /// for the same file name in the same tree across scans and reboots.
  final String uri;
  final String name;
  final int size;
  final DateTime lastModified;
  final String? mimeType;
}

/// Thrown when the persisted grant behind a tree URI is gone (user revoked
/// it, app data cleared, or the provider is unavailable).
class SafPermissionLostException implements Exception {
  SafPermissionLostException(this.message);
  final String message;
  @override
  String toString() => message;
}

class SpeakrSaf {
  SpeakrSaf._();

  static const MethodChannel _channel = MethodChannel('com.inrego.speakr_saf');

  /// Shows the system folder picker and persists READ|WRITE on the result.
  /// Returns null when the user cancels.
  static Future<SafTree?> pickTree({String? initialUri}) async {
    final raw = await _channel.invokeMethod<Map<Object?, Object?>>(
      'pickTree',
      {'initialUri': initialUri},
    );
    if (raw == null) return null;
    return SafTree(
      uri: raw['uri'] as String,
      displayPath: raw['displayPath'] as String,
    );
  }

  /// Whether the app still holds a persisted READ|WRITE grant for [treeUri].
  static Future<bool> hasPersistedPermission(String treeUri) async {
    final ok = await _channel.invokeMethod<bool>(
      'hasPersistedPermission',
      {'treeUri': treeUri},
    );
    return ok ?? false;
  }

  /// Gives the grant back. Used when the last folder config pointing at a
  /// tree is removed.
  static Future<void> releaseTree(String treeUri) =>
      _channel.invokeMethod<void>('releaseTree', {'treeUri': treeUri});

  /// Direct child files (no directories, non-recursive) of [treeUri].
  static Future<List<SafDocument>> listChildren(String treeUri) async {
    try {
      final raw = await _channel.invokeMethod<List<Object?>>(
        'listChildren',
        {'treeUri': treeUri},
      );
      return [
        for (final item in raw ?? const [])
          if (item is Map<Object?, Object?>) SafDocument.fromMap(item),
      ];
    } on PlatformException catch (e) {
      throw _translate(e);
    }
  }

  /// Fresh metadata for a document, or null if it no longer exists.
  static Future<SafDocument?> stat(String documentUri) async {
    try {
      final raw = await _channel.invokeMethod<Map<Object?, Object?>>(
        'statDocument',
        {'documentUri': documentUri},
      );
      return raw == null ? null : SafDocument.fromMap(raw);
    } on PlatformException catch (e) {
      if (e.code == 'not_found') return null;
      throw _translate(e);
    }
  }

  /// Streams the document into [destinationPath]. Returns bytes written.
  static Future<int> copyToFile(String documentUri, String destinationPath) async {
    try {
      final n = await _channel.invokeMethod<int>('copyToFile', {
        'documentUri': documentUri,
        'destinationPath': destinationPath,
      });
      return n ?? 0;
    } on PlatformException catch (e) {
      throw _translate(e);
    }
  }

  /// Deletes the document. Returns false if the provider refused.
  static Future<bool> delete(String documentUri) async {
    try {
      final ok = await _channel.invokeMethod<bool>(
        'deleteDocument',
        {'documentUri': documentUri},
      );
      return ok ?? false;
    } on PlatformException catch (e) {
      if (e.code == 'not_found') return true;
      throw _translate(e);
    }
  }

  static Object _translate(PlatformException e) {
    if (e.code == 'permission_lost') {
      return SafPermissionLostException(
        e.message ?? 'Folder access was revoked',
      );
    }
    return e;
  }
}
