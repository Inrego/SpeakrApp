// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Tag _$TagFromJson(Map<String, dynamic> json) {
  return _Tag.fromJson(json);
}

/// @nodoc
mixin _$Tag {
  int get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get color => throw _privateConstructorUsedError;
  @JsonKey(name: 'custom_prompt')
  String? get customPrompt => throw _privateConstructorUsedError;
  @JsonKey(name: 'default_language')
  String? get defaultLanguage => throw _privateConstructorUsedError;
  @JsonKey(name: 'default_min_speakers')
  int? get defaultMinSpeakers => throw _privateConstructorUsedError;
  @JsonKey(name: 'default_max_speakers')
  int? get defaultMaxSpeakers => throw _privateConstructorUsedError;

  /// Serializes this Tag to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Tag
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TagCopyWith<Tag> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TagCopyWith<$Res> {
  factory $TagCopyWith(Tag value, $Res Function(Tag) then) =
      _$TagCopyWithImpl<$Res, Tag>;
  @useResult
  $Res call({
    int id,
    String name,
    String? color,
    @JsonKey(name: 'custom_prompt') String? customPrompt,
    @JsonKey(name: 'default_language') String? defaultLanguage,
    @JsonKey(name: 'default_min_speakers') int? defaultMinSpeakers,
    @JsonKey(name: 'default_max_speakers') int? defaultMaxSpeakers,
  });
}

/// @nodoc
class _$TagCopyWithImpl<$Res, $Val extends Tag> implements $TagCopyWith<$Res> {
  _$TagCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Tag
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? color = freezed,
    Object? customPrompt = freezed,
    Object? defaultLanguage = freezed,
    Object? defaultMinSpeakers = freezed,
    Object? defaultMaxSpeakers = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            color: freezed == color
                ? _value.color
                : color // ignore: cast_nullable_to_non_nullable
                      as String?,
            customPrompt: freezed == customPrompt
                ? _value.customPrompt
                : customPrompt // ignore: cast_nullable_to_non_nullable
                      as String?,
            defaultLanguage: freezed == defaultLanguage
                ? _value.defaultLanguage
                : defaultLanguage // ignore: cast_nullable_to_non_nullable
                      as String?,
            defaultMinSpeakers: freezed == defaultMinSpeakers
                ? _value.defaultMinSpeakers
                : defaultMinSpeakers // ignore: cast_nullable_to_non_nullable
                      as int?,
            defaultMaxSpeakers: freezed == defaultMaxSpeakers
                ? _value.defaultMaxSpeakers
                : defaultMaxSpeakers // ignore: cast_nullable_to_non_nullable
                      as int?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TagImplCopyWith<$Res> implements $TagCopyWith<$Res> {
  factory _$$TagImplCopyWith(_$TagImpl value, $Res Function(_$TagImpl) then) =
      __$$TagImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    String name,
    String? color,
    @JsonKey(name: 'custom_prompt') String? customPrompt,
    @JsonKey(name: 'default_language') String? defaultLanguage,
    @JsonKey(name: 'default_min_speakers') int? defaultMinSpeakers,
    @JsonKey(name: 'default_max_speakers') int? defaultMaxSpeakers,
  });
}

/// @nodoc
class __$$TagImplCopyWithImpl<$Res> extends _$TagCopyWithImpl<$Res, _$TagImpl>
    implements _$$TagImplCopyWith<$Res> {
  __$$TagImplCopyWithImpl(_$TagImpl _value, $Res Function(_$TagImpl) _then)
    : super(_value, _then);

  /// Create a copy of Tag
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? color = freezed,
    Object? customPrompt = freezed,
    Object? defaultLanguage = freezed,
    Object? defaultMinSpeakers = freezed,
    Object? defaultMaxSpeakers = freezed,
  }) {
    return _then(
      _$TagImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        color: freezed == color
            ? _value.color
            : color // ignore: cast_nullable_to_non_nullable
                  as String?,
        customPrompt: freezed == customPrompt
            ? _value.customPrompt
            : customPrompt // ignore: cast_nullable_to_non_nullable
                  as String?,
        defaultLanguage: freezed == defaultLanguage
            ? _value.defaultLanguage
            : defaultLanguage // ignore: cast_nullable_to_non_nullable
                  as String?,
        defaultMinSpeakers: freezed == defaultMinSpeakers
            ? _value.defaultMinSpeakers
            : defaultMinSpeakers // ignore: cast_nullable_to_non_nullable
                  as int?,
        defaultMaxSpeakers: freezed == defaultMaxSpeakers
            ? _value.defaultMaxSpeakers
            : defaultMaxSpeakers // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TagImpl implements _Tag {
  const _$TagImpl({
    required this.id,
    required this.name,
    this.color,
    @JsonKey(name: 'custom_prompt') this.customPrompt,
    @JsonKey(name: 'default_language') this.defaultLanguage,
    @JsonKey(name: 'default_min_speakers') this.defaultMinSpeakers,
    @JsonKey(name: 'default_max_speakers') this.defaultMaxSpeakers,
  });

  factory _$TagImpl.fromJson(Map<String, dynamic> json) =>
      _$$TagImplFromJson(json);

  @override
  final int id;
  @override
  final String name;
  @override
  final String? color;
  @override
  @JsonKey(name: 'custom_prompt')
  final String? customPrompt;
  @override
  @JsonKey(name: 'default_language')
  final String? defaultLanguage;
  @override
  @JsonKey(name: 'default_min_speakers')
  final int? defaultMinSpeakers;
  @override
  @JsonKey(name: 'default_max_speakers')
  final int? defaultMaxSpeakers;

  @override
  String toString() {
    return 'Tag(id: $id, name: $name, color: $color, customPrompt: $customPrompt, defaultLanguage: $defaultLanguage, defaultMinSpeakers: $defaultMinSpeakers, defaultMaxSpeakers: $defaultMaxSpeakers)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TagImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.color, color) || other.color == color) &&
            (identical(other.customPrompt, customPrompt) ||
                other.customPrompt == customPrompt) &&
            (identical(other.defaultLanguage, defaultLanguage) ||
                other.defaultLanguage == defaultLanguage) &&
            (identical(other.defaultMinSpeakers, defaultMinSpeakers) ||
                other.defaultMinSpeakers == defaultMinSpeakers) &&
            (identical(other.defaultMaxSpeakers, defaultMaxSpeakers) ||
                other.defaultMaxSpeakers == defaultMaxSpeakers));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    color,
    customPrompt,
    defaultLanguage,
    defaultMinSpeakers,
    defaultMaxSpeakers,
  );

  /// Create a copy of Tag
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TagImplCopyWith<_$TagImpl> get copyWith =>
      __$$TagImplCopyWithImpl<_$TagImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TagImplToJson(this);
  }
}

abstract class _Tag implements Tag {
  const factory _Tag({
    required final int id,
    required final String name,
    final String? color,
    @JsonKey(name: 'custom_prompt') final String? customPrompt,
    @JsonKey(name: 'default_language') final String? defaultLanguage,
    @JsonKey(name: 'default_min_speakers') final int? defaultMinSpeakers,
    @JsonKey(name: 'default_max_speakers') final int? defaultMaxSpeakers,
  }) = _$TagImpl;

  factory _Tag.fromJson(Map<String, dynamic> json) = _$TagImpl.fromJson;

  @override
  int get id;
  @override
  String get name;
  @override
  String? get color;
  @override
  @JsonKey(name: 'custom_prompt')
  String? get customPrompt;
  @override
  @JsonKey(name: 'default_language')
  String? get defaultLanguage;
  @override
  @JsonKey(name: 'default_min_speakers')
  int? get defaultMinSpeakers;
  @override
  @JsonKey(name: 'default_max_speakers')
  int? get defaultMaxSpeakers;

  /// Create a copy of Tag
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TagImplCopyWith<_$TagImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Speaker _$SpeakerFromJson(Map<String, dynamic> json) {
  return _Speaker.fromJson(json);
}

/// @nodoc
mixin _$Speaker {
  int get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'has_voice_profile')
  bool get hasVoiceProfile => throw _privateConstructorUsedError;
  @JsonKey(name: 'use_count')
  int get useCount => throw _privateConstructorUsedError;

  /// Serializes this Speaker to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Speaker
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SpeakerCopyWith<Speaker> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SpeakerCopyWith<$Res> {
  factory $SpeakerCopyWith(Speaker value, $Res Function(Speaker) then) =
      _$SpeakerCopyWithImpl<$Res, Speaker>;
  @useResult
  $Res call({
    int id,
    String name,
    @JsonKey(name: 'has_voice_profile') bool hasVoiceProfile,
    @JsonKey(name: 'use_count') int useCount,
  });
}

/// @nodoc
class _$SpeakerCopyWithImpl<$Res, $Val extends Speaker>
    implements $SpeakerCopyWith<$Res> {
  _$SpeakerCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Speaker
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? hasVoiceProfile = null,
    Object? useCount = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            hasVoiceProfile: null == hasVoiceProfile
                ? _value.hasVoiceProfile
                : hasVoiceProfile // ignore: cast_nullable_to_non_nullable
                      as bool,
            useCount: null == useCount
                ? _value.useCount
                : useCount // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SpeakerImplCopyWith<$Res> implements $SpeakerCopyWith<$Res> {
  factory _$$SpeakerImplCopyWith(
    _$SpeakerImpl value,
    $Res Function(_$SpeakerImpl) then,
  ) = __$$SpeakerImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    String name,
    @JsonKey(name: 'has_voice_profile') bool hasVoiceProfile,
    @JsonKey(name: 'use_count') int useCount,
  });
}

/// @nodoc
class __$$SpeakerImplCopyWithImpl<$Res>
    extends _$SpeakerCopyWithImpl<$Res, _$SpeakerImpl>
    implements _$$SpeakerImplCopyWith<$Res> {
  __$$SpeakerImplCopyWithImpl(
    _$SpeakerImpl _value,
    $Res Function(_$SpeakerImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Speaker
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? hasVoiceProfile = null,
    Object? useCount = null,
  }) {
    return _then(
      _$SpeakerImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        hasVoiceProfile: null == hasVoiceProfile
            ? _value.hasVoiceProfile
            : hasVoiceProfile // ignore: cast_nullable_to_non_nullable
                  as bool,
        useCount: null == useCount
            ? _value.useCount
            : useCount // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SpeakerImpl implements _Speaker {
  const _$SpeakerImpl({
    required this.id,
    required this.name,
    @JsonKey(name: 'has_voice_profile') this.hasVoiceProfile = false,
    @JsonKey(name: 'use_count') this.useCount = 0,
  });

  factory _$SpeakerImpl.fromJson(Map<String, dynamic> json) =>
      _$$SpeakerImplFromJson(json);

  @override
  final int id;
  @override
  final String name;
  @override
  @JsonKey(name: 'has_voice_profile')
  final bool hasVoiceProfile;
  @override
  @JsonKey(name: 'use_count')
  final int useCount;

  @override
  String toString() {
    return 'Speaker(id: $id, name: $name, hasVoiceProfile: $hasVoiceProfile, useCount: $useCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SpeakerImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.hasVoiceProfile, hasVoiceProfile) ||
                other.hasVoiceProfile == hasVoiceProfile) &&
            (identical(other.useCount, useCount) ||
                other.useCount == useCount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, name, hasVoiceProfile, useCount);

  /// Create a copy of Speaker
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SpeakerImplCopyWith<_$SpeakerImpl> get copyWith =>
      __$$SpeakerImplCopyWithImpl<_$SpeakerImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SpeakerImplToJson(this);
  }
}

abstract class _Speaker implements Speaker {
  const factory _Speaker({
    required final int id,
    required final String name,
    @JsonKey(name: 'has_voice_profile') final bool hasVoiceProfile,
    @JsonKey(name: 'use_count') final int useCount,
  }) = _$SpeakerImpl;

  factory _Speaker.fromJson(Map<String, dynamic> json) = _$SpeakerImpl.fromJson;

  @override
  int get id;
  @override
  String get name;
  @override
  @JsonKey(name: 'has_voice_profile')
  bool get hasVoiceProfile;
  @override
  @JsonKey(name: 'use_count')
  int get useCount;

  /// Create a copy of Speaker
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SpeakerImplCopyWith<_$SpeakerImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Recording _$RecordingFromJson(Map<String, dynamic> json) {
  return _Recording.fromJson(json);
}

/// @nodoc
mixin _$Recording {
  int get id => throw _privateConstructorUsedError;
  String? get title => throw _privateConstructorUsedError;
  @JsonKey(name: 'meeting_date', fromJson: _parseFlexibleDate)
  DateTime? get meetingDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at', fromJson: _parseFlexibleDate)
  DateTime? get createdAt => throw _privateConstructorUsedError;
  String? get participants => throw _privateConstructorUsedError;
  @JsonKey(name: 'file_size')
  int? get fileSize => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_highlighted')
  bool get isHighlighted => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_inbox')
  bool get isInbox => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _parseRecordingStatus)
  RecordingStatus get status => throw _privateConstructorUsedError;
  List<Tag> get tags =>
      throw _privateConstructorUsedError; // Returned by the v1 list endpoint.
  @JsonKey(name: 'audio_available')
  bool? get audioAvailable => throw _privateConstructorUsedError;
  @JsonKey(name: 'error_message')
  String? get errorMessage => throw _privateConstructorUsedError;
  @JsonKey(name: 'has_summary')
  bool? get hasSummary => throw _privateConstructorUsedError;
  @JsonKey(name: 'has_transcription')
  bool? get hasTranscription => throw _privateConstructorUsedError;
  @JsonKey(name: 'original_filename')
  String? get originalFilename => throw _privateConstructorUsedError; // Optional rich fields returned by the unofficial /api/recordings/{id}.
  String? get summary => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  String? get transcription => throw _privateConstructorUsedError;
  @JsonKey(name: 'audio_duration')
  double? get audioDuration => throw _privateConstructorUsedError;

  /// Serializes this Recording to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Recording
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RecordingCopyWith<Recording> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RecordingCopyWith<$Res> {
  factory $RecordingCopyWith(Recording value, $Res Function(Recording) then) =
      _$RecordingCopyWithImpl<$Res, Recording>;
  @useResult
  $Res call({
    int id,
    String? title,
    @JsonKey(name: 'meeting_date', fromJson: _parseFlexibleDate)
    DateTime? meetingDate,
    @JsonKey(name: 'created_at', fromJson: _parseFlexibleDate)
    DateTime? createdAt,
    String? participants,
    @JsonKey(name: 'file_size') int? fileSize,
    @JsonKey(name: 'is_highlighted') bool isHighlighted,
    @JsonKey(name: 'is_inbox') bool isInbox,
    @JsonKey(fromJson: _parseRecordingStatus) RecordingStatus status,
    List<Tag> tags,
    @JsonKey(name: 'audio_available') bool? audioAvailable,
    @JsonKey(name: 'error_message') String? errorMessage,
    @JsonKey(name: 'has_summary') bool? hasSummary,
    @JsonKey(name: 'has_transcription') bool? hasTranscription,
    @JsonKey(name: 'original_filename') String? originalFilename,
    String? summary,
    String? notes,
    String? transcription,
    @JsonKey(name: 'audio_duration') double? audioDuration,
  });
}

/// @nodoc
class _$RecordingCopyWithImpl<$Res, $Val extends Recording>
    implements $RecordingCopyWith<$Res> {
  _$RecordingCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Recording
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = freezed,
    Object? meetingDate = freezed,
    Object? createdAt = freezed,
    Object? participants = freezed,
    Object? fileSize = freezed,
    Object? isHighlighted = null,
    Object? isInbox = null,
    Object? status = null,
    Object? tags = null,
    Object? audioAvailable = freezed,
    Object? errorMessage = freezed,
    Object? hasSummary = freezed,
    Object? hasTranscription = freezed,
    Object? originalFilename = freezed,
    Object? summary = freezed,
    Object? notes = freezed,
    Object? transcription = freezed,
    Object? audioDuration = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            title: freezed == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String?,
            meetingDate: freezed == meetingDate
                ? _value.meetingDate
                : meetingDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            participants: freezed == participants
                ? _value.participants
                : participants // ignore: cast_nullable_to_non_nullable
                      as String?,
            fileSize: freezed == fileSize
                ? _value.fileSize
                : fileSize // ignore: cast_nullable_to_non_nullable
                      as int?,
            isHighlighted: null == isHighlighted
                ? _value.isHighlighted
                : isHighlighted // ignore: cast_nullable_to_non_nullable
                      as bool,
            isInbox: null == isInbox
                ? _value.isInbox
                : isInbox // ignore: cast_nullable_to_non_nullable
                      as bool,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as RecordingStatus,
            tags: null == tags
                ? _value.tags
                : tags // ignore: cast_nullable_to_non_nullable
                      as List<Tag>,
            audioAvailable: freezed == audioAvailable
                ? _value.audioAvailable
                : audioAvailable // ignore: cast_nullable_to_non_nullable
                      as bool?,
            errorMessage: freezed == errorMessage
                ? _value.errorMessage
                : errorMessage // ignore: cast_nullable_to_non_nullable
                      as String?,
            hasSummary: freezed == hasSummary
                ? _value.hasSummary
                : hasSummary // ignore: cast_nullable_to_non_nullable
                      as bool?,
            hasTranscription: freezed == hasTranscription
                ? _value.hasTranscription
                : hasTranscription // ignore: cast_nullable_to_non_nullable
                      as bool?,
            originalFilename: freezed == originalFilename
                ? _value.originalFilename
                : originalFilename // ignore: cast_nullable_to_non_nullable
                      as String?,
            summary: freezed == summary
                ? _value.summary
                : summary // ignore: cast_nullable_to_non_nullable
                      as String?,
            notes: freezed == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                      as String?,
            transcription: freezed == transcription
                ? _value.transcription
                : transcription // ignore: cast_nullable_to_non_nullable
                      as String?,
            audioDuration: freezed == audioDuration
                ? _value.audioDuration
                : audioDuration // ignore: cast_nullable_to_non_nullable
                      as double?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$RecordingImplCopyWith<$Res>
    implements $RecordingCopyWith<$Res> {
  factory _$$RecordingImplCopyWith(
    _$RecordingImpl value,
    $Res Function(_$RecordingImpl) then,
  ) = __$$RecordingImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    String? title,
    @JsonKey(name: 'meeting_date', fromJson: _parseFlexibleDate)
    DateTime? meetingDate,
    @JsonKey(name: 'created_at', fromJson: _parseFlexibleDate)
    DateTime? createdAt,
    String? participants,
    @JsonKey(name: 'file_size') int? fileSize,
    @JsonKey(name: 'is_highlighted') bool isHighlighted,
    @JsonKey(name: 'is_inbox') bool isInbox,
    @JsonKey(fromJson: _parseRecordingStatus) RecordingStatus status,
    List<Tag> tags,
    @JsonKey(name: 'audio_available') bool? audioAvailable,
    @JsonKey(name: 'error_message') String? errorMessage,
    @JsonKey(name: 'has_summary') bool? hasSummary,
    @JsonKey(name: 'has_transcription') bool? hasTranscription,
    @JsonKey(name: 'original_filename') String? originalFilename,
    String? summary,
    String? notes,
    String? transcription,
    @JsonKey(name: 'audio_duration') double? audioDuration,
  });
}

/// @nodoc
class __$$RecordingImplCopyWithImpl<$Res>
    extends _$RecordingCopyWithImpl<$Res, _$RecordingImpl>
    implements _$$RecordingImplCopyWith<$Res> {
  __$$RecordingImplCopyWithImpl(
    _$RecordingImpl _value,
    $Res Function(_$RecordingImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Recording
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = freezed,
    Object? meetingDate = freezed,
    Object? createdAt = freezed,
    Object? participants = freezed,
    Object? fileSize = freezed,
    Object? isHighlighted = null,
    Object? isInbox = null,
    Object? status = null,
    Object? tags = null,
    Object? audioAvailable = freezed,
    Object? errorMessage = freezed,
    Object? hasSummary = freezed,
    Object? hasTranscription = freezed,
    Object? originalFilename = freezed,
    Object? summary = freezed,
    Object? notes = freezed,
    Object? transcription = freezed,
    Object? audioDuration = freezed,
  }) {
    return _then(
      _$RecordingImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        title: freezed == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String?,
        meetingDate: freezed == meetingDate
            ? _value.meetingDate
            : meetingDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        participants: freezed == participants
            ? _value.participants
            : participants // ignore: cast_nullable_to_non_nullable
                  as String?,
        fileSize: freezed == fileSize
            ? _value.fileSize
            : fileSize // ignore: cast_nullable_to_non_nullable
                  as int?,
        isHighlighted: null == isHighlighted
            ? _value.isHighlighted
            : isHighlighted // ignore: cast_nullable_to_non_nullable
                  as bool,
        isInbox: null == isInbox
            ? _value.isInbox
            : isInbox // ignore: cast_nullable_to_non_nullable
                  as bool,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as RecordingStatus,
        tags: null == tags
            ? _value._tags
            : tags // ignore: cast_nullable_to_non_nullable
                  as List<Tag>,
        audioAvailable: freezed == audioAvailable
            ? _value.audioAvailable
            : audioAvailable // ignore: cast_nullable_to_non_nullable
                  as bool?,
        errorMessage: freezed == errorMessage
            ? _value.errorMessage
            : errorMessage // ignore: cast_nullable_to_non_nullable
                  as String?,
        hasSummary: freezed == hasSummary
            ? _value.hasSummary
            : hasSummary // ignore: cast_nullable_to_non_nullable
                  as bool?,
        hasTranscription: freezed == hasTranscription
            ? _value.hasTranscription
            : hasTranscription // ignore: cast_nullable_to_non_nullable
                  as bool?,
        originalFilename: freezed == originalFilename
            ? _value.originalFilename
            : originalFilename // ignore: cast_nullable_to_non_nullable
                  as String?,
        summary: freezed == summary
            ? _value.summary
            : summary // ignore: cast_nullable_to_non_nullable
                  as String?,
        notes: freezed == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as String?,
        transcription: freezed == transcription
            ? _value.transcription
            : transcription // ignore: cast_nullable_to_non_nullable
                  as String?,
        audioDuration: freezed == audioDuration
            ? _value.audioDuration
            : audioDuration // ignore: cast_nullable_to_non_nullable
                  as double?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$RecordingImpl implements _Recording {
  const _$RecordingImpl({
    required this.id,
    this.title,
    @JsonKey(name: 'meeting_date', fromJson: _parseFlexibleDate)
    this.meetingDate,
    @JsonKey(name: 'created_at', fromJson: _parseFlexibleDate) this.createdAt,
    this.participants,
    @JsonKey(name: 'file_size') this.fileSize,
    @JsonKey(name: 'is_highlighted') this.isHighlighted = false,
    @JsonKey(name: 'is_inbox') this.isInbox = false,
    @JsonKey(fromJson: _parseRecordingStatus)
    this.status = RecordingStatus.completed,
    final List<Tag> tags = const <Tag>[],
    @JsonKey(name: 'audio_available') this.audioAvailable,
    @JsonKey(name: 'error_message') this.errorMessage,
    @JsonKey(name: 'has_summary') this.hasSummary,
    @JsonKey(name: 'has_transcription') this.hasTranscription,
    @JsonKey(name: 'original_filename') this.originalFilename,
    this.summary,
    this.notes,
    this.transcription,
    @JsonKey(name: 'audio_duration') this.audioDuration,
  }) : _tags = tags;

  factory _$RecordingImpl.fromJson(Map<String, dynamic> json) =>
      _$$RecordingImplFromJson(json);

  @override
  final int id;
  @override
  final String? title;
  @override
  @JsonKey(name: 'meeting_date', fromJson: _parseFlexibleDate)
  final DateTime? meetingDate;
  @override
  @JsonKey(name: 'created_at', fromJson: _parseFlexibleDate)
  final DateTime? createdAt;
  @override
  final String? participants;
  @override
  @JsonKey(name: 'file_size')
  final int? fileSize;
  @override
  @JsonKey(name: 'is_highlighted')
  final bool isHighlighted;
  @override
  @JsonKey(name: 'is_inbox')
  final bool isInbox;
  @override
  @JsonKey(fromJson: _parseRecordingStatus)
  final RecordingStatus status;
  final List<Tag> _tags;
  @override
  @JsonKey()
  List<Tag> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  // Returned by the v1 list endpoint.
  @override
  @JsonKey(name: 'audio_available')
  final bool? audioAvailable;
  @override
  @JsonKey(name: 'error_message')
  final String? errorMessage;
  @override
  @JsonKey(name: 'has_summary')
  final bool? hasSummary;
  @override
  @JsonKey(name: 'has_transcription')
  final bool? hasTranscription;
  @override
  @JsonKey(name: 'original_filename')
  final String? originalFilename;
  // Optional rich fields returned by the unofficial /api/recordings/{id}.
  @override
  final String? summary;
  @override
  final String? notes;
  @override
  final String? transcription;
  @override
  @JsonKey(name: 'audio_duration')
  final double? audioDuration;

  @override
  String toString() {
    return 'Recording(id: $id, title: $title, meetingDate: $meetingDate, createdAt: $createdAt, participants: $participants, fileSize: $fileSize, isHighlighted: $isHighlighted, isInbox: $isInbox, status: $status, tags: $tags, audioAvailable: $audioAvailable, errorMessage: $errorMessage, hasSummary: $hasSummary, hasTranscription: $hasTranscription, originalFilename: $originalFilename, summary: $summary, notes: $notes, transcription: $transcription, audioDuration: $audioDuration)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RecordingImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.meetingDate, meetingDate) ||
                other.meetingDate == meetingDate) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.participants, participants) ||
                other.participants == participants) &&
            (identical(other.fileSize, fileSize) ||
                other.fileSize == fileSize) &&
            (identical(other.isHighlighted, isHighlighted) ||
                other.isHighlighted == isHighlighted) &&
            (identical(other.isInbox, isInbox) || other.isInbox == isInbox) &&
            (identical(other.status, status) || other.status == status) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.audioAvailable, audioAvailable) ||
                other.audioAvailable == audioAvailable) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage) &&
            (identical(other.hasSummary, hasSummary) ||
                other.hasSummary == hasSummary) &&
            (identical(other.hasTranscription, hasTranscription) ||
                other.hasTranscription == hasTranscription) &&
            (identical(other.originalFilename, originalFilename) ||
                other.originalFilename == originalFilename) &&
            (identical(other.summary, summary) || other.summary == summary) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.transcription, transcription) ||
                other.transcription == transcription) &&
            (identical(other.audioDuration, audioDuration) ||
                other.audioDuration == audioDuration));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    id,
    title,
    meetingDate,
    createdAt,
    participants,
    fileSize,
    isHighlighted,
    isInbox,
    status,
    const DeepCollectionEquality().hash(_tags),
    audioAvailable,
    errorMessage,
    hasSummary,
    hasTranscription,
    originalFilename,
    summary,
    notes,
    transcription,
    audioDuration,
  ]);

  /// Create a copy of Recording
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RecordingImplCopyWith<_$RecordingImpl> get copyWith =>
      __$$RecordingImplCopyWithImpl<_$RecordingImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RecordingImplToJson(this);
  }
}

abstract class _Recording implements Recording {
  const factory _Recording({
    required final int id,
    final String? title,
    @JsonKey(name: 'meeting_date', fromJson: _parseFlexibleDate)
    final DateTime? meetingDate,
    @JsonKey(name: 'created_at', fromJson: _parseFlexibleDate)
    final DateTime? createdAt,
    final String? participants,
    @JsonKey(name: 'file_size') final int? fileSize,
    @JsonKey(name: 'is_highlighted') final bool isHighlighted,
    @JsonKey(name: 'is_inbox') final bool isInbox,
    @JsonKey(fromJson: _parseRecordingStatus) final RecordingStatus status,
    final List<Tag> tags,
    @JsonKey(name: 'audio_available') final bool? audioAvailable,
    @JsonKey(name: 'error_message') final String? errorMessage,
    @JsonKey(name: 'has_summary') final bool? hasSummary,
    @JsonKey(name: 'has_transcription') final bool? hasTranscription,
    @JsonKey(name: 'original_filename') final String? originalFilename,
    final String? summary,
    final String? notes,
    final String? transcription,
    @JsonKey(name: 'audio_duration') final double? audioDuration,
  }) = _$RecordingImpl;

  factory _Recording.fromJson(Map<String, dynamic> json) =
      _$RecordingImpl.fromJson;

  @override
  int get id;
  @override
  String? get title;
  @override
  @JsonKey(name: 'meeting_date', fromJson: _parseFlexibleDate)
  DateTime? get meetingDate;
  @override
  @JsonKey(name: 'created_at', fromJson: _parseFlexibleDate)
  DateTime? get createdAt;
  @override
  String? get participants;
  @override
  @JsonKey(name: 'file_size')
  int? get fileSize;
  @override
  @JsonKey(name: 'is_highlighted')
  bool get isHighlighted;
  @override
  @JsonKey(name: 'is_inbox')
  bool get isInbox;
  @override
  @JsonKey(fromJson: _parseRecordingStatus)
  RecordingStatus get status;
  @override
  List<Tag> get tags; // Returned by the v1 list endpoint.
  @override
  @JsonKey(name: 'audio_available')
  bool? get audioAvailable;
  @override
  @JsonKey(name: 'error_message')
  String? get errorMessage;
  @override
  @JsonKey(name: 'has_summary')
  bool? get hasSummary;
  @override
  @JsonKey(name: 'has_transcription')
  bool? get hasTranscription;
  @override
  @JsonKey(name: 'original_filename')
  String? get originalFilename; // Optional rich fields returned by the unofficial /api/recordings/{id}.
  @override
  String? get summary;
  @override
  String? get notes;
  @override
  String? get transcription;
  @override
  @JsonKey(name: 'audio_duration')
  double? get audioDuration;

  /// Create a copy of Recording
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RecordingImplCopyWith<_$RecordingImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

RecordingPage _$RecordingPageFromJson(Map<String, dynamic> json) {
  return _RecordingPage.fromJson(json);
}

/// @nodoc
mixin _$RecordingPage {
  List<Recording> get recordings => throw _privateConstructorUsedError;
  int get page => throw _privateConstructorUsedError;
  @JsonKey(name: 'per_page')
  int get perPage => throw _privateConstructorUsedError;
  int get total => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_pages')
  int get totalPages => throw _privateConstructorUsedError;

  /// Serializes this RecordingPage to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RecordingPage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RecordingPageCopyWith<RecordingPage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RecordingPageCopyWith<$Res> {
  factory $RecordingPageCopyWith(
    RecordingPage value,
    $Res Function(RecordingPage) then,
  ) = _$RecordingPageCopyWithImpl<$Res, RecordingPage>;
  @useResult
  $Res call({
    List<Recording> recordings,
    int page,
    @JsonKey(name: 'per_page') int perPage,
    int total,
    @JsonKey(name: 'total_pages') int totalPages,
  });
}

/// @nodoc
class _$RecordingPageCopyWithImpl<$Res, $Val extends RecordingPage>
    implements $RecordingPageCopyWith<$Res> {
  _$RecordingPageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RecordingPage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? recordings = null,
    Object? page = null,
    Object? perPage = null,
    Object? total = null,
    Object? totalPages = null,
  }) {
    return _then(
      _value.copyWith(
            recordings: null == recordings
                ? _value.recordings
                : recordings // ignore: cast_nullable_to_non_nullable
                      as List<Recording>,
            page: null == page
                ? _value.page
                : page // ignore: cast_nullable_to_non_nullable
                      as int,
            perPage: null == perPage
                ? _value.perPage
                : perPage // ignore: cast_nullable_to_non_nullable
                      as int,
            total: null == total
                ? _value.total
                : total // ignore: cast_nullable_to_non_nullable
                      as int,
            totalPages: null == totalPages
                ? _value.totalPages
                : totalPages // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$RecordingPageImplCopyWith<$Res>
    implements $RecordingPageCopyWith<$Res> {
  factory _$$RecordingPageImplCopyWith(
    _$RecordingPageImpl value,
    $Res Function(_$RecordingPageImpl) then,
  ) = __$$RecordingPageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<Recording> recordings,
    int page,
    @JsonKey(name: 'per_page') int perPage,
    int total,
    @JsonKey(name: 'total_pages') int totalPages,
  });
}

/// @nodoc
class __$$RecordingPageImplCopyWithImpl<$Res>
    extends _$RecordingPageCopyWithImpl<$Res, _$RecordingPageImpl>
    implements _$$RecordingPageImplCopyWith<$Res> {
  __$$RecordingPageImplCopyWithImpl(
    _$RecordingPageImpl _value,
    $Res Function(_$RecordingPageImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RecordingPage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? recordings = null,
    Object? page = null,
    Object? perPage = null,
    Object? total = null,
    Object? totalPages = null,
  }) {
    return _then(
      _$RecordingPageImpl(
        recordings: null == recordings
            ? _value._recordings
            : recordings // ignore: cast_nullable_to_non_nullable
                  as List<Recording>,
        page: null == page
            ? _value.page
            : page // ignore: cast_nullable_to_non_nullable
                  as int,
        perPage: null == perPage
            ? _value.perPage
            : perPage // ignore: cast_nullable_to_non_nullable
                  as int,
        total: null == total
            ? _value.total
            : total // ignore: cast_nullable_to_non_nullable
                  as int,
        totalPages: null == totalPages
            ? _value.totalPages
            : totalPages // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$RecordingPageImpl implements _RecordingPage {
  const _$RecordingPageImpl({
    final List<Recording> recordings = const <Recording>[],
    this.page = 1,
    @JsonKey(name: 'per_page') this.perPage = 25,
    this.total = 0,
    @JsonKey(name: 'total_pages') this.totalPages = 1,
  }) : _recordings = recordings;

  factory _$RecordingPageImpl.fromJson(Map<String, dynamic> json) =>
      _$$RecordingPageImplFromJson(json);

  final List<Recording> _recordings;
  @override
  @JsonKey()
  List<Recording> get recordings {
    if (_recordings is EqualUnmodifiableListView) return _recordings;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_recordings);
  }

  @override
  @JsonKey()
  final int page;
  @override
  @JsonKey(name: 'per_page')
  final int perPage;
  @override
  @JsonKey()
  final int total;
  @override
  @JsonKey(name: 'total_pages')
  final int totalPages;

  @override
  String toString() {
    return 'RecordingPage(recordings: $recordings, page: $page, perPage: $perPage, total: $total, totalPages: $totalPages)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RecordingPageImpl &&
            const DeepCollectionEquality().equals(
              other._recordings,
              _recordings,
            ) &&
            (identical(other.page, page) || other.page == page) &&
            (identical(other.perPage, perPage) || other.perPage == perPage) &&
            (identical(other.total, total) || other.total == total) &&
            (identical(other.totalPages, totalPages) ||
                other.totalPages == totalPages));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_recordings),
    page,
    perPage,
    total,
    totalPages,
  );

  /// Create a copy of RecordingPage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RecordingPageImplCopyWith<_$RecordingPageImpl> get copyWith =>
      __$$RecordingPageImplCopyWithImpl<_$RecordingPageImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RecordingPageImplToJson(this);
  }
}

abstract class _RecordingPage implements RecordingPage {
  const factory _RecordingPage({
    final List<Recording> recordings,
    final int page,
    @JsonKey(name: 'per_page') final int perPage,
    final int total,
    @JsonKey(name: 'total_pages') final int totalPages,
  }) = _$RecordingPageImpl;

  factory _RecordingPage.fromJson(Map<String, dynamic> json) =
      _$RecordingPageImpl.fromJson;

  @override
  List<Recording> get recordings;
  @override
  int get page;
  @override
  @JsonKey(name: 'per_page')
  int get perPage;
  @override
  int get total;
  @override
  @JsonKey(name: 'total_pages')
  int get totalPages;

  /// Create a copy of RecordingPage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RecordingPageImplCopyWith<_$RecordingPageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TranscriptSegment _$TranscriptSegmentFromJson(Map<String, dynamic> json) {
  return _TranscriptSegment.fromJson(json);
}

/// @nodoc
mixin _$TranscriptSegment {
  String? get speaker => throw _privateConstructorUsedError;
  @JsonKey(name: 'start_time')
  double? get startTime => throw _privateConstructorUsedError;
  @JsonKey(name: 'end_time')
  double? get endTime => throw _privateConstructorUsedError;
  String? get sentence => throw _privateConstructorUsedError;

  /// Serializes this TranscriptSegment to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TranscriptSegment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TranscriptSegmentCopyWith<TranscriptSegment> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TranscriptSegmentCopyWith<$Res> {
  factory $TranscriptSegmentCopyWith(
    TranscriptSegment value,
    $Res Function(TranscriptSegment) then,
  ) = _$TranscriptSegmentCopyWithImpl<$Res, TranscriptSegment>;
  @useResult
  $Res call({
    String? speaker,
    @JsonKey(name: 'start_time') double? startTime,
    @JsonKey(name: 'end_time') double? endTime,
    String? sentence,
  });
}

/// @nodoc
class _$TranscriptSegmentCopyWithImpl<$Res, $Val extends TranscriptSegment>
    implements $TranscriptSegmentCopyWith<$Res> {
  _$TranscriptSegmentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TranscriptSegment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? speaker = freezed,
    Object? startTime = freezed,
    Object? endTime = freezed,
    Object? sentence = freezed,
  }) {
    return _then(
      _value.copyWith(
            speaker: freezed == speaker
                ? _value.speaker
                : speaker // ignore: cast_nullable_to_non_nullable
                      as String?,
            startTime: freezed == startTime
                ? _value.startTime
                : startTime // ignore: cast_nullable_to_non_nullable
                      as double?,
            endTime: freezed == endTime
                ? _value.endTime
                : endTime // ignore: cast_nullable_to_non_nullable
                      as double?,
            sentence: freezed == sentence
                ? _value.sentence
                : sentence // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TranscriptSegmentImplCopyWith<$Res>
    implements $TranscriptSegmentCopyWith<$Res> {
  factory _$$TranscriptSegmentImplCopyWith(
    _$TranscriptSegmentImpl value,
    $Res Function(_$TranscriptSegmentImpl) then,
  ) = __$$TranscriptSegmentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String? speaker,
    @JsonKey(name: 'start_time') double? startTime,
    @JsonKey(name: 'end_time') double? endTime,
    String? sentence,
  });
}

/// @nodoc
class __$$TranscriptSegmentImplCopyWithImpl<$Res>
    extends _$TranscriptSegmentCopyWithImpl<$Res, _$TranscriptSegmentImpl>
    implements _$$TranscriptSegmentImplCopyWith<$Res> {
  __$$TranscriptSegmentImplCopyWithImpl(
    _$TranscriptSegmentImpl _value,
    $Res Function(_$TranscriptSegmentImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TranscriptSegment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? speaker = freezed,
    Object? startTime = freezed,
    Object? endTime = freezed,
    Object? sentence = freezed,
  }) {
    return _then(
      _$TranscriptSegmentImpl(
        speaker: freezed == speaker
            ? _value.speaker
            : speaker // ignore: cast_nullable_to_non_nullable
                  as String?,
        startTime: freezed == startTime
            ? _value.startTime
            : startTime // ignore: cast_nullable_to_non_nullable
                  as double?,
        endTime: freezed == endTime
            ? _value.endTime
            : endTime // ignore: cast_nullable_to_non_nullable
                  as double?,
        sentence: freezed == sentence
            ? _value.sentence
            : sentence // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TranscriptSegmentImpl implements _TranscriptSegment {
  const _$TranscriptSegmentImpl({
    this.speaker,
    @JsonKey(name: 'start_time') this.startTime,
    @JsonKey(name: 'end_time') this.endTime,
    this.sentence,
  });

  factory _$TranscriptSegmentImpl.fromJson(Map<String, dynamic> json) =>
      _$$TranscriptSegmentImplFromJson(json);

  @override
  final String? speaker;
  @override
  @JsonKey(name: 'start_time')
  final double? startTime;
  @override
  @JsonKey(name: 'end_time')
  final double? endTime;
  @override
  final String? sentence;

  @override
  String toString() {
    return 'TranscriptSegment(speaker: $speaker, startTime: $startTime, endTime: $endTime, sentence: $sentence)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TranscriptSegmentImpl &&
            (identical(other.speaker, speaker) || other.speaker == speaker) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.endTime, endTime) || other.endTime == endTime) &&
            (identical(other.sentence, sentence) ||
                other.sentence == sentence));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, speaker, startTime, endTime, sentence);

  /// Create a copy of TranscriptSegment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TranscriptSegmentImplCopyWith<_$TranscriptSegmentImpl> get copyWith =>
      __$$TranscriptSegmentImplCopyWithImpl<_$TranscriptSegmentImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$TranscriptSegmentImplToJson(this);
  }
}

abstract class _TranscriptSegment implements TranscriptSegment {
  const factory _TranscriptSegment({
    final String? speaker,
    @JsonKey(name: 'start_time') final double? startTime,
    @JsonKey(name: 'end_time') final double? endTime,
    final String? sentence,
  }) = _$TranscriptSegmentImpl;

  factory _TranscriptSegment.fromJson(Map<String, dynamic> json) =
      _$TranscriptSegmentImpl.fromJson;

  @override
  String? get speaker;
  @override
  @JsonKey(name: 'start_time')
  double? get startTime;
  @override
  @JsonKey(name: 'end_time')
  double? get endTime;
  @override
  String? get sentence;

  /// Create a copy of TranscriptSegment
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TranscriptSegmentImplCopyWith<_$TranscriptSegmentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

RecordingStatusResponse _$RecordingStatusResponseFromJson(
  Map<String, dynamic> json,
) {
  return _RecordingStatusResponse.fromJson(json);
}

/// @nodoc
mixin _$RecordingStatusResponse {
  @JsonKey(fromJson: _parseRecordingStatus)
  RecordingStatus get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'queue_position')
  int? get queuePosition => throw _privateConstructorUsedError;
  String? get message => throw _privateConstructorUsedError;

  /// Serializes this RecordingStatusResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RecordingStatusResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RecordingStatusResponseCopyWith<RecordingStatusResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RecordingStatusResponseCopyWith<$Res> {
  factory $RecordingStatusResponseCopyWith(
    RecordingStatusResponse value,
    $Res Function(RecordingStatusResponse) then,
  ) = _$RecordingStatusResponseCopyWithImpl<$Res, RecordingStatusResponse>;
  @useResult
  $Res call({
    @JsonKey(fromJson: _parseRecordingStatus) RecordingStatus status,
    @JsonKey(name: 'queue_position') int? queuePosition,
    String? message,
  });
}

/// @nodoc
class _$RecordingStatusResponseCopyWithImpl<
  $Res,
  $Val extends RecordingStatusResponse
>
    implements $RecordingStatusResponseCopyWith<$Res> {
  _$RecordingStatusResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RecordingStatusResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? queuePosition = freezed,
    Object? message = freezed,
  }) {
    return _then(
      _value.copyWith(
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as RecordingStatus,
            queuePosition: freezed == queuePosition
                ? _value.queuePosition
                : queuePosition // ignore: cast_nullable_to_non_nullable
                      as int?,
            message: freezed == message
                ? _value.message
                : message // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$RecordingStatusResponseImplCopyWith<$Res>
    implements $RecordingStatusResponseCopyWith<$Res> {
  factory _$$RecordingStatusResponseImplCopyWith(
    _$RecordingStatusResponseImpl value,
    $Res Function(_$RecordingStatusResponseImpl) then,
  ) = __$$RecordingStatusResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(fromJson: _parseRecordingStatus) RecordingStatus status,
    @JsonKey(name: 'queue_position') int? queuePosition,
    String? message,
  });
}

/// @nodoc
class __$$RecordingStatusResponseImplCopyWithImpl<$Res>
    extends
        _$RecordingStatusResponseCopyWithImpl<
          $Res,
          _$RecordingStatusResponseImpl
        >
    implements _$$RecordingStatusResponseImplCopyWith<$Res> {
  __$$RecordingStatusResponseImplCopyWithImpl(
    _$RecordingStatusResponseImpl _value,
    $Res Function(_$RecordingStatusResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RecordingStatusResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? queuePosition = freezed,
    Object? message = freezed,
  }) {
    return _then(
      _$RecordingStatusResponseImpl(
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as RecordingStatus,
        queuePosition: freezed == queuePosition
            ? _value.queuePosition
            : queuePosition // ignore: cast_nullable_to_non_nullable
                  as int?,
        message: freezed == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$RecordingStatusResponseImpl implements _RecordingStatusResponse {
  const _$RecordingStatusResponseImpl({
    @JsonKey(fromJson: _parseRecordingStatus) required this.status,
    @JsonKey(name: 'queue_position') this.queuePosition,
    this.message,
  });

  factory _$RecordingStatusResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$RecordingStatusResponseImplFromJson(json);

  @override
  @JsonKey(fromJson: _parseRecordingStatus)
  final RecordingStatus status;
  @override
  @JsonKey(name: 'queue_position')
  final int? queuePosition;
  @override
  final String? message;

  @override
  String toString() {
    return 'RecordingStatusResponse(status: $status, queuePosition: $queuePosition, message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RecordingStatusResponseImpl &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.queuePosition, queuePosition) ||
                other.queuePosition == queuePosition) &&
            (identical(other.message, message) || other.message == message));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, status, queuePosition, message);

  /// Create a copy of RecordingStatusResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RecordingStatusResponseImplCopyWith<_$RecordingStatusResponseImpl>
  get copyWith =>
      __$$RecordingStatusResponseImplCopyWithImpl<
        _$RecordingStatusResponseImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RecordingStatusResponseImplToJson(this);
  }
}

abstract class _RecordingStatusResponse implements RecordingStatusResponse {
  const factory _RecordingStatusResponse({
    @JsonKey(fromJson: _parseRecordingStatus)
    required final RecordingStatus status,
    @JsonKey(name: 'queue_position') final int? queuePosition,
    final String? message,
  }) = _$RecordingStatusResponseImpl;

  factory _RecordingStatusResponse.fromJson(Map<String, dynamic> json) =
      _$RecordingStatusResponseImpl.fromJson;

  @override
  @JsonKey(fromJson: _parseRecordingStatus)
  RecordingStatus get status;
  @override
  @JsonKey(name: 'queue_position')
  int? get queuePosition;
  @override
  String? get message;

  /// Create a copy of RecordingStatusResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RecordingStatusResponseImplCopyWith<_$RecordingStatusResponseImpl>
  get copyWith => throw _privateConstructorUsedError;
}

ChatMessage _$ChatMessageFromJson(Map<String, dynamic> json) {
  return _ChatMessage.fromJson(json);
}

/// @nodoc
mixin _$ChatMessage {
  String get role => throw _privateConstructorUsedError; // "user" | "assistant"
  String get text => throw _privateConstructorUsedError;

  /// Serializes this ChatMessage to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChatMessageCopyWith<ChatMessage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChatMessageCopyWith<$Res> {
  factory $ChatMessageCopyWith(
    ChatMessage value,
    $Res Function(ChatMessage) then,
  ) = _$ChatMessageCopyWithImpl<$Res, ChatMessage>;
  @useResult
  $Res call({String role, String text});
}

/// @nodoc
class _$ChatMessageCopyWithImpl<$Res, $Val extends ChatMessage>
    implements $ChatMessageCopyWith<$Res> {
  _$ChatMessageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? role = null, Object? text = null}) {
    return _then(
      _value.copyWith(
            role: null == role
                ? _value.role
                : role // ignore: cast_nullable_to_non_nullable
                      as String,
            text: null == text
                ? _value.text
                : text // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ChatMessageImplCopyWith<$Res>
    implements $ChatMessageCopyWith<$Res> {
  factory _$$ChatMessageImplCopyWith(
    _$ChatMessageImpl value,
    $Res Function(_$ChatMessageImpl) then,
  ) = __$$ChatMessageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String role, String text});
}

/// @nodoc
class __$$ChatMessageImplCopyWithImpl<$Res>
    extends _$ChatMessageCopyWithImpl<$Res, _$ChatMessageImpl>
    implements _$$ChatMessageImplCopyWith<$Res> {
  __$$ChatMessageImplCopyWithImpl(
    _$ChatMessageImpl _value,
    $Res Function(_$ChatMessageImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? role = null, Object? text = null}) {
    return _then(
      _$ChatMessageImpl(
        role: null == role
            ? _value.role
            : role // ignore: cast_nullable_to_non_nullable
                  as String,
        text: null == text
            ? _value.text
            : text // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ChatMessageImpl implements _ChatMessage {
  const _$ChatMessageImpl({required this.role, required this.text});

  factory _$ChatMessageImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChatMessageImplFromJson(json);

  @override
  final String role;
  // "user" | "assistant"
  @override
  final String text;

  @override
  String toString() {
    return 'ChatMessage(role: $role, text: $text)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChatMessageImpl &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.text, text) || other.text == text));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, role, text);

  /// Create a copy of ChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChatMessageImplCopyWith<_$ChatMessageImpl> get copyWith =>
      __$$ChatMessageImplCopyWithImpl<_$ChatMessageImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ChatMessageImplToJson(this);
  }
}

abstract class _ChatMessage implements ChatMessage {
  const factory _ChatMessage({
    required final String role,
    required final String text,
  }) = _$ChatMessageImpl;

  factory _ChatMessage.fromJson(Map<String, dynamic> json) =
      _$ChatMessageImpl.fromJson;

  @override
  String get role; // "user" | "assistant"
  @override
  String get text;

  /// Create a copy of ChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChatMessageImplCopyWith<_$ChatMessageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ChatResponse _$ChatResponseFromJson(Map<String, dynamic> json) {
  return _ChatResponse.fromJson(json);
}

/// @nodoc
mixin _$ChatResponse {
  @JsonKey(name: 'response')
  String get response => throw _privateConstructorUsedError;

  /// Serializes this ChatResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ChatResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChatResponseCopyWith<ChatResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChatResponseCopyWith<$Res> {
  factory $ChatResponseCopyWith(
    ChatResponse value,
    $Res Function(ChatResponse) then,
  ) = _$ChatResponseCopyWithImpl<$Res, ChatResponse>;
  @useResult
  $Res call({@JsonKey(name: 'response') String response});
}

/// @nodoc
class _$ChatResponseCopyWithImpl<$Res, $Val extends ChatResponse>
    implements $ChatResponseCopyWith<$Res> {
  _$ChatResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChatResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? response = null}) {
    return _then(
      _value.copyWith(
            response: null == response
                ? _value.response
                : response // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ChatResponseImplCopyWith<$Res>
    implements $ChatResponseCopyWith<$Res> {
  factory _$$ChatResponseImplCopyWith(
    _$ChatResponseImpl value,
    $Res Function(_$ChatResponseImpl) then,
  ) = __$$ChatResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({@JsonKey(name: 'response') String response});
}

/// @nodoc
class __$$ChatResponseImplCopyWithImpl<$Res>
    extends _$ChatResponseCopyWithImpl<$Res, _$ChatResponseImpl>
    implements _$$ChatResponseImplCopyWith<$Res> {
  __$$ChatResponseImplCopyWithImpl(
    _$ChatResponseImpl _value,
    $Res Function(_$ChatResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ChatResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? response = null}) {
    return _then(
      _$ChatResponseImpl(
        response: null == response
            ? _value.response
            : response // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ChatResponseImpl implements _ChatResponse {
  const _$ChatResponseImpl({@JsonKey(name: 'response') required this.response});

  factory _$ChatResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChatResponseImplFromJson(json);

  @override
  @JsonKey(name: 'response')
  final String response;

  @override
  String toString() {
    return 'ChatResponse(response: $response)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChatResponseImpl &&
            (identical(other.response, response) ||
                other.response == response));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, response);

  /// Create a copy of ChatResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChatResponseImplCopyWith<_$ChatResponseImpl> get copyWith =>
      __$$ChatResponseImplCopyWithImpl<_$ChatResponseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ChatResponseImplToJson(this);
  }
}

abstract class _ChatResponse implements ChatResponse {
  const factory _ChatResponse({
    @JsonKey(name: 'response') required final String response,
  }) = _$ChatResponseImpl;

  factory _ChatResponse.fromJson(Map<String, dynamic> json) =
      _$ChatResponseImpl.fromJson;

  @override
  @JsonKey(name: 'response')
  String get response;

  /// Create a copy of ChatResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChatResponseImplCopyWith<_$ChatResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

StatsResponse _$StatsResponseFromJson(Map<String, dynamic> json) {
  return _StatsResponse.fromJson(json);
}

/// @nodoc
mixin _$StatsResponse {
  StatsActivity? get activity => throw _privateConstructorUsedError;
  StatsQueue? get queue => throw _privateConstructorUsedError;
  StatsRecordings? get recordings => throw _privateConstructorUsedError;
  StatsStorage? get storage => throw _privateConstructorUsedError;
  StatsTokens? get tokens => throw _privateConstructorUsedError;
  StatsTranscription? get transcription => throw _privateConstructorUsedError;

  /// Serializes this StatsResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of StatsResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StatsResponseCopyWith<StatsResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StatsResponseCopyWith<$Res> {
  factory $StatsResponseCopyWith(
    StatsResponse value,
    $Res Function(StatsResponse) then,
  ) = _$StatsResponseCopyWithImpl<$Res, StatsResponse>;
  @useResult
  $Res call({
    StatsActivity? activity,
    StatsQueue? queue,
    StatsRecordings? recordings,
    StatsStorage? storage,
    StatsTokens? tokens,
    StatsTranscription? transcription,
  });

  $StatsActivityCopyWith<$Res>? get activity;
  $StatsQueueCopyWith<$Res>? get queue;
  $StatsRecordingsCopyWith<$Res>? get recordings;
  $StatsStorageCopyWith<$Res>? get storage;
  $StatsTokensCopyWith<$Res>? get tokens;
  $StatsTranscriptionCopyWith<$Res>? get transcription;
}

/// @nodoc
class _$StatsResponseCopyWithImpl<$Res, $Val extends StatsResponse>
    implements $StatsResponseCopyWith<$Res> {
  _$StatsResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StatsResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? activity = freezed,
    Object? queue = freezed,
    Object? recordings = freezed,
    Object? storage = freezed,
    Object? tokens = freezed,
    Object? transcription = freezed,
  }) {
    return _then(
      _value.copyWith(
            activity: freezed == activity
                ? _value.activity
                : activity // ignore: cast_nullable_to_non_nullable
                      as StatsActivity?,
            queue: freezed == queue
                ? _value.queue
                : queue // ignore: cast_nullable_to_non_nullable
                      as StatsQueue?,
            recordings: freezed == recordings
                ? _value.recordings
                : recordings // ignore: cast_nullable_to_non_nullable
                      as StatsRecordings?,
            storage: freezed == storage
                ? _value.storage
                : storage // ignore: cast_nullable_to_non_nullable
                      as StatsStorage?,
            tokens: freezed == tokens
                ? _value.tokens
                : tokens // ignore: cast_nullable_to_non_nullable
                      as StatsTokens?,
            transcription: freezed == transcription
                ? _value.transcription
                : transcription // ignore: cast_nullable_to_non_nullable
                      as StatsTranscription?,
          )
          as $Val,
    );
  }

  /// Create a copy of StatsResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $StatsActivityCopyWith<$Res>? get activity {
    if (_value.activity == null) {
      return null;
    }

    return $StatsActivityCopyWith<$Res>(_value.activity!, (value) {
      return _then(_value.copyWith(activity: value) as $Val);
    });
  }

  /// Create a copy of StatsResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $StatsQueueCopyWith<$Res>? get queue {
    if (_value.queue == null) {
      return null;
    }

    return $StatsQueueCopyWith<$Res>(_value.queue!, (value) {
      return _then(_value.copyWith(queue: value) as $Val);
    });
  }

  /// Create a copy of StatsResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $StatsRecordingsCopyWith<$Res>? get recordings {
    if (_value.recordings == null) {
      return null;
    }

    return $StatsRecordingsCopyWith<$Res>(_value.recordings!, (value) {
      return _then(_value.copyWith(recordings: value) as $Val);
    });
  }

  /// Create a copy of StatsResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $StatsStorageCopyWith<$Res>? get storage {
    if (_value.storage == null) {
      return null;
    }

    return $StatsStorageCopyWith<$Res>(_value.storage!, (value) {
      return _then(_value.copyWith(storage: value) as $Val);
    });
  }

  /// Create a copy of StatsResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $StatsTokensCopyWith<$Res>? get tokens {
    if (_value.tokens == null) {
      return null;
    }

    return $StatsTokensCopyWith<$Res>(_value.tokens!, (value) {
      return _then(_value.copyWith(tokens: value) as $Val);
    });
  }

  /// Create a copy of StatsResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $StatsTranscriptionCopyWith<$Res>? get transcription {
    if (_value.transcription == null) {
      return null;
    }

    return $StatsTranscriptionCopyWith<$Res>(_value.transcription!, (value) {
      return _then(_value.copyWith(transcription: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$StatsResponseImplCopyWith<$Res>
    implements $StatsResponseCopyWith<$Res> {
  factory _$$StatsResponseImplCopyWith(
    _$StatsResponseImpl value,
    $Res Function(_$StatsResponseImpl) then,
  ) = __$$StatsResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    StatsActivity? activity,
    StatsQueue? queue,
    StatsRecordings? recordings,
    StatsStorage? storage,
    StatsTokens? tokens,
    StatsTranscription? transcription,
  });

  @override
  $StatsActivityCopyWith<$Res>? get activity;
  @override
  $StatsQueueCopyWith<$Res>? get queue;
  @override
  $StatsRecordingsCopyWith<$Res>? get recordings;
  @override
  $StatsStorageCopyWith<$Res>? get storage;
  @override
  $StatsTokensCopyWith<$Res>? get tokens;
  @override
  $StatsTranscriptionCopyWith<$Res>? get transcription;
}

/// @nodoc
class __$$StatsResponseImplCopyWithImpl<$Res>
    extends _$StatsResponseCopyWithImpl<$Res, _$StatsResponseImpl>
    implements _$$StatsResponseImplCopyWith<$Res> {
  __$$StatsResponseImplCopyWithImpl(
    _$StatsResponseImpl _value,
    $Res Function(_$StatsResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of StatsResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? activity = freezed,
    Object? queue = freezed,
    Object? recordings = freezed,
    Object? storage = freezed,
    Object? tokens = freezed,
    Object? transcription = freezed,
  }) {
    return _then(
      _$StatsResponseImpl(
        activity: freezed == activity
            ? _value.activity
            : activity // ignore: cast_nullable_to_non_nullable
                  as StatsActivity?,
        queue: freezed == queue
            ? _value.queue
            : queue // ignore: cast_nullable_to_non_nullable
                  as StatsQueue?,
        recordings: freezed == recordings
            ? _value.recordings
            : recordings // ignore: cast_nullable_to_non_nullable
                  as StatsRecordings?,
        storage: freezed == storage
            ? _value.storage
            : storage // ignore: cast_nullable_to_non_nullable
                  as StatsStorage?,
        tokens: freezed == tokens
            ? _value.tokens
            : tokens // ignore: cast_nullable_to_non_nullable
                  as StatsTokens?,
        transcription: freezed == transcription
            ? _value.transcription
            : transcription // ignore: cast_nullable_to_non_nullable
                  as StatsTranscription?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$StatsResponseImpl implements _StatsResponse {
  const _$StatsResponseImpl({
    this.activity,
    this.queue,
    this.recordings,
    this.storage,
    this.tokens,
    this.transcription,
  });

  factory _$StatsResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$StatsResponseImplFromJson(json);

  @override
  final StatsActivity? activity;
  @override
  final StatsQueue? queue;
  @override
  final StatsRecordings? recordings;
  @override
  final StatsStorage? storage;
  @override
  final StatsTokens? tokens;
  @override
  final StatsTranscription? transcription;

  @override
  String toString() {
    return 'StatsResponse(activity: $activity, queue: $queue, recordings: $recordings, storage: $storage, tokens: $tokens, transcription: $transcription)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StatsResponseImpl &&
            (identical(other.activity, activity) ||
                other.activity == activity) &&
            (identical(other.queue, queue) || other.queue == queue) &&
            (identical(other.recordings, recordings) ||
                other.recordings == recordings) &&
            (identical(other.storage, storage) || other.storage == storage) &&
            (identical(other.tokens, tokens) || other.tokens == tokens) &&
            (identical(other.transcription, transcription) ||
                other.transcription == transcription));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    activity,
    queue,
    recordings,
    storage,
    tokens,
    transcription,
  );

  /// Create a copy of StatsResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StatsResponseImplCopyWith<_$StatsResponseImpl> get copyWith =>
      __$$StatsResponseImplCopyWithImpl<_$StatsResponseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StatsResponseImplToJson(this);
  }
}

abstract class _StatsResponse implements StatsResponse {
  const factory _StatsResponse({
    final StatsActivity? activity,
    final StatsQueue? queue,
    final StatsRecordings? recordings,
    final StatsStorage? storage,
    final StatsTokens? tokens,
    final StatsTranscription? transcription,
  }) = _$StatsResponseImpl;

  factory _StatsResponse.fromJson(Map<String, dynamic> json) =
      _$StatsResponseImpl.fromJson;

  @override
  StatsActivity? get activity;
  @override
  StatsQueue? get queue;
  @override
  StatsRecordings? get recordings;
  @override
  StatsStorage? get storage;
  @override
  StatsTokens? get tokens;
  @override
  StatsTranscription? get transcription;

  /// Create a copy of StatsResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StatsResponseImplCopyWith<_$StatsResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

StatsActivity _$StatsActivityFromJson(Map<String, dynamic> json) {
  return _StatsActivity.fromJson(json);
}

/// @nodoc
mixin _$StatsActivity {
  @JsonKey(name: 'last_transcription')
  DateTime? get lastTranscription => throw _privateConstructorUsedError;
  @JsonKey(name: 'recordings_today')
  int? get recordingsToday => throw _privateConstructorUsedError;

  /// Serializes this StatsActivity to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of StatsActivity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StatsActivityCopyWith<StatsActivity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StatsActivityCopyWith<$Res> {
  factory $StatsActivityCopyWith(
    StatsActivity value,
    $Res Function(StatsActivity) then,
  ) = _$StatsActivityCopyWithImpl<$Res, StatsActivity>;
  @useResult
  $Res call({
    @JsonKey(name: 'last_transcription') DateTime? lastTranscription,
    @JsonKey(name: 'recordings_today') int? recordingsToday,
  });
}

/// @nodoc
class _$StatsActivityCopyWithImpl<$Res, $Val extends StatsActivity>
    implements $StatsActivityCopyWith<$Res> {
  _$StatsActivityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StatsActivity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? lastTranscription = freezed,
    Object? recordingsToday = freezed,
  }) {
    return _then(
      _value.copyWith(
            lastTranscription: freezed == lastTranscription
                ? _value.lastTranscription
                : lastTranscription // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            recordingsToday: freezed == recordingsToday
                ? _value.recordingsToday
                : recordingsToday // ignore: cast_nullable_to_non_nullable
                      as int?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$StatsActivityImplCopyWith<$Res>
    implements $StatsActivityCopyWith<$Res> {
  factory _$$StatsActivityImplCopyWith(
    _$StatsActivityImpl value,
    $Res Function(_$StatsActivityImpl) then,
  ) = __$$StatsActivityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'last_transcription') DateTime? lastTranscription,
    @JsonKey(name: 'recordings_today') int? recordingsToday,
  });
}

/// @nodoc
class __$$StatsActivityImplCopyWithImpl<$Res>
    extends _$StatsActivityCopyWithImpl<$Res, _$StatsActivityImpl>
    implements _$$StatsActivityImplCopyWith<$Res> {
  __$$StatsActivityImplCopyWithImpl(
    _$StatsActivityImpl _value,
    $Res Function(_$StatsActivityImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of StatsActivity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? lastTranscription = freezed,
    Object? recordingsToday = freezed,
  }) {
    return _then(
      _$StatsActivityImpl(
        lastTranscription: freezed == lastTranscription
            ? _value.lastTranscription
            : lastTranscription // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        recordingsToday: freezed == recordingsToday
            ? _value.recordingsToday
            : recordingsToday // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$StatsActivityImpl implements _StatsActivity {
  const _$StatsActivityImpl({
    @JsonKey(name: 'last_transcription') this.lastTranscription,
    @JsonKey(name: 'recordings_today') this.recordingsToday,
  });

  factory _$StatsActivityImpl.fromJson(Map<String, dynamic> json) =>
      _$$StatsActivityImplFromJson(json);

  @override
  @JsonKey(name: 'last_transcription')
  final DateTime? lastTranscription;
  @override
  @JsonKey(name: 'recordings_today')
  final int? recordingsToday;

  @override
  String toString() {
    return 'StatsActivity(lastTranscription: $lastTranscription, recordingsToday: $recordingsToday)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StatsActivityImpl &&
            (identical(other.lastTranscription, lastTranscription) ||
                other.lastTranscription == lastTranscription) &&
            (identical(other.recordingsToday, recordingsToday) ||
                other.recordingsToday == recordingsToday));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, lastTranscription, recordingsToday);

  /// Create a copy of StatsActivity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StatsActivityImplCopyWith<_$StatsActivityImpl> get copyWith =>
      __$$StatsActivityImplCopyWithImpl<_$StatsActivityImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StatsActivityImplToJson(this);
  }
}

abstract class _StatsActivity implements StatsActivity {
  const factory _StatsActivity({
    @JsonKey(name: 'last_transcription') final DateTime? lastTranscription,
    @JsonKey(name: 'recordings_today') final int? recordingsToday,
  }) = _$StatsActivityImpl;

  factory _StatsActivity.fromJson(Map<String, dynamic> json) =
      _$StatsActivityImpl.fromJson;

  @override
  @JsonKey(name: 'last_transcription')
  DateTime? get lastTranscription;
  @override
  @JsonKey(name: 'recordings_today')
  int? get recordingsToday;

  /// Create a copy of StatsActivity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StatsActivityImplCopyWith<_$StatsActivityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

StatsQueue _$StatsQueueFromJson(Map<String, dynamic> json) {
  return _StatsQueue.fromJson(json);
}

/// @nodoc
mixin _$StatsQueue {
  @JsonKey(name: 'jobs_processing')
  int? get jobsProcessing => throw _privateConstructorUsedError;
  @JsonKey(name: 'jobs_queued')
  int? get jobsQueued => throw _privateConstructorUsedError;

  /// Serializes this StatsQueue to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of StatsQueue
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StatsQueueCopyWith<StatsQueue> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StatsQueueCopyWith<$Res> {
  factory $StatsQueueCopyWith(
    StatsQueue value,
    $Res Function(StatsQueue) then,
  ) = _$StatsQueueCopyWithImpl<$Res, StatsQueue>;
  @useResult
  $Res call({
    @JsonKey(name: 'jobs_processing') int? jobsProcessing,
    @JsonKey(name: 'jobs_queued') int? jobsQueued,
  });
}

/// @nodoc
class _$StatsQueueCopyWithImpl<$Res, $Val extends StatsQueue>
    implements $StatsQueueCopyWith<$Res> {
  _$StatsQueueCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StatsQueue
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? jobsProcessing = freezed, Object? jobsQueued = freezed}) {
    return _then(
      _value.copyWith(
            jobsProcessing: freezed == jobsProcessing
                ? _value.jobsProcessing
                : jobsProcessing // ignore: cast_nullable_to_non_nullable
                      as int?,
            jobsQueued: freezed == jobsQueued
                ? _value.jobsQueued
                : jobsQueued // ignore: cast_nullable_to_non_nullable
                      as int?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$StatsQueueImplCopyWith<$Res>
    implements $StatsQueueCopyWith<$Res> {
  factory _$$StatsQueueImplCopyWith(
    _$StatsQueueImpl value,
    $Res Function(_$StatsQueueImpl) then,
  ) = __$$StatsQueueImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'jobs_processing') int? jobsProcessing,
    @JsonKey(name: 'jobs_queued') int? jobsQueued,
  });
}

/// @nodoc
class __$$StatsQueueImplCopyWithImpl<$Res>
    extends _$StatsQueueCopyWithImpl<$Res, _$StatsQueueImpl>
    implements _$$StatsQueueImplCopyWith<$Res> {
  __$$StatsQueueImplCopyWithImpl(
    _$StatsQueueImpl _value,
    $Res Function(_$StatsQueueImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of StatsQueue
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? jobsProcessing = freezed, Object? jobsQueued = freezed}) {
    return _then(
      _$StatsQueueImpl(
        jobsProcessing: freezed == jobsProcessing
            ? _value.jobsProcessing
            : jobsProcessing // ignore: cast_nullable_to_non_nullable
                  as int?,
        jobsQueued: freezed == jobsQueued
            ? _value.jobsQueued
            : jobsQueued // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$StatsQueueImpl implements _StatsQueue {
  const _$StatsQueueImpl({
    @JsonKey(name: 'jobs_processing') this.jobsProcessing,
    @JsonKey(name: 'jobs_queued') this.jobsQueued,
  });

  factory _$StatsQueueImpl.fromJson(Map<String, dynamic> json) =>
      _$$StatsQueueImplFromJson(json);

  @override
  @JsonKey(name: 'jobs_processing')
  final int? jobsProcessing;
  @override
  @JsonKey(name: 'jobs_queued')
  final int? jobsQueued;

  @override
  String toString() {
    return 'StatsQueue(jobsProcessing: $jobsProcessing, jobsQueued: $jobsQueued)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StatsQueueImpl &&
            (identical(other.jobsProcessing, jobsProcessing) ||
                other.jobsProcessing == jobsProcessing) &&
            (identical(other.jobsQueued, jobsQueued) ||
                other.jobsQueued == jobsQueued));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, jobsProcessing, jobsQueued);

  /// Create a copy of StatsQueue
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StatsQueueImplCopyWith<_$StatsQueueImpl> get copyWith =>
      __$$StatsQueueImplCopyWithImpl<_$StatsQueueImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StatsQueueImplToJson(this);
  }
}

abstract class _StatsQueue implements StatsQueue {
  const factory _StatsQueue({
    @JsonKey(name: 'jobs_processing') final int? jobsProcessing,
    @JsonKey(name: 'jobs_queued') final int? jobsQueued,
  }) = _$StatsQueueImpl;

  factory _StatsQueue.fromJson(Map<String, dynamic> json) =
      _$StatsQueueImpl.fromJson;

  @override
  @JsonKey(name: 'jobs_processing')
  int? get jobsProcessing;
  @override
  @JsonKey(name: 'jobs_queued')
  int? get jobsQueued;

  /// Create a copy of StatsQueue
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StatsQueueImplCopyWith<_$StatsQueueImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

StatsRecordings _$StatsRecordingsFromJson(Map<String, dynamic> json) {
  return _StatsRecordings.fromJson(json);
}

/// @nodoc
mixin _$StatsRecordings {
  int? get completed => throw _privateConstructorUsedError;
  int? get failed => throw _privateConstructorUsedError;
  int? get pending => throw _privateConstructorUsedError;
  int? get processing => throw _privateConstructorUsedError;
  int? get total => throw _privateConstructorUsedError;

  /// Serializes this StatsRecordings to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of StatsRecordings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StatsRecordingsCopyWith<StatsRecordings> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StatsRecordingsCopyWith<$Res> {
  factory $StatsRecordingsCopyWith(
    StatsRecordings value,
    $Res Function(StatsRecordings) then,
  ) = _$StatsRecordingsCopyWithImpl<$Res, StatsRecordings>;
  @useResult
  $Res call({
    int? completed,
    int? failed,
    int? pending,
    int? processing,
    int? total,
  });
}

/// @nodoc
class _$StatsRecordingsCopyWithImpl<$Res, $Val extends StatsRecordings>
    implements $StatsRecordingsCopyWith<$Res> {
  _$StatsRecordingsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StatsRecordings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? completed = freezed,
    Object? failed = freezed,
    Object? pending = freezed,
    Object? processing = freezed,
    Object? total = freezed,
  }) {
    return _then(
      _value.copyWith(
            completed: freezed == completed
                ? _value.completed
                : completed // ignore: cast_nullable_to_non_nullable
                      as int?,
            failed: freezed == failed
                ? _value.failed
                : failed // ignore: cast_nullable_to_non_nullable
                      as int?,
            pending: freezed == pending
                ? _value.pending
                : pending // ignore: cast_nullable_to_non_nullable
                      as int?,
            processing: freezed == processing
                ? _value.processing
                : processing // ignore: cast_nullable_to_non_nullable
                      as int?,
            total: freezed == total
                ? _value.total
                : total // ignore: cast_nullable_to_non_nullable
                      as int?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$StatsRecordingsImplCopyWith<$Res>
    implements $StatsRecordingsCopyWith<$Res> {
  factory _$$StatsRecordingsImplCopyWith(
    _$StatsRecordingsImpl value,
    $Res Function(_$StatsRecordingsImpl) then,
  ) = __$$StatsRecordingsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int? completed,
    int? failed,
    int? pending,
    int? processing,
    int? total,
  });
}

/// @nodoc
class __$$StatsRecordingsImplCopyWithImpl<$Res>
    extends _$StatsRecordingsCopyWithImpl<$Res, _$StatsRecordingsImpl>
    implements _$$StatsRecordingsImplCopyWith<$Res> {
  __$$StatsRecordingsImplCopyWithImpl(
    _$StatsRecordingsImpl _value,
    $Res Function(_$StatsRecordingsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of StatsRecordings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? completed = freezed,
    Object? failed = freezed,
    Object? pending = freezed,
    Object? processing = freezed,
    Object? total = freezed,
  }) {
    return _then(
      _$StatsRecordingsImpl(
        completed: freezed == completed
            ? _value.completed
            : completed // ignore: cast_nullable_to_non_nullable
                  as int?,
        failed: freezed == failed
            ? _value.failed
            : failed // ignore: cast_nullable_to_non_nullable
                  as int?,
        pending: freezed == pending
            ? _value.pending
            : pending // ignore: cast_nullable_to_non_nullable
                  as int?,
        processing: freezed == processing
            ? _value.processing
            : processing // ignore: cast_nullable_to_non_nullable
                  as int?,
        total: freezed == total
            ? _value.total
            : total // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$StatsRecordingsImpl implements _StatsRecordings {
  const _$StatsRecordingsImpl({
    this.completed,
    this.failed,
    this.pending,
    this.processing,
    this.total,
  });

  factory _$StatsRecordingsImpl.fromJson(Map<String, dynamic> json) =>
      _$$StatsRecordingsImplFromJson(json);

  @override
  final int? completed;
  @override
  final int? failed;
  @override
  final int? pending;
  @override
  final int? processing;
  @override
  final int? total;

  @override
  String toString() {
    return 'StatsRecordings(completed: $completed, failed: $failed, pending: $pending, processing: $processing, total: $total)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StatsRecordingsImpl &&
            (identical(other.completed, completed) ||
                other.completed == completed) &&
            (identical(other.failed, failed) || other.failed == failed) &&
            (identical(other.pending, pending) || other.pending == pending) &&
            (identical(other.processing, processing) ||
                other.processing == processing) &&
            (identical(other.total, total) || other.total == total));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, completed, failed, pending, processing, total);

  /// Create a copy of StatsRecordings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StatsRecordingsImplCopyWith<_$StatsRecordingsImpl> get copyWith =>
      __$$StatsRecordingsImplCopyWithImpl<_$StatsRecordingsImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$StatsRecordingsImplToJson(this);
  }
}

abstract class _StatsRecordings implements StatsRecordings {
  const factory _StatsRecordings({
    final int? completed,
    final int? failed,
    final int? pending,
    final int? processing,
    final int? total,
  }) = _$StatsRecordingsImpl;

  factory _StatsRecordings.fromJson(Map<String, dynamic> json) =
      _$StatsRecordingsImpl.fromJson;

  @override
  int? get completed;
  @override
  int? get failed;
  @override
  int? get pending;
  @override
  int? get processing;
  @override
  int? get total;

  /// Create a copy of StatsRecordings
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StatsRecordingsImplCopyWith<_$StatsRecordingsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

StatsStorage _$StatsStorageFromJson(Map<String, dynamic> json) {
  return _StatsStorage.fromJson(json);
}

/// @nodoc
mixin _$StatsStorage {
  @JsonKey(name: 'used_bytes')
  int? get usedBytes => throw _privateConstructorUsedError;
  @JsonKey(name: 'used_human')
  String? get usedHuman => throw _privateConstructorUsedError;

  /// Serializes this StatsStorage to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of StatsStorage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StatsStorageCopyWith<StatsStorage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StatsStorageCopyWith<$Res> {
  factory $StatsStorageCopyWith(
    StatsStorage value,
    $Res Function(StatsStorage) then,
  ) = _$StatsStorageCopyWithImpl<$Res, StatsStorage>;
  @useResult
  $Res call({
    @JsonKey(name: 'used_bytes') int? usedBytes,
    @JsonKey(name: 'used_human') String? usedHuman,
  });
}

/// @nodoc
class _$StatsStorageCopyWithImpl<$Res, $Val extends StatsStorage>
    implements $StatsStorageCopyWith<$Res> {
  _$StatsStorageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StatsStorage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? usedBytes = freezed, Object? usedHuman = freezed}) {
    return _then(
      _value.copyWith(
            usedBytes: freezed == usedBytes
                ? _value.usedBytes
                : usedBytes // ignore: cast_nullable_to_non_nullable
                      as int?,
            usedHuman: freezed == usedHuman
                ? _value.usedHuman
                : usedHuman // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$StatsStorageImplCopyWith<$Res>
    implements $StatsStorageCopyWith<$Res> {
  factory _$$StatsStorageImplCopyWith(
    _$StatsStorageImpl value,
    $Res Function(_$StatsStorageImpl) then,
  ) = __$$StatsStorageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'used_bytes') int? usedBytes,
    @JsonKey(name: 'used_human') String? usedHuman,
  });
}

/// @nodoc
class __$$StatsStorageImplCopyWithImpl<$Res>
    extends _$StatsStorageCopyWithImpl<$Res, _$StatsStorageImpl>
    implements _$$StatsStorageImplCopyWith<$Res> {
  __$$StatsStorageImplCopyWithImpl(
    _$StatsStorageImpl _value,
    $Res Function(_$StatsStorageImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of StatsStorage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? usedBytes = freezed, Object? usedHuman = freezed}) {
    return _then(
      _$StatsStorageImpl(
        usedBytes: freezed == usedBytes
            ? _value.usedBytes
            : usedBytes // ignore: cast_nullable_to_non_nullable
                  as int?,
        usedHuman: freezed == usedHuman
            ? _value.usedHuman
            : usedHuman // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$StatsStorageImpl implements _StatsStorage {
  const _$StatsStorageImpl({
    @JsonKey(name: 'used_bytes') this.usedBytes,
    @JsonKey(name: 'used_human') this.usedHuman,
  });

  factory _$StatsStorageImpl.fromJson(Map<String, dynamic> json) =>
      _$$StatsStorageImplFromJson(json);

  @override
  @JsonKey(name: 'used_bytes')
  final int? usedBytes;
  @override
  @JsonKey(name: 'used_human')
  final String? usedHuman;

  @override
  String toString() {
    return 'StatsStorage(usedBytes: $usedBytes, usedHuman: $usedHuman)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StatsStorageImpl &&
            (identical(other.usedBytes, usedBytes) ||
                other.usedBytes == usedBytes) &&
            (identical(other.usedHuman, usedHuman) ||
                other.usedHuman == usedHuman));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, usedBytes, usedHuman);

  /// Create a copy of StatsStorage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StatsStorageImplCopyWith<_$StatsStorageImpl> get copyWith =>
      __$$StatsStorageImplCopyWithImpl<_$StatsStorageImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StatsStorageImplToJson(this);
  }
}

abstract class _StatsStorage implements StatsStorage {
  const factory _StatsStorage({
    @JsonKey(name: 'used_bytes') final int? usedBytes,
    @JsonKey(name: 'used_human') final String? usedHuman,
  }) = _$StatsStorageImpl;

  factory _StatsStorage.fromJson(Map<String, dynamic> json) =
      _$StatsStorageImpl.fromJson;

  @override
  @JsonKey(name: 'used_bytes')
  int? get usedBytes;
  @override
  @JsonKey(name: 'used_human')
  String? get usedHuman;

  /// Create a copy of StatsStorage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StatsStorageImplCopyWith<_$StatsStorageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

StatsTokens _$StatsTokensFromJson(Map<String, dynamic> json) {
  return _StatsTokens.fromJson(json);
}

/// @nodoc
mixin _$StatsTokens {
  int? get budget => throw _privateConstructorUsedError;
  double? get percentage => throw _privateConstructorUsedError;
  @JsonKey(name: 'used_this_month')
  int? get usedThisMonth => throw _privateConstructorUsedError;

  /// Serializes this StatsTokens to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of StatsTokens
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StatsTokensCopyWith<StatsTokens> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StatsTokensCopyWith<$Res> {
  factory $StatsTokensCopyWith(
    StatsTokens value,
    $Res Function(StatsTokens) then,
  ) = _$StatsTokensCopyWithImpl<$Res, StatsTokens>;
  @useResult
  $Res call({
    int? budget,
    double? percentage,
    @JsonKey(name: 'used_this_month') int? usedThisMonth,
  });
}

/// @nodoc
class _$StatsTokensCopyWithImpl<$Res, $Val extends StatsTokens>
    implements $StatsTokensCopyWith<$Res> {
  _$StatsTokensCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StatsTokens
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? budget = freezed,
    Object? percentage = freezed,
    Object? usedThisMonth = freezed,
  }) {
    return _then(
      _value.copyWith(
            budget: freezed == budget
                ? _value.budget
                : budget // ignore: cast_nullable_to_non_nullable
                      as int?,
            percentage: freezed == percentage
                ? _value.percentage
                : percentage // ignore: cast_nullable_to_non_nullable
                      as double?,
            usedThisMonth: freezed == usedThisMonth
                ? _value.usedThisMonth
                : usedThisMonth // ignore: cast_nullable_to_non_nullable
                      as int?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$StatsTokensImplCopyWith<$Res>
    implements $StatsTokensCopyWith<$Res> {
  factory _$$StatsTokensImplCopyWith(
    _$StatsTokensImpl value,
    $Res Function(_$StatsTokensImpl) then,
  ) = __$$StatsTokensImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int? budget,
    double? percentage,
    @JsonKey(name: 'used_this_month') int? usedThisMonth,
  });
}

/// @nodoc
class __$$StatsTokensImplCopyWithImpl<$Res>
    extends _$StatsTokensCopyWithImpl<$Res, _$StatsTokensImpl>
    implements _$$StatsTokensImplCopyWith<$Res> {
  __$$StatsTokensImplCopyWithImpl(
    _$StatsTokensImpl _value,
    $Res Function(_$StatsTokensImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of StatsTokens
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? budget = freezed,
    Object? percentage = freezed,
    Object? usedThisMonth = freezed,
  }) {
    return _then(
      _$StatsTokensImpl(
        budget: freezed == budget
            ? _value.budget
            : budget // ignore: cast_nullable_to_non_nullable
                  as int?,
        percentage: freezed == percentage
            ? _value.percentage
            : percentage // ignore: cast_nullable_to_non_nullable
                  as double?,
        usedThisMonth: freezed == usedThisMonth
            ? _value.usedThisMonth
            : usedThisMonth // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$StatsTokensImpl implements _StatsTokens {
  const _$StatsTokensImpl({
    this.budget,
    this.percentage,
    @JsonKey(name: 'used_this_month') this.usedThisMonth,
  });

  factory _$StatsTokensImpl.fromJson(Map<String, dynamic> json) =>
      _$$StatsTokensImplFromJson(json);

  @override
  final int? budget;
  @override
  final double? percentage;
  @override
  @JsonKey(name: 'used_this_month')
  final int? usedThisMonth;

  @override
  String toString() {
    return 'StatsTokens(budget: $budget, percentage: $percentage, usedThisMonth: $usedThisMonth)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StatsTokensImpl &&
            (identical(other.budget, budget) || other.budget == budget) &&
            (identical(other.percentage, percentage) ||
                other.percentage == percentage) &&
            (identical(other.usedThisMonth, usedThisMonth) ||
                other.usedThisMonth == usedThisMonth));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, budget, percentage, usedThisMonth);

  /// Create a copy of StatsTokens
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StatsTokensImplCopyWith<_$StatsTokensImpl> get copyWith =>
      __$$StatsTokensImplCopyWithImpl<_$StatsTokensImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StatsTokensImplToJson(this);
  }
}

abstract class _StatsTokens implements StatsTokens {
  const factory _StatsTokens({
    final int? budget,
    final double? percentage,
    @JsonKey(name: 'used_this_month') final int? usedThisMonth,
  }) = _$StatsTokensImpl;

  factory _StatsTokens.fromJson(Map<String, dynamic> json) =
      _$StatsTokensImpl.fromJson;

  @override
  int? get budget;
  @override
  double? get percentage;
  @override
  @JsonKey(name: 'used_this_month')
  int? get usedThisMonth;

  /// Create a copy of StatsTokens
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StatsTokensImplCopyWith<_$StatsTokensImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

StatsTranscription _$StatsTranscriptionFromJson(Map<String, dynamic> json) {
  return _StatsTranscription.fromJson(json);
}

/// @nodoc
mixin _$StatsTranscription {
  @JsonKey(name: 'budget_minutes')
  int? get budgetMinutes => throw _privateConstructorUsedError;
  @JsonKey(name: 'budget_seconds')
  int? get budgetSeconds => throw _privateConstructorUsedError;
  @JsonKey(name: 'estimated_cost')
  double? get estimatedCost => throw _privateConstructorUsedError;
  double? get percentage => throw _privateConstructorUsedError;
  @JsonKey(name: 'used_this_month_minutes')
  int? get usedThisMonthMinutes => throw _privateConstructorUsedError;
  @JsonKey(name: 'used_this_month_seconds')
  int? get usedThisMonthSeconds => throw _privateConstructorUsedError;

  /// Serializes this StatsTranscription to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of StatsTranscription
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StatsTranscriptionCopyWith<StatsTranscription> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StatsTranscriptionCopyWith<$Res> {
  factory $StatsTranscriptionCopyWith(
    StatsTranscription value,
    $Res Function(StatsTranscription) then,
  ) = _$StatsTranscriptionCopyWithImpl<$Res, StatsTranscription>;
  @useResult
  $Res call({
    @JsonKey(name: 'budget_minutes') int? budgetMinutes,
    @JsonKey(name: 'budget_seconds') int? budgetSeconds,
    @JsonKey(name: 'estimated_cost') double? estimatedCost,
    double? percentage,
    @JsonKey(name: 'used_this_month_minutes') int? usedThisMonthMinutes,
    @JsonKey(name: 'used_this_month_seconds') int? usedThisMonthSeconds,
  });
}

/// @nodoc
class _$StatsTranscriptionCopyWithImpl<$Res, $Val extends StatsTranscription>
    implements $StatsTranscriptionCopyWith<$Res> {
  _$StatsTranscriptionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StatsTranscription
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? budgetMinutes = freezed,
    Object? budgetSeconds = freezed,
    Object? estimatedCost = freezed,
    Object? percentage = freezed,
    Object? usedThisMonthMinutes = freezed,
    Object? usedThisMonthSeconds = freezed,
  }) {
    return _then(
      _value.copyWith(
            budgetMinutes: freezed == budgetMinutes
                ? _value.budgetMinutes
                : budgetMinutes // ignore: cast_nullable_to_non_nullable
                      as int?,
            budgetSeconds: freezed == budgetSeconds
                ? _value.budgetSeconds
                : budgetSeconds // ignore: cast_nullable_to_non_nullable
                      as int?,
            estimatedCost: freezed == estimatedCost
                ? _value.estimatedCost
                : estimatedCost // ignore: cast_nullable_to_non_nullable
                      as double?,
            percentage: freezed == percentage
                ? _value.percentage
                : percentage // ignore: cast_nullable_to_non_nullable
                      as double?,
            usedThisMonthMinutes: freezed == usedThisMonthMinutes
                ? _value.usedThisMonthMinutes
                : usedThisMonthMinutes // ignore: cast_nullable_to_non_nullable
                      as int?,
            usedThisMonthSeconds: freezed == usedThisMonthSeconds
                ? _value.usedThisMonthSeconds
                : usedThisMonthSeconds // ignore: cast_nullable_to_non_nullable
                      as int?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$StatsTranscriptionImplCopyWith<$Res>
    implements $StatsTranscriptionCopyWith<$Res> {
  factory _$$StatsTranscriptionImplCopyWith(
    _$StatsTranscriptionImpl value,
    $Res Function(_$StatsTranscriptionImpl) then,
  ) = __$$StatsTranscriptionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'budget_minutes') int? budgetMinutes,
    @JsonKey(name: 'budget_seconds') int? budgetSeconds,
    @JsonKey(name: 'estimated_cost') double? estimatedCost,
    double? percentage,
    @JsonKey(name: 'used_this_month_minutes') int? usedThisMonthMinutes,
    @JsonKey(name: 'used_this_month_seconds') int? usedThisMonthSeconds,
  });
}

/// @nodoc
class __$$StatsTranscriptionImplCopyWithImpl<$Res>
    extends _$StatsTranscriptionCopyWithImpl<$Res, _$StatsTranscriptionImpl>
    implements _$$StatsTranscriptionImplCopyWith<$Res> {
  __$$StatsTranscriptionImplCopyWithImpl(
    _$StatsTranscriptionImpl _value,
    $Res Function(_$StatsTranscriptionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of StatsTranscription
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? budgetMinutes = freezed,
    Object? budgetSeconds = freezed,
    Object? estimatedCost = freezed,
    Object? percentage = freezed,
    Object? usedThisMonthMinutes = freezed,
    Object? usedThisMonthSeconds = freezed,
  }) {
    return _then(
      _$StatsTranscriptionImpl(
        budgetMinutes: freezed == budgetMinutes
            ? _value.budgetMinutes
            : budgetMinutes // ignore: cast_nullable_to_non_nullable
                  as int?,
        budgetSeconds: freezed == budgetSeconds
            ? _value.budgetSeconds
            : budgetSeconds // ignore: cast_nullable_to_non_nullable
                  as int?,
        estimatedCost: freezed == estimatedCost
            ? _value.estimatedCost
            : estimatedCost // ignore: cast_nullable_to_non_nullable
                  as double?,
        percentage: freezed == percentage
            ? _value.percentage
            : percentage // ignore: cast_nullable_to_non_nullable
                  as double?,
        usedThisMonthMinutes: freezed == usedThisMonthMinutes
            ? _value.usedThisMonthMinutes
            : usedThisMonthMinutes // ignore: cast_nullable_to_non_nullable
                  as int?,
        usedThisMonthSeconds: freezed == usedThisMonthSeconds
            ? _value.usedThisMonthSeconds
            : usedThisMonthSeconds // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$StatsTranscriptionImpl implements _StatsTranscription {
  const _$StatsTranscriptionImpl({
    @JsonKey(name: 'budget_minutes') this.budgetMinutes,
    @JsonKey(name: 'budget_seconds') this.budgetSeconds,
    @JsonKey(name: 'estimated_cost') this.estimatedCost,
    this.percentage,
    @JsonKey(name: 'used_this_month_minutes') this.usedThisMonthMinutes,
    @JsonKey(name: 'used_this_month_seconds') this.usedThisMonthSeconds,
  });

  factory _$StatsTranscriptionImpl.fromJson(Map<String, dynamic> json) =>
      _$$StatsTranscriptionImplFromJson(json);

  @override
  @JsonKey(name: 'budget_minutes')
  final int? budgetMinutes;
  @override
  @JsonKey(name: 'budget_seconds')
  final int? budgetSeconds;
  @override
  @JsonKey(name: 'estimated_cost')
  final double? estimatedCost;
  @override
  final double? percentage;
  @override
  @JsonKey(name: 'used_this_month_minutes')
  final int? usedThisMonthMinutes;
  @override
  @JsonKey(name: 'used_this_month_seconds')
  final int? usedThisMonthSeconds;

  @override
  String toString() {
    return 'StatsTranscription(budgetMinutes: $budgetMinutes, budgetSeconds: $budgetSeconds, estimatedCost: $estimatedCost, percentage: $percentage, usedThisMonthMinutes: $usedThisMonthMinutes, usedThisMonthSeconds: $usedThisMonthSeconds)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StatsTranscriptionImpl &&
            (identical(other.budgetMinutes, budgetMinutes) ||
                other.budgetMinutes == budgetMinutes) &&
            (identical(other.budgetSeconds, budgetSeconds) ||
                other.budgetSeconds == budgetSeconds) &&
            (identical(other.estimatedCost, estimatedCost) ||
                other.estimatedCost == estimatedCost) &&
            (identical(other.percentage, percentage) ||
                other.percentage == percentage) &&
            (identical(other.usedThisMonthMinutes, usedThisMonthMinutes) ||
                other.usedThisMonthMinutes == usedThisMonthMinutes) &&
            (identical(other.usedThisMonthSeconds, usedThisMonthSeconds) ||
                other.usedThisMonthSeconds == usedThisMonthSeconds));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    budgetMinutes,
    budgetSeconds,
    estimatedCost,
    percentage,
    usedThisMonthMinutes,
    usedThisMonthSeconds,
  );

  /// Create a copy of StatsTranscription
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StatsTranscriptionImplCopyWith<_$StatsTranscriptionImpl> get copyWith =>
      __$$StatsTranscriptionImplCopyWithImpl<_$StatsTranscriptionImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$StatsTranscriptionImplToJson(this);
  }
}

abstract class _StatsTranscription implements StatsTranscription {
  const factory _StatsTranscription({
    @JsonKey(name: 'budget_minutes') final int? budgetMinutes,
    @JsonKey(name: 'budget_seconds') final int? budgetSeconds,
    @JsonKey(name: 'estimated_cost') final double? estimatedCost,
    final double? percentage,
    @JsonKey(name: 'used_this_month_minutes') final int? usedThisMonthMinutes,
    @JsonKey(name: 'used_this_month_seconds') final int? usedThisMonthSeconds,
  }) = _$StatsTranscriptionImpl;

  factory _StatsTranscription.fromJson(Map<String, dynamic> json) =
      _$StatsTranscriptionImpl.fromJson;

  @override
  @JsonKey(name: 'budget_minutes')
  int? get budgetMinutes;
  @override
  @JsonKey(name: 'budget_seconds')
  int? get budgetSeconds;
  @override
  @JsonKey(name: 'estimated_cost')
  double? get estimatedCost;
  @override
  double? get percentage;
  @override
  @JsonKey(name: 'used_this_month_minutes')
  int? get usedThisMonthMinutes;
  @override
  @JsonKey(name: 'used_this_month_seconds')
  int? get usedThisMonthSeconds;

  /// Create a copy of StatsTranscription
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StatsTranscriptionImplCopyWith<_$StatsTranscriptionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
