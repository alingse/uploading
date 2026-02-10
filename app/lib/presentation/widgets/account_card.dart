import 'package:flutter/material.dart';
import '../../../domain/entities/s3_account.dart';

/// 账户卡片组件
///
/// 显示单个 S3 账户的信息
class AccountCard extends StatelessWidget {
  /// 账户信息
  final S3Account account;

  /// 点击回调
  final VoidCallback onTap;

  /// 是否可以滑动删除
  final bool enableSlideToDelete;

  /// 删除回调
  final VoidCallback? onDelete;

  const AccountCard({
    super.key,
    required this.account,
    required this.onTap,
    this.enableSlideToDelete = true,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget cardChild = Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: ListTile(
        leading: Icon(
          account.isActive ? Icons.check_circle : Icons.cloud_outlined,
          color: account.isActive
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurface.withValues(alpha: 0.6),
        ),
        title: Text(
          account.accountName,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: account.isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Bucket: ${account.bucket}', style: theme.textTheme.bodySmall),
            Text('区域: ${account.region}', style: theme.textTheme.bodySmall),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (account.isActive)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '当前',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ],
        ),
        onTap: onTap,
      ),
    );

    if (enableSlideToDelete && onDelete != null) {
      return Dismissible(
        key: Key(account.id),
        direction: DismissDirection.endToStart,
        onDismissed: (_) => onDelete!(),
        background: Container(
          alignment: AlignmentDirectional.centerEnd,
          padding: const EdgeInsets.only(right: 20),
          color: theme.colorScheme.error,
          child: Icon(Icons.delete, color: theme.colorScheme.onError),
        ),
        child: cardChild,
      );
    }

    return cardChild;
  }
}
