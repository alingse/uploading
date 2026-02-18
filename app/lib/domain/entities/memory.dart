import 'package:freezed_annotation/freezed_annotation.dart';

part 'memory.freezed.dart';
part 'memory.g.dart';

/// 记忆点实体
///
/// 用于记录与物品相关的重要回忆或故事
@freezed
class Memory with _$Memory {
  const factory Memory({
    /// 唯一标识
    required String id,

    /// 记忆内容
    required String content,
  }) = _Memory;

  factory Memory.fromJson(Map<String, dynamic> json) => _$MemoryFromJson(json);
}

/// Memory 扩展方法
extension MemoryX on Memory {
  /// 转换为 JSON Map（用于数据库存储）
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
    };
  }

  /// 从 JSON Map 创建 Memory
  static Memory fromMap(Map<String, dynamic> map) {
    return Memory.fromJson(map);
  }
}
