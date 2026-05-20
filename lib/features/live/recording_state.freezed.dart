// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'recording_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RecordingState {

 int get elapsedSeconds; bool get paused; bool get started; bool get uploading; String? get error; int get speakers; List<String> get activeTags; int? get folderId; bool get miniOpen; int? get miniWindowId; bool get micEnabled; SystemAudioMode get systemMode; bool get systemAudioSupported; bool get processLoopbackSupported; bool get micPending; bool get systemPending; double get audioLevel; String? get processSourceName; int? get processSourcePid;
/// Create a copy of RecordingState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecordingStateCopyWith<RecordingState> get copyWith => _$RecordingStateCopyWithImpl<RecordingState>(this as RecordingState, _$identity);

  /// Serializes this RecordingState to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecordingState&&(identical(other.elapsedSeconds, elapsedSeconds) || other.elapsedSeconds == elapsedSeconds)&&(identical(other.paused, paused) || other.paused == paused)&&(identical(other.started, started) || other.started == started)&&(identical(other.uploading, uploading) || other.uploading == uploading)&&(identical(other.error, error) || other.error == error)&&(identical(other.speakers, speakers) || other.speakers == speakers)&&const DeepCollectionEquality().equals(other.activeTags, activeTags)&&(identical(other.folderId, folderId) || other.folderId == folderId)&&(identical(other.miniOpen, miniOpen) || other.miniOpen == miniOpen)&&(identical(other.miniWindowId, miniWindowId) || other.miniWindowId == miniWindowId)&&(identical(other.micEnabled, micEnabled) || other.micEnabled == micEnabled)&&(identical(other.systemMode, systemMode) || other.systemMode == systemMode)&&(identical(other.systemAudioSupported, systemAudioSupported) || other.systemAudioSupported == systemAudioSupported)&&(identical(other.processLoopbackSupported, processLoopbackSupported) || other.processLoopbackSupported == processLoopbackSupported)&&(identical(other.micPending, micPending) || other.micPending == micPending)&&(identical(other.systemPending, systemPending) || other.systemPending == systemPending)&&(identical(other.audioLevel, audioLevel) || other.audioLevel == audioLevel)&&(identical(other.processSourceName, processSourceName) || other.processSourceName == processSourceName)&&(identical(other.processSourcePid, processSourcePid) || other.processSourcePid == processSourcePid));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,elapsedSeconds,paused,started,uploading,error,speakers,const DeepCollectionEquality().hash(activeTags),folderId,miniOpen,miniWindowId,micEnabled,systemMode,systemAudioSupported,processLoopbackSupported,micPending,systemPending,audioLevel,processSourceName,processSourcePid]);

@override
String toString() {
  return 'RecordingState(elapsedSeconds: $elapsedSeconds, paused: $paused, started: $started, uploading: $uploading, error: $error, speakers: $speakers, activeTags: $activeTags, folderId: $folderId, miniOpen: $miniOpen, miniWindowId: $miniWindowId, micEnabled: $micEnabled, systemMode: $systemMode, systemAudioSupported: $systemAudioSupported, processLoopbackSupported: $processLoopbackSupported, micPending: $micPending, systemPending: $systemPending, audioLevel: $audioLevel, processSourceName: $processSourceName, processSourcePid: $processSourcePid)';
}


}

/// @nodoc
abstract mixin class $RecordingStateCopyWith<$Res>  {
  factory $RecordingStateCopyWith(RecordingState value, $Res Function(RecordingState) _then) = _$RecordingStateCopyWithImpl;
@useResult
$Res call({
 int elapsedSeconds, bool paused, bool started, bool uploading, String? error, int speakers, List<String> activeTags, int? folderId, bool miniOpen, int? miniWindowId, bool micEnabled, SystemAudioMode systemMode, bool systemAudioSupported, bool processLoopbackSupported, bool micPending, bool systemPending, double audioLevel, String? processSourceName, int? processSourcePid
});




}
/// @nodoc
class _$RecordingStateCopyWithImpl<$Res>
    implements $RecordingStateCopyWith<$Res> {
  _$RecordingStateCopyWithImpl(this._self, this._then);

  final RecordingState _self;
  final $Res Function(RecordingState) _then;

/// Create a copy of RecordingState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? elapsedSeconds = null,Object? paused = null,Object? started = null,Object? uploading = null,Object? error = freezed,Object? speakers = null,Object? activeTags = null,Object? folderId = freezed,Object? miniOpen = null,Object? miniWindowId = freezed,Object? micEnabled = null,Object? systemMode = null,Object? systemAudioSupported = null,Object? processLoopbackSupported = null,Object? micPending = null,Object? systemPending = null,Object? audioLevel = null,Object? processSourceName = freezed,Object? processSourcePid = freezed,}) {
  return _then(_self.copyWith(
elapsedSeconds: null == elapsedSeconds ? _self.elapsedSeconds : elapsedSeconds // ignore: cast_nullable_to_non_nullable
as int,paused: null == paused ? _self.paused : paused // ignore: cast_nullable_to_non_nullable
as bool,started: null == started ? _self.started : started // ignore: cast_nullable_to_non_nullable
as bool,uploading: null == uploading ? _self.uploading : uploading // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,speakers: null == speakers ? _self.speakers : speakers // ignore: cast_nullable_to_non_nullable
as int,activeTags: null == activeTags ? _self.activeTags : activeTags // ignore: cast_nullable_to_non_nullable
as List<String>,folderId: freezed == folderId ? _self.folderId : folderId // ignore: cast_nullable_to_non_nullable
as int?,miniOpen: null == miniOpen ? _self.miniOpen : miniOpen // ignore: cast_nullable_to_non_nullable
as bool,miniWindowId: freezed == miniWindowId ? _self.miniWindowId : miniWindowId // ignore: cast_nullable_to_non_nullable
as int?,micEnabled: null == micEnabled ? _self.micEnabled : micEnabled // ignore: cast_nullable_to_non_nullable
as bool,systemMode: null == systemMode ? _self.systemMode : systemMode // ignore: cast_nullable_to_non_nullable
as SystemAudioMode,systemAudioSupported: null == systemAudioSupported ? _self.systemAudioSupported : systemAudioSupported // ignore: cast_nullable_to_non_nullable
as bool,processLoopbackSupported: null == processLoopbackSupported ? _self.processLoopbackSupported : processLoopbackSupported // ignore: cast_nullable_to_non_nullable
as bool,micPending: null == micPending ? _self.micPending : micPending // ignore: cast_nullable_to_non_nullable
as bool,systemPending: null == systemPending ? _self.systemPending : systemPending // ignore: cast_nullable_to_non_nullable
as bool,audioLevel: null == audioLevel ? _self.audioLevel : audioLevel // ignore: cast_nullable_to_non_nullable
as double,processSourceName: freezed == processSourceName ? _self.processSourceName : processSourceName // ignore: cast_nullable_to_non_nullable
as String?,processSourcePid: freezed == processSourcePid ? _self.processSourcePid : processSourcePid // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [RecordingState].
extension RecordingStatePatterns on RecordingState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RecordingState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RecordingState() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RecordingState value)  $default,){
final _that = this;
switch (_that) {
case _RecordingState():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RecordingState value)?  $default,){
final _that = this;
switch (_that) {
case _RecordingState() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int elapsedSeconds,  bool paused,  bool started,  bool uploading,  String? error,  int speakers,  List<String> activeTags,  int? folderId,  bool miniOpen,  int? miniWindowId,  bool micEnabled,  SystemAudioMode systemMode,  bool systemAudioSupported,  bool processLoopbackSupported,  bool micPending,  bool systemPending,  double audioLevel,  String? processSourceName,  int? processSourcePid)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RecordingState() when $default != null:
return $default(_that.elapsedSeconds,_that.paused,_that.started,_that.uploading,_that.error,_that.speakers,_that.activeTags,_that.folderId,_that.miniOpen,_that.miniWindowId,_that.micEnabled,_that.systemMode,_that.systemAudioSupported,_that.processLoopbackSupported,_that.micPending,_that.systemPending,_that.audioLevel,_that.processSourceName,_that.processSourcePid);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int elapsedSeconds,  bool paused,  bool started,  bool uploading,  String? error,  int speakers,  List<String> activeTags,  int? folderId,  bool miniOpen,  int? miniWindowId,  bool micEnabled,  SystemAudioMode systemMode,  bool systemAudioSupported,  bool processLoopbackSupported,  bool micPending,  bool systemPending,  double audioLevel,  String? processSourceName,  int? processSourcePid)  $default,) {final _that = this;
switch (_that) {
case _RecordingState():
return $default(_that.elapsedSeconds,_that.paused,_that.started,_that.uploading,_that.error,_that.speakers,_that.activeTags,_that.folderId,_that.miniOpen,_that.miniWindowId,_that.micEnabled,_that.systemMode,_that.systemAudioSupported,_that.processLoopbackSupported,_that.micPending,_that.systemPending,_that.audioLevel,_that.processSourceName,_that.processSourcePid);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int elapsedSeconds,  bool paused,  bool started,  bool uploading,  String? error,  int speakers,  List<String> activeTags,  int? folderId,  bool miniOpen,  int? miniWindowId,  bool micEnabled,  SystemAudioMode systemMode,  bool systemAudioSupported,  bool processLoopbackSupported,  bool micPending,  bool systemPending,  double audioLevel,  String? processSourceName,  int? processSourcePid)?  $default,) {final _that = this;
switch (_that) {
case _RecordingState() when $default != null:
return $default(_that.elapsedSeconds,_that.paused,_that.started,_that.uploading,_that.error,_that.speakers,_that.activeTags,_that.folderId,_that.miniOpen,_that.miniWindowId,_that.micEnabled,_that.systemMode,_that.systemAudioSupported,_that.processLoopbackSupported,_that.micPending,_that.systemPending,_that.audioLevel,_that.processSourceName,_that.processSourcePid);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RecordingState extends RecordingState {
  const _RecordingState({this.elapsedSeconds = 0, this.paused = false, this.started = false, this.uploading = false, this.error, this.speakers = 2, final  List<String> activeTags = const <String>[], this.folderId, this.miniOpen = false, this.miniWindowId, this.micEnabled = true, this.systemMode = SystemAudioMode.off, this.systemAudioSupported = false, this.processLoopbackSupported = false, this.micPending = false, this.systemPending = false, this.audioLevel = 0.0, this.processSourceName, this.processSourcePid}): _activeTags = activeTags,super._();
  factory _RecordingState.fromJson(Map<String, dynamic> json) => _$RecordingStateFromJson(json);

@override@JsonKey() final  int elapsedSeconds;
@override@JsonKey() final  bool paused;
@override@JsonKey() final  bool started;
@override@JsonKey() final  bool uploading;
@override final  String? error;
@override@JsonKey() final  int speakers;
 final  List<String> _activeTags;
@override@JsonKey() List<String> get activeTags {
  if (_activeTags is EqualUnmodifiableListView) return _activeTags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_activeTags);
}

@override final  int? folderId;
@override@JsonKey() final  bool miniOpen;
@override final  int? miniWindowId;
@override@JsonKey() final  bool micEnabled;
@override@JsonKey() final  SystemAudioMode systemMode;
@override@JsonKey() final  bool systemAudioSupported;
@override@JsonKey() final  bool processLoopbackSupported;
@override@JsonKey() final  bool micPending;
@override@JsonKey() final  bool systemPending;
@override@JsonKey() final  double audioLevel;
@override final  String? processSourceName;
@override final  int? processSourcePid;

/// Create a copy of RecordingState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecordingStateCopyWith<_RecordingState> get copyWith => __$RecordingStateCopyWithImpl<_RecordingState>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RecordingStateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecordingState&&(identical(other.elapsedSeconds, elapsedSeconds) || other.elapsedSeconds == elapsedSeconds)&&(identical(other.paused, paused) || other.paused == paused)&&(identical(other.started, started) || other.started == started)&&(identical(other.uploading, uploading) || other.uploading == uploading)&&(identical(other.error, error) || other.error == error)&&(identical(other.speakers, speakers) || other.speakers == speakers)&&const DeepCollectionEquality().equals(other._activeTags, _activeTags)&&(identical(other.folderId, folderId) || other.folderId == folderId)&&(identical(other.miniOpen, miniOpen) || other.miniOpen == miniOpen)&&(identical(other.miniWindowId, miniWindowId) || other.miniWindowId == miniWindowId)&&(identical(other.micEnabled, micEnabled) || other.micEnabled == micEnabled)&&(identical(other.systemMode, systemMode) || other.systemMode == systemMode)&&(identical(other.systemAudioSupported, systemAudioSupported) || other.systemAudioSupported == systemAudioSupported)&&(identical(other.processLoopbackSupported, processLoopbackSupported) || other.processLoopbackSupported == processLoopbackSupported)&&(identical(other.micPending, micPending) || other.micPending == micPending)&&(identical(other.systemPending, systemPending) || other.systemPending == systemPending)&&(identical(other.audioLevel, audioLevel) || other.audioLevel == audioLevel)&&(identical(other.processSourceName, processSourceName) || other.processSourceName == processSourceName)&&(identical(other.processSourcePid, processSourcePid) || other.processSourcePid == processSourcePid));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,elapsedSeconds,paused,started,uploading,error,speakers,const DeepCollectionEquality().hash(_activeTags),folderId,miniOpen,miniWindowId,micEnabled,systemMode,systemAudioSupported,processLoopbackSupported,micPending,systemPending,audioLevel,processSourceName,processSourcePid]);

@override
String toString() {
  return 'RecordingState(elapsedSeconds: $elapsedSeconds, paused: $paused, started: $started, uploading: $uploading, error: $error, speakers: $speakers, activeTags: $activeTags, folderId: $folderId, miniOpen: $miniOpen, miniWindowId: $miniWindowId, micEnabled: $micEnabled, systemMode: $systemMode, systemAudioSupported: $systemAudioSupported, processLoopbackSupported: $processLoopbackSupported, micPending: $micPending, systemPending: $systemPending, audioLevel: $audioLevel, processSourceName: $processSourceName, processSourcePid: $processSourcePid)';
}


}

/// @nodoc
abstract mixin class _$RecordingStateCopyWith<$Res> implements $RecordingStateCopyWith<$Res> {
  factory _$RecordingStateCopyWith(_RecordingState value, $Res Function(_RecordingState) _then) = __$RecordingStateCopyWithImpl;
@override @useResult
$Res call({
 int elapsedSeconds, bool paused, bool started, bool uploading, String? error, int speakers, List<String> activeTags, int? folderId, bool miniOpen, int? miniWindowId, bool micEnabled, SystemAudioMode systemMode, bool systemAudioSupported, bool processLoopbackSupported, bool micPending, bool systemPending, double audioLevel, String? processSourceName, int? processSourcePid
});




}
/// @nodoc
class __$RecordingStateCopyWithImpl<$Res>
    implements _$RecordingStateCopyWith<$Res> {
  __$RecordingStateCopyWithImpl(this._self, this._then);

  final _RecordingState _self;
  final $Res Function(_RecordingState) _then;

/// Create a copy of RecordingState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? elapsedSeconds = null,Object? paused = null,Object? started = null,Object? uploading = null,Object? error = freezed,Object? speakers = null,Object? activeTags = null,Object? folderId = freezed,Object? miniOpen = null,Object? miniWindowId = freezed,Object? micEnabled = null,Object? systemMode = null,Object? systemAudioSupported = null,Object? processLoopbackSupported = null,Object? micPending = null,Object? systemPending = null,Object? audioLevel = null,Object? processSourceName = freezed,Object? processSourcePid = freezed,}) {
  return _then(_RecordingState(
elapsedSeconds: null == elapsedSeconds ? _self.elapsedSeconds : elapsedSeconds // ignore: cast_nullable_to_non_nullable
as int,paused: null == paused ? _self.paused : paused // ignore: cast_nullable_to_non_nullable
as bool,started: null == started ? _self.started : started // ignore: cast_nullable_to_non_nullable
as bool,uploading: null == uploading ? _self.uploading : uploading // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,speakers: null == speakers ? _self.speakers : speakers // ignore: cast_nullable_to_non_nullable
as int,activeTags: null == activeTags ? _self._activeTags : activeTags // ignore: cast_nullable_to_non_nullable
as List<String>,folderId: freezed == folderId ? _self.folderId : folderId // ignore: cast_nullable_to_non_nullable
as int?,miniOpen: null == miniOpen ? _self.miniOpen : miniOpen // ignore: cast_nullable_to_non_nullable
as bool,miniWindowId: freezed == miniWindowId ? _self.miniWindowId : miniWindowId // ignore: cast_nullable_to_non_nullable
as int?,micEnabled: null == micEnabled ? _self.micEnabled : micEnabled // ignore: cast_nullable_to_non_nullable
as bool,systemMode: null == systemMode ? _self.systemMode : systemMode // ignore: cast_nullable_to_non_nullable
as SystemAudioMode,systemAudioSupported: null == systemAudioSupported ? _self.systemAudioSupported : systemAudioSupported // ignore: cast_nullable_to_non_nullable
as bool,processLoopbackSupported: null == processLoopbackSupported ? _self.processLoopbackSupported : processLoopbackSupported // ignore: cast_nullable_to_non_nullable
as bool,micPending: null == micPending ? _self.micPending : micPending // ignore: cast_nullable_to_non_nullable
as bool,systemPending: null == systemPending ? _self.systemPending : systemPending // ignore: cast_nullable_to_non_nullable
as bool,audioLevel: null == audioLevel ? _self.audioLevel : audioLevel // ignore: cast_nullable_to_non_nullable
as double,processSourceName: freezed == processSourceName ? _self.processSourceName : processSourceName // ignore: cast_nullable_to_non_nullable
as String?,processSourcePid: freezed == processSourcePid ? _self.processSourcePid : processSourcePid // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
