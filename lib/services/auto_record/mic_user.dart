import 'package:flutter/foundation.dart';

import 'auto_record_settings.dart';

@immutable
class MicUser {
  const MicUser({
    required this.key,
    required this.displayName,
    required this.kind,
    required this.lastStart,
    required this.lastStop,
    this.exePath,
  });

  /// Raw match key — exe basename for non-packaged apps, the full
  /// MSIX package family name (e.g. `MSTeams_8wekyb3d8bbwe`) for
  /// packaged apps.
  final String key;

  /// Human-readable label for display ("Teams", "MSTeams", "Zoom.exe").
  final String displayName;

  final AllowlistKind kind;

  /// Decoded full exe path for non-packaged apps; null for packaged.
  final String? exePath;

  final DateTime lastStart;
  final DateTime lastStop;

  bool get isInUse => lastStart.isAfter(lastStop);

  /// True iff this entry matches an allowlist row. Comparison is
  /// case-insensitive; packaged matches use a prefix test against the
  /// MSIX family name.
  bool matches(AllowlistEntry entry) {
    final mine = key.toLowerCase();
    final theirs = entry.key.toLowerCase();
    if (entry.kind != kind) return false;
    return entry.kind == AllowlistKind.packagedPrefix
        ? mine.startsWith(theirs)
        : mine == theirs;
  }

  @override
  bool operator ==(Object other) =>
      other is MicUser && other.key == key && other.kind == kind;

  @override
  int get hashCode => Object.hash(key, kind);
}
