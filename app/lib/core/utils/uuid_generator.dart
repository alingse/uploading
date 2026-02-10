import 'dart:math';

/// UUID 生成器
///
/// 生成 v4 UUID
class UuidGenerator {
  static final Random _random = Random();

  /// 生成新的 UUID v4
  static String generate() {
    // 生成 UUID v4
    final bytes = List<int>.generate(16, (_) => _random.nextInt(256));

    // 设置版本和变体位
    bytes[6] = (bytes[6] & 0x0F) | 0x40; // 版本 4
    bytes[8] = (bytes[8] & 0x3F) | 0x80; // 变体

    // 转换为十六进制字符串
    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join('');

    // 格式化为 UUID
    return '${hex.substring(0, 8)}-'
        '${hex.substring(8, 12)}-'
        '${hex.substring(12, 16)}-'
        '${hex.substring(16, 20)}-'
        '${hex.substring(20, 32)}';
  }

  /// 验证 UUID 格式
  static bool isValid(String uuid) {
    // 简单的 UUID 格式验证
    final regex = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
    );
    return regex.hasMatch(uuid);
  }
}
