// Hand-rolled domain models for the Speakr REST API v1.
// Source of truth: openapi/speakr-openapi.json (info.version 1.0.0).
// Regenerate manually if the API gains new shapes.

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:intl/intl.dart';

part 'models.freezed.dart';
part 'models.g.dart';

// The v1 list endpoint returns ISO-8601 timestamps; the unofficial detail
// endpoint at /api/recordings/{id} returns "Apr 23, 2026, 2:19:29 PM" with a
// U+202F narrow no-break space before AM/PM. Accept both shapes.
DateTime? _parseFlexibleDate(Object? raw) {
  if (raw is! String || raw.isEmpty) return null;
  final iso = DateTime.tryParse(raw);
  if (iso != null) return iso;
  final normalized = raw.replaceAll(' ', ' ').replaceAll(' ', ' ');
  try {
    return DateFormat("MMM d, yyyy, h:mm:ss a").parse(normalized);
  } catch (_) {
    return null;
  }
}

enum RecordingStatus {
  @JsonValue('PENDING')
  pending,
  @JsonValue('PROCESSING')
  processing,
  @JsonValue('SUMMARIZING')
  summarizing,
  @JsonValue('COMPLETED')
  completed,
  @JsonValue('FAILED')
  failed;

  bool get isInProgress =>
      this == RecordingStatus.pending ||
      this == RecordingStatus.processing ||
      this == RecordingStatus.summarizing;

  String get displayLabel => switch (this) {
        RecordingStatus.pending => 'Pending',
        RecordingStatus.processing => 'Processing',
        RecordingStatus.summarizing => 'Summarizing',
        RecordingStatus.completed => 'Completed',
        RecordingStatus.failed => 'Failed',
      };
}

@freezed
class Tag with _$Tag {
  const factory Tag({
    required int id,
    required String name,
    String? color,
    @JsonKey(name: 'custom_prompt') String? customPrompt,
    @JsonKey(name: 'default_language') String? defaultLanguage,
    @JsonKey(name: 'default_min_speakers') int? defaultMinSpeakers,
    @JsonKey(name: 'default_max_speakers') int? defaultMaxSpeakers,
  }) = _Tag;

  factory Tag.fromJson(Map<String, dynamic> json) => _$TagFromJson(json);
}

@freezed
class Speaker with _$Speaker {
  const factory Speaker({
    required int id,
    required String name,
    @JsonKey(name: 'has_voice_profile') @Default(false) bool hasVoiceProfile,
    @JsonKey(name: 'use_count') @Default(0) int useCount,
  }) = _Speaker;

  factory Speaker.fromJson(Map<String, dynamic> json) =>
      _$SpeakerFromJson(json);
}

@freezed
class Recording with _$Recording {
  const factory Recording({
    required int id,
    String? title,
    @JsonKey(name: 'meeting_date', fromJson: _parseFlexibleDate)
    DateTime? meetingDate,
    @JsonKey(name: 'created_at', fromJson: _parseFlexibleDate)
    DateTime? createdAt,
    String? participants,
    @JsonKey(name: 'file_size') int? fileSize,
    @JsonKey(name: 'is_highlighted') @Default(false) bool isHighlighted,
    @JsonKey(name: 'is_inbox') @Default(false) bool isInbox,
    @Default(RecordingStatus.completed) RecordingStatus status,
    @Default(<Tag>[]) List<Tag> tags,

    // Returned by the v1 list endpoint.
    @JsonKey(name: 'audio_available') bool? audioAvailable,
    @JsonKey(name: 'error_message') String? errorMessage,
    @JsonKey(name: 'has_summary') bool? hasSummary,
    @JsonKey(name: 'has_transcription') bool? hasTranscription,
    @JsonKey(name: 'original_filename') String? originalFilename,

    // Optional rich fields returned by the unofficial /api/recordings/{id}.
    String? summary,
    String? notes,
    String? transcription,
    @JsonKey(name: 'audio_duration') double? audioDuration,
  }) = _Recording;

  factory Recording.fromJson(Map<String, dynamic> json) =>
      _$RecordingFromJson(json);
}

@freezed
class RecordingPage with _$RecordingPage {
  const factory RecordingPage({
    @Default(<Recording>[]) List<Recording> recordings,
    @Default(1) int page,
    @JsonKey(name: 'per_page') @Default(25) int perPage,
    @Default(0) int total,
    @JsonKey(name: 'total_pages') @Default(1) int totalPages,
  }) = _RecordingPage;

  factory RecordingPage.fromJson(Map<String, dynamic> json) =>
      _$RecordingPageFromJson(json);
}

@freezed
class TranscriptSegment with _$TranscriptSegment {
  const factory TranscriptSegment({
    String? speaker,
    @JsonKey(name: 'start_time') double? startTime,
    @JsonKey(name: 'end_time') double? endTime,
    String? sentence,
  }) = _TranscriptSegment;

  factory TranscriptSegment.fromJson(Map<String, dynamic> json) =>
      _$TranscriptSegmentFromJson(json);
}

@freezed
class RecordingStatusResponse with _$RecordingStatusResponse {
  const factory RecordingStatusResponse({
    required RecordingStatus status,
    @JsonKey(name: 'queue_position') int? queuePosition,
    String? message,
  }) = _RecordingStatusResponse;

  factory RecordingStatusResponse.fromJson(Map<String, dynamic> json) =>
      _$RecordingStatusResponseFromJson(json);
}

@freezed
class ChatMessage with _$ChatMessage {
  const factory ChatMessage({
    required String role, // "user" | "assistant"
    required String text,
  }) = _ChatMessage;

  factory ChatMessage.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageFromJson(json);
}

@freezed
class ChatResponse with _$ChatResponse {
  const factory ChatResponse({
    @JsonKey(name: 'response') required String response,
  }) = _ChatResponse;

  factory ChatResponse.fromJson(Map<String, dynamic> json) =>
      _$ChatResponseFromJson(json);
}

@freezed
class StatsResponse with _$StatsResponse {
  const factory StatsResponse({
    int? recordings,
    @JsonKey(name: 'total_recordings') int? totalRecordings,
    @JsonKey(name: 'storage_used_bytes') int? storageUsedBytes,
    String? version,
  }) = _StatsResponse;

  factory StatsResponse.fromJson(Map<String, dynamic> json) =>
      _$StatsResponseFromJson(json);
}
