import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 错误日志页面
///
/// 显示应用错误日志，支持复制到剪贴板
class ErrorLogPage extends StatefulWidget {
  /// 错误信息
  final String error;

  /// 堆栈跟踪（可选）
  final String? stackTrace;

  const ErrorLogPage({
    super.key,
    required this.error,
    this.stackTrace,
  });

  /// 显示错误日志对话框
  static Future<void> show(
    BuildContext context, {
    required String error,
    String? stackTrace,
  }) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ErrorLogPage(
          error: error,
          stackTrace: stackTrace,
        ),
      ),
    );
  }

  @override
  State<ErrorLogPage> createState() => _ErrorLogPageState();
}

class _ErrorLogPageState extends State<ErrorLogPage> {
  /// 复制到剪贴板
  Future<void> _copyToClipboard() async {
    final buffer = StringBuffer();
    buffer.writeln('=== 错误日志 ===');
    buffer.writeln('时间: ${DateTime.now()}');
    buffer.writeln('错误: ${widget.error}');
    if (widget.stackTrace != null) {
      buffer.writeln('堆栈: ${widget.stackTrace}');
    }

    await Clipboard.setData(ClipboardData(text: buffer.toString()));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('已复制到剪贴板')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('错误日志'),
        backgroundColor: theme.colorScheme.errorContainer,
        foregroundColor: theme.colorScheme.onErrorContainer,
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            tooltip: '复制',
            onPressed: _copyToClipboard,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 错误图标
          Icon(
            Icons.error_outline,
            size: 64,
            color: theme.colorScheme.error,
          ),
          const SizedBox(height: 24),

          // 错误标题
          Text(
            '发生错误',
            style: theme.textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // 错误信息
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              widget.error,
              style: TextStyle(
                color: theme.colorScheme.onErrorContainer,
                fontFamily: 'monospace',
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 堆栈跟踪（如果有）
          if (widget.stackTrace != null) ...[
            Text(
              '堆栈跟踪',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                widget.stackTrace!,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _copyToClipboard,
        icon: const Icon(Icons.copy),
        label: const Text('复制日志'),
      ),
    );
  }
}
