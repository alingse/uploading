import 'dart:async';
import 'package:uploading/data/datasources/local/app_database.dart';
import 'package:uploading/data/datasources/local/dao/s3_account_dao.dart';
import 'package:uploading/domain/entities/s3_account.dart';
import 'package:uploading/services/oss_service.dart';
import 'package:uploading/services/secure_storage_service.dart';
import 'package:uploading/services/sync_service.dart';
import 'package:uploading/services/logging_service.dart';

/// 同步状态
enum SyncState {
  /// 空闲
  idle,

  /// 同步中
  syncing,

  /// 完成
  completed,

  /// 失败
  failed,
}

/// 自动同步管理器
///
/// 负责管理自动同步的触发和状态
class AutoSyncManager {
  /// 单例
  AutoSyncManager._internal();
  static final AutoSyncManager instance = AutoSyncManager._internal();

  /// 同步状态流控制器
  final _syncStateController = StreamController<SyncState>.broadcast();

  /// 同步状态流
  Stream<SyncState> get syncStateStream => _syncStateController.stream;

  /// 当前同步状态
  SyncState _currentState = SyncState.idle;

  /// 当前账户 ID
  String? _currentAccountId;

  /// 上次同步时间
  DateTime? _lastSyncTime;

  /// 防抖定时器（30秒内不重复同步）
  Timer? _debounceTimer;

  /// 防抖时间（秒）
  static const Duration _debounceDuration = Duration(seconds: 30);

  /// 定期同步定时器（10分钟）
  Timer? _periodicTimer;

  /// 定期同步间隔
  static const Duration _periodicSyncInterval = Duration(minutes: 10);

  /// 完成状态显示定时器（短暂显示勾选图标）
  Timer? _completedStateTimer;

  /// 是否正在同步
  bool get isSyncing => _currentState == SyncState.syncing;

  /// 获取最后同步时间
  DateTime? get lastSyncTime => _lastSyncTime;

  /// 获取当前同步状态
  SyncState get currentState => _currentState;

  /// 设置同步状态
  void _setState(SyncState state) {
    if (_currentState != state) {
      _currentState = state;
      _syncStateController.add(state);
      LoggingService().debug('同步状态变更', context: {'state': state.name});
    }
  }

  /// 请求同步（带防抖）
  ///
  /// 如果距离上次同步不到 30 秒，则延迟执行
  /// 如果正在同步，则忽略请求
  Future<void> requestSync(String accountId) async {
    _currentAccountId = accountId;

    // 如果正在同步，忽略请求
    if (isSyncing) {
      LoggingService().debug('同步进行中，忽略请求');
      return;
    }

    // 取消之前的防抖定时器
    _debounceTimer?.cancel();

    // 计算距离上次同步的时间
    if (_lastSyncTime != null) {
      final timeSinceLastSync = DateTime.now().difference(_lastSyncTime!);
      if (timeSinceLastSync < _debounceDuration) {
        LoggingService().debug('防抖：延迟同步', context: {
          'timeSinceLastSync': timeSinceLastSync.inSeconds,
        });
        // 延迟执行
        _debounceTimer = Timer(_debounceDuration - timeSinceLastSync, () {
          _performSync(accountId);
        });
        return;
      }
    }

    // 立即执行同步
    await _performSync(accountId);
  }

  /// 执行同步
  Future<void> _performSync(String accountId) async {
    if (isSyncing) return;

    try {
      _setState(SyncState.syncing);
      LoggingService().info('开始同步', context: {'accountId': accountId});

      // 获取激活账户
      final accountDao = S3AccountDao();
      final accountMap = await accountDao.getActiveAccount();
      if (accountMap == null) {
        throw Exception('没有激活的账户');
      }

      // 从 secure storage 获取凭证
      final storage = SecureStorageService.instance;
      final credentials = await storage.getS3Credentials(accountId);

      if (credentials['accessKey'] == null || credentials['secretKey'] == null) {
        throw Exception('账户凭证不完整');
      }

      // 构建 S3Account 实体
      final account = S3Account(
        id: accountMap['id'] as String,
        accountName: accountMap['account_name'] as String,
        endpoint: accountMap['endpoint'] as String,
        bucket: accountMap['bucket'] as String,
        region: accountMap['region'] as String,
        accessKey: credentials['accessKey']!,
        secretKey: credentials['secretKey']!,
        isActive: accountMap['is_active'] == 1,
        lastSyncedAt: accountMap['last_synced_at'] != null
            ? DateTime.fromMillisecondsSinceEpoch(
                accountMap['last_synced_at'] as int,
              )
            : null,
        createdAt: DateTime.fromMillisecondsSinceEpoch(
          accountMap['created_at'] as int,
        ),
      );

      // 创建 OSS 服务
      final ossService = OssService.fromAccount(account);
      ossService.init();

      // 创建同步服务
      final syncService = SyncService(
        ossService: ossService,
        database: AppDatabase.instance,
      );

      // 执行同步并监听进度
      await for (final progress in syncService.sync(accountId: accountId)) {
        LoggingService().debug('同步进度', context: {
          'stage': progress.stage.name,
          'progress': progress.progress,
        });

        if (progress.error != null) {
          throw Exception(progress.error);
        }
      }

      // 同步完成
      _lastSyncTime = DateTime.now();
      _setState(SyncState.completed);
      LoggingService().info('同步完成', context: {
        'accountId': accountId,
        'timestamp': _lastSyncTime!.toIso8601String(),
      });

      // 短暂显示完成状态后恢复为空闲
      _completedStateTimer?.cancel();
      _completedStateTimer = Timer(const Duration(seconds: 3), () {
        _setState(SyncState.idle);
      });
    } catch (e, stackTrace) {
      LoggingService().error('同步失败', error: e, stackTrace: stackTrace);
      _setState(SyncState.failed);
      _lastSyncTime = null;

      // 短暂显示失败状态后恢复为空闲
      _completedStateTimer?.cancel();
      _completedStateTimer = Timer(const Duration(seconds: 5), () {
        _setState(SyncState.idle);
      });
    }
  }

  /// 启动定期同步
  ///
  /// 每隔指定时间自动同步一次
  void startPeriodicSync(String accountId) {
    _currentAccountId = accountId;
    _periodicTimer?.cancel();

    LoggingService().info('启动定期同步', context: {
      'accountId': accountId,
      'interval': _periodicSyncInterval.inMinutes,
    });

    _periodicTimer = Timer.periodic(_periodicSyncInterval, (_) {
      LoggingService().debug('定期同步触发');
      requestSync(accountId);
    });
  }

  /// 停止定期同步
  void stopPeriodicSync() {
    _periodicTimer?.cancel();
    _periodicTimer = null;
    LoggingService().info('停止定期同步');
  }

  /// 立即重试同步（失败时）
  Future<void> retrySync() async {
    if (_currentAccountId == null) {
      LoggingService().warning('无法重试同步：没有设置账户 ID');
      return;
    }

    // 重置防抖，立即执行
    _lastSyncTime = null;
    await requestSync(_currentAccountId!);
  }

  /// 释放资源
  void dispose() {
    _debounceTimer?.cancel();
    _periodicTimer?.cancel();
    _completedStateTimer?.cancel();
    _syncStateController.close();
  }
}
