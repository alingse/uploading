import 'package:intl/intl.dart';

/// 日期格式化工具
class DateFormatter {
  /// 日期格式：YYYY-MM-DD
  static const String dateFormat = 'yyyy-MM-dd';

  /// 日期时间格式：YYYY-MM-DD HH:mm
  static const String dateTimeFormat = 'yyyy-MM-dd HH:mm';

  /// 格式化为日期
  static String formatDate(DateTime date) {
    return DateFormat(dateFormat).format(date);
  }

  /// 格式化为日期时间
  static String formatDateTime(DateTime dateTime) {
    return DateFormat(dateTimeFormat).format(dateTime);
  }

  /// 解析日期字符串
  static DateTime? parseDate(String dateString) {
    try {
      return DateFormat(dateFormat).parse(dateString);
    } catch (e) {
      return null;
    }
  }

  /// 解析日期时间字符串
  static DateTime? parseDateTime(String dateTimeString) {
    try {
      return DateFormat(dateTimeFormat).parse(dateTimeString);
    } catch (e) {
      // 尝试只解析日期部分
      return parseDate(dateTimeString);
    }
  }

  /// 获取相对时间描述（如"3天前"）
  static String getRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return '刚刚';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}分钟前';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}小时前';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}天前';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks周前';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months个月前';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years年前';
    }
  }

  /// 判断是否为今天
  static bool isToday(DateTime dateTime) {
    final now = DateTime.now();
    return dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day;
  }

  /// 判断是否为昨天
  static bool isYesterday(DateTime dateTime) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return dateTime.year == yesterday.year &&
        dateTime.month == yesterday.month &&
        dateTime.day == yesterday.day;
  }
}
