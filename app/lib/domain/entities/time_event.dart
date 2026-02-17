import 'package:freezed_annotation/freezed_annotation.dart';

part 'time_event.freezed.dart';
part 'time_event.g.dart';

/// 时间事件实体
///
/// 记录物品生命周期中的任意时间节点
@freezed
class TimeEvent with _$TimeEvent {
  const factory TimeEvent({
    /// 唯一标识
    required String id,

    /// 关联的物品 ID
    String? itemId,

    /// 自定义标签（如"买入"、"谁送的"、"制作时间"、"打包"等）
    required String label,

    /// 日期时间（格式：YYYY-MM-DD 或 YYYY-MM-DD HH:MM）
    required String datetime,

    /// 对应的值（如价格、人名等，可为空）
    @Default('') String value,

    /// 详细描述（可选）
    String? description,
  }) = _TimeEvent;

  factory TimeEvent.fromJson(Map<String, dynamic> json) =>
      _$TimeEventFromJson(json);
}

/// TimeEvent 扩展方法
extension TimeEventX on TimeEvent {
  /// 转换为数据库格式
  ///
  /// TimeEvent 的字段名已经是 snake_case，直接添加 item_id 即可
  Map<String, dynamic> toDbMap() {
    return {
      'id': id,
      'item_id': itemId,
      'label': label,
      'datetime': datetime,
      'value': value,
      'description': description,
    };
  }
}

/// TimeEvent 数据库转换工具
class TimeEventDbConverter {
  /// 从数据库格式创建 TimeEvent
  static TimeEvent fromDbMap(Map<String, dynamic> map) {
    return TimeEvent.fromJson({
      'id': map['id'] as String,
      'itemId': map['item_id'] as String?,
      'label': map['label'] as String,
      'datetime': map['datetime'] as String,
      'value': map['value'] as String? ?? '',
      'description': map['description'] as String?,
    });
  }
}
