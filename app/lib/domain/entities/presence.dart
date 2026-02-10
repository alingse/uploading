/// 存在性枚举
///
/// 表示物品的当前存在状态
enum Presence {
  /// 实物保留 - 物理物品继续存在
  physical,

  /// 电子永生 - 物品已断舍离，仅保留数字记录
  electronic,

  /// 待决策 - 尚未决定
  pending,
}

/// Presence 扩展方法
extension PresenceExtension on Presence {
  /// 获取显示名称
  String get displayName {
    switch (this) {
      case Presence.physical:
        return '实物保留';
      case Presence.electronic:
        return '电子永生';
      case Presence.pending:
        return '待决策';
    }
  }

  /// 获取英文键值（用于存储）
  String get key {
    switch (this) {
      case Presence.physical:
        return 'physical';
      case Presence.electronic:
        return 'electronic';
      case Presence.pending:
        return 'pending';
    }
  }

  /// 从字符串解析 Presence
  static Presence fromKey(String key) {
    return Presence.values.firstWhere(
      (e) => e.key == key,
      orElse: () => Presence.pending,
    );
  }
}
