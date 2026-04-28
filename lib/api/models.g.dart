// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TagImpl _$$TagImplFromJson(Map<String, dynamic> json) => _$TagImpl(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  color: json['color'] as String?,
  customPrompt: json['custom_prompt'] as String?,
  defaultLanguage: json['default_language'] as String?,
  defaultMinSpeakers: (json['default_min_speakers'] as num?)?.toInt(),
  defaultMaxSpeakers: (json['default_max_speakers'] as num?)?.toInt(),
);

Map<String, dynamic> _$$TagImplToJson(_$TagImpl instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'color': instance.color,
  'custom_prompt': instance.customPrompt,
  'default_language': instance.defaultLanguage,
  'default_min_speakers': instance.defaultMinSpeakers,
  'default_max_speakers': instance.defaultMaxSpeakers,
};

_$SpeakerImpl _$$SpeakerImplFromJson(Map<String, dynamic> json) =>
    _$SpeakerImpl(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      hasVoiceProfile: json['has_voice_profile'] as bool? ?? false,
      useCount: (json['use_count'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$SpeakerImplToJson(_$SpeakerImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'has_voice_profile': instance.hasVoiceProfile,
      'use_count': instance.useCount,
    };

_$RecordingImpl _$$RecordingImplFromJson(Map<String, dynamic> json) =>
    _$RecordingImpl(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String?,
      meetingDate: _parseFlexibleDate(json['meeting_date']),
      createdAt: _parseFlexibleDate(json['created_at']),
      participants: json['participants'] as String?,
      fileSize: (json['file_size'] as num?)?.toInt(),
      isHighlighted: json['is_highlighted'] as bool? ?? false,
      isInbox: json['is_inbox'] as bool? ?? false,
      status:
          $enumDecodeNullable(_$RecordingStatusEnumMap, json['status']) ??
          RecordingStatus.completed,
      tags:
          (json['tags'] as List<dynamic>?)
              ?.map((e) => Tag.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <Tag>[],
      audioAvailable: json['audio_available'] as bool?,
      errorMessage: json['error_message'] as String?,
      hasSummary: json['has_summary'] as bool?,
      hasTranscription: json['has_transcription'] as bool?,
      originalFilename: json['original_filename'] as String?,
      summary: json['summary'] as String?,
      notes: json['notes'] as String?,
      transcription: json['transcription'] as String?,
      audioDuration: (json['audio_duration'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$$RecordingImplToJson(_$RecordingImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'meeting_date': instance.meetingDate?.toIso8601String(),
      'created_at': instance.createdAt?.toIso8601String(),
      'participants': instance.participants,
      'file_size': instance.fileSize,
      'is_highlighted': instance.isHighlighted,
      'is_inbox': instance.isInbox,
      'status': _$RecordingStatusEnumMap[instance.status]!,
      'tags': instance.tags,
      'audio_available': instance.audioAvailable,
      'error_message': instance.errorMessage,
      'has_summary': instance.hasSummary,
      'has_transcription': instance.hasTranscription,
      'original_filename': instance.originalFilename,
      'summary': instance.summary,
      'notes': instance.notes,
      'transcription': instance.transcription,
      'audio_duration': instance.audioDuration,
    };

const _$RecordingStatusEnumMap = {
  RecordingStatus.pending: 'PENDING',
  RecordingStatus.processing: 'PROCESSING',
  RecordingStatus.summarizing: 'SUMMARIZING',
  RecordingStatus.completed: 'COMPLETED',
  RecordingStatus.failed: 'FAILED',
};

_$RecordingPageImpl _$$RecordingPageImplFromJson(Map<String, dynamic> json) =>
    _$RecordingPageImpl(
      recordings:
          (json['recordings'] as List<dynamic>?)
              ?.map((e) => Recording.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <Recording>[],
      page: (json['page'] as num?)?.toInt() ?? 1,
      perPage: (json['per_page'] as num?)?.toInt() ?? 25,
      total: (json['total'] as num?)?.toInt() ?? 0,
      totalPages: (json['total_pages'] as num?)?.toInt() ?? 1,
    );

Map<String, dynamic> _$$RecordingPageImplToJson(_$RecordingPageImpl instance) =>
    <String, dynamic>{
      'recordings': instance.recordings,
      'page': instance.page,
      'per_page': instance.perPage,
      'total': instance.total,
      'total_pages': instance.totalPages,
    };

_$TranscriptSegmentImpl _$$TranscriptSegmentImplFromJson(
  Map<String, dynamic> json,
) => _$TranscriptSegmentImpl(
  speaker: json['speaker'] as String?,
  startTime: (json['start_time'] as num?)?.toDouble(),
  endTime: (json['end_time'] as num?)?.toDouble(),
  sentence: json['sentence'] as String?,
);

Map<String, dynamic> _$$TranscriptSegmentImplToJson(
  _$TranscriptSegmentImpl instance,
) => <String, dynamic>{
  'speaker': instance.speaker,
  'start_time': instance.startTime,
  'end_time': instance.endTime,
  'sentence': instance.sentence,
};

_$RecordingStatusResponseImpl _$$RecordingStatusResponseImplFromJson(
  Map<String, dynamic> json,
) => _$RecordingStatusResponseImpl(
  status: $enumDecode(_$RecordingStatusEnumMap, json['status']),
  queuePosition: (json['queue_position'] as num?)?.toInt(),
  message: json['message'] as String?,
);

Map<String, dynamic> _$$RecordingStatusResponseImplToJson(
  _$RecordingStatusResponseImpl instance,
) => <String, dynamic>{
  'status': _$RecordingStatusEnumMap[instance.status]!,
  'queue_position': instance.queuePosition,
  'message': instance.message,
};

_$ChatMessageImpl _$$ChatMessageImplFromJson(Map<String, dynamic> json) =>
    _$ChatMessageImpl(
      role: json['role'] as String,
      text: json['text'] as String,
    );

Map<String, dynamic> _$$ChatMessageImplToJson(_$ChatMessageImpl instance) =>
    <String, dynamic>{'role': instance.role, 'text': instance.text};

_$ChatResponseImpl _$$ChatResponseImplFromJson(Map<String, dynamic> json) =>
    _$ChatResponseImpl(response: json['response'] as String);

Map<String, dynamic> _$$ChatResponseImplToJson(_$ChatResponseImpl instance) =>
    <String, dynamic>{'response': instance.response};

_$StatsResponseImpl _$$StatsResponseImplFromJson(Map<String, dynamic> json) =>
    _$StatsResponseImpl(
      recordings: (json['recordings'] as num?)?.toInt(),
      totalRecordings: (json['total_recordings'] as num?)?.toInt(),
      storageUsedBytes: (json['storage_used_bytes'] as num?)?.toInt(),
      version: json['version'] as String?,
    );

Map<String, dynamic> _$$StatsResponseImplToJson(_$StatsResponseImpl instance) =>
    <String, dynamic>{
      'recordings': instance.recordings,
      'total_recordings': instance.totalRecordings,
      'storage_used_bytes': instance.storageUsedBytes,
      'version': instance.version,
    };
