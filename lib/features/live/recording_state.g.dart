// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recording_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RecordingState _$RecordingStateFromJson(Map<String, dynamic> json) =>
    _RecordingState(
      elapsedSeconds: (json['elapsedSeconds'] as num?)?.toInt() ?? 0,
      paused: json['paused'] as bool? ?? false,
      started: json['started'] as bool? ?? false,
      uploading: json['uploading'] as bool? ?? false,
      error: json['error'] as String?,
      speakers: (json['speakers'] as num?)?.toInt() ?? 2,
      activeTags:
          (json['activeTags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      folderId: (json['folderId'] as num?)?.toInt(),
      miniOpen: json['miniOpen'] as bool? ?? false,
      miniWindowId: (json['miniWindowId'] as num?)?.toInt(),
      micEnabled: json['micEnabled'] as bool? ?? true,
      systemEnabled: json['systemEnabled'] as bool? ?? false,
      systemAudioSupported: json['systemAudioSupported'] as bool? ?? false,
      micPending: json['micPending'] as bool? ?? false,
      systemPending: json['systemPending'] as bool? ?? false,
    );

Map<String, dynamic> _$RecordingStateToJson(_RecordingState instance) =>
    <String, dynamic>{
      'elapsedSeconds': instance.elapsedSeconds,
      'paused': instance.paused,
      'started': instance.started,
      'uploading': instance.uploading,
      'error': instance.error,
      'speakers': instance.speakers,
      'activeTags': instance.activeTags,
      'folderId': instance.folderId,
      'miniOpen': instance.miniOpen,
      'miniWindowId': instance.miniWindowId,
      'micEnabled': instance.micEnabled,
      'systemEnabled': instance.systemEnabled,
      'systemAudioSupported': instance.systemAudioSupported,
      'micPending': instance.micPending,
      'systemPending': instance.systemPending,
    };
