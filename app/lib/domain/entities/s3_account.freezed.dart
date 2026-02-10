// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 's3_account.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

S3Account _$S3AccountFromJson(Map<String, dynamic> json) {
  return _S3Account.fromJson(json);
}

/// @nodoc
mixin _$S3Account {
  /// 唯一标识
  String get id => throw _privateConstructorUsedError;

  /// 账户名称（用户自定义，便于识别）
  String get accountName => throw _privateConstructorUsedError;

  /// S3 端点（如阿里云 OSS: https://oss-cn-hangzhou.aliyuncs.com）
  String get endpoint => throw _privateConstructorUsedError;

  /// Access Key ID
  String get accessKey => throw _privateConstructorUsedError;

  /// Secret Access Key
  String get secretKey => throw _privateConstructorUsedError;

  /// Bucket 名称
  String get bucket => throw _privateConstructorUsedError;

  /// 区域
  String get region => throw _privateConstructorUsedError;

  /// 是否为当前激活的账户
  bool get isActive => throw _privateConstructorUsedError;

  /// 最后同步时间（可选）
  DateTime? get lastSyncedAt => throw _privateConstructorUsedError;

  /// 创建时间
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this S3Account to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of S3Account
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $S3AccountCopyWith<S3Account> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $S3AccountCopyWith<$Res> {
  factory $S3AccountCopyWith(S3Account value, $Res Function(S3Account) then) =
      _$S3AccountCopyWithImpl<$Res, S3Account>;
  @useResult
  $Res call(
      {String id,
      String accountName,
      String endpoint,
      String accessKey,
      String secretKey,
      String bucket,
      String region,
      bool isActive,
      DateTime? lastSyncedAt,
      DateTime createdAt});
}

/// @nodoc
class _$S3AccountCopyWithImpl<$Res, $Val extends S3Account>
    implements $S3AccountCopyWith<$Res> {
  _$S3AccountCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of S3Account
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? accountName = null,
    Object? endpoint = null,
    Object? accessKey = null,
    Object? secretKey = null,
    Object? bucket = null,
    Object? region = null,
    Object? isActive = null,
    Object? lastSyncedAt = freezed,
    Object? createdAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      accountName: null == accountName
          ? _value.accountName
          : accountName // ignore: cast_nullable_to_non_nullable
              as String,
      endpoint: null == endpoint
          ? _value.endpoint
          : endpoint // ignore: cast_nullable_to_non_nullable
              as String,
      accessKey: null == accessKey
          ? _value.accessKey
          : accessKey // ignore: cast_nullable_to_non_nullable
              as String,
      secretKey: null == secretKey
          ? _value.secretKey
          : secretKey // ignore: cast_nullable_to_non_nullable
              as String,
      bucket: null == bucket
          ? _value.bucket
          : bucket // ignore: cast_nullable_to_non_nullable
              as String,
      region: null == region
          ? _value.region
          : region // ignore: cast_nullable_to_non_nullable
              as String,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      lastSyncedAt: freezed == lastSyncedAt
          ? _value.lastSyncedAt
          : lastSyncedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$S3AccountImplCopyWith<$Res>
    implements $S3AccountCopyWith<$Res> {
  factory _$$S3AccountImplCopyWith(
          _$S3AccountImpl value, $Res Function(_$S3AccountImpl) then) =
      __$$S3AccountImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String accountName,
      String endpoint,
      String accessKey,
      String secretKey,
      String bucket,
      String region,
      bool isActive,
      DateTime? lastSyncedAt,
      DateTime createdAt});
}

/// @nodoc
class __$$S3AccountImplCopyWithImpl<$Res>
    extends _$S3AccountCopyWithImpl<$Res, _$S3AccountImpl>
    implements _$$S3AccountImplCopyWith<$Res> {
  __$$S3AccountImplCopyWithImpl(
      _$S3AccountImpl _value, $Res Function(_$S3AccountImpl) _then)
      : super(_value, _then);

  /// Create a copy of S3Account
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? accountName = null,
    Object? endpoint = null,
    Object? accessKey = null,
    Object? secretKey = null,
    Object? bucket = null,
    Object? region = null,
    Object? isActive = null,
    Object? lastSyncedAt = freezed,
    Object? createdAt = null,
  }) {
    return _then(_$S3AccountImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      accountName: null == accountName
          ? _value.accountName
          : accountName // ignore: cast_nullable_to_non_nullable
              as String,
      endpoint: null == endpoint
          ? _value.endpoint
          : endpoint // ignore: cast_nullable_to_non_nullable
              as String,
      accessKey: null == accessKey
          ? _value.accessKey
          : accessKey // ignore: cast_nullable_to_non_nullable
              as String,
      secretKey: null == secretKey
          ? _value.secretKey
          : secretKey // ignore: cast_nullable_to_non_nullable
              as String,
      bucket: null == bucket
          ? _value.bucket
          : bucket // ignore: cast_nullable_to_non_nullable
              as String,
      region: null == region
          ? _value.region
          : region // ignore: cast_nullable_to_non_nullable
              as String,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      lastSyncedAt: freezed == lastSyncedAt
          ? _value.lastSyncedAt
          : lastSyncedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$S3AccountImpl implements _S3Account {
  const _$S3AccountImpl(
      {required this.id,
      required this.accountName,
      required this.endpoint,
      required this.accessKey,
      required this.secretKey,
      required this.bucket,
      required this.region,
      this.isActive = false,
      this.lastSyncedAt,
      required this.createdAt});

  factory _$S3AccountImpl.fromJson(Map<String, dynamic> json) =>
      _$$S3AccountImplFromJson(json);

  /// 唯一标识
  @override
  final String id;

  /// 账户名称（用户自定义，便于识别）
  @override
  final String accountName;

  /// S3 端点（如阿里云 OSS: https://oss-cn-hangzhou.aliyuncs.com）
  @override
  final String endpoint;

  /// Access Key ID
  @override
  final String accessKey;

  /// Secret Access Key
  @override
  final String secretKey;

  /// Bucket 名称
  @override
  final String bucket;

  /// 区域
  @override
  final String region;

  /// 是否为当前激活的账户
  @override
  @JsonKey()
  final bool isActive;

  /// 最后同步时间（可选）
  @override
  final DateTime? lastSyncedAt;

  /// 创建时间
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'S3Account(id: $id, accountName: $accountName, endpoint: $endpoint, accessKey: $accessKey, secretKey: $secretKey, bucket: $bucket, region: $region, isActive: $isActive, lastSyncedAt: $lastSyncedAt, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$S3AccountImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.accountName, accountName) ||
                other.accountName == accountName) &&
            (identical(other.endpoint, endpoint) ||
                other.endpoint == endpoint) &&
            (identical(other.accessKey, accessKey) ||
                other.accessKey == accessKey) &&
            (identical(other.secretKey, secretKey) ||
                other.secretKey == secretKey) &&
            (identical(other.bucket, bucket) || other.bucket == bucket) &&
            (identical(other.region, region) || other.region == region) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.lastSyncedAt, lastSyncedAt) ||
                other.lastSyncedAt == lastSyncedAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, accountName, endpoint,
      accessKey, secretKey, bucket, region, isActive, lastSyncedAt, createdAt);

  /// Create a copy of S3Account
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$S3AccountImplCopyWith<_$S3AccountImpl> get copyWith =>
      __$$S3AccountImplCopyWithImpl<_$S3AccountImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$S3AccountImplToJson(
      this,
    );
  }
}

abstract class _S3Account implements S3Account {
  const factory _S3Account(
      {required final String id,
      required final String accountName,
      required final String endpoint,
      required final String accessKey,
      required final String secretKey,
      required final String bucket,
      required final String region,
      final bool isActive,
      final DateTime? lastSyncedAt,
      required final DateTime createdAt}) = _$S3AccountImpl;

  factory _S3Account.fromJson(Map<String, dynamic> json) =
      _$S3AccountImpl.fromJson;

  /// 唯一标识
  @override
  String get id;

  /// 账户名称（用户自定义，便于识别）
  @override
  String get accountName;

  /// S3 端点（如阿里云 OSS: https://oss-cn-hangzhou.aliyuncs.com）
  @override
  String get endpoint;

  /// Access Key ID
  @override
  String get accessKey;

  /// Secret Access Key
  @override
  String get secretKey;

  /// Bucket 名称
  @override
  String get bucket;

  /// 区域
  @override
  String get region;

  /// 是否为当前激活的账户
  @override
  bool get isActive;

  /// 最后同步时间（可选）
  @override
  DateTime? get lastSyncedAt;

  /// 创建时间
  @override
  DateTime get createdAt;

  /// Create a copy of S3Account
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$S3AccountImplCopyWith<_$S3AccountImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
