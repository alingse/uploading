import '../../domain/entities/time_event.dart';

/// 时间事件数据模型
///
/// 用于 DAO 和 Entity 之间的转换
class TimeEventModel {
  final String id;
  final String itemId;
  final String label;
  final String datetime;
  final String value;
  final String? description;

  TimeEventModel({
    required this.id,
    required this.itemId,
    required this.label,
    required this.datetime,
    required this.value,
    this.description,
  });

  /// 从实体创建模型
  factory TimeEventModel.fromEntity(TimeEvent entity, String itemId) {
    return TimeEventModel(
      id: entity.id,
      itemId: itemId,
      label: entity.label,
      datetime: entity.datetime,
      value: entity.value,
      description: entity.description,
    );
  }

  /// 从 JSON 创建模型
  factory TimeEventModel.fromJson(Map<String, dynamic> json) {
    return TimeEventModel(
      id: json['id'] as String,
      itemId: json['item_id'] as String,
      label: json['label'] as String,
      datetime: json['datetime'] as String,
      value: (json['value'] as String?) ?? '',
      description: json['description'] as String?,
    );
  }

  /// 转换为实体
  TimeEvent toEntity() {
    return TimeEvent(
      id: id,
      label: label,
      datetime: datetime,
      value: value,
      description: description,
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'item_id': itemId,
      'label': label,
      'datetime': datetime,
      'value': value,
      'description': description,
    };
  }

  /// 复制并修改部分字段
  TimeEventModel copyWith({
    String? id,
    String? itemId,
    String? label,
    String? datetime,
    String? value,
    String? description,
  }) {
    return TimeEventModel(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      label: label ?? this.label,
      datetime: datetime ?? this.datetime,
      value: value ?? this.value,
      description: description ?? this.description,
    );
  }
}
