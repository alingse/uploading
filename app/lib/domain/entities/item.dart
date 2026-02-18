import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'memory.dart';
import 'photo.dart';
import 'presence.dart';
import 'time_event.dart';

part 'item.freezed.dart';
part 'item.g.dart';

/// 物品实体
///
/// 应用的核心数据模型，表示用户记录的一个物品
@freezed
class Item with _$Item {
  const factory Item({
    /// 唯一标识
    required String id,

    /// 照片列表
    required List<Photo> photos,

    /// 存在性（实物保留/电子永生/待决策）
    required Presence presence,

    /// 文字备注
    String? notes,

    /// 标签列表
    @Default([]) List<String> tags,

    /// 创建时间
    required DateTime createdAt,

    /// 时间事件列表（灵活的时间节点记录）
    @Default([]) List<TimeEvent> timeEvents,

    /// 记忆点列表
    @Default([]) List<Memory> memories,

    /// 最后同步时间（可选）
    DateTime? lastSyncedAt,
  }) = _Item;

  factory Item.fromJson(Map<String, dynamic> json) => _$ItemFromJson(json);
}

/// Item 扩展方法
extension ItemX on Item {
  /// 转换为数据库格式（snake_case，仅包含 items 表字段）
  ///
  /// 注意：photos、tags、timeEvents 存储在单独的表中
  /// memories 以 JSON 字符串形式存储在 items 表中
  Map<String, dynamic> toDbMap() {
    // 将 memories 序列化为 JSON 字符串
    final memoriesJson = memories.isNotEmpty
        ? const JsonEncoder().convert(memories.map((m) => m.toMap()).toList())
        : null;

    return {
      'id': id,
      'presence': _$PresenceEnumMap[presence]!,
      'notes': notes,
      'created_at': createdAt.millisecondsSinceEpoch,
      'last_synced_at': lastSyncedAt?.millisecondsSinceEpoch,
      'memories': memoriesJson,
    };
  }
}

/// Item 数据库转换工具
class ItemDbConverter {
  /// 从数据库格式创建 Item（需要单独加载关联数据）
  static Item fromDbMap(
    Map<String, dynamic> map, {
    List<Photo> photos = const [],
    List<String> tags = const [],
    List<TimeEvent> timeEvents = const [],
    List<Memory> memories = const [],
  }) {
    // 解析 memories JSON
    List<Memory> parsedMemories = memories;
    final memoriesJson = map['memories'] as String?;
    if (memoriesJson != null && memoriesJson.isNotEmpty) {
      try {
        final List<dynamic> decoded = const JsonDecoder().convert(memoriesJson);
        parsedMemories = decoded.map((e) => Memory.fromJson(e as Map<String, dynamic>)).toList();
      } catch (_) {
        // 如果解析失败，使用传入的 memories 或空列表
        parsedMemories = memories;
      }
    }

    return Item.fromJson({
      'id': map['id'] as String,
      'photos': photos.map((p) => p.toJson()).toList(),
      'presence': map['presence'] as String,
      'notes': map['notes'] as String?,
      'tags': tags,
      'createdAt': DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      'timeEvents': timeEvents.map((e) => e.toJson()).toList(),
      'memories': parsedMemories.map((m) => m.toJson()).toList(),
      'lastSyncedAt': map['last_synced_at'] == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(map['last_synced_at'] as int),
    });
  }
}
