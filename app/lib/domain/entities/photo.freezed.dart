// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'photo.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Photo _$PhotoFromJson(Map<String, dynamic> json) {
  return _Photo.fromJson(json);
}

/// @nodoc
mixin _$Photo {
  /// 唯一标识
  String get id => throw _privateConstructorUsedError;

  /// 关联的物品 ID
  String? get itemId => throw _privateConstructorUsedError;

  /// S3 存储键（原图）
  String get s3Key => throw _privateConstructorUsedError;

  /// S3 存储键（缩略图）
  String? get s3KeyThumbnail => throw _privateConstructorUsedError;

  /// 本地文件路径（可选）
  String? get localPath => throw _privateConstructorUsedError;

  /// 上传状态
  UploadStatus get uploadStatus => throw _privateConstructorUsedError;

  /// 创建时间
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// 文件扩展名（如 jpg, png, webp）
  String? get fileExtension => throw _privateConstructorUsedError;

  /// Serializes this Photo to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Photo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PhotoCopyWith<Photo> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PhotoCopyWith<$Res> {
  factory $PhotoCopyWith(Photo value, $Res Function(Photo) then) =
      _$PhotoCopyWithImpl<$Res, Photo>;
  @useResult
  $Res call(
      {String id,
      String? itemId,
      String s3Key,
      String? s3KeyThumbnail,
      String? localPath,
      UploadStatus uploadStatus,
      DateTime? createdAt,
      String? fileExtension});
}

/// @nodoc
class _$PhotoCopyWithImpl<$Res, $Val extends Photo>
    implements $PhotoCopyWith<$Res> {
  _$PhotoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Photo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? itemId = freezed,
    Object? s3Key = null,
    Object? s3KeyThumbnail = freezed,
    Object? localPath = freezed,
    Object? uploadStatus = null,
    Object? createdAt = freezed,
    Object? fileExtension = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      itemId: freezed == itemId
          ? _value.itemId
          : itemId // ignore: cast_nullable_to_non_nullable
              as String?,
      s3Key: null == s3Key
          ? _value.s3Key
          : s3Key // ignore: cast_nullable_to_non_nullable
              as String,
      s3KeyThumbnail: freezed == s3KeyThumbnail
          ? _value.s3KeyThumbnail
          : s3KeyThumbnail // ignore: cast_nullable_to_non_nullable
              as String?,
      localPath: freezed == localPath
          ? _value.localPath
          : localPath // ignore: cast_nullable_to_non_nullable
              as String?,
      uploadStatus: null == uploadStatus
          ? _value.uploadStatus
          : uploadStatus // ignore: cast_nullable_to_non_nullable
              as UploadStatus,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      fileExtension: freezed == fileExtension
          ? _value.fileExtension
          : fileExtension // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PhotoImplCopyWith<$Res> implements $PhotoCopyWith<$Res> {
  factory _$$PhotoImplCopyWith(
          _$PhotoImpl value, $Res Function(_$PhotoImpl) then) =
      __$$PhotoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String? itemId,
      String s3Key,
      String? s3KeyThumbnail,
      String? localPath,
      UploadStatus uploadStatus,
      DateTime? createdAt,
      String? fileExtension});
}

/// @nodoc
class __$$PhotoImplCopyWithImpl<$Res>
    extends _$PhotoCopyWithImpl<$Res, _$PhotoImpl>
    implements _$$PhotoImplCopyWith<$Res> {
  __$$PhotoImplCopyWithImpl(
      _$PhotoImpl _value, $Res Function(_$PhotoImpl) _then)
      : super(_value, _then);

  /// Create a copy of Photo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? itemId = freezed,
    Object? s3Key = null,
    Object? s3KeyThumbnail = freezed,
    Object? localPath = freezed,
    Object? uploadStatus = null,
    Object? createdAt = freezed,
    Object? fileExtension = freezed,
  }) {
    return _then(_$PhotoImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      itemId: freezed == itemId
          ? _value.itemId
          : itemId // ignore: cast_nullable_to_non_nullable
              as String?,
      s3Key: null == s3Key
          ? _value.s3Key
          : s3Key // ignore: cast_nullable_to_non_nullable
              as String,
      s3KeyThumbnail: freezed == s3KeyThumbnail
          ? _value.s3KeyThumbnail
          : s3KeyThumbnail // ignore: cast_nullable_to_non_nullable
              as String?,
      localPath: freezed == localPath
          ? _value.localPath
          : localPath // ignore: cast_nullable_to_non_nullable
              as String?,
      uploadStatus: null == uploadStatus
          ? _value.uploadStatus
          : uploadStatus // ignore: cast_nullable_to_non_nullable
              as UploadStatus,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      fileExtension: freezed == fileExtension
          ? _value.fileExtension
          : fileExtension // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PhotoImpl implements _Photo {
  const _$PhotoImpl(
      {required this.id,
      this.itemId,
      required this.s3Key,
      this.s3KeyThumbnail,
      this.localPath,
      this.uploadStatus = UploadStatus.pending,
      this.createdAt,
      this.fileExtension});

  factory _$PhotoImpl.fromJson(Map<String, dynamic> json) =>
      _$$PhotoImplFromJson(json);

  /// 唯一标识
  @override
  final String id;

  /// 关联的物品 ID
  @override
  final String? itemId;

  /// S3 存储键（原图）
  @override
  final String s3Key;

  /// S3 存储键（缩略图）
  @override
  final String? s3KeyThumbnail;

  /// 本地文件路径（可选）
  @override
  final String? localPath;

  /// 上传状态
  @override
  @JsonKey()
  final UploadStatus uploadStatus;

  /// 创建时间
  @override
  final DateTime? createdAt;

  /// 文件扩展名（如 jpg, png, webp）
  @override
  final String? fileExtension;

  @override
  String toString() {
    return 'Photo(id: $id, itemId: $itemId, s3Key: $s3Key, s3KeyThumbnail: $s3KeyThumbnail, localPath: $localPath, uploadStatus: $uploadStatus, createdAt: $createdAt, fileExtension: $fileExtension)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PhotoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.itemId, itemId) || other.itemId == itemId) &&
            (identical(other.s3Key, s3Key) || other.s3Key == s3Key) &&
            (identical(other.s3KeyThumbnail, s3KeyThumbnail) ||
                other.s3KeyThumbnail == s3KeyThumbnail) &&
            (identical(other.localPath, localPath) ||
                other.localPath == localPath) &&
            (identical(other.uploadStatus, uploadStatus) ||
                other.uploadStatus == uploadStatus) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.fileExtension, fileExtension) ||
                other.fileExtension == fileExtension));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, itemId, s3Key,
      s3KeyThumbnail, localPath, uploadStatus, createdAt, fileExtension);

  /// Create a copy of Photo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PhotoImplCopyWith<_$PhotoImpl> get copyWith =>
      __$$PhotoImplCopyWithImpl<_$PhotoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PhotoImplToJson(
      this,
    );
  }
}

abstract class _Photo implements Photo {
  const factory _Photo(
      {required final String id,
      final String? itemId,
      required final String s3Key,
      final String? s3KeyThumbnail,
      final String? localPath,
      final UploadStatus uploadStatus,
      final DateTime? createdAt,
      final String? fileExtension}) = _$PhotoImpl;

  factory _Photo.fromJson(Map<String, dynamic> json) = _$PhotoImpl.fromJson;

  /// 唯一标识
  @override
  String get id;

  /// 关联的物品 ID
  @override
  String? get itemId;

  /// S3 存储键（原图）
  @override
  String get s3Key;

  /// S3 存储键（缩略图）
  @override
  String? get s3KeyThumbnail;

  /// 本地文件路径（可选）
  @override
  String? get localPath;

  /// 上传状态
  @override
  UploadStatus get uploadStatus;

  /// 创建时间
  @override
  DateTime? get createdAt;

  /// 文件扩展名（如 jpg, png, webp）
  @override
  String? get fileExtension;

  /// Create a copy of Photo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PhotoImplCopyWith<_$PhotoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
