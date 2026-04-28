// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'recording_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

RecordingState _$RecordingStateFromJson(Map<String, dynamic> json) {
  return _RecordingState.fromJson(json);
}

/// @nodoc
mixin _$RecordingState {
  int get elapsedSeconds => throw _privateConstructorUsedError;
  bool get paused => throw _privateConstructorUsedError;
  bool get started => throw _privateConstructorUsedError;
  bool get uploading => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;
  int get speakers => throw _privateConstructorUsedError;
  List<String> get activeTags => throw _privateConstructorUsedError;
  bool get miniOpen => throw _privateConstructorUsedError;
  int? get miniWindowId => throw _privateConstructorUsedError;

  /// Serializes this RecordingState to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RecordingState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RecordingStateCopyWith<RecordingState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RecordingStateCopyWith<$Res> {
  factory $RecordingStateCopyWith(
    RecordingState value,
    $Res Function(RecordingState) then,
  ) = _$RecordingStateCopyWithImpl<$Res, RecordingState>;
  @useResult
  $Res call({
    int elapsedSeconds,
    bool paused,
    bool started,
    bool uploading,
    String? error,
    int speakers,
    List<String> activeTags,
    bool miniOpen,
    int? miniWindowId,
  });
}

/// @nodoc
class _$RecordingStateCopyWithImpl<$Res, $Val extends RecordingState>
    implements $RecordingStateCopyWith<$Res> {
  _$RecordingStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RecordingState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? elapsedSeconds = null,
    Object? paused = null,
    Object? started = null,
    Object? uploading = null,
    Object? error = freezed,
    Object? speakers = null,
    Object? activeTags = null,
    Object? miniOpen = null,
    Object? miniWindowId = freezed,
  }) {
    return _then(
      _value.copyWith(
            elapsedSeconds: null == elapsedSeconds
                ? _value.elapsedSeconds
                : elapsedSeconds // ignore: cast_nullable_to_non_nullable
                      as int,
            paused: null == paused
                ? _value.paused
                : paused // ignore: cast_nullable_to_non_nullable
                      as bool,
            started: null == started
                ? _value.started
                : started // ignore: cast_nullable_to_non_nullable
                      as bool,
            uploading: null == uploading
                ? _value.uploading
                : uploading // ignore: cast_nullable_to_non_nullable
                      as bool,
            error: freezed == error
                ? _value.error
                : error // ignore: cast_nullable_to_non_nullable
                      as String?,
            speakers: null == speakers
                ? _value.speakers
                : speakers // ignore: cast_nullable_to_non_nullable
                      as int,
            activeTags: null == activeTags
                ? _value.activeTags
                : activeTags // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            miniOpen: null == miniOpen
                ? _value.miniOpen
                : miniOpen // ignore: cast_nullable_to_non_nullable
                      as bool,
            miniWindowId: freezed == miniWindowId
                ? _value.miniWindowId
                : miniWindowId // ignore: cast_nullable_to_non_nullable
                      as int?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$RecordingStateImplCopyWith<$Res>
    implements $RecordingStateCopyWith<$Res> {
  factory _$$RecordingStateImplCopyWith(
    _$RecordingStateImpl value,
    $Res Function(_$RecordingStateImpl) then,
  ) = __$$RecordingStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int elapsedSeconds,
    bool paused,
    bool started,
    bool uploading,
    String? error,
    int speakers,
    List<String> activeTags,
    bool miniOpen,
    int? miniWindowId,
  });
}

/// @nodoc
class __$$RecordingStateImplCopyWithImpl<$Res>
    extends _$RecordingStateCopyWithImpl<$Res, _$RecordingStateImpl>
    implements _$$RecordingStateImplCopyWith<$Res> {
  __$$RecordingStateImplCopyWithImpl(
    _$RecordingStateImpl _value,
    $Res Function(_$RecordingStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RecordingState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? elapsedSeconds = null,
    Object? paused = null,
    Object? started = null,
    Object? uploading = null,
    Object? error = freezed,
    Object? speakers = null,
    Object? activeTags = null,
    Object? miniOpen = null,
    Object? miniWindowId = freezed,
  }) {
    return _then(
      _$RecordingStateImpl(
        elapsedSeconds: null == elapsedSeconds
            ? _value.elapsedSeconds
            : elapsedSeconds // ignore: cast_nullable_to_non_nullable
                  as int,
        paused: null == paused
            ? _value.paused
            : paused // ignore: cast_nullable_to_non_nullable
                  as bool,
        started: null == started
            ? _value.started
            : started // ignore: cast_nullable_to_non_nullable
                  as bool,
        uploading: null == uploading
            ? _value.uploading
            : uploading // ignore: cast_nullable_to_non_nullable
                  as bool,
        error: freezed == error
            ? _value.error
            : error // ignore: cast_nullable_to_non_nullable
                  as String?,
        speakers: null == speakers
            ? _value.speakers
            : speakers // ignore: cast_nullable_to_non_nullable
                  as int,
        activeTags: null == activeTags
            ? _value._activeTags
            : activeTags // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        miniOpen: null == miniOpen
            ? _value.miniOpen
            : miniOpen // ignore: cast_nullable_to_non_nullable
                  as bool,
        miniWindowId: freezed == miniWindowId
            ? _value.miniWindowId
            : miniWindowId // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$RecordingStateImpl extends _RecordingState {
  const _$RecordingStateImpl({
    this.elapsedSeconds = 0,
    this.paused = false,
    this.started = false,
    this.uploading = false,
    this.error,
    this.speakers = 2,
    final List<String> activeTags = const <String>[],
    this.miniOpen = false,
    this.miniWindowId,
  }) : _activeTags = activeTags,
       super._();

  factory _$RecordingStateImpl.fromJson(Map<String, dynamic> json) =>
      _$$RecordingStateImplFromJson(json);

  @override
  @JsonKey()
  final int elapsedSeconds;
  @override
  @JsonKey()
  final bool paused;
  @override
  @JsonKey()
  final bool started;
  @override
  @JsonKey()
  final bool uploading;
  @override
  final String? error;
  @override
  @JsonKey()
  final int speakers;
  final List<String> _activeTags;
  @override
  @JsonKey()
  List<String> get activeTags {
    if (_activeTags is EqualUnmodifiableListView) return _activeTags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_activeTags);
  }

  @override
  @JsonKey()
  final bool miniOpen;
  @override
  final int? miniWindowId;

  @override
  String toString() {
    return 'RecordingState(elapsedSeconds: $elapsedSeconds, paused: $paused, started: $started, uploading: $uploading, error: $error, speakers: $speakers, activeTags: $activeTags, miniOpen: $miniOpen, miniWindowId: $miniWindowId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RecordingStateImpl &&
            (identical(other.elapsedSeconds, elapsedSeconds) ||
                other.elapsedSeconds == elapsedSeconds) &&
            (identical(other.paused, paused) || other.paused == paused) &&
            (identical(other.started, started) || other.started == started) &&
            (identical(other.uploading, uploading) ||
                other.uploading == uploading) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.speakers, speakers) ||
                other.speakers == speakers) &&
            const DeepCollectionEquality().equals(
              other._activeTags,
              _activeTags,
            ) &&
            (identical(other.miniOpen, miniOpen) ||
                other.miniOpen == miniOpen) &&
            (identical(other.miniWindowId, miniWindowId) ||
                other.miniWindowId == miniWindowId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    elapsedSeconds,
    paused,
    started,
    uploading,
    error,
    speakers,
    const DeepCollectionEquality().hash(_activeTags),
    miniOpen,
    miniWindowId,
  );

  /// Create a copy of RecordingState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RecordingStateImplCopyWith<_$RecordingStateImpl> get copyWith =>
      __$$RecordingStateImplCopyWithImpl<_$RecordingStateImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$RecordingStateImplToJson(this);
  }
}

abstract class _RecordingState extends RecordingState {
  const factory _RecordingState({
    final int elapsedSeconds,
    final bool paused,
    final bool started,
    final bool uploading,
    final String? error,
    final int speakers,
    final List<String> activeTags,
    final bool miniOpen,
    final int? miniWindowId,
  }) = _$RecordingStateImpl;
  const _RecordingState._() : super._();

  factory _RecordingState.fromJson(Map<String, dynamic> json) =
      _$RecordingStateImpl.fromJson;

  @override
  int get elapsedSeconds;
  @override
  bool get paused;
  @override
  bool get started;
  @override
  bool get uploading;
  @override
  String? get error;
  @override
  int get speakers;
  @override
  List<String> get activeTags;
  @override
  bool get miniOpen;
  @override
  int? get miniWindowId;

  /// Create a copy of RecordingState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RecordingStateImplCopyWith<_$RecordingStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
