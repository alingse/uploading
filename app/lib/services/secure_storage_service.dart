import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../domain/entities/s3_account.dart';

/// 安全存储服务
///
/// 使用 flutter_secure_storage 安全存储敏感信息（如 S3 凭证）
class SecureStorageService {
  final _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  // 私有构造函数
  SecureStorageService._();

  // 单例实例
  static final SecureStorageService instance = SecureStorageService._();

  /// 保存 S3 账户的凭证
  Future<void> saveS3Credentials(S3Account account) async {
    await _secureStorage.write(
      key: 's3_account_${account.id}_access_key',
      value: account.accessKey,
    );
    await _secureStorage.write(
      key: 's3_account_${account.id}_secret_key',
      value: account.secretKey,
    );
  }

  /// 获取 S3 账户的凭证
  ///
  /// 返回值说明：
  /// - 如果凭证存在，返回包含凭证的 Map
  /// - 如果凭证不存在，对应的值为 null（而非空字符串）
  /// - 调用者应检查返回值是否为 null 来判断凭证是否缺失
  Future<Map<String, String?>> getS3Credentials(String accountId) async {
    final accessKey = await _secureStorage.read(
      key: 's3_account_${accountId}_access_key',
    );
    final secretKey = await _secureStorage.read(
      key: 's3_account_${accountId}_secret_key',
    );

    return {'accessKey': accessKey, 'secretKey': secretKey};
  }

  /// 删除 S3 账户的凭证
  Future<void> deleteS3Credentials(String accountId) async {
    await _secureStorage.delete(key: 's3_account_${accountId}_access_key');
    await _secureStorage.delete(key: 's3_account_${accountId}_secret_key');
  }

  /// 保存通用键值对
  Future<void> set(String key, String value) async {
    await _secureStorage.write(key: key, value: value);
  }

  /// 获取通用键值对
  Future<String?> get(String key) async {
    return await _secureStorage.read(key: key);
  }

  /// 删除通用键值对
  Future<void> delete(String key) async {
    await _secureStorage.delete(key: key);
  }

  /// 清空所有数据
  Future<void> clearAll() async {
    await _secureStorage.deleteAll();
  }

  /// 检查键是否存在
  Future<bool> containsKey(String key) async {
    final value = await _secureStorage.read(key: key);
    return value != null;
  }
}
