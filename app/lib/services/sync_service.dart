import 'dart:io';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uploading/core/config/app_config.dart';
import '../data/datasources/local/app_database.dart';
import '../data/datasources/local/dao/sync_metadata_dao.dart';
import '../data/datasources/local/dao/photo_dao.dart';
import 'oss_service.dart';

/// 同步阶段
enum SyncStage {
  /// 准备中
  preparing,

  /// 下载中
  downloading,

  /// 上传中
  uploading,

  /// 上传照片中
  uploadingPhotos,

  /// 完成中
  finalizing,

  /// 完成
  completed,

  /// 失败
  failed,
}

/// 同步进度
class SyncProgress {
  final SyncStage stage;
  final double progress; // 0.0 - 1.0
  final String? error;
  final String? warning; // 警告信息（不中断流程，但需要用户注意）

  SyncProgress({
    required this.stage,
    required this.progress,
    this.error,
    this.warning,
  });

  @override
  String toString() {
    return 'SyncProgress(stage: $stage, progress: $progress, error: $error, warning: $warning)';
  }

  /// 是否有警告需要用户注意
  bool get hasWarning => warning != null && warning!.isNotEmpty;
}

/// 同步服务
///
/// 处理本地数据库与阿里云 OSS 之间的数据同步
class SyncService {
  final OssService ossService;
  final AppDatabase database;

  SyncService({required this.ossService, required this.database});

  final SyncMetadataDao _metadataDao = SyncMetadataDao();
  final PhotoDao _photoDao = PhotoDao();

  /// 执行同步
  Stream<SyncProgress> sync({required String accountId}) async* {
    yield SyncProgress(stage: SyncStage.preparing, progress: 0.0);

    try {
      // 1. 下载远程变更
      yield SyncProgress(stage: SyncStage.downloading, progress: 0.2);
      await _pullRemoteChanges(accountId);

      // 2. 上传本地变更
      yield SyncProgress(stage: SyncStage.uploading, progress: 0.5);
      await _pushLocalChanges(accountId);

      // 3. 上传待处理的照片
      yield SyncProgress(stage: SyncStage.uploadingPhotos, progress: 0.8);
      final warning = await _uploadPendingPhotos();

      // 4. 更新同步元数据
      yield SyncProgress(stage: SyncStage.finalizing, progress: 0.95);
      await _metadataDao.setLastSyncTime(accountId, DateTime.now());

      // 完成时如果有警告，传递给用户
      yield SyncProgress(
        stage: SyncStage.completed,
        progress: 1.0,
        warning: warning,
      );
    } catch (e) {
      yield SyncProgress(
        stage: SyncStage.failed,
        progress: 0,
        error: e.toString(),
      );
    }
  }

  /// 拉取远程变更
  Future<void> _pullRemoteChanges(String accountId) async {
    // TODO: 实现 OSS 下载和合并逻辑
    // 1. 从 OSS 下载远程数据库
    // 2. 打开下载的数据库并合并变更
    // 3. 比较 last_synced_at 并解决冲突
  }

  /// 推送本地数据库到 OSS（完整数据库文件）
  Future<void> _pushLocalChanges(String accountId) async {
    // 1. 获取数据库文件路径
    final dbPath = await getDatabasesPath();
    final originalDbPath = '$dbPath/${AppConfig.databaseName}';

    // 2. 生成带时间戳的文件名
    final timestamp = DateFormat('yyyyMMddHHmmss').format(DateTime.now());
    final fileName = 'uploading.db.$timestamp';
    final remotePath = 'accounts/$accountId/database/$fileName';

    // 3. 上传数据库文件到 OSS
    await ossService.uploadFile(file: File(originalDbPath), key: remotePath);
  }

  /// 上传待处理的照片（修复竞态条件）
  ///
  /// 使用状态机 + 乐观锁模式防止并发上传：
  /// 1. pending -> uploading（原子操作，使用 claimPendingPhotosForUpload）
  /// 2. 上传文件
  /// 3. uploading -> completed 或 failed
  ///
  /// 返回：如果有需要用户注意的警告，返回警告消息；否则返回 null
  Future<String?> _uploadPendingPhotos() async {
    const batchSize = 10; // 每批处理的照片数量
    const maxIterations = 100; // 最大迭代次数，防止无限循环
    const emptyResultThreshold = 3; // 连续空结果阈值后退出

    int iteration = 0;
    int emptyResultCount = 0;
    int uploadedCount = 0; // 成功上传的照片数量

    while (iteration < maxIterations) {
      iteration++;

      // 获取待处理照片
      final pendingPhotos = await _photoDao.getPendingPhotos();
      if (pendingPhotos.isEmpty) {
        emptyResultCount++;
        // 连续多次没有待处理照片，安全退出
        if (emptyResultCount >= emptyResultThreshold) {
          break;
        }
        // 等待一小段时间再重试，避免 CPU 占用
        await Future.delayed(const Duration(milliseconds: 100));
        continue;
      }

      // 重置空结果计数器
      emptyResultCount = 0;

      // 取出一批照片 ID
      final batchIds = pendingPhotos
          .take(batchSize)
          .map((p) => p['id'] as String)
          .toList();

      // 原子地声明这些照片由本进程处理（状态机：pending -> uploading）
      // 使用乐观锁：只有状态为 pending 的照片才能被转换
      final claimedCount = await _photoDao.claimPendingPhotosForUpload(
        batchIds,
      );

      if (claimedCount == 0) {
        // 没有成功声明任何照片，说明已被其他进程处理
        // 或者所有照片状态已改变，继续下一轮检查
        continue;
      }

      // 获取成功声明的照片（状态为 uploading）
      final db = await database.database;
      final placeholders = List.filled(batchIds.length, '?');
      final claimedPhotos = await db.query(
        'photos',
        where: 'id IN (${placeholders.join(',')}) AND upload_status = ?',
        whereArgs: [...batchIds, 'uploading'],
      );

      // 逐个上传
      for (var photo in claimedPhotos) {
        final photoId = photo['id'] as String;
        final localPath = photo['local_path'] as String?;

        if (localPath != null) {
          final file = File(localPath);
          if (await file.exists()) {
            try {
              await ossService.uploadFile(
                file: file,
                key: photo['s3_key'] as String,
              );
              // 成功：状态 uploading -> completed
              await _photoDao.update(photoId, {'upload_status': 'completed'});
              uploadedCount++;
            } catch (e) {
              // 失败：重置为 pending 允许重试
              await _photoDao.update(photoId, {'upload_status': 'pending'});
            }
          } else {
            // 文件不存在，标记为失败
            await _photoDao.update(photoId, {'upload_status': 'failed'});
          }
        }
      }
    }

    // 如果达到最大迭代次数，返回警告信息给用户
    if (iteration >= maxIterations) {
      // 检查是否还有待处理的照片
      final remainingPending = await _photoDao.getPendingPhotos();
      if (remainingPending.isNotEmpty) {
        return '本次同步已处理 $uploadedCount 张照片，但还有 ${remainingPending.length} 张照片待处理。'
            '请稍后再次同步以完成剩余照片的上传。';
      }
    }

    return null;
  }
}
