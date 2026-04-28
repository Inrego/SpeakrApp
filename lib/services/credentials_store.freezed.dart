// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'credentials_store.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SpeakrCredentials _$SpeakrCredentialsFromJson(Map<String, dynamic> json) {
  return _SpeakrCredentials.fromJson(json);
}

/// @nodoc
mixin _$SpeakrCredentials {
  String get baseUrl => throw _privateConstructorUsedError;
  String get token => throw _privateConstructorUsedError;

  /// Serializes this SpeakrCredentials to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SpeakrCredentials
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SpeakrCredentialsCopyWith<SpeakrCredentials> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SpeakrCredentialsCopyWith<$Res> {
  factory $SpeakrCredentialsCopyWith(
    SpeakrCredentials value,
    $Res Function(SpeakrCredentials) then,
  ) = _$SpeakrCredentialsCopyWithImpl<$Res, SpeakrCredentials>;
  @useResult
  $Res call({String baseUrl, String token});
}

/// @nodoc
class _$SpeakrCredentialsCopyWithImpl<$Res, $Val extends SpeakrCredentials>
    implements $SpeakrCredentialsCopyWith<$Res> {
  _$SpeakrCredentialsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SpeakrCredentials
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? baseUrl = null, Object? token = null}) {
    return _then(
      _value.copyWith(
            baseUrl: null == baseUrl
                ? _value.baseUrl
                : baseUrl // ignore: cast_nullable_to_non_nullable
                      as String,
            token: null == token
                ? _value.token
                : token // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SpeakrCredentialsImplCopyWith<$Res>
    implements $SpeakrCredentialsCopyWith<$Res> {
  factory _$$SpeakrCredentialsImplCopyWith(
    _$SpeakrCredentialsImpl value,
    $Res Function(_$SpeakrCredentialsImpl) then,
  ) = __$$SpeakrCredentialsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String baseUrl, String token});
}

/// @nodoc
class __$$SpeakrCredentialsImplCopyWithImpl<$Res>
    extends _$SpeakrCredentialsCopyWithImpl<$Res, _$SpeakrCredentialsImpl>
    implements _$$SpeakrCredentialsImplCopyWith<$Res> {
  __$$SpeakrCredentialsImplCopyWithImpl(
    _$SpeakrCredentialsImpl _value,
    $Res Function(_$SpeakrCredentialsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SpeakrCredentials
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? baseUrl = null, Object? token = null}) {
    return _then(
      _$SpeakrCredentialsImpl(
        baseUrl: null == baseUrl
            ? _value.baseUrl
            : baseUrl // ignore: cast_nullable_to_non_nullable
                  as String,
        token: null == token
            ? _value.token
            : token // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SpeakrCredentialsImpl implements _SpeakrCredentials {
  const _$SpeakrCredentialsImpl({required this.baseUrl, required this.token});

  factory _$SpeakrCredentialsImpl.fromJson(Map<String, dynamic> json) =>
      _$$SpeakrCredentialsImplFromJson(json);

  @override
  final String baseUrl;
  @override
  final String token;

  @override
  String toString() {
    return 'SpeakrCredentials(baseUrl: $baseUrl, token: $token)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SpeakrCredentialsImpl &&
            (identical(other.baseUrl, baseUrl) || other.baseUrl == baseUrl) &&
            (identical(other.token, token) || other.token == token));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, baseUrl, token);

  /// Create a copy of SpeakrCredentials
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SpeakrCredentialsImplCopyWith<_$SpeakrCredentialsImpl> get copyWith =>
      __$$SpeakrCredentialsImplCopyWithImpl<_$SpeakrCredentialsImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SpeakrCredentialsImplToJson(this);
  }
}

abstract class _SpeakrCredentials implements SpeakrCredentials {
  const factory _SpeakrCredentials({
    required final String baseUrl,
    required final String token,
  }) = _$SpeakrCredentialsImpl;

  factory _SpeakrCredentials.fromJson(Map<String, dynamic> json) =
      _$SpeakrCredentialsImpl.fromJson;

  @override
  String get baseUrl;
  @override
  String get token;

  /// Create a copy of SpeakrCredentials
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SpeakrCredentialsImplCopyWith<_$SpeakrCredentialsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
