# Flutter 记忆上传应用 - 实现计划

## 项目概述

**长期目标**：记忆上传工具（日记、图片、视频、心情等）
**短期目标（MVP）**：拍照、识别、标记、标签、记忆描述、实体识别（用于搬家断舍离）

---

## 技术栈

- **框架**：Flutter
- **平台**：iOS + Android
- **状态管理**：Riverpod
- **本地存储**：SQLite3 (sqflite)
- **云端存储**：S3 兼容 API（默认阿里云 OSS）
- **后台任务**：workmanager

---

## 数据模型

### Item（物品实体）
```dart
{
  "id": "uuid",
  "photos": ["s3_key1", "s3_key2"],
  "presence": "physical|electronic|pending",  // 存在性：实物保留/电子永生/待决策
  "notes": "文字备注",
  "tags": ["标签1", "标签2"],
  "createdAt": "2024-01-15 14:30",
  "timeEvents": [
    {
      "label": "买入",
      "datetime": "2024-01-15",
      "value": "500元",
      "description": "淘宝打折入手"
    }
  ]
}
```

**字段说明**：
- `presence`: 存在性（physical=实物保留, electronic=电子永生, pending=待决策）
- `timeEvents`: 灵活的时间节点记录，用户可自定义任何类型的时间事件

---

## 架构设计

### 三层架构

```
┌─────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                        │
│  Pages → Riverpod Providers → Widgets                       │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                      DOMAIN LAYER                            │
│  Entities → Use Cases → Repository Interfaces               │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                       DATA LAYER                             │
│  Repositories → Data Sources (SQLite + S3) → Models         │
└─────────────────────────────────────────────────────────────┘
```

---

## 项目目录结构

```
lib/
├── main.dart
├── core/
│   ├── config/
│   │   └── app_config.dart           # 默认阿里云配置
│   ├── constants/
│   ├── errors/
│   └── utils/
│
├── data/                              # 数据层
│   ├── datasources/
│   │   ├── local/
│   │   │   ├── app_database.dart     # SQLite 设置
│   │   │   └── dao/                  # 数据访问对象
│   │   └── remote/
│   │       └── s3_datasource.dart    # S3 API 客户端
│   ├── models/                        # DTOs
│   └── repositories/                  # Repository 实现
│
├── domain/                            # 领域层
│   ├── entities/                      # 业务实体
│   ├── repositories/                  # Repository 接口
│   └── usecases/                      # 业务逻辑用例
│
├── presentation/                      # 表现层
│   ├── providers/                     # Riverpod providers
│   ├── pages/                         # 页面
│   └── widgets/                       # 通用组件
│
└── services/                          # 服务层
    ├── s3_service.dart                # S3 操作封装
    ├── database_service.dart          # 数据库操作封装
    └── sync_service.dart              # 同步编排服务
```

---

## 核心依赖 (pubspec.yaml)

```yaml
dependencies:
  # 状态管理
  riverpod: ^2.4.9
  riverpod_annotation: ^2.3.3
  flutter_riverpod: ^2.4.9

  # 数据库
  sqflite: ^2.3.0
  path_provider: ^2.1.1
  path: ^1.8.3

  # S3 / 云存储
  aws_common: ^0.5.0
  aws_signature_v4: ^0.4.0

  # 安全存储
  flutter_secure_storage: ^9.0.0

  # UUID
  uuid: ^4.2.1

  # 图片处理
  image_picker: ^1.0.4
  cached_network_image: ^3.3.0
  photo_view: ^0.14.0

  # 后台任务
  workmanager: ^0.5.1

  # 工具
  intl: ^0.18.1
  dio: ^5.4.0
  connectivity_plus: ^5.0.2

dev_dependencies:
  build_runner: ^2.4.7
  riverpod_generator: ^2.3.9
  json_serializable: ^6.7.1
  freezed: ^2.4.5
```

---

## 实现步骤

### 第 1 步：项目初始化
```bash
flutter create inventory_app
cd inventory_app
```

### 第 2 步：创建目录结构
```bash
mkdir -p lib/{core/{config,constants,errors,utils},data/{datasources/{local,remote},models,repositories},domain/{entities,repositories,usecases},presentation/{providers,pages,widgets},services}
```

### 第 3 步：实现核心模块（按优先级）

#### 3.1 数据层基础
- [ ] `lib/data/datasources/local/app_database.dart` - SQLite 数据库设置
- [ ] `lib/domain/entities/item.dart` - 物品实体定义
- [ ] `lib/data/models/item_model.dart` - 物品 DTO

#### 3.2 S3 服务
- [ ] `lib/core/config/app_config.dart` - S3 配置（默认阿里云）
- [ ] `lib/services/s3_service.dart` - S3 操作封装

#### 3.3 同步服务
- [ ] `lib/services/sync_service.dart` - 数据同步逻辑
- [ ] `lib/services/secure_storage_service.dart` - 安全存储凭证

#### 3.4 状态管理
- [ ] `lib/presentation/providers/item_provider.dart` - 物品状态管理
- [ ] `lib/presentation/providers/sync_provider.dart` - 同步状态管理
- [ ] `lib/presentation/providers/account_provider.dart` - 账户状态管理

#### 3.5 UI 页面
- [ ] `lib/presentation/pages/home/home_page.dart` - 物品列表页
- [ ] `lib/presentation/pages/item_detail/item_detail_page.dart` - 物品详情页
- [ ] `lib/presentation/pages/settings/settings_page.dart` - 设置页（S3 配置）
- [ ] `lib/presentation/pages/sync/sync_page.dart` - 同步页

---

## 数据库 Schema

```sql
-- 物品表
CREATE TABLE items (
  id TEXT PRIMARY KEY,
  presence TEXT NOT NULL,
  notes TEXT,
  created_at INTEGER NOT NULL,
  last_synced_at INTEGER
);

-- 标签表
CREATE TABLE tags (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  item_id TEXT NOT NULL,
  tag_name TEXT NOT NULL,
  FOREIGN KEY (item_id) REFERENCES items (id) ON DELETE CASCADE
);

-- 时间事件表
CREATE TABLE time_events (
  id TEXT PRIMARY KEY,
  item_id TEXT NOT NULL,
  label TEXT NOT NULL,
  datetime INTEGER NOT NULL,
  value TEXT NOT NULL,
  description TEXT,
  FOREIGN KEY (item_id) REFERENCES items (id) ON DELETE CASCADE
);

-- 照片表
CREATE TABLE photos (
  id TEXT PRIMARY KEY,
  item_id TEXT NOT NULL,
  s3_key TEXT NOT NULL,
  local_path TEXT,
  upload_status TEXT NOT NULL,
  created_at INTEGER NOT NULL,
  FOREIGN KEY (item_id) REFERENCES items (id) ON DELETE CASCADE
);

-- S3 账户表
CREATE TABLE s3_accounts (
  id TEXT PRIMARY KEY,
  account_name TEXT NOT NULL UNIQUE,
  endpoint TEXT NOT NULL,
  access_key TEXT NOT NULL,
  secret_key TEXT NOT NULL,
  bucket TEXT NOT NULL,
  region TEXT NOT NULL,
  is_active INTEGER NOT NULL DEFAULT 0,
  last_synced_at INTEGER,
  created_at INTEGER NOT NULL
);

-- 同步元数据表
CREATE TABLE sync_metadata (
  key TEXT PRIMARY KEY,
  value TEXT NOT NULL,
  updated_at INTEGER NOT NULL
);
```

---

## 同步策略

### 同步流程
1. **准备阶段**：检查网络，获取上次同步时间
2. **下载阶段**：从 S3 下载远程数据库，合并变更
3. **上传阶段**：推送本地变更到 S3
4. **上传照片**：上传待处理的照片
5. **完成阶段**：更新同步元数据

### 冲突解决
- 采用 **Last-Write-Wins** 策略
- 基于 `last_synced_at` 时间戳比较

### 账户切换
1. 备份当前数据库到 S3
2. 下载新账户的数据库
3. 设置新账户为激活状态
4. 刷新数据

---

## 关键文件清单

实现时需要优先创建的核心文件：

| 文件路径 | 说明 |
|---------|------|
| `lib/data/datasources/local/app_database.dart` | 数据库设置 |
| `lib/domain/entities/item.dart` | 物品实体 |
| `lib/services/sync_service.dart` | 同步服务 |
| `lib/services/s3_service.dart` | S3 服务 |
| `lib/presentation/providers/item_provider.dart` | 状态管理 |

---

## 默认 S3 配置（阿里云 OSS）

```dart
class AppConfig {
  static const String defaultS3Endpoint = 'https://oss-cn-hangzhou.aliyuncs.com';
  static const String defaultS3Region = 'oss-cn-hangzhou';
  static const String defaultS3Bucket = 'inventory-app-default';
}
```

---

## 验证步骤

1. 创建 Flutter 项目
2. 安装依赖 `flutter pub get`
3. 运行应用 `flutter run`
4. 测试拍照功能
5. 测试物品记录
6. 测试 S3 上传
7. 测试账户切换
8. 测试同步功能
