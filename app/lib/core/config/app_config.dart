/// 应用配置
///
/// 包含默认 S3 配置（阿里云 OSS）和应用级别的常量
class AppConfig {
  // 私有构造函数，防止实例化
  AppConfig._();

  /// 默认 S3 端点（阿里云 OSS 杭州）
  static const String defaultS3Endpoint =
      'https://oss-cn-hangzhou.aliyuncs.com';

  /// 默认 S3 区域
  static const String defaultS3Region = 'cn-hangzhou';

  /// 默认 S3 Bucket
  static const String defaultS3Bucket = 'inventory-app-default';

  /// S3 兼容端点模板（支持不同区域）
  static const Map<String, String> ossRegionEndpoints = {
    'cn-hangzhou': 'https://oss-cn-hangzhou.aliyuncs.com',
    'cn-beijing': 'https://oss-cn-beijing.aliyuncs.com',
    'cn-shanghai': 'https://oss-cn-shanghai.aliyuncs.com',
    'cn-shenzhen': 'https://oss-cn-shenzhen.aliyuncs.com',
    'cn-chengdu': 'https://oss-cn-chengdu.aliyuncs.com',
    'cn-guangzhou': 'https://oss-cn-guangzhou.aliyuncs.com',
    'cn-nanjing': 'https://oss-cn-nanjing.aliyuncs.com',
    'cn-wuhan': 'https://oss-cn-wuhan.aliyuncs.com',
    'us-west-1': 'https://oss-us-west-1.aliyuncs.com',
    'us-east-1': 'https://oss-us-east-1.aliyuncs.com',
    'eu-central-1': 'https://oss-eu-central-1.aliyuncs.com',
  };

  /// 根据区域获取端点
  static String getEndpointForRegion(String region) {
    return ossRegionEndpoints[region] ?? defaultS3Endpoint;
  }

  /// 数据库文件名
  static const String databaseName = 'inventory.db';

  /// S3 路径前缀
  static const String s3AccountsPrefix = 'accounts';
  static const String s3AppPath = 'uploading';
  static const String s3DatabasePath = 'database';
  static const String s3PhotosPath = 'photos';

  /// 构建账户数据库的 S3 Key
  static String buildAccountDbKey(String accountId) {
    return '$s3AccountsPrefix/$accountId/$s3AppPath/$s3DatabasePath/$databaseName';
  }

  /// 构建照片的 S3 Key（带日期分区和文件扩展名）
  ///
  /// 路径格式: accounts/{shortAccountId}/uploading/photos/{yyyy}/{MM}/{shortPhotoId}.{extension}
  /// - shortAccountId: accountId 的前 8 位
  /// - 日期分区: yyyy/MM（用于按月组织照片）
  /// - shortPhotoId: photoId 的前 8 位（缩短路径长度）
  /// - extension: 文件扩展名（如 jpg, png）
  static String buildPhotoKey(
    String accountId,
    String photoId,
    String extension,
  ) {
    final shortAccountId = accountId.substring(0, 8);
    final shortPhotoId = photoId.substring(0, 8);
    final now = DateTime.now();
    final year = now.year.toString();
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    return '$s3AccountsPrefix/$shortAccountId/$s3AppPath/$s3PhotosPath/$year/$month/$day/$shortPhotoId.$extension';
  }

  /// 每个物品最大照片数量
  static const int maxPhotosPerItem = 10;
}
