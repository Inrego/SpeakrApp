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
    RecordingStatus status,
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
    RecordingStatus status,
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
  @JsonKey()
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
    final RecordingStatus status,
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
    RecordingStatus status,
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
    RecordingStatus status,
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
    required this.status,
    @JsonKey(name: 'queue_position') this.queuePosition,
    this.message,
  });

  factory _$RecordingStatusResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$RecordingStatusResponseImplFromJson(json);

  @override
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
    required final RecordingStatus status,
    @JsonKey(name: 'queue_position') final int? queuePosition,
    final String? message,
  }) = _$RecordingStatusResponseImpl;

  factory _RecordingStatusResponse.fromJson(Map<String, dynamic> json) =
      _$RecordingStatusResponseImpl.fromJson;

  @override
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
  int? get recordings => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_recordings')
  int? get totalRecordings => throw _privateConstructorUsedError;
  @JsonKey(name: 'storage_used_bytes')
  int? get storageUsedBytes => throw _privateConstructorUsedError;
  String? get version => throw _privateConstructorUsedError;

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
    int? recordings,
    @JsonKey(name: 'total_recordings') int? totalRecordings,
    @JsonKey(name: 'storage_used_bytes') int? storageUsedBytes,
    String? version,
  });
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
    Object? recordings = freezed,
    Object? totalRecordings = freezed,
    Object? storageUsedBytes = freezed,
    Object? version = freezed,
  }) {
    return _then(
      _value.copyWith(
            recordings: freezed == recordings
                ? _value.recordings
                : recordings // ignore: cast_nullable_to_non_nullable
                      as int?,
            totalRecordings: freezed == totalRecordings
                ? _value.totalRecordings
                : totalRecordings // ignore: cast_nullable_to_non_nullable
                      as int?,
            storageUsedBytes: freezed == storageUsedBytes
                ? _value.storageUsedBytes
                : storageUsedBytes // ignore: cast_nullable_to_non_nullable
                      as int?,
            version: freezed == version
                ? _value.version
                : version // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
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
    int? recordings,
    @JsonKey(name: 'total_recordings') int? totalRecordings,
    @JsonKey(name: 'storage_used_bytes') int? storageUsedBytes,
    String? version,
  });
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
    Object? recordings = freezed,
    Object? totalRecordings = freezed,
    Object? storageUsedBytes = freezed,
    Object? version = freezed,
  }) {
    return _then(
      _$StatsResponseImpl(
        recordings: freezed == recordings
            ? _value.recordings
            : recordings // ignore: cast_nullable_to_non_nullable
                  as int?,
        totalRecordings: freezed == totalRecordings
            ? _value.totalRecordings
            : totalRecordings // ignore: cast_nullable_to_non_nullable
                  as int?,
        storageUsedBytes: freezed == storageUsedBytes
            ? _value.storageUsedBytes
            : storageUsedBytes // ignore: cast_nullable_to_non_nullable
                  as int?,
        version: freezed == version
            ? _value.version
            : version // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$StatsResponseImpl implements _StatsResponse {
  const _$StatsResponseImpl({
    this.recordings,
    @JsonKey(name: 'total_recordings') this.totalRecordings,
    @JsonKey(name: 'storage_used_bytes') this.storageUsedBytes,
    this.version,
  });

  factory _$StatsResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$StatsResponseImplFromJson(json);

  @override
  final int? recordings;
  @override
  @JsonKey(name: 'total_recordings')
  final int? totalRecordings;
  @override
  @JsonKey(name: 'storage_used_bytes')
  final int? storageUsedBytes;
  @override
  final String? version;

  @override
  String toString() {
    return 'StatsResponse(recordings: $recordings, totalRecordings: $totalRecordings, storageUsedBytes: $storageUsedBytes, version: $version)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StatsResponseImpl &&
            (identical(other.recordings, recordings) ||
                other.recordings == recordings) &&
            (identical(other.totalRecordings, totalRecordings) ||
                other.totalRecordings == totalRecordings) &&
            (identical(other.storageUsedBytes, storageUsedBytes) ||
                other.storageUsedBytes == storageUsedBytes) &&
            (identical(other.version, version) || other.version == version));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    recordings,
    totalRecordings,
    storageUsedBytes,
    version,
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
    final int? recordings,
    @JsonKey(name: 'total_recordings') final int? totalRecordings,
    @JsonKey(name: 'storage_used_bytes') final int? storageUsedBytes,
    final String? version,
  }) = _$StatsResponseImpl;

  factory _StatsResponse.fromJson(Map<String, dynamic> json) =
      _$StatsResponseImpl.fromJson;

  @override
  int? get recordings;
  @override
  @JsonKey(name: 'total_recordings')
  int? get totalRecordings;
  @override
  @JsonKey(name: 'storage_used_bytes')
  int? get storageUsedBytes;
  @override
  String? get version;

  /// Create a copy of StatsResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StatsResponseImplCopyWith<_$StatsResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
