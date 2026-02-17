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

/// Photo 扩展方法
extension PhotoX on Photo {
  /// 转换为数据库格式（snake_case）
  ///
  /// toJson() 使用 camelCase（用于 JSON 序列化）
  /// 数据库使用 snake_case 列名
  Map<String, dynamic> toDbMap() {
    return {
      'id': id,
      'item_id': itemId,
      's3_key': s3Key,
      'local_path': localPath,
      'upload_status': _$UploadStatusEnumMap[uploadStatus]!,
      'created_at': createdAt?.millisecondsSinceEpoch,
    };
  }
}

/// Photo 数据库转换工具
class PhotoDbConverter {
  /// 从数据库格式创建 Photo（snake_case -> camelCase）
  static Photo fromDbMap(Map<String, dynamic> map) {
    return Photo.fromJson({
      'id': map['id'] as String,
      'itemId': map['item_id'] as String?,
      's3Key': map['s3_key'] as String,
      'localPath': map['local_path'] as String?,
      'uploadStatus': map['upload_status'] as String?,
      'createdAt': map['created_at'] == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
    });
  }
}
