import 'package:path/path.dart' as path;

/// 路径工具类
///
/// 提供统一的路径和 Key 推导逻辑，避免在多处重复实现
class PathUtils {
  PathUtils._();

  /// 构建缩略图 S3 Key
  ///
  /// 从原图 S3 Key 推导出缩略图 Key
  /// 原图: accounts/{accountId}/uploading/photos/{yyyy}/{MM}/{dd}/{photoId}.jpg
  /// 缩略图: accounts/{accountId}/uploading/photos/{yyyy}/{MM}/{dd}/{photoId}-thumb.jpg
  ///
  /// [originalS3Key] 原图的 S3 Key
  /// 返回缩略图的 S3 Key
  static String buildThumbnailKey(String originalS3Key) {
    final lastDotIndex = originalS3Key.lastIndexOf('.');
    if (lastDotIndex == -1) return '$originalS3Key-thumb';
    final extension = originalS3Key.substring(lastDotIndex);
    final base = originalS3Key.substring(0, lastDotIndex);
    return '$base-thumb$extension';
  }

  /// 获取缩略图本地文件路径
  ///
  /// 从原图本地路径推导缩略图路径
  /// 原图: /path/to/image.jpg
  /// 缩略图: /path/to/image-thumb.jpg
  ///
  /// [originalLocalPath] 原图的本地文件路径
  /// 返回缩略图的本地文件路径
  static String getThumbnailLocalPath(String originalLocalPath) {
    final dir = path.dirname(originalLocalPath);
    final fileNameWithoutExt = path.basenameWithoutExtension(originalLocalPath);
    final ext = path.extension(originalLocalPath);
    return path.join(dir, '$fileNameWithoutExt-thumb$ext');
  }

  /// 获取文件扩展名
  ///
  /// 从文件路径中提取扩展名（不包含点）
  ///
  /// [filePath] 文件路径
  /// 返回小写的扩展名，如 'jpg'、'png'；如果没有扩展名返回空字符串
  static String getExtension(String filePath) {
    final ext = path.extension(filePath);
    if (ext.isEmpty) return '';
    // 移除开头的点并转为小写
    return ext.substring(1).toLowerCase();
  }
}
