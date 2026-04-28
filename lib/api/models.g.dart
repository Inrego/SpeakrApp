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
      lastUsed: json['last_used'] == null
          ? null
          : DateTime.parse(json['last_used'] as String),
    );

Map<String, dynamic> _$$SpeakerImplToJson(_$SpeakerImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'has_voice_profile': instance.hasVoiceProfile,
      'use_count': instance.useCount,
      'last_used': instance.lastUsed?.toIso8601String(),
    };

_$SpeakerSuggestionImpl _$$SpeakerSuggestionImplFromJson(
  Map<String, dynamic> json,
) => _$SpeakerSuggestionImpl(
  speakerId: (json['speaker_id'] as num).toInt(),
  name: json['name'] as String,
  confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
  similarity: (json['similarity'] as num?)?.toDouble() ?? 0.0,
  embeddingCount: (json['embedding_count'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$$SpeakerSuggestionImplToJson(
  _$SpeakerSuggestionImpl instance,
) => <String, dynamic>{
  'speaker_id': instance.speakerId,
  'name': instance.name,
  'confidence': instance.confidence,
  'similarity': instance.similarity,
  'embedding_count': instance.embeddingCount,
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
      status: json['status'] == null
          ? RecordingStatus.completed
          : _parseRecordingStatus(json['status']),
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
  RecordingStatus.queued: 'QUEUED',
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
  status: _parseRecordingStatus(json['status']),
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
      activity: json['activity'] == null
          ? null
          : StatsActivity.fromJson(json['activity'] as Map<String, dynamic>),
      queue: json['queue'] == null
          ? null
          : StatsQueue.fromJson(json['queue'] as Map<String, dynamic>),
      recordings: json['recordings'] == null
          ? null
          : StatsRecordings.fromJson(
              json['recordings'] as Map<String, dynamic>,
            ),
      storage: json['storage'] == null
          ? null
          : StatsStorage.fromJson(json['storage'] as Map<String, dynamic>),
      tokens: json['tokens'] == null
          ? null
          : StatsTokens.fromJson(json['tokens'] as Map<String, dynamic>),
      transcription: json['transcription'] == null
          ? null
          : StatsTranscription.fromJson(
              json['transcription'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$$StatsResponseImplToJson(_$StatsResponseImpl instance) =>
    <String, dynamic>{
      'activity': instance.activity,
      'queue': instance.queue,
      'recordings': instance.recordings,
      'storage': instance.storage,
      'tokens': instance.tokens,
      'transcription': instance.transcription,
    };

_$StatsActivityImpl _$$StatsActivityImplFromJson(Map<String, dynamic> json) =>
    _$StatsActivityImpl(
      lastTranscription: json['last_transcription'] == null
          ? null
          : DateTime.parse(json['last_transcription'] as String),
      recordingsToday: (json['recordings_today'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$StatsActivityImplToJson(_$StatsActivityImpl instance) =>
    <String, dynamic>{
      'last_transcription': instance.lastTranscription?.toIso8601String(),
      'recordings_today': instance.recordingsToday,
    };

_$StatsQueueImpl _$$StatsQueueImplFromJson(Map<String, dynamic> json) =>
    _$StatsQueueImpl(
      jobsProcessing: (json['jobs_processing'] as num?)?.toInt(),
      jobsQueued: (json['jobs_queued'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$StatsQueueImplToJson(_$StatsQueueImpl instance) =>
    <String, dynamic>{
      'jobs_processing': instance.jobsProcessing,
      'jobs_queued': instance.jobsQueued,
    };

_$StatsRecordingsImpl _$$StatsRecordingsImplFromJson(
  Map<String, dynamic> json,
) => _$StatsRecordingsImpl(
  completed: (json['completed'] as num?)?.toInt(),
  failed: (json['failed'] as num?)?.toInt(),
  pending: (json['pending'] as num?)?.toInt(),
  processing: (json['processing'] as num?)?.toInt(),
  total: (json['total'] as num?)?.toInt(),
);

Map<String, dynamic> _$$StatsRecordingsImplToJson(
  _$StatsRecordingsImpl instance,
) => <String, dynamic>{
  'completed': instance.completed,
  'failed': instance.failed,
  'pending': instance.pending,
  'processing': instance.processing,
  'total': instance.total,
};

_$StatsStorageImpl _$$StatsStorageImplFromJson(Map<String, dynamic> json) =>
    _$StatsStorageImpl(
      usedBytes: (json['used_bytes'] as num?)?.toInt(),
      usedHuman: json['used_human'] as String?,
    );

Map<String, dynamic> _$$StatsStorageImplToJson(_$StatsStorageImpl instance) =>
    <String, dynamic>{
      'used_bytes': instance.usedBytes,
      'used_human': instance.usedHuman,
    };

_$StatsTokensImpl _$$StatsTokensImplFromJson(Map<String, dynamic> json) =>
    _$StatsTokensImpl(
      budget: (json['budget'] as num?)?.toInt(),
      percentage: (json['percentage'] as num?)?.toDouble(),
      usedThisMonth: (json['used_this_month'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$StatsTokensImplToJson(_$StatsTokensImpl instance) =>
    <String, dynamic>{
      'budget': instance.budget,
      'percentage': instance.percentage,
      'used_this_month': instance.usedThisMonth,
    };

_$StatsTranscriptionImpl _$$StatsTranscriptionImplFromJson(
  Map<String, dynamic> json,
) => _$StatsTranscriptionImpl(
  budgetMinutes: (json['budget_minutes'] as num?)?.toInt(),
  budgetSeconds: (json['budget_seconds'] as num?)?.toInt(),
  estimatedCost: (json['estimated_cost'] as num?)?.toDouble(),
  percentage: (json['percentage'] as num?)?.toDouble(),
  usedThisMonthMinutes: (json['used_this_month_minutes'] as num?)?.toInt(),
  usedThisMonthSeconds: (json['used_this_month_seconds'] as num?)?.toInt(),
);

Map<String, dynamic> _$$StatsTranscriptionImplToJson(
  _$StatsTranscriptionImpl instance,
) => <String, dynamic>{
  'budget_minutes': instance.budgetMinutes,
  'budget_seconds': instance.budgetSeconds,
  'estimated_cost': instance.estimatedCost,
  'percentage': instance.percentage,
  'used_this_month_minutes': instance.usedThisMonthMinutes,
  'used_this_month_seconds': instance.usedThisMonthSeconds,
};
