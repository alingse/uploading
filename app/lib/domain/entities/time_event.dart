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
