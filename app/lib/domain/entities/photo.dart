import 'package:freezed_annotation/freezed_annotation.dart';

part 'photo.freezed.dart';
part 'photo.g.dart';

/// 照片上传状态
enum UploadStatus {
  /// 待上传
  @JsonValue('pending')
  pending,

  /// 上传中
  @JsonValue('uploading')
  uploading,

  /// 上传完成
  @JsonValue('completed')
  completed,

  /// 上传失败
  @JsonValue('failed')
  failed,
}

/// 照片实体
///
/// 表示物品的关联照片
@freezed
class Photo with _$Photo {
  const factory Photo({
    /// 唯一标识
    required String id,

    /// 关联的物品 ID
    String? itemId,

    /// S3 存储键
    required String s3Key,

    /// 本地文件路径（可选）
    String? localPath,

    /// 上传状态
    @Default(UploadStatus.pending) UploadStatus uploadStatus,

    /// 创建时间
    DateTime? createdAt,
  }) = _Photo;

  factory Photo.fromJson(Map<String, dynamic> json) => _$PhotoFromJson(json);
}
