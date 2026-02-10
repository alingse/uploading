import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:uploading/core/config/app_config.dart';

/// 应用数据库
///
/// SQLite 数据库的单例管理类
class AppDatabase {
  // 私有构造函数
  AppDatabase._internal();

  // 单例实例
  static final AppDatabase instance = AppDatabase._internal();

  // 数据库实例
  static Database? _database;

  // 可注入的数据库实例（用于测试）
  static Database? _injectedDatabase;

  /// 获取数据库实例
  Future<Database> get database async {
    // 优先使用注入的数据库（测试场景）
    if (_injectedDatabase != null) return _injectedDatabase!;
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// 注入测试数据库实例
  ///
  /// 注意：此方法仅用于测试，在调用后必须调用 [clearInjection] 清理
  static void injectTestDatabase(Database db) {
    _injectedDatabase = db;
  }

  /// 清除注入的测试数据库
  ///
  /// 必须在测试完成后调用，以避免污染其他测试
  static void clearInjection() {
    _injectedDatabase = null;
  }

  /// 初始化数据库
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppConfig.databaseName);

    return await openDatabase(
      path,
      version: 3,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// 创建数据库表
  Future<void> _onCreate(Database db, int version) async {
    // 物品表
    await db.execute('''
      CREATE TABLE items (
        id TEXT PRIMARY KEY,
        presence TEXT NOT NULL,
        notes TEXT,
        created_at INTEGER NOT NULL,
        last_synced_at INTEGER
      )
    ''');

    // 标签表
    await db.execute('''
      CREATE TABLE tags (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        item_id TEXT NOT NULL,
        tag_name TEXT NOT NULL,
        FOREIGN KEY (item_id) REFERENCES items (id) ON DELETE CASCADE
      )
    ''');

    // 时间事件表
    await db.execute('''
      CREATE TABLE time_events (
        id TEXT PRIMARY KEY,
        item_id TEXT NOT NULL,
        label TEXT NOT NULL,
        datetime TEXT NOT NULL,
        value TEXT NOT NULL,
        description TEXT,
        FOREIGN KEY (item_id) REFERENCES items (id) ON DELETE CASCADE
      )
    ''');

    // 照片表
    await db.execute('''
      CREATE TABLE photos (
        id TEXT PRIMARY KEY,
        item_id TEXT NOT NULL,
        s3_key TEXT NOT NULL,
        local_path TEXT,
        upload_status TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        FOREIGN KEY (item_id) REFERENCES items (id) ON DELETE CASCADE
      )
    ''');

    // S3 账户表（v2：不包含凭证）
    await db.execute('''
      CREATE TABLE s3_accounts (
        id TEXT PRIMARY KEY,
        account_name TEXT NOT NULL UNIQUE,
        endpoint TEXT NOT NULL,
        bucket TEXT NOT NULL,
        region TEXT NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 0,
        last_synced_at INTEGER,
        created_at INTEGER NOT NULL
      )
    ''');

    // 同步元数据表
    await db.execute('''
      CREATE TABLE sync_metadata (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    // 创建索引
    await _createIndexes(db);
  }

  /// 创建索引
  Future<void> _createIndexes(Database db) async {
    await db.execute('CREATE INDEX idx_items_created_at ON items(created_at)');
    await db.execute(
      'CREATE INDEX idx_time_events_item_id ON time_events(item_id)',
    );
    await db.execute('CREATE INDEX idx_photos_item_id ON photos(item_id)');
    await db.execute('CREATE INDEX idx_tags_item_id ON tags(item_id)');
    await db.execute(
      'CREATE INDEX idx_sync_metadata_updated_at ON sync_metadata(updated_at)',
    );
    await _createS3AccountIndexes(db);
  }

  /// 创建 S3 账户索引
  Future<void> _createS3AccountIndexes(Database db) async {
    await db.execute(
      'CREATE INDEX idx_s3_accounts_is_active ON s3_accounts(is_active)',
    );
    await db.execute(
      'CREATE INDEX idx_s3_accounts_created_at ON s3_accounts(created_at)',
    );
  }

  /// 数据库升级
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // 处理数据库版本升级
    if (oldVersion < 2) {
      await migrateToVersion2(db);
    }
    if (oldVersion < 3) {
      await migrateToVersion3(db);
    }
  }

  /// 迁移到版本 2：从数据库中移除 S3 凭证
  ///
  /// 安全修复：移除 access_key 和 secret_key 列
  /// 这些凭证将仅存储在 SecureStorage 中
  Future<void> migrateToVersion2(Database db) async {
    // 检查是否已存在旧版本表
    final tableExists = await _checkTableExists(db, 's3_accounts');
    if (!tableExists) {
      // 如果表不存在，创建新表
      await db.execute('''
        CREATE TABLE s3_accounts (
          id TEXT PRIMARY KEY,
          account_name TEXT NOT NULL UNIQUE,
          endpoint TEXT NOT NULL,
          bucket TEXT NOT NULL,
          region TEXT NOT NULL,
          is_active INTEGER NOT NULL DEFAULT 0,
          last_synced_at INTEGER,
          created_at INTEGER NOT NULL
        )
      ''');
      await _createS3AccountIndexes(db);
      return;
    }

    // 检查是否已经是新版本（不包含凭证列）
    final hasOldColumns = await _checkColumnExists(
      db,
      's3_accounts',
      'access_key',
    );
    if (!hasOldColumns) {
      // 已经是新版本，无需迁移
      return;
    }

    // 迁移数据：创建新表，复制数据（排除凭证），删除旧表
    await db.transaction((txn) async {
      // 1. 创建新表（不包含凭证）
      await txn.execute('''
        CREATE TABLE s3_accounts_new (
          id TEXT PRIMARY KEY,
          account_name TEXT NOT NULL UNIQUE,
          endpoint TEXT NOT NULL,
          bucket TEXT NOT NULL,
          region TEXT NOT NULL,
          is_active INTEGER NOT NULL DEFAULT 0,
          last_synced_at INTEGER,
          created_at INTEGER NOT NULL
        )
      ''');

      // 2. 复制数据（排除凭证列）
      await txn.execute('''
        INSERT INTO s3_accounts_new
        SELECT id, account_name, endpoint, bucket, region,
               is_active, last_synced_at, created_at
        FROM s3_accounts
      ''');

      // 3. 删除旧表
      await txn.execute('DROP TABLE s3_accounts');

      // 4. 重命名新表
      await txn.execute('ALTER TABLE s3_accounts_new RENAME TO s3_accounts');
    });

    // 5. 重建索引
    await _createS3AccountIndexes(db);
  }

  /// 迁移到版本3：添加唯一性保证，确保只有一个激活账户
  ///
  /// 安全修复：使用触发器自动确保只有一个激活账户
  /// - 删除多余的激活账户，保留最早创建的
  /// - 创建触发器保证唯一性
  Future<void> migrateToVersion3(Database db) async {
    await db.transaction((txn) async {
      // 1. 确保只有一个激活账户：保留最早创建的，删除其他的
      await txn.execute('''
        DELETE FROM s3_accounts
        WHERE is_active = 1
        AND id NOT IN (
          SELECT id FROM s3_accounts
          WHERE is_active = 1
          ORDER BY created_at ASC
          LIMIT 1
        )
      ''');

      // 2. 删除可能存在的旧触发器
      await txn.execute(
        'DROP TRIGGER IF EXISTS ensure_single_active_account_insert',
      );
      await txn.execute(
        'DROP TRIGGER IF EXISTS ensure_single_active_account_update',
      );

      // 3. 创建触发器保证插入时只有一个激活账户
      await txn.execute('''
        CREATE TRIGGER ensure_single_active_account_insert
        AFTER INSERT ON s3_accounts
        WHEN NEW.is_active = 1
        BEGIN
          UPDATE s3_accounts SET is_active = 0
          WHERE id != NEW.id AND is_active = 1;
        END
      ''');

      // 4. 创建触发器保证更新时只有一个激活账户
      await txn.execute('''
        CREATE TRIGGER ensure_single_active_account_update
        AFTER UPDATE ON s3_accounts
        WHEN NEW.is_active = 1 AND OLD.is_active = 0
        BEGIN
          UPDATE s3_accounts SET is_active = 0
          WHERE id != NEW.id AND is_active = 1;
        END
      ''');
    });
  }

  /// 检查表是否存在
  Future<bool> _checkTableExists(Database db, String tableName) async {
    final result = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
      [tableName],
    );
    return result.isNotEmpty;
  }

  /// 检查列是否存在
  Future<bool> _checkColumnExists(
    Database db,
    String tableName,
    String columnName,
  ) async {
    final result = await db.rawQuery("PRAGMA table_info($tableName)");
    final columns = result.map((col) => col['name'] as String).toList();
    return columns.contains(columnName);
  }

  /// 关闭数据库
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }

  /// 清空所有数据（用于测试）
  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('tags');
    await db.delete('time_events');
    await db.delete('photos');
    await db.delete('items');
    await db.delete('sync_metadata');
  }
}
