import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

/// 日志级别
enum LogLevel {
  debug,
  info,
  warning,
  error,
}

/// 日志服务
///
/// 持久化记录应用日志到本地文件
class LoggingService {
  /// 单例
  static final LoggingService _instance = LoggingService._internal();
  factory LoggingService() => _instance;
  LoggingService._internal();

  /// 日志文件
  File? _logFile;

  /// 最大日志文件大小 (10MB)
  static const int _maxLogSize = 10 * 1024 * 1024;

  /// 初始化日志服务
  Future<void> init() async {
    final directory = await getApplicationDocumentsDirectory();
    _logFile = File('${directory.path}/app_logs.txt');

    // 如果文件过大，清空
    if (await _logFile!.exists()) {
      final size = await _logFile!.length();
      if (size > _maxLogSize) {
        await _logFile!.writeAsString('');
      }
    }
  }

  /// 写入日志
  Future<void> log(
    LogLevel level,
    String message, {
    Map<String, dynamic>? context,
    Object? error,
    StackTrace? stackTrace,
  }) async {
    if (_logFile == null) {
      await init();
    }

    final timestamp = DateFormat('yyyy-MM-dd HH:mm:ss.SSS').format(DateTime.now());
    final levelStr = level.name.toUpperCase();

    final buffer = StringBuffer();
    buffer.writeln('[$timestamp] [$levelStr] $message');

    if (context != null && context.isNotEmpty) {
      buffer.writeln('  Context: $context');
    }

    if (error != null) {
      buffer.writeln('  Error: $error');
    }

    if (stackTrace != null) {
      buffer.writeln('  StackTrace: $stackTrace');
    }

    buffer.writeln(''); // 空行分隔

    await _logFile!.writeAsString(
      buffer.toString(),
      mode: FileMode.append,
    );
  }

  /// Debug 日志
  Future<void> debug(String message, {Map<String, dynamic>? context}) =>
      log(LogLevel.debug, message, context: context);

  /// Info 日志
  Future<void> info(String message, {Map<String, dynamic>? context}) =>
      log(LogLevel.info, message, context: context);

  /// Warning 日志
  Future<void> warning(String message, {Map<String, dynamic>? context}) =>
      log(LogLevel.warning, message, context: context);

  /// Error 日志
  Future<void> error(
    String message, {
    Map<String, dynamic>? context,
    Object? error,
    StackTrace? stackTrace,
  }) =>
      log(
        LogLevel.error,
        message,
        context: context,
        error: error,
        stackTrace: stackTrace,
      );

  /// 读取所有日志
  Future<String> getLogs() async {
    if (_logFile == null || !await _logFile!.exists()) {
      return '暂无日志';
    }
    return await _logFile!.readAsString();
  }

  /// 清空日志
  Future<void> clearLogs() async {
    if (_logFile != null && await _logFile!.exists()) {
      await _logFile!.writeAsString('');
    }
  }

  /// 获取日志文件路径（用于分享）
  Future<String> getLogFilePath() async {
    if (_logFile == null) {
      await init();
    }
    return _logFile!.path;
  }
}
