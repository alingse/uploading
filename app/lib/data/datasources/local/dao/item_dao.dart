import 'package:sqflite/sqflite.dart';
import '../app_database.dart';

/// 物品数据访问对象
class ItemDao {
  final AppDatabase _database = AppDatabase.instance;

  /// 插入物品
  Future<int> insert(Map<String, dynamic> item) async {
    final db = await _database.database;
    return await db.insert(
      'items',
      item,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// 批量插入物品
  Future<void> insertBatch(List<Map<String, dynamic>> items) async {
    final db = await _database.database;
    final batch = db.batch();
    for (var item in items) {
      batch.insert('items', item, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  /// 根据 ID 查询物品
  Future<Map<String, dynamic>?> getById(String id) async {
    final db = await _database.database;
    final results = await db.query(
      'items',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return results.isNotEmpty ? results.first : null;
  }

  /// 查询所有物品
  Future<List<Map<String, dynamic>>> getAll() async {
    final db = await _database.database;
    return await db.query('items', orderBy: 'created_at DESC');
  }

  /// 根据 presence 状态查询物品
  Future<List<Map<String, dynamic>>> getByPresence(String presence) async {
    final db = await _database.database;
    return await db.query(
      'items',
      where: 'presence = ?',
      whereArgs: [presence],
      orderBy: 'created_at DESC',
    );
  }

  /// 更新物品
  Future<int> update(String id, Map<String, dynamic> values) async {
    final db = await _database.database;
    return await db.update('items', values, where: 'id = ?', whereArgs: [id]);
  }

  /// 删除物品
  Future<int> delete(String id) async {
    final db = await _database.database;
    return await db.delete('items', where: 'id = ?', whereArgs: [id]);
  }

  /// 获取物品数量
  Future<int> count() async {
    final db = await _database.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM items');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// 根据关键字搜索物品（备注或标签）
  Future<List<Map<String, dynamic>>> search(String keyword) async {
    final db = await _database.database;
    final pattern = '%$keyword%';
    return await db.rawQuery(
      '''
      SELECT DISTINCT items.* FROM items
      LEFT JOIN tags ON items.id = tags.item_id
      WHERE items.notes LIKE ?
         OR tags.tag_name LIKE ?
      ORDER BY items.created_at DESC
    ''',
      [pattern, pattern],
    );
  }
}
