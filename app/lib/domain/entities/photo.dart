import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';

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

    /// S3 存储键（原图）
    required String s3Key,

    /// S3 存储键（缩略图）
    String? s3KeyThumbnail,

    /// 本地文件路径（可选）
    String? localPath,

    /// 上传状态
    @Default(UploadStatus.pending) UploadStatus uploadStatus,

    /// 创建时间
    DateTime? createdAt,

    /// 文件扩展名（如 jpg, png, webp）
    String? fileExtension,
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
      's3_key_thumbnail': s3KeyThumbnail,
      'local_path': localPath,
      'upload_status': _$UploadStatusEnumMap[uploadStatus]!,
      'created_at': createdAt?.millisecondsSinceEpoch,
      'file_extension': fileExtension,
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
      's3KeyThumbnail': map['s3_key_thumbnail'] as String?,
      'localPath': map['local_path'] as String?,
      'uploadStatus': map['upload_status'] as String?,
      'createdAt': map['created_at'] == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      'fileExtension': map['file_extension'] as String?,
    });
  }

  /// 创建待上传的照片实体
  ///
  /// [originalLocalPath] 原图本地文件路径
  /// [thumbnailLocalPath] 缩略图本地文件路径
  /// [itemId] 关联的物品 ID
  /// [accountId] S3 账户 ID，用于构建 S3 Key
  /// [buildS3Key] 构建 S3 Key 的函数，默认格式为 `accounts/{shortAccountId}/uploading/photos/{yyyy}/{MM}/{dd}/{shortPhotoId}.{extension}`
  /// [buildThumbnailKey] 构建缩略图 S3 Key 的函数，从原图 Key 推导，默认为 `{originalKey}-thumb.{ext}`
  static Photo createForUpload({
    required String originalLocalPath,
    required String thumbnailLocalPath,
    required String itemId,
    required String accountId,
    String Function(String accountId, String photoId, String extension)? buildS3Key,
    String Function(String originalS3Key)? buildThumbnailKey,
  }) {
    final photoId = const Uuid().v4();

    // 从本地文件路径中提取文件扩展名
    String extension = 'jpg'; // 默认为 jpg
    final pathParts = originalLocalPath.split('.');
    if (pathParts.length > 1) {
      final ext = pathParts.last.toLowerCase();
      // 验证扩展名是否为支持的图片格式
      if (const ['jpg', 'jpeg', 'png', 'gif', 'webp', 'heic', 'heif'].contains(ext)) {
        extension = ext == 'jpeg' ? 'jpg' : ext; // jpeg 统一为 jpg
      }
    }

    final s3Key = (buildS3Key ?? _defaultS3KeyBuilder)(accountId, photoId, extension);
    // 缩略图 S3 Key 从原图 Key 推导（依赖注入）
    final s3KeyThumbnail = (buildThumbnailKey ?? _defaultThumbnailKeyBuilder)(s3Key);

    return Photo(
      id: photoId,
      itemId: itemId,
      s3Key: s3Key,
      s3KeyThumbnail: s3KeyThumbnail,
      localPath: originalLocalPath,
      uploadStatus: UploadStatus.pending,
      createdAt: DateTime.now(),
      fileExtension: extension,
    );
  }

  /// 默认 S3 Key 构建函数
  static String _defaultS3KeyBuilder(
    String accountId,
    String photoId,
    String extension,
  ) {
    // 确保 accountId 至少有 8 个字符（兼容 'default' 等 7 字符的情况）
    final shortAccountId = accountId.length >= 8
        ? accountId.substring(0, 8)
        : accountId.padRight(8, '0');
    // UUID 格式确保至少有 8 个字符
    final shortPhotoId = photoId.length >= 8
        ? photoId.substring(0, 8)
        : photoId.padRight(8, '0');
    final now = DateTime.now();
    final year = now.year.toString();
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    return 'accounts/$shortAccountId/uploading/photos/$year/$month/$day/$shortPhotoId.$extension';
  }

  /// 默认缩略图 S3 Key 构建函数
  ///
  /// 从原图 S3 Key 推导缩略图 Key
  /// 原图: accounts/{accountId}/uploading/photos/{yyyy}/{MM}/{dd}/{photoId}.jpg
  /// 缩略图: accounts/{accountId}/uploading/photos/{yyyy}/{MM}/{dd}/{photoId}-thumb.jpg
  static String _defaultThumbnailKeyBuilder(String originalS3Key) {
    final lastDotIndex = originalS3Key.lastIndexOf('.');
    if (lastDotIndex == -1) return '$originalS3Key-thumb';
    final extension = originalS3Key.substring(lastDotIndex);
    final base = originalS3Key.substring(0, lastDotIndex);
    return '$base-thumb$extension';
  }
}
