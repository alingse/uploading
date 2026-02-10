import 'dart:io';
import 'package:flutter_oss_aliyun/flutter_oss_aliyun.dart';
import '../domain/entities/s3_account.dart';

/// 阿里云 OSS 服务
///
/// 使用 flutter_oss_aliyun 包封装阿里云 OSS 操作
class OssService {
  final String endpoint;
  final String accessKey;
  final String secretKey;
  final String bucket;
  final String region;

  OssService({
    required this.endpoint,
    required this.accessKey,
    required this.secretKey,
    required this.bucket,
    required this.region,
  });

  /// 从 S3Account 创建 OssService
  factory OssService.fromAccount(S3Account account) {
    return OssService(
      endpoint: account.endpoint,
      accessKey: account.accessKey,
      secretKey: account.secretKey,
      bucket: account.bucket,
      region: account.region,
    );
  }

  /// 初始化 OSS 客户端
  void init() {
    Client.init(
      ossEndpoint: endpoint,
      bucketName: bucket,
      authGetter: _authGetter,
    );
  }

  /// 获取认证信息
  Auth _authGetter() {
    // 设置一个较长的过期时间（1年后）
    final expiration = DateTime.now().add(const Duration(days: 365));
    return Auth(
      accessKey: accessKey,
      accessSecret: secretKey,
      expire: expiration.toIso8601String(),
      secureToken: '', // 不使用 STS 临时凭证
    );
  }

  /// 上传文件到 OSS
  Future<String> uploadFile({
    required File file,
    required String key,
    String? contentType,
    void Function(int bytes, int totalBytes)? onProgress,
  }) async {
    try {
      // 构建请求头，设置 Content-Type
      final headers = contentType != null
          ? {'Content-Type': contentType}
          : null;

      await Client().putObjectFile(
        file.path,
        fileKey: key,
        option: PutRequestOption(
          onSendProgress: onProgress,
          aclModel: AclMode.publicRead, // 公共读取，支持直接 URL 访问
          headers: headers,
        ),
      );
      return key;
    } catch (e) {
      throw OssUploadException('上传失败: $e');
    }
  }

  /// 上传字节数据到 OSS
  Future<String> uploadBytes({
    required List<int> bytes,
    required String key,
    String? contentType,
    void Function(int bytes, int totalBytes)? onProgress,
  }) async {
    try {
      // 构建请求头，设置 Content-Type
      final headers = contentType != null
          ? {'Content-Type': contentType}
          : null;

      await Client().putObject(
        bytes,
        key,
        option: PutRequestOption(
          onSendProgress: onProgress,
          aclModel: AclMode.publicRead,
          headers: headers,
        ),
      );
      return key;
    } catch (e) {
      throw OssUploadException('上传失败: $e');
    }
  }

  /// 从 OSS 下载文件
  Future<File> downloadFile({
    required String key,
    required String localPath,
    void Function(int bytes, int totalBytes)? onProgress,
  }) async {
    try {
      await Client().downloadObject(
        key,
        localPath,
        onReceiveProgress: onProgress,
      );
      return File(localPath);
    } catch (e) {
      throw OssDownloadException('下载失败: $e');
    }
  }

  /// 获取文件内容（字节）
  Future<List<int>> getFileBytes(String key) async {
    try {
      final response = await Client().getObject(key);
      return response.data;
    } catch (e) {
      throw OssDownloadException('获取文件失败: $e');
    }
  }

  /// 列出 Bucket 中所有文件
  ///
  /// 注意：此方法使用了 dynamic 类型，因为 flutter_oss_aliyun 包的
  /// Client 类可能未在类型定义中完整导出 listFiles 方法。
  /// 这是第三方包的限制，已添加运行时类型检查以确保安全性。
  Future<List<String>> listObjects({String? prefix}) async {
    try {
      // 构建请求参数
      final params = <String, dynamic>{'max-keys': '100'};
      if (prefix != null) {
        params['prefix'] = prefix;
      }

      // 调用 listFiles 并解析响应
      final response = await _listFilesWithTypeSafety(params);
      return response;
    } catch (e) {
      throw OssException('列出文件失败: $e');
    }
  }

  /// 类型安全的 listFiles 调用
  ///
  /// 将 dynamic 调用隔离在此方法中，添加详细的运行时类型检查
  /// TODO: 当 flutter_oss_aliyun 包更新后，移除 dynamic 调用
  Future<List<String>> _listFilesWithTypeSafety(Map<String, dynamic> params) async {
    // dynamic 调用：这是第三方包的限制，包可能未完整导出 API
    // ignore: avoid_dynamic_calls
    final dynamic client = Client();
    // ignore: avoid_dynamic_calls
    final response = await client.listFiles(params);

    // 解析返回的文件列表（带类型检查）
    final List<String> keys = [];

    // 类型安全的响应解析
    if (response == null) {
      return keys;
    }

    // 尝试访问 data 属性
    final dynamic data = response.data;
    if (data == null || data is! Map) {
      return keys;
    }

    final dataMap = data as Map<String, dynamic>;

    // 检查 Contents 字段
    if (!dataMap.containsKey('Contents')) {
      return keys;
    }

    final dynamic contents = dataMap['Contents'];
    if (contents is! List) {
      return keys;
    }

    // 解析每个文件项
    for (var item in contents) {
      if (item is Map<String, dynamic> && item.containsKey('Key')) {
        final dynamic key = item['Key'];
        if (key is String) {
          keys.add(key);
        }
      }
    }

    return keys;
  }

  /// 删除文件
  Future<void> deleteObject(String key) async {
    try {
      await Client().deleteObject(key);
    } catch (e) {
      throw OssException('删除文件失败: $e');
    }
  }

  /// 批量删除文件
  Future<void> deleteObjects(List<String> keys) async {
    try {
      await Client().deleteObjects(keys);
    } catch (e) {
      throw OssException('批量删除失败: $e');
    }
  }

  /// 检查文件是否存在
  Future<bool> doesObjectExist(String key) async {
    try {
      return await Client().doesObjectExist(key);
    } on SocketException catch (e) {
      throw OssException('网络连接失败: $e');
    } on OssException {
      rethrow;
    } catch (e) {
      throw OssException('检查文件是否存在时发生未知错误: $e');
    }
  }

  /// 获取已签名的文件 URL（用于临时访问）
  Future<String> getSignedUrl(String key) async {
    try {
      return await Client().getSignedUrl(key);
    } catch (e) {
      throw OssException('获取签名 URL 失败: $e');
    }
  }

  /// 获取文件元信息
  Future<Map<String, dynamic>> getObjectMetadata(String key) async {
    try {
      final response = await Client().getObjectMeta(key);
      return response.data;
    } catch (e) {
      throw OssException('获取文件元信息失败: $e');
    }
  }

  /// 构建公共访问 URL（适用于 public-read 文件）
  ///
  /// 阿里云 OSS 的公共 URL 格式: https://{bucket}.{endpoint}/{key}
  /// 注意: endpoint 通常包含协议，需要移除 https:// 前缀
  String getPublicUrl(String key) {
    // 移除 endpoint 的协议前缀
    final cleanEndpoint = endpoint.replaceFirst('https://', '').replaceFirst('http://', '');
    return 'https://$bucket.$cleanEndpoint/$key';
  }
}

/// OSS 上传异常
class OssUploadException implements Exception {
  final String message;
  OssUploadException(this.message);

  @override
  String toString() => message;
}

/// OSS 下载异常
class OssDownloadException implements Exception {
  final String message;
  OssDownloadException(this.message);

  @override
  String toString() => message;
}

/// OSS 通用异常
class OssException implements Exception {
  final String message;
  OssException(this.message);

  @override
  String toString() => message;
}
