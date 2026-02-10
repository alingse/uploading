import '../entities/s3_account.dart';

/// S3 账户仓储接口
///
/// 定义 S3 账户数据访问的抽象操作
abstract class S3AccountRepository {
  /// 获取所有账户
  Future<List<S3Account>> getAllAccounts();

  /// 获取当前激活的账户
  Future<S3Account?> getActiveAccount();

  /// 根据 ID 获取账户
  Future<S3Account?> getAccountById(String id);

  /// 添加新账户
  Future<void> addAccount(S3Account account);

  /// 更新账户
  Future<void> updateAccount(S3Account account);

  /// 删除账户
  Future<void> deleteAccount(String id);

  /// 设置激活账户
  Future<void> setActiveAccount(String id);
}
