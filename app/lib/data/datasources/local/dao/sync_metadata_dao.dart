import 'package:sqflite/sqflite.dart';
import '../app_database.dart';

/// 同步元数据数据访问对象
class SyncMetadataDao {
  final AppDatabase _database = AppDatabase.instance;

  /// 设置元数据
  Future<void> set(String key, String value) async {
    final db = await _database.database;
    final now = DateTime.now().millisecondsSinceEpoch;
    await db.insert('sync_metadata', {
      'key': key,
      'value': value,
      'updated_at': now,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// 获取元数据
  Future<String?> get(String key) async {
    final db = await _database.database;
    final results = await db.query(
      'sync_metadata',
      where: 'key = ?',
      whereArgs: [key],
      limit: 1,
    );
    if (results.isEmpty) return null;
    return results.first['value'] as String?;
  }

  /// 获取元数据的更新时间
  Future<DateTime?> getUpdatedAt(String key) async {
    final db = await _database.database;
    final results = await db.query(
      'sync_metadata',
      where: 'key = ?',
      whereArgs: [key],
      columns: ['updated_at'],
      limit: 1,
    );
    if (results.isEmpty) return null;
    final timestamp = results.first['updated_at'] as int;
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  /// 删除元数据
  Future<int> delete(String key) async {
    final db = await _database.database;
    return await db.delete('sync_metadata', where: 'key = ?', whereArgs: [key]);
  }

  /// 获取最后同步时间（指定账户）
  Future<DateTime> getLastSyncTime(String accountId) async {
    final key = 'last_sync_$accountId';
    final timestamp = await get(key);
    if (timestamp == null) return DateTime.fromMillisecondsSinceEpoch(0);
    return DateTime.fromMillisecondsSinceEpoch(int.parse(timestamp));
  }

  /// 设置最后同步时间
  Future<void> setLastSyncTime(String accountId, DateTime syncTime) async {
    final key = 'last_sync_$accountId';
    await set(key, syncTime.millisecondsSinceEpoch.toString());
  }
}
