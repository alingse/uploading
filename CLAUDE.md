# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 项目概述

**项目名称**：记忆上传工具（uploading）

**长期目标**：记忆上传工具（日记、图片、视频、心情等）

**短期目标（MVP）**：拍照、识别、标记、标签、记忆描述、实体识别（用于搬家断舍离）

**核心概念**：
- 用户通过拍照记录物品
- 为物品添加标签、备注、时间事件、记忆点
- 记录物品的"存在性"（实物保留/电子永生/待决策）
- 支持多账户本地 + 云端（阿里云 OSS）双向同步

---

## 技术栈

| 技术选型 | 版本 | 用途 |
|---------|------|-----|
| Flutter | SDK ^3.8.1 | 跨平台移动框架（iOS + Android） |
| Riverpod | ^2.4.9 | 状态管理（带代码生成） |
| SQLite | sqflite ^2.3.0 | 本地持久化存储 |
| 阿里云 OSS | flutter_oss_aliyun ^6.4.2 | 云端存储（S3 兼容 API） |
| freezed | ^2.4.5 | 不可变数据类（代码生成） |
| flutter_image_compress | ^2.1.0 | 图片压缩 |
| flutter_secure_storage | ^9.0.0 | 安全存储（S3 凭证） |
| ML Kit | google_mlkit_image_labeling ^0.14.0 | AI 图片标签识别 |

---

## 常用命令

### 开发调试
```bash
cd app/
flutter pub get                    # 安装依赖
flutter run                       # 运行应用
flutter build apk                 # 构建 Android APK
flutter build ios                 # 构建 iOS 应用
```

### 代码生成
```bash
cd app/
flutter pub run build_runner build --delete-conflicting-outputs
```
**重要**：修改以下文件后必须运行代码生成：
- `lib/domain/entities/*.dart` - 实体类（@freezed 注解）
- 任何包含 `@riverpod` 注解的文件

### 应用图标生成
```bash
cd app/
flutter pub run flutter_launcher_icons
```

### 测试
```bash
cd app/
flutter test                      # 运行所有测试
flutter test test/widget_test.dart  # 运行指定测试
```

### 代码检查
```bash
cd app/
flutter analyze                   # 静态分析
```

---

## 架构设计

项目采用**三层架构**（Clean Architecture）：

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
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                      SERVICES LAYER                          │
│  OSS Service, Sync Service, AutoSyncManager, Logging        │
└─────────────────────────────────────────────────────────────┘
```

### 目录结构
```
lib/
├── core/              # 核心工具和配置
│   ├── config/        # 应用配置（S3 端点、区域、图片压缩参数）
│   └── utils/         # 工具类（UUID 生成、日期格式化、路径处理）
│
├── data/              # 数据层
│   ├── datasources/
│   │   └── local/
│   │       ├── app_database.dart    # SQLite 数据库单例（当前版本：8）
│   │       └── dao/                 # 数据访问对象
│   ├── models/      # DTOs
│   └── repositories/ # Repository 实现
│
├── domain/            # 领域层
│   ├── entities/      # 业务实体（Item, Photo, TimeEvent, Memory 等）
│   └── repositories/  # Repository 接口
│
├── presentation/      # 表现层
│   ├── providers/     # Riverpod Providers
│   ├── pages/         # 页面
│   └── widgets/       # 通用组件
│
└── services/          # 服务层
    ├── oss_service.dart           # 阿里云 OSS 操作封装
    ├── sync_service.dart          # 数据同步编排
    ├── auto_sync_manager.dart     # 自动同步管理器（单例）
    ├── secure_storage_service.dart # 安全存储（凭证）
    ├── image_compress_service.dart # 图片压缩和缩略图生成
    └── logging_service.dart        # 日志服务
```

---

## 核心数据模型

### Item（物品实体）

应用的核心数据模型，表示用户记录的一个物品：

```dart
{
  "id": "uuid",
  "photos": [Photo 实体列表],
  "presence": "physical|electronic|pending",  // 存在性
  "notes": "文字备注",
  "tags": ["标签1", "标签2"],
  "createdAt": "2024-01-15 14:30",
  "timeEvents": [TimeEvent 实体列表],     // 时间事件
  "memories": [Memory 实体列表],           // 记忆点（JSON 存储在 items 表）
  "lastSyncedAt": "2024-01-15 15:00"     // 最后同步时间
}
```

**presence（存在性）字段说明**：
- `physical` - 实物保留
- `electronic` - 电子永生（仅保留照片/记录）
- `pending` - 待决策

### Memory（记忆点实体）

用于记录与物品相关的重要回忆或故事（以 JSON 形式存储在 items 表的 memories 列中）：

```dart
{
  "id": "uuid",
  "content": "这是我大学毕业时买的笔记本..."
}
```

**重要**：memories 存储在 items 表的 TEXT 列中，使用 JSON 序列化/反序列化。

---

## 数据库 Schema

| 表名 | 用途 |
|-----|------|
| `items` | 物品记录（包含 memories JSON 列） |
| `photos` | 照片元数据（包含上传状态、缩略图路径） |
| `time_events` | 时间事件记录 |
| `tags` | 物品标签 |
| `s3_accounts` | 云存储账户信息（不含凭证） |
| `sync_metadata` | 同步状态追踪 |

**当前数据库版本**：8

**照片上传状态**：
- `pending` - 待上传
- `uploading` - 上传中（用于并发控制）
- `completed` - 上传成功
- `failed` - 上传失败

---

## 数据库版本管理与迁移

### 版本历史

| 版本 | 变更说明 |
|------|---------|
| **v8** | 添加 `photos.s3_key_thumbnail` 列（缩略图存储） |
| **v7** | 添加 `items.memories` 列（记忆点，JSON 存储） |
| **v6** | 添加 `photos.file_extension` 列，优化照片路径结构 |
| **v5** | 修复格式错误的 endpoint |
| **v4** | 更新 S3 路径结构，添加 `/uploading/` 路径段 |
| **v3** | 添加唯一性保证，确保只有一个激活账户（使用触发器） |
| **v2** | 从数据库移除 S3 凭证（安全修复） |
| **v1** | 初始版本 |

### 新增数据库迁移的步骤

1. **更新版本号**：修改 `app_database.dart` 中的 `version` 参数
   ```dart
   return await openDatabase(
     path,
     version: 9,  // 递增版本号
     onCreate: _onCreate,
     onUpgrade: _onUpgrade,
   );
   ```

2. **更新 _onCreate**：在新数据库创建时包含新结构
   ```dart
   await db.execute('''
     CREATE TABLE items (
       ...
       new_column TEXT  -- 新增列
     )
   ''');
   ```

3. **添加迁移方法**：实现 `migrateToVersionX` 方法
   ```dart
   Future<void> migrateToVersion9(Database db) async {
     // 对于简单列添加，使用 ALTER TABLE
     await db.execute('ALTER TABLE items ADD COLUMN new_column TEXT');

     // 对于复杂变更，可能需要：
     // 1. 创建新表
     // 2. 迁移数据
     // 3. 删除旧表
     // 4. 重命名新表
   }
   ```

4. **注册迁移**：在 `_onUpgrade` 中添加条件
   ```dart
   if (oldVersion < 9) {
     await migrateToVersion9(db);
   }
   ```

### 迁移最佳实践

- **向后兼容**：迁移不应破坏现有数据
- **幂等性**：多次执行迁移应产生相同结果
- **事务保护**：复杂迁移使用 `db.transaction()` 包装
- **列检查**：使用 `_checkColumnExists()` 避免重复添加列
- **测试验证**：在真实设备上测试从旧版本升级

---

## 图片处理

### 压缩配置

```dart
// lib/core/config/app_config.dart
static const int maxImageWidth = 1920;   // 最大宽度（FHD）
static const int maxImageHeight = 1920;  // 最大高度
static const int imageQuality = 90;      // 压缩质量（0-100）
static const int maxUncompressedImageSize = 500 * 1024;  // 不压缩阈值
```

### 缩略图

- 自动生成缩略图（使用 `ImageCompressService`）
- 缩略图与原图分别上传到 OSS
- 缩略图上传失败时，使用原图 S3 Key 作为降级方案

### 缩略图路径

本地缩略图路径：`{original_path}-thumb{extension}`
OSS 缩略图 Key：`{original_s3_key}-thumb.{extension}`

---

## AI 图片标签识别

### 功能概述

使用 Google ML Kit Image Labeling 自动识别图片中的物品标签，为用户提供智能标签建议。

### 技术实现

| 组件 | 文件路径 | 说明 |
|------|---------|------|
| **服务接口** | `domain/services/i_image_labeling_service.dart` | 图片标签识别抽象接口 |
| **ML Kit 实现** | `services/mlkit_image_labeling_service.dart` | 使用 ML Kit 的具体实现 |
| **标签翻译** | `core/config/label_translations.dart` | 英文→中文标签翻译映射 |
| **结果实体** | `domain/entities/image_label_result.dart` | 识别结果数据模型 |
| **UI 基类** | `presentation/widgets/image_labeling_base.dart` | 页面标签识别功能基类 |
| **建议组件** | `presentation/widgets/suggested_tags.dart` | AI 建议标签 UI 组件 |

### ML Kit 配置

```dart
// lib/core/config/app_config.dart
static const double mlKitConfidenceThreshold = 0.5;  // 置信度阈值（0.0-1.0）
static const int mlKitMaxLabels = 10;                 // 最大返回标签数
```

### 使用方式

在需要标签识别的页面中：

```dart
class MyPage extends ImageLabelingBase<MyPage> {
  // 实现 ImageLabelingBase 要求的抽象属性和方法
  @override
  List<ImageLabelResult> get suggestedTags => _suggestedTags;

  @override
  set suggestedTags(List<ImageLabelResult> value) {
    setState(() => _suggestedTags = value);
  }

  // 触发识别
  Future<void> _pickImage() async {
    final image = await ImagePicker().pickImage(...);
    if (image != null) {
      await labelImage(File(image.path));  // 调用基类方法
    }
  }
}
```

### 标签翻译

ML Kit 返回英文标签，通过 `LabelTranslations.translate()` 自动翻译为中文：
- 覆盖 400+ 常见物品标签
- 未匹配时返回英文原文
- 支持电子产品、家具、厨房用品、衣物等分类

### 架构设计

- **DIP（依赖倒置）**：通过 `IImageLabelingService` 接口，可轻松替换为 TFLite 等其他实现
- **可测试性**：`ImageLabelingBase` 提供 `injectLabelingService()` 方法用于单元测试

---

## 同步策略

### 同步流程

1. **准备阶段**：检查网络，获取上次同步时间
2. **下载阶段**：从 OSS 下载远程数据库，合并变更（TODO）
3. **上传阶段**：推送本地数据库文件到 OSS
4. **上传照片**：上传待处理的照片（带并发控制）
5. **完成阶段**：更新同步元数据

### 照片上传并发控制

使用状态机 + 乐观锁模式：
1. `pending` → `uploading`（原子操作，通过 WHERE 条件）
2. 上传文件
3. `uploading` → `completed` 或 `failed`

### AutoSyncManager

- 单例模式，管理自动同步
- 防抖机制：30秒内不重复同步
- 定期同步：每 10 分钟自动同步一次
- 应用恢复前台时触发同步
- 同步状态流：idle → syncing → completed/failed → idle

### 冲突解决

- 采用 **Last-Write-Wins** 策略
- 基于 `last_synced_at` 时间戳比较

---

## OSS 集成

### 默认配置（阿里云 OSS 杭州）

```dart
// lib/core/config/app_config.dart
static const String defaultS3Endpoint = 'https://oss-cn-hangzhou.aliyuncs.com';
static const String defaultS3Region = 'cn-hangzhou';
static const String defaultS3Bucket = 'inventory-app-default';
```

### S3 路径结构

```
accounts/
  └── {shortAccountId}/          # accountId 前 8 位
      └── uploading/
          ├── database/
          │   └── uploading.db.{timestamp}  # 带时间戳的数据库备份
          └── photos/
              └── {yyyy}/{MM}/{dd}/
                  └── {shortPhotoId}.{extension}          # 原图
                  └── {shortPhotoId}-thumb.{extension}    # 缩略图
```

### Content-Type 设置

上传照片时根据文件扩展名设置正确的 Content-Type：
- jpg/jpeg → image/jpeg
- png → image/png
- gif → image/gif
- webp → image/webp
- heic/heif → image/heic

---

## 安全性

### S3 凭证存储

- **数据库**：仅存储账户配置（endpoint、bucket、region），不存储凭证
- **SecureStorage**：使用 `flutter_secure_storage` 存储 accessKey 和 secretKey
- 运行时从 SecureStorage 读取凭证，构建完整的 S3Account 实体

### 激活账户唯一性

- 使用数据库触发器确保只有一个激活账户
- 插入/更新时自动将其他账户设为非激活状态

---

## 关键文件说明

| 文件路径 | 说明 |
|---------|------|
| `lib/core/config/app_config.dart` | S3 端点、区域、路径常量、图片压缩配置、ML Kit 配置 |
| `lib/core/config/label_translations.dart` | 英文→中文标签翻译映射 |
| `lib/data/datasources/local/app_database.dart` | SQLite Schema（版本 8）和迁移逻辑 |
| `lib/domain/entities/image_label_result.dart` | 图片标签识别结果实体 |
| `lib/domain/services/i_image_labeling_service.dart` | 图片标签识别服务接口 |
| `lib/services/sync_service.dart` | 同步编排（带进度流、照片上传） |
| `lib/services/oss_service.dart` | OSS 操作封装 |
| `lib/services/auto_sync_manager.dart` | 自动同步管理器（单例） |
| `lib/services/image_compress_service.dart` | 图片压缩和缩略图生成 |
| `lib/services/mlkit_image_labeling_service.dart` | ML Kit 图片标签识别实现 |
| `lib/presentation/widgets/image_labeling_base.dart` | AI 标签识别基类（可测试） |
| `lib/presentation/widgets/suggested_tags.dart` | AI 建议标签 UI 组件 |
| `lib/domain/entities/item.dart` | 物品实体定义（含 memories JSON 处理） |
| `lib/main.dart` | 应用入口，设置 WidgetsBindingObserver 监听应用生命周期 |

---

## 开发注意事项

1. **修改实体类后必须运行代码生成**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

2. **OSS 认证**：使用 flutter_oss_aliyun 包，需要正确配置 Auth 对象

3. **数据库版本升级**：在 `app_database.dart` 的 `_onUpgrade` 方法中添加迁移逻辑

4. **照片上传状态**：通过 `photos.upload_status` 追踪（pending/uploading/completed/failed）

5. **memories 存储**：作为 JSON 字符串存储在 items 表中，使用 ItemDbConverter 处理转换

6. **测试支持**：
   - `AppDatabase` 支持注入测试数据库（`injectTestDatabase`），测试后需调用 `clearInjection`
   - `ImageLabelingBase` 支持注入标签识别服务（`injectLabelingService`），用于 mock ML Kit

7. **分析配置**：`analysis_options.yaml` 中配置了忽略 Riverpod 生成代码的 deprecated 警告

8. **浮点数比较**：涉及浮点数的相等性判断（如 `ImageLabelResult.confidence`）使用容差比较（epsilon = 1e-9），避免精度误差
