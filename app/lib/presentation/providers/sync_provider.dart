import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uploading/services/auto_sync_manager.dart';

part 'sync_provider.g.dart';

/// 自动同步管理器 Provider
///
/// 提供 AutoSyncManager 单例
@riverpod
AutoSyncManager autoSyncManager(AutoSyncManagerRef ref) {
  return AutoSyncManager.instance;
}

/// 最后同步时间 Provider
///
/// 提供最后同步的时间戳
@riverpod
DateTime? lastSyncTime(LastSyncTimeRef ref) {
  final manager = ref.watch(autoSyncManagerProvider);
  return manager.lastSyncTime;
}
