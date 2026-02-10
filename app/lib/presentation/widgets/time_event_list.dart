import 'package:flutter/material.dart';
import '../../../domain/entities/time_event.dart';

/// 时间事件列表组件
///
/// 显示物品的时间事件列表
class TimeEventList extends StatelessWidget {
  /// 时间事件列表
  final List<TimeEvent> events;

  /// 点击事件回调
  final ValueChanged<TimeEvent>? onTap;

  /// 是否可编辑
  final bool editable;

  /// 删除回调
  final ValueChanged<TimeEvent>? onDelete;

  const TimeEventList({
    super.key,
    required this.events,
    this.onTap,
    this.editable = false,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return _buildEmptyState(context);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < events.length; i++) ...[
          if (i > 0) const SizedBox(height: 8),
          _TimeEventTile(
            event: events[i],
            onTap: onTap,
            editable: editable,
            onDelete: onDelete,
          ),
        ],
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.schedule_outlined,
              size: 24,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 8),
            Text(
              '暂无时间事件',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 时间事件单个项目
class _TimeEventTile extends StatelessWidget {
  final TimeEvent event;
  final ValueChanged<TimeEvent>? onTap;
  final bool editable;
  final ValueChanged<TimeEvent>? onDelete;

  const _TimeEventTile({
    required this.event,
    this.onTap,
    this.editable = false,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap != null ? () => onTap!(event) : null,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.event_outlined,
                size: 20,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.label,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    event.datetime,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  if (event.value.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      event.value,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  if (event.description != null &&
                      event.description!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(event.description!, style: theme.textTheme.bodySmall),
                  ],
                ],
              ),
            ),
            if (editable && onDelete != null)
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => onDelete!(event),
                color: theme.colorScheme.error,
              ),
          ],
        ),
      ),
    );
  }
}

/// 时间事件添加/编辑对话框
class TimeEventDialog extends StatefulWidget {
  /// 要编辑的时间事件（null 表示新增）
  final TimeEvent? event;

  const TimeEventDialog({super.key, this.event});

  static Future<TimeEvent?> show(BuildContext context, [TimeEvent? event]) {
    return showModalBottomSheet<TimeEvent>(
      context: context,
      isScrollControlled: true,
      builder: (context) => TimeEventDialog(event: event),
    );
  }

  @override
  State<TimeEventDialog> createState() => _TimeEventDialogState();
}

class _TimeEventDialogState extends State<TimeEventDialog> {
  late final TextEditingController _labelController;
  late final TextEditingController _datetimeController;
  late final TextEditingController _valueController;
  late final TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _labelController = TextEditingController(text: widget.event?.label);
    _datetimeController = TextEditingController(text: widget.event?.datetime);
    _valueController = TextEditingController(text: widget.event?.value);
    _descriptionController = TextEditingController(
      text: widget.event?.description,
    );
  }

  @override
  void dispose() {
    _labelController.dispose();
    _datetimeController.dispose();
    _valueController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_labelController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请输入标签')));
      return;
    }

    if (_datetimeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请输入日期时间')));
      return;
    }

    final event = TimeEvent(
      id: widget.event?.id ?? _generateId(),
      label: _labelController.text.trim(),
      datetime: _datetimeController.text.trim(),
      value: _valueController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
    );

    Navigator.of(context).pop(event);
  }

  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.event == null ? '添加时间事件' : '编辑时间事件',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _labelController,
              decoration: const InputDecoration(
                labelText: '标签',
                hintText: '如：买入、制作时间等',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _datetimeController,
              decoration: const InputDecoration(
                labelText: '日期时间',
                hintText: 'YYYY-MM-DD 或 YYYY-MM-DD HH:MM',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _valueController,
              decoration: const InputDecoration(
                labelText: '值（可选）',
                hintText: '如：价格、人名等',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: '描述（可选）',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _submit,
              child: Text(widget.event == null ? '添加' : '保存'),
            ),
          ],
        ),
      ),
    );
  }
}
