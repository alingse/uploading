import 'package:sqflite/sqflite.dart';
import '../app_database.dart';

/// S3 账户操作异常
class S3AccountException implements Exception {
  final String message;
  S3AccountException(this.message);

  @override
  String toString() => 'S3AccountException: $message';
}

/// S3 账户数据访问对象
class S3AccountDao {
  final AppDatabase _database = AppDatabase.instance;

  /// 插入账户
  Future<int> insert(Map<String, dynamic> account) async {
    final db = await _database.database;
    return await db.insert(
      's3_accounts',
      account,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// 根据 ID 查询账户（排除凭证）
  Future<Map<String, dynamic>?> getById(String id) async {
    final db = await _database.database;
    final results = await db.query(
      's3_accounts',
      columns: const [
        // 明确指定列，排除凭证
        'id',
        'account_name',
        'endpoint',
        'bucket',
        'region',
        'is_active',
        'last_synced_at',
        'created_at',
      ],
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return results.isNotEmpty ? results.first : null;
  }

  /// 获取当前激活的账户（排除凭证）
  Future<Map<String, dynamic>?> getActiveAccount() async {
    final db = await _database.database;
    final results = await db.query(
      's3_accounts',
      columns: const [
        // 明确指定列，排除凭证
        'id',
        'account_name',
        'endpoint',
        'bucket',
        'region',
        'is_active',
        'last_synced_at',
        'created_at',
      ],
      where: 'is_active = ?',
      whereArgs: [1],
      limit: 1,
    );
    return results.isNotEmpty ? results.first : null;
  }

  /// 获取所有账户（排除凭证）
  Future<List<Map<String, dynamic>>> getAll() async {
    final db = await _database.database;
    return await db.query(
      's3_accounts',
      columns: const [
        // 明确指定列，排除凭证
        'id',
        'account_name',
        'endpoint',
        'bucket',
        'region',
        'is_active',
        'last_synced_at',
        'created_at',
      ],
      orderBy: 'created_at DESC',
    );
  }

  /// 更新账户
  Future<int> update(String id, Map<String, dynamic> values) async {
    final db = await _database.database;
    return await db.update(
      's3_accounts',
      values,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// 设置激活账户（取消其他账户的激活状态）
  Future<void> setActiveAccount(String id) async {
    final db = await _database.database;

    try {
      await db.transaction((txn) async {
        // 取消所有账户的激活状态
        await txn.update('s3_accounts', {'is_active': 0});

        // 设置指定账户为激活
        final rowsUpdated = await txn.update(
          's3_accounts',
          {'is_active': 1},
          where: 'id = ?',
          whereArgs: [id],
        );

        // 验证账户是否存在
        if (rowsUpdated == 0) {
          throw S3AccountException('账户不存在: $id');
        }
      });
    } on S3AccountException {
      rethrow;
    } catch (e) {
      throw S3AccountException('设置激活账户失败: $e');
    }
  }

  /// 删除账户
  Future<int> delete(String id) async {
    final db = await _database.database;
    return await db.delete('s3_accounts', where: 'id = ?', whereArgs: [id]);
  }

  /// 更新账户的最后同步时间
  Future<void> updateLastSyncTime(String id, DateTime syncTime) async {
    await update(id, {'last_synced_at': syncTime.millisecondsSinceEpoch});
  }

  /// 检查数据库中是否存在 access_key 和 secret_key 列（用于迁移验证）
  Future<bool> hasCredentialsColumns() async {
    final db = await _database.database;
    final result = await db.rawQuery("PRAGMA table_info(s3_accounts)");

    final columns = result.map((col) => col['name'] as String).toList();
    return columns.contains('access_key') && columns.contains('secret_key');
  }

  /// 获取包含凭证的账户（仅用于迁移，从旧版本数据库）
  /// 迁移完成后不再使用
  Future<Map<String, dynamic>?> getByIdWithCredentials(String id) async {
    final db = await _database.database;
    final results = await db.query(
      's3_accounts',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return results.isNotEmpty ? results.first : null;
  }
}
