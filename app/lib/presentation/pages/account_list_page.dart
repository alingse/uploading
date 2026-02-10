import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/s3_account.dart';
import '../../../data/repositories/s3_account_repository.dart';
import '../providers/s3_account_provider.dart';
import '../widgets/account_card.dart';
import 'account_edit_page.dart';

/// 账户列表页面
///
/// 显示所有已配置的云存储账户
class AccountListPage extends ConsumerWidget {
  const AccountListPage({super.key});

  /// 将内部错误转换为用户友好的错误消息
  String _getErrorMessage(Object error) {
    // 使用异常类型匹配，而不是字符串匹配
    if (error is S3CredentialsMissingException) {
      return '账户凭证未找到，请重新登录账户';
    }
    if (error.toString().contains('S3AccountException')) {
      return '账户操作失败，请重试';
    }
    if (error.toString().contains('Database') ||
        error.toString().contains('sqlite')) {
      return '数据库错误，请重启应用';
    }
    // 默认通用错误消息
    return '加载账户列表时出错，请稍后重试';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(accountListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('云存储账户')),
      body: accountsAsync.when(
        data: (accounts) {
          if (accounts.isEmpty) {
            return _EmptyState(onAdd: () => _navigateToEdit(context));
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: accounts.length,
            itemBuilder: (context, index) {
              return AccountCard(
                account: accounts[index],
                onTap: () => _showOptions(context, ref, accounts[index]),
                onDelete: () =>
                    _confirmDelete(context, ref, accounts[index].id),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('加载失败', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(
                _getErrorMessage(error),
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () {
                  ref.invalidate(accountListProvider);
                },
                icon: const Icon(Icons.refresh),
                label: const Text('重试'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToEdit(context),
        icon: const Icon(Icons.add),
        label: const Text('添加账户'),
      ),
    );
  }

  /// 导航到编辑页面
  void _navigateToEdit(BuildContext context, [String? accountId]) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AccountEditPage(accountId: accountId)),
    );
  }

  /// 显示账户选项
  void _showOptions(BuildContext context, WidgetRef ref, S3Account account) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('编辑'),
              onTap: () {
                Navigator.pop(context);
                _navigateToEdit(context, account.id);
              },
            ),
            if (!account.isActive)
              ListTile(
                leading: const Icon(Icons.check_circle),
                title: const Text('设为当前账户'),
                onTap: () async {
                  Navigator.pop(context);
                  try {
                    await ref
                        .read(accountListProvider.notifier)
                        .setActiveAccount(account.id);
                    if (context.mounted) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(const SnackBar(content: Text('已切换账户')));
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text('切换失败: $e')));
                    }
                  }
                },
              ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('删除', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(context, ref, account.id);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 确认删除
  void _confirmDelete(BuildContext context, WidgetRef ref, String accountId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除这个账户吗？此操作无法撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ref
                    .read(accountListProvider.notifier)
                    .deleteAccount(accountId);
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('账户已删除')));
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('删除失败: $e')));
                }
              }
            },
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
}

/// 空状态组件
class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.cloud_off,
            size: 80,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 24),
          Text('还没有配置云存储账户', style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            '添加阿里云 OSS 账户以同步数据',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: const Text('添加账户'),
          ),
        ],
      ),
    );
  }
}
