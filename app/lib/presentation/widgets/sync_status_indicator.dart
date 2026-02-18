import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uploading/presentation/providers/sync_provider.dart';
import 'package:uploading/services/auto_sync_manager.dart';

/// 同步状态指示器
///
/// 在 AppBar 中显示当前同步状态
class SyncStatusIndicator extends ConsumerWidget {
  const SyncStatusIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final manager = ref.watch(autoSyncManagerProvider);

    return StreamBuilder<SyncState>(
      stream: manager.syncStateStream,
      initialData: SyncState.idle,
      builder: (context, snapshot) {
        final state = snapshot.data ?? SyncState.idle;

        switch (state) {
          case SyncState.idle:
            // 空闲状态不显示任何图标
            return const SizedBox.shrink();
          case SyncState.syncing:
            // 同步中：显示旋转的加载图标
            return const _SyncingIcon();
          case SyncState.completed:
            // 完成：显示勾选图标（短暂显示）
            return const _CompletedIcon();
          case SyncState.failed:
            // 失败：显示警告图标（可点击重试）
            return _FailedIcon(
              onRetry: () async {
                final manager = ref.read(autoSyncManagerProvider);
                await manager.retrySync();
              },
            );
        }
      },
    );
  }
}

/// 同步中的图标
class _SyncingIcon extends StatelessWidget {
  const _SyncingIcon();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

/// 完成的图标
class _CompletedIcon extends StatelessWidget {
  const _CompletedIcon();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Icon(
        Icons.check_circle,
        color: Colors.green,
        size: 20,
      ),
    );
  }
}

/// 失败的图标
class _FailedIcon extends StatelessWidget {
  final VoidCallback onRetry;

  const _FailedIcon({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.warning, color: Colors.orange, size: 20),
      tooltip: '同步失败，点击重试',
      onPressed: onRetry,
    );
  }
}
