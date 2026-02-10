import 'package:sqflite/sqflite.dart';
import '../app_database.dart';

/// 照片数据访问对象
class PhotoDao {
  final AppDatabase _database = AppDatabase.instance;

  /// 插入照片
  Future<int> insert(Map<String, dynamic> photo) async {
    final db = await _database.database;
    return await db.insert(
      'photos',
      photo,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// 批量插入照片
  Future<void> insertBatch(List<Map<String, dynamic>> photos) async {
    final db = await _database.database;
    final batch = db.batch();
    for (var photo in photos) {
      batch.insert(
        'photos',
        photo,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  /// 根据 ID 查询照片
  Future<Map<String, dynamic>?> getById(String id) async {
    final db = await _database.database;
    final results = await db.query(
      'photos',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return results.isNotEmpty ? results.first : null;
  }

  /// 根据物品 ID 查询所有照片
  Future<List<Map<String, dynamic>>> getByItemId(String itemId) async {
    final db = await _database.database;
    return await db.query(
      'photos',
      where: 'item_id = ?',
      whereArgs: [itemId],
      orderBy: 'created_at DESC',
    );
  }

  /// 更新照片
  Future<int> update(String id, Map<String, dynamic> values) async {
    final db = await _database.database;
    return await db.update('photos', values, where: 'id = ?', whereArgs: [id]);
  }

  /// 删除照片
  Future<int> delete(String id) async {
    final db = await _database.database;
    return await db.delete('photos', where: 'id = ?', whereArgs: [id]);
  }

  /// 删除物品的所有照片
  Future<int> deleteByItemId(String itemId) async {
    final db = await _database.database;
    return await db.delete('photos', where: 'item_id = ?', whereArgs: [itemId]);
  }

  /// 获取待上传的照片
  Future<List<Map<String, dynamic>>> getPendingPhotos() async {
    final db = await _database.database;
    return await db.query(
      'photos',
      where: 'upload_status = ?',
      whereArgs: ['pending'],
    );
  }

  /// 获取上传失败的照片
  Future<List<Map<String, dynamic>>> getFailedPhotos() async {
    final db = await _database.database;
    return await db.query(
      'photos',
      where: 'upload_status = ?',
      whereArgs: ['failed'],
    );
  }

  /// 原子地将照片从 pending 状态转换为 uploading 状态
  /// 返回成功转换的照片数量（如果为 0 说明已被其他进程处理）
  ///
  /// 使用乐观锁模式：只有当照片状态为 pending 时才能转换为 uploading
  /// 这防止了多个同步进程同时处理同一张照片的竞态条件
  Future<int> claimPendingPhotosForUpload(List<String> photoIds) async {
    if (photoIds.isEmpty) return 0;

    final db = await _database.database;
    final batch = db.batch();

    for (final id in photoIds) {
      batch.update(
        'photos',
        {'upload_status': 'uploading'},
        where: 'id = ? AND upload_status = ?',
        whereArgs: [id, 'pending'],
      );
    }

    final results = await batch.commit(continueOnError: false);
    return results.whereType<int>().where((r) => r > 0).length;
  }
}
