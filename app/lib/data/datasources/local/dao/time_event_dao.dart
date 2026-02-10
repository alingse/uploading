import 'package:sqflite/sqflite.dart';
import '../app_database.dart';

/// 时间事件数据访问对象
class TimeEventDao {
  final AppDatabase _database = AppDatabase.instance;

  /// 插入时间事件
  Future<int> insert(Map<String, dynamic> event) async {
    final db = await _database.database;
    return await db.insert(
      'time_events',
      event,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// 批量插入时间事件
  Future<void> insertBatch(List<Map<String, dynamic>> events) async {
    final db = await _database.database;
    final batch = db.batch();
    for (var event in events) {
      batch.insert(
        'time_events',
        event,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  /// 根据 ID 查询时间事件
  Future<Map<String, dynamic>?> getById(String id) async {
    final db = await _database.database;
    final results = await db.query(
      'time_events',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return results.isNotEmpty ? results.first : null;
  }

  /// 根据物品 ID 查询所有时间事件
  Future<List<Map<String, dynamic>>> getByItemId(String itemId) async {
    final db = await _database.database;
    return await db.query(
      'time_events',
      where: 'item_id = ?',
      whereArgs: [itemId],
      orderBy: 'datetime DESC',
    );
  }

  /// 更新时间事件
  Future<int> update(String id, Map<String, dynamic> values) async {
    final db = await _database.database;
    return await db.update(
      'time_events',
      values,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// 删除时间事件
  Future<int> delete(String id) async {
    final db = await _database.database;
    return await db.delete('time_events', where: 'id = ?', whereArgs: [id]);
  }

  /// 删除物品的所有时间事件
  Future<int> deleteByItemId(String itemId) async {
    final db = await _database.database;
    return await db.delete(
      'time_events',
      where: 'item_id = ?',
      whereArgs: [itemId],
    );
  }
}
