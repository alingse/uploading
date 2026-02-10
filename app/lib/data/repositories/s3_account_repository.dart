import '../../domain/entities/s3_account.dart';
import '../../domain/repositories/s3_account_repository.dart';
import '../../services/secure_storage_service.dart';
import '../datasources/local/dao/s3_account_dao.dart';
import '../models/s3_account_model.dart';

/// S3 凭证缺失异常
class S3CredentialsMissingException implements Exception {
  final String accountId;
  S3CredentialsMissingException(this.accountId);

  @override
  String toString() => 'S3 凭证缺失: 账户 $accountId 的凭证未找到，请重新配置';
}

/// S3 账户仓储实现
///
/// 组合使用 S3AccountDao 和 SecureStorageService
/// - 数据库存储：账户基本信息（不包括凭证）
/// - 安全存储：accessKey 和 secretKey（唯一存储位置）
class S3AccountRepositoryImpl implements S3AccountRepository {
  final S3AccountDao _dao;
  final SecureStorageService _secureStorage;

  S3AccountRepositoryImpl({
    required S3AccountDao dao,
    SecureStorageService? secureStorage,
  }) : _dao = dao,
       _secureStorage = secureStorage ?? SecureStorageService.instance;

  @override
  Future<List<S3Account>> getAllAccounts() async {
    final maps = await _dao.getAll();
    final accounts = <S3Account>[];

    for (final map in maps) {
      final model = S3AccountModel.fromJson(map);
      // 从 SecureStorage 获取凭证
      final credentials = await _secureStorage.getS3Credentials(map['id']);

      // 检查凭证是否缺失
      final accountId = map['id'] as String;
      _validateCredentials(credentials, accountId);

      // 合并数据
      final account = model.toEntity(
        accessKey: credentials['accessKey']!,
        secretKey: credentials['secretKey']!,
      );
      accounts.add(account);
    }

    return accounts;
  }

  @override
  Future<S3Account?> getActiveAccount() async {
    final map = await _dao.getActiveAccount();
    if (map == null) return null;

    final model = S3AccountModel.fromJson(map);
    // 从 SecureStorage 获取凭证
    final credentials = await _secureStorage.getS3Credentials(map['id']);

    // 检查凭证是否缺失
    final accountId = map['id'] as String;
    _validateCredentials(credentials, accountId);

    // 合并数据返回完整实体
    return model.toEntity(
      accessKey: credentials['accessKey']!,
      secretKey: credentials['secretKey']!,
    );
  }

  @override
  Future<S3Account?> getAccountById(String id) async {
    final map = await _dao.getById(id);
    if (map == null) return null;

    final model = S3AccountModel.fromJson(map);
    // 从 SecureStorage 获取凭证
    final credentials = await _secureStorage.getS3Credentials(id);

    // 检查凭证是否缺失
    _validateCredentials(credentials, id);

    // 合并数据返回完整实体
    return model.toEntity(
      accessKey: credentials['accessKey']!,
      secretKey: credentials['secretKey']!,
    );
  }

  /// 验证凭证是否完整
  void _validateCredentials(Map<String, String?> credentials, String accountId) {
    if (credentials['accessKey'] == null || credentials['accessKey']!.isEmpty) {
      throw S3CredentialsMissingException(accountId);
    }
    if (credentials['secretKey'] == null || credentials['secretKey']!.isEmpty) {
      throw S3CredentialsMissingException(accountId);
    }
  }

  @override
  Future<void> addAccount(S3Account account) async {
    // 先存储凭证到安全存储
    await _secureStorage.saveS3Credentials(account);
    // 再存储非敏感信息到数据库
    final model = S3AccountModel.fromEntity(account);
    await _dao.insert(model.toJson());
  }

  @override
  Future<void> updateAccount(S3Account account) async {
    // 更新安全存储中的凭证
    await _secureStorage.saveS3Credentials(account);
    // 更新数据库中的非敏感信息
    final model = S3AccountModel.fromEntity(account);
    await _dao.update(account.id, model.toJson());
  }

  @override
  Future<void> deleteAccount(String id) async {
    // 先删除安全存储中的凭证
    await _secureStorage.deleteS3Credentials(id);
    // 再删除数据库记录
    await _dao.delete(id);
  }

  @override
  Future<void> setActiveAccount(String id) async {
    await _dao.setActiveAccount(id);
  }

  /// 迁移方法：从旧版本数据库（包含凭证）迁移到新版本
  /// 迁移完成后，所有凭证将仅存储在 SecureStorage 中
  Future<void> migrateFromOldVersion() async {
    // 检查是否需要迁移
    final hasOldColumns = await _dao.hasCredentialsColumns();
    if (!hasOldColumns) {
      // 数据库已经是新版本，无需迁移
      return;
    }

    // 获取所有账户（包括凭证）
    final allAccounts = await _dao.getAll();
    for (final accountMap in allAccounts) {
      final id = accountMap['id'] as String;

      // 检查 SecureStorage 中是否已有凭证
      final credentials = await _secureStorage.getS3Credentials(id);
      final hasCredentialsInSecureStorage =
          credentials['accessKey'] != null &&
          credentials['accessKey']!.isNotEmpty;

      // 如果 SecureStorage 中没有凭证，且数据库中有凭证，则迁移
      if (!hasCredentialsInSecureStorage &&
          accountMap.containsKey('access_key')) {
        final accessKey = accountMap['access_key'] as String;
        final secretKey = accountMap['secret_key'] as String;

        // 创建临时 S3Account 对象用于保存凭证
        final tempAccount = S3Account(
          id: id,
          accountName: accountMap['account_name'] as String,
          endpoint: accountMap['endpoint'] as String,
          accessKey: accessKey,
          secretKey: secretKey,
          bucket: accountMap['bucket'] as String,
          region: accountMap['region'] as String,
          isActive: (accountMap['is_active'] as int) == 1,
          lastSyncedAt: accountMap['last_synced_at'] != null
              ? DateTime.fromMillisecondsSinceEpoch(
                  accountMap['last_synced_at'] as int,
                )
              : null,
          createdAt: DateTime.fromMillisecondsSinceEpoch(
            accountMap['created_at'] as int,
          ),
        );

        // 保存凭证到 SecureStorage
        await _secureStorage.saveS3Credentials(tempAccount);
      }
    }
  }
}
