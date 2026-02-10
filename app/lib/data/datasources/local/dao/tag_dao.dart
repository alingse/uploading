import 'package:sqflite/sqflite.dart';
import '../app_database.dart';

/// 标签数据访问对象
class TagDao {
  final AppDatabase _database = AppDatabase.instance;

  /// 插入标签
  Future<int> insert(Map<String, dynamic> tag) async {
    final db = await _database.database;
    return await db.insert(
      'tags',
      tag,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// 批量插入标签
  Future<void> insertBatch(List<Map<String, dynamic>> tags) async {
    final db = await _database.database;
    final batch = db.batch();
    for (var tag in tags) {
      batch.insert('tags', tag, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  /// 根据物品 ID 查询所有标签
  Future<List<Map<String, dynamic>>> getByItemId(String itemId) async {
    final db = await _database.database;
    return await db.query('tags', where: 'item_id = ?', whereArgs: [itemId]);
  }

  /// 删除标签
  Future<int> delete(int id) async {
    final db = await _database.database;
    return await db.delete('tags', where: 'id = ?', whereArgs: [id]);
  }

  /// 删除物品的所有标签
  Future<int> deleteByItemId(String itemId) async {
    final db = await _database.database;
    return await db.delete('tags', where: 'item_id = ?', whereArgs: [itemId]);
  }

  /// 获取所有不重复的标签
  Future<List<String>> getAllUniqueTags() async {
    final db = await _database.database;
    final results = await db.rawQuery(
      'SELECT DISTINCT tag_name FROM tags ORDER BY tag_name',
    );
    return results.map((row) => row['tag_name'] as String).toList();
  }

  /// 根据标签名查询物品 ID
  Future<List<String>> getItemIdsByTag(String tagName) async {
    final db = await _database.database;
    final results = await db.query(
      'tags',
      where: 'tag_name = ?',
      whereArgs: [tagName],
      columns: ['item_id'],
    );
    return results.map((row) => row['item_id'] as String).toList();
  }
}
