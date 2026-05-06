import 'package:flutter/foundation.dart';

/// How a mic-using app is matched against the allowlist. Win32 apps
/// register under `NonPackaged` with their full exe path; MSIX apps
/// register under their package family name (e.g. `MSTeams_8wekyb3d8bbwe`).
enum AllowlistKind {
  /// Match on the .exe basename, case-insensitively (e.g. `Teams.exe`).
  exeBasename,

  /// Match if the app's MSIX package family starts with this prefix
  /// (e.g. `MSTeams` matches `MSTeams_8wekyb3d8bbwe`).
  packagedPrefix,
}

@immutable
class AllowlistEntry {
  const AllowlistEntry({
    required this.key,
    required this.displayName,
    required this.kind,
    this.speakers,
    this.tagIds = const [],
  });

  /// The match value: an exe basename or an MSIX family prefix. Stored
  /// verbatim; comparison is case-insensitive.
  final String key;

  /// Human-readable name shown in the UI ("Microsoft Teams").
  final String displayName;

  final AllowlistKind kind;

  /// Per-app speaker count override. `null` means use
  /// [AutoRecordSettings.defaultSpeakers].
  final int? speakers;

  /// Per-app tag IDs to attach to recordings triggered by this app.
  /// Empty means use [AutoRecordSettings.defaultTagIds].
  final List<int> tagIds;

  AllowlistEntry copyWith({
    String? key,
    String? displayName,
    AllowlistKind? kind,
    Object? speakers = _sentinel,
    List<int>? tagIds,
  }) {
    return AllowlistEntry(
      key: key ?? this.key,
      displayName: displayName ?? this.displayName,
      kind: kind ?? this.kind,
      speakers: identical(speakers, _sentinel) ? this.speakers : speakers as int?,
      tagIds: tagIds ?? this.tagIds,
    );
  }

  Map<String, dynamic> toJson() => {
        'key': key,
        'displayName': displayName,
        'kind': kind.name,
        if (speakers != null) 'speakers': speakers,
        if (tagIds.isNotEmpty) 'tagIds': tagIds,
      };

  factory AllowlistEntry.fromJson(Map<String, dynamic> json) {
    final rawKind = json['kind'] as String? ?? AllowlistKind.exeBasename.name;
    final kind = AllowlistKind.values.firstWhere(
      (k) => k.name == rawKind,
      orElse: () => AllowlistKind.exeBasename,
    );
    return AllowlistEntry(
      key: (json['key'] as String?) ?? '',
      displayName: (json['displayName'] as String?) ?? (json['key'] as String? ?? ''),
      kind: kind,
      speakers: (json['speakers'] as num?)?.toInt(),
      tagIds: (json['tagIds'] as List? ?? const [])
          .whereType<num>()
          .map((n) => n.toInt())
          .toList(growable: false),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AllowlistEntry &&
        other.key.toLowerCase() == key.toLowerCase() &&
        other.kind == kind;
  }

  @override
  int get hashCode => Object.hash(key.toLowerCase(), kind);
}

const Object _sentinel = Object();

@immutable
class RecentlySeenEntry {
  const RecentlySeenEntry({
    required this.key,
    required this.displayName,
    required this.kind,
    required this.lastSeenMs,
  });

  final String key;
  final String displayName;
  final AllowlistKind kind;
  final int lastSeenMs;

  Map<String, dynamic> toJson() => {
        'key': key,
        'displayName': displayName,
        'kind': kind.name,
        'lastSeenMs': lastSeenMs,
      };

  factory RecentlySeenEntry.fromJson(Map<String, dynamic> json) {
    final rawKind = json['kind'] as String? ?? AllowlistKind.exeBasename.name;
    final kind = AllowlistKind.values.firstWhere(
      (k) => k.name == rawKind,
      orElse: () => AllowlistKind.exeBasename,
    );
    return RecentlySeenEntry(
      key: (json['key'] as String?) ?? '',
      displayName:
          (json['displayName'] as String?) ?? (json['key'] as String? ?? ''),
      kind: kind,
      lastSeenMs: (json['lastSeenMs'] as num?)?.toInt() ?? 0,
    );
  }

  AllowlistEntry toAllowlistEntry() =>
      AllowlistEntry(key: key, displayName: displayName, kind: kind);
}

@immutable
class AutoRecordSettings {
  const AutoRecordSettings({
    this.enabled = false,
    this.allowlist = const [],
    this.recentlySeen = const [],
    this.silenceSeconds = 15,
    this.minKeepSeconds = 10,
    this.defaultSpeakers = 2,
    this.defaultTagIds = const [],
  });

  final bool enabled;
  final List<AllowlistEntry> allowlist;
  final List<RecentlySeenEntry> recentlySeen;

  /// Auto-stop prompt fires only after the speaker output has been
  /// quiet for at least this long *and* the trigger app has released
  /// the mic.
  final int silenceSeconds;

  /// Auto-recorded sessions shorter than this are discarded silently
  /// (no library entry).
  final int minKeepSeconds;

  final int defaultSpeakers;
  final List<int> defaultTagIds;

  AutoRecordSettings copyWith({
    bool? enabled,
    List<AllowlistEntry>? allowlist,
    List<RecentlySeenEntry>? recentlySeen,
    int? silenceSeconds,
    int? minKeepSeconds,
    int? defaultSpeakers,
    List<int>? defaultTagIds,
  }) {
    return AutoRecordSettings(
      enabled: enabled ?? this.enabled,
      allowlist: allowlist ?? this.allowlist,
      recentlySeen: recentlySeen ?? this.recentlySeen,
      silenceSeconds: silenceSeconds ?? this.silenceSeconds,
      minKeepSeconds: minKeepSeconds ?? this.minKeepSeconds,
      defaultSpeakers: defaultSpeakers ?? this.defaultSpeakers,
      defaultTagIds: defaultTagIds ?? this.defaultTagIds,
    );
  }

  Map<String, dynamic> toJson() => {
        'enabled': enabled,
        'allowlist': allowlist.map((e) => e.toJson()).toList(),
        'recentlySeen': recentlySeen.map((e) => e.toJson()).toList(),
        'silenceSeconds': silenceSeconds,
        'minKeepSeconds': minKeepSeconds,
        'defaultSpeakers': defaultSpeakers,
        'defaultTagIds': defaultTagIds,
      };

  factory AutoRecordSettings.fromJson(Map<String, dynamic> json) {
    return AutoRecordSettings(
      enabled: json['enabled'] as bool? ?? false,
      allowlist: (json['allowlist'] as List? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(AllowlistEntry.fromJson)
          .toList(growable: false),
      recentlySeen: (json['recentlySeen'] as List? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(RecentlySeenEntry.fromJson)
          .toList(growable: false),
      silenceSeconds: (json['silenceSeconds'] as num?)?.toInt() ?? 15,
      minKeepSeconds: (json['minKeepSeconds'] as num?)?.toInt() ?? 10,
      defaultSpeakers: (json['defaultSpeakers'] as num?)?.toInt() ?? 2,
      defaultTagIds: (json['defaultTagIds'] as List? ?? const [])
          .whereType<num>()
          .map((n) => n.toInt())
          .toList(growable: false),
    );
  }
}
