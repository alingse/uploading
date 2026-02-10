# 记忆上传工具 - 待实现功能清单

> 项目：uploading（记忆上传工具）
> 更新时间：2026-02-05

---

## 功能总览

| 模块 | 状态 | 说明 |
|------|------|------|
| 账户管理 | ✅ 已完成 | 添加、编辑、删除云存储账户 |
| 拍照记录 | ✅ 已完成 | 拍照、选择图片、保存到数据库 |
| 云同步功能 | ⏳ 待实现 | 与 OSS 双向同步 |
| 物品管理 | ⏳ 待实现 | 列表、详情、编辑、删除 |
| 时间事件 | ⏳ 待实现 | 买入、赠送等时间节点记录 |

---

## 1. 云同步功能 (高优先级)

**文件**: `lib/services/sync_service.dart`

### TODO 项

| # | 功能 | 位置 | 说明 |
|---|------|------|------|
| 1.1 | OSS 下载远程数据库 | 第107-111行 | 从 OSS 下载账户的远程数据库文件 |
| 1.2 | 数据库合并逻辑 | 第118行 | 比较本地和远程数据，解决冲突 |
| 1.3 | 序列化并上传本地变更 | 第143行 | 将本地修改序列化后上传到 OSS |

### 实现要点

- **同步流程**: 准备 → 下载 → 上传 → 上传照片 → 完成
- **冲突解决**: 基于 `last_synced_at` 的 Last-Write-Wins 策略
- **数据库路径**: `accounts/{accountId}/database/inventory.db`

---

## 2. 物品管理功能 (高优先级)

### 2.1 物品列表页面

**新建文件**: `lib/presentation/pages/item_list_page.dart`

| 功能 | 说明 |
|------|------|
| 展示所有物品 | 从数据库加载并显示物品列表 |
| 按存在性筛选 | 筛选实物保留/电子永生/待决策 |
| 搜索功能 | 按备注、标签搜索物品 |
| 下拉刷新 | 重新加载数据 |
| 点击查看详情 | 跳转到物品详情页 |

### 2.2 物品详情/编辑页面

**新建文件**: `lib/presentation/pages/item_detail_page.dart`

| 功能 | 说明 |
|------|------|
| 查看物品信息 | 显示照片、备注、标签、存在性 |
| 编辑物品信息 | 修改备注、标签、存在性 |
| 管理照片 | 添加、删除照片 |
| 管理时间事件 | 添加、编辑、删除时间事件 |
| 删除物品 | 删除物品及其关联数据 |

### 2.3 Repository 层

**新建文件**:
- `lib/domain/repositories/item_repository.dart` (接口)
- `lib/data/repositories/item_repository.dart` (实现)

---

## 3. 时间事件功能 (中优先级)

### 3.1 时间事件表单

**组件**: 可复用在物品详情页中

| 字段 | 类型 | 说明 |
|------|------|------|
| label | String | 事件标签（如：买入、赠送） |
| datetime | DateTime | 事件时间 |
| value | String | 数值（如：500元） |
| description | String | 描述 |

### 3.2 实现要点

- 使用 `TimeEventDao` 进行数据库操作
- 支持为单个物品添加多个时间事件
- 时间事件列表按时间倒序排列

---

## 4. 照片功能完善 (中优先级)

### 4.1 多照片支持

**当前状态**: 拍照页面只支持单张照片

**改进**: 允许一个物品添加多张照片

### 4.2 照片上传到 OSS

**当前状态**: `sync_service.dart` 中已有 `_uploadPendingPhotos()` 方法框架

**实现要点**:
- 遍历 `upload_status = pending` 的照片
- 使用 `OssService.uploadFile()` 上传
- 上传成功后更新状态为 `completed`
- 上传失败更新状态为 `failed`

### 4.3 照片查看大图

**依赖**: 已有 `photo_view` 包

**实现**: 点击照片预览图进入大图查看模式

---

## 5. 用户体验优化 (低优先级)

| 功能 | 说明 |
|------|------|
| 主页物品列表展示 | 在主页显示最近的物品，快捷访问 |
| 手动同步按钮 | 在设置页面添加"立即同步"按钮 |
| 网络状态检测 | 同步前检查网络连接，无网络时提示 |
| 深色模式切换 | 用户手动切换深色/浅色主题 |
| 加载状态优化 | 各页面添加骨架屏或加载动画 |

---

## 6. 技术债务

| # | 问题 | 优先级 |
|---|------|--------|
| 6.1 | 数据库版本升级逻辑为空 | 中 |
| 6.2 | 照片的 `itemId` 字段刚添加，可能需要数据迁移 | 低 |
| 6.3 | 缺少单元测试 | 中 |

---

## 实现顺序建议

### 第一阶段：核心功能
1. 物品列表页面
2. 物品详情/编辑页面
3. 删除物品功能

### 第二阶段：数据同步
1. 实现数据库序列化
2. 实现数据库下载和合并
3. 实现照片上传到 OSS
4. 手动触发同步入口

### 第三阶段：增强功能
1. 时间事件管理
2. 多照片支持
3. 搜索和筛选
4. 用户体验优化

---

## 相关文件

### 核心文件

| 文件 | 说明 |
|------|------|
| `lib/core/config/app_config.dart` | 应用配置（S3 端点、路径） |
| `lib/data/datasources/local/app_database.dart` | 数据库 Schema 定义 |
| `lib/services/sync_service.dart` | 同步服务（待完善） |
| `lib/services/oss_service.dart` | OSS 操作封装 |

### DAO 层

| 文件 | 说明 |
|------|------|
| `lib/data/datasources/local/dao/item_dao.dart` | 物品数据访问 |
| `lib/data/datasources/local/dao/photo_dao.dart` | 照片数据访问 |
| `lib/data/datasources/local/dao/time_event_dao.dart` | 时间事件数据访问 |
| `lib/data/datasources/local/dao/tag_dao.dart` | 标签数据访问 |

### 实体层

| 文件 | 说明 |
|------|------|
| `lib/domain/entities/item.dart` | 物品实体 |
| `lib/domain/entities/photo.dart` | 照片实体 |
| `lib/domain/entities/time_event.dart` | 时间事件实体 |
| `lib/domain/entities/presence.dart` | 存在性枚举 |

---

## 开发命令

```bash
# 安装依赖
flutter pub get

# 代码生成（修改实体后必须运行）
flutter pub run build_runner build --delete-conflicting-outputs

# 运行应用
flutter run

# 清理编译缓存
flutter clean
```
