import 'dart:convert';

import '../../domain/entities/item.dart';
import '../../domain/entities/memory.dart';
import '../../domain/entities/presence.dart';
import 'photo_model.dart';
import 'time_event_model.dart';

/// 物品数据模型
///
/// 用于 DAO 和 Entity 之间的转换
class ItemModel {
  final String id;
  final Presence presence;
  final String? notes;
  final DateTime createdAt;
  final DateTime? lastSyncedAt;
  final List<PhotoModel> photos;
  final List<TimeEventModel> timeEvents;
  final List<String> tags;
  final List<Memory> memories;

  ItemModel({
    required this.id,
    required this.presence,
    this.notes,
    required this.createdAt,
    this.lastSyncedAt,
    this.photos = const [],
    this.timeEvents = const [],
    this.tags = const [],
    this.memories = const [],
  });

  /// 从实体创建模型
  factory ItemModel.fromEntity(Item entity) {
    return ItemModel(
      id: entity.id,
      presence: entity.presence,
      notes: entity.notes,
      createdAt: entity.createdAt,
      lastSyncedAt: entity.lastSyncedAt,
      photos: entity.photos.map((e) => PhotoModel.fromEntity(e)).toList(),
      timeEvents: entity.timeEvents
          .map((e) => TimeEventModel.fromEntity(e, entity.id))
          .toList(),
      tags: entity.tags,
      memories: entity.memories,
    );
  }

  /// 从 JSON 创建模型
  factory ItemModel.fromJson(Map<String, dynamic> json) {
    // 解析 memories JSON 字符串
    List<Memory> parsedMemories = [];
    final memoriesJson = json['memories'] as String?;
    if (memoriesJson != null && memoriesJson.isNotEmpty) {
      try {
        final List<dynamic> decoded = jsonDecode(memoriesJson);
        parsedMemories = decoded.map((e) => Memory.fromJson(e as Map<String, dynamic>)).toList();
      } catch (_) {
        // 如果解析失败，使用空列表
        parsedMemories = [];
      }
    }

    return ItemModel(
      id: json['id'] as String,
      presence: PresenceExtension.fromKey(json['presence'] as String),
      notes: json['notes'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['created_at'] as int),
      lastSyncedAt: json['last_synced_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['last_synced_at'] as int)
          : null,
      photos: [],
      timeEvents: [],
      tags: [],
      memories: parsedMemories,
    );
  }

  /// 转换为实体
  Item toEntity() {
    return Item(
      id: id,
      presence: presence,
      notes: notes,
      createdAt: createdAt,
      lastSyncedAt: lastSyncedAt,
      photos: photos.map((e) => e.toEntity()).toList(),
      timeEvents: timeEvents.map((e) => e.toEntity()).toList(),
      tags: tags,
      memories: memories,
    );
  }

  /// 转换为 JSON（仅基础字段）
  ///
  /// memories 序列化为 JSON 字符串用于数据库存储
  Map<String, dynamic> toJson() {
    // 将 memories 序列化为 JSON 字符串
    final memoriesJson = memories.isNotEmpty
        ? jsonEncode(memories.map((m) => m.toMap()).toList())
        : null;

    return {
      'id': id,
      'presence': presence.key,
      'notes': notes,
      'created_at': createdAt.millisecondsSinceEpoch,
      'last_synced_at': lastSyncedAt?.millisecondsSinceEpoch,
      'memories': memoriesJson,
    };
  }

  /// 复制并修改部分字段
  ItemModel copyWith({
    String? id,
    Presence? presence,
    String? notes,
    DateTime? createdAt,
    DateTime? lastSyncedAt,
    List<PhotoModel>? photos,
    List<TimeEventModel>? timeEvents,
    List<String>? tags,
    List<Memory>? memories,
  }) {
    return ItemModel(
      id: id ?? this.id,
      presence: presence ?? this.presence,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      photos: photos ?? this.photos,
      timeEvents: timeEvents ?? this.timeEvents,
      tags: tags ?? this.tags,
      memories: memories ?? this.memories,
    );
  }
}
