// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recording_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RecordingStateImpl _$$RecordingStateImplFromJson(Map<String, dynamic> json) =>
    _$RecordingStateImpl(
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
      miniOpen: json['miniOpen'] as bool? ?? false,
      miniWindowId: (json['miniWindowId'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$RecordingStateImplToJson(
  _$RecordingStateImpl instance,
) => <String, dynamic>{
  'elapsedSeconds': instance.elapsedSeconds,
  'paused': instance.paused,
  'started': instance.started,
  'uploading': instance.uploading,
  'error': instance.error,
  'speakers': instance.speakers,
  'activeTags': instance.activeTags,
  'miniOpen': instance.miniOpen,
  'miniWindowId': instance.miniWindowId,
};
