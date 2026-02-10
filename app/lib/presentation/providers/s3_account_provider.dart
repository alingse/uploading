import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/datasources/local/dao/s3_account_dao.dart';
import '../../../data/repositories/s3_account_repository.dart';
import '../../../domain/entities/s3_account.dart';
import '../../../domain/repositories/s3_account_repository.dart';

part 's3_account_provider.g.dart';

/// S3 账户仓储 Provider
@riverpod
S3AccountRepository s3AccountRepository(S3AccountRepositoryRef ref) {
  return S3AccountRepositoryImpl(dao: S3AccountDao());
}

/// 账户列表 Provider
///
/// 管理所有 S3 账户的状态
@riverpod
class AccountList extends _$AccountList {
  @override
  Future<List<S3Account>> build() async {
    final repo = ref.read(s3AccountRepositoryProvider);
    return await repo.getAllAccounts();
  }

  /// 添加账户
  Future<void> addAccount(S3Account account) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(s3AccountRepositoryProvider);
      await repo.addAccount(account);
      return await repo.getAllAccounts();
    });
  }

  /// 更新账户
  Future<void> updateAccount(S3Account account) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(s3AccountRepositoryProvider);
      await repo.updateAccount(account);
      return await repo.getAllAccounts();
    });
  }

  /// 删除账户
  Future<void> deleteAccount(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(s3AccountRepositoryProvider);
      await repo.deleteAccount(id);
      return await repo.getAllAccounts();
    });
  }

  /// 设置激活账户
  Future<void> setActiveAccount(String id) async {
    final repo = ref.read(s3AccountRepositoryProvider);
    await repo.setActiveAccount(id);
    ref.invalidate(accountListProvider);
  }

  /// 刷新列表
  Future<void> refresh() async {
    ref.invalidate(accountListProvider);
  }
}

/// 当前激活账户 Provider
///
/// 提供当前激活的 S3 账户
@riverpod
Future<S3Account?> activeAccount(ActiveAccountRef ref) async {
  final repo = ref.read(s3AccountRepositoryProvider);
  return await repo.getActiveAccount();
}

/// 根据 ID 获取账户 Provider
///
/// 提供根据 ID 获取单个账户的能力
@riverpod
Future<S3Account?> accountById(AccountByIdRef ref, String id) async {
  final repo = ref.read(s3AccountRepositoryProvider);
  return await repo.getAccountById(id);
}
