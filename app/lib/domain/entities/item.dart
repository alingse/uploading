import 'package:freezed_annotation/freezed_annotation.dart';
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

    /// 最后同步时间（可选）
    DateTime? lastSyncedAt,
  }) = _Item;

  factory Item.fromJson(Map<String, dynamic> json) => _$ItemFromJson(json);
}
