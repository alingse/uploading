# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 项目概述

**项目名称**：记忆上传工具（uploading）

**长期目标**：记忆上传工具（日记、图片、视频、心情等）

**短期目标（MVP）**：拍照、识别、标记、标签、记忆描述、实体识别（用于搬家断舍离）

**核心概念**：
- 用户通过拍照记录物品
- 为物品添加标签、备注、时间事件
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
```

### 目录结构
```
lib/
├── core/              # 核心工具和配置
│   ├── config/        # 应用配置（S3 端点、区域等）
│   └── utils/         # 工具类（UUID 生成、日期格式化）
│
├── data/              # 数据层
│   ├── datasources/
│   │   └── local/
│   │       ├── app_database.dart    # SQLite 数据库单例
│   │       └── dao/                 # 数据访问对象
│   ├── models/      # DTOs
│   └── repositories/ # Repository 实现
│
├── domain/            # 领域层
│   ├── entities/      # 业务实体（Item, Photo, TimeEvent 等）
│   ├── repositories/  # Repository 接口
│   └── usecases/      # 业务逻辑用例
│
├── presentation/      # 表现层
│   ├── providers/     # Riverpod Providers
│   ├── pages/         # 页面
│   └── widgets/       # 通用组件
│
└── services/          # 服务层
    ├── oss_service.dart           # 阿里云 OSS 操作封装
    ├── sync_service.dart          # 数据同步编排
    └── secure_storage_service.dart # 安全存储（凭证）
```

---

## 核心数据模型

### Item（物品实体）

应用的核心数据模型，表示用户记录的一个物品：

```dart
{
  "id": "uuid",
  "photos": ["s3_key1", "s3_key2"],    // 照片列表（存储在 OSS）
  "presence": "physical|electronic|pending",  // 存在性
  "notes": "文字备注",
  "tags": ["标签1", "标签2"],
  "createdAt": "2024-01-15 14:30",
  "timeEvents": [                       // 灵活的时间节点记录
    {
      "label": "买入",
      "datetime": "2024-01-15",
      "value": "500元",
      "description": "淘宝打折入手"
    }
  ]
}
```

**presence（存在性）字段说明**：
- `physical` - 实物保留
- `electronic` - 电子永生（仅保留照片/记录）
- `pending` - 待决策

---

## 数据库 Schema

| 表名 | 用途 |
|-----|------|
| `items` | 物品记录 |
| `photos` | 照片元数据（包含上传状态：pending/completed/failed） |
| `time_events` | 时间事件记录 |
| `tags` | 物品标签 |
| `s3_accounts` | 云存储账户凭证 |
| `sync_metadata` | 同步状态追踪 |

---

## 同步策略

### 同步流程

1. **准备阶段**：检查网络，获取上次同步时间
2. **下载阶段**：从 OSS 下载远程数据库，合并变更
3. **上传阶段**：推送本地变更到 OSS
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

## OSS 集成

### 默认配置（阿里云 OSS 杭州）

```dart
// lib/core/config/app_config.dart
static const String defaultS3Endpoint = 'https://oss-cn-hangzhou.aliyuncs.com';
static const String defaultS3Region = 'oss-cn-hangzhou';
static const String defaultS3Bucket = 'inventory-app-default';
```

### S3 路径结构

```
accounts/
  └── {accountId}/
      ├── database/
      │   └── inventory.db
      └── photos/
          └── {photoId}
```

---

## 关键文件说明

| 文件路径 | 说明 |
|---------|------|
| `lib/core/config/app_config.dart` | S3 端点、区域、路径常量 |
| `lib/data/datasources/local/app_database.dart` | SQLite Schema 和迁移 |
| `lib/services/sync_service.dart` | 同步编排（带进度流） |
| `lib/services/oss_service.dart` | OSS 操作封装 |
| `lib/domain/entities/item.dart` | 物品实体定义 |

---

## 开发注意事项

1. **修改实体类后必须运行代码生成**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

2. **OSS 认证**：使用 flutter_oss_aliyun 包，需要正确配置 Auth 对象

3. **数据库版本升级**：在 `app_database.dart` 的 `_onUpgrade` 方法中处理

4. **照片上传状态**：通过 `photos.upload_status` 追踪（pending/completed/failed）
