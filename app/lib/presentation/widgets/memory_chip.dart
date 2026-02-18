import 'package:flutter/material.dart';
import '../../domain/entities/memory.dart';

/// 记忆点芯片组件
///
/// 显示单个记忆点
class MemoryChip extends StatelessWidget {
  /// 记忆点内容
  final String content;

  /// 点击回调（可选）
  final VoidCallback? onTap;

  /// 删除回调（可选）
  final VoidCallback? onDelete;

  /// 是否可删除
  final bool deletable;

  const MemoryChip({
    super.key,
    required this.content,
    this.onTap,
    this.deletable = false,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final chip = Chip(
      label: Text(
        content,
        style: TextStyle(
          color: theme.colorScheme.onSecondaryContainer,
          fontSize: 13,
        ),
      ),
      backgroundColor: theme.colorScheme.secondaryContainer,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      visualDensity: VisualDensity.compact,
      deleteIcon: Icon(
        Icons.close,
        size: 18,
        color: theme.colorScheme.onSecondaryContainer,
      ),
      onDeleted: deletable ? onDelete : null,
      avatar: Icon(
        Icons.psychology_outlined,
        size: 16,
        color: theme.colorScheme.onSecondaryContainer,
      ),
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: chip);
    }

    return chip;
  }
}

/// 记忆点列表组件
///
/// 显示多个记忆点
class MemoryList extends StatelessWidget {
  /// 记忆点列表
  final List<Memory> memories;

  /// 点击记忆点回调
  final ValueChanged<Memory>? onTap;

  /// 删除记忆点回调
  final ValueChanged<Memory>? onDelete;

  /// 是否可删除
  final bool deletable;

  const MemoryList({
    super.key,
    required this.memories,
    this.onTap,
    this.deletable = false,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (memories.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: memories.map((memory) {
        return MemoryChip(
          content: memory.content,
          onTap: onTap != null ? () => onTap!(memory) : null,
          deletable: deletable,
          onDelete: onDelete != null ? () => onDelete!(memory) : null,
        );
      }).toList(),
    );
  }
}

/// 记忆点输入组件
///
/// 用于输入和管理记忆点
class MemoryInputField extends StatefulWidget {
  /// 当前记忆点列表
  final List<Memory> memories;

  /// 记忆点变化回调
  final ValueChanged<List<Memory>> onChanged;

  /// 提示文本
  final String hintText;

  const MemoryInputField({
    super.key,
    required this.memories,
    required this.onChanged,
    this.hintText = '添加记忆点',
  });

  @override
  State<MemoryInputField> createState() => _MemoryInputFieldState();
}

class _MemoryInputFieldState extends State<MemoryInputField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addMemory(String content) {
    final trimmed = content.trim();
    if (trimmed.isNotEmpty) {
      // 检查是否已存在相同内容的记忆点
      if (!widget.memories.any((m) => m.content == trimmed)) {
        final newMemory = Memory(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          content: trimmed,
        );
        widget.onChanged([...widget.memories, newMemory]);
      }
    }
    _controller.clear();
  }

  void _removeMemory(Memory memory) {
    widget.onChanged(widget.memories.where((m) => m.id != memory.id).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.memories.isNotEmpty) ...[
          MemoryList(
            memories: widget.memories,
            deletable: true,
            onDelete: _removeMemory,
          ),
          const SizedBox(height: 8),
        ],
        TextField(
          controller: _controller,
          decoration: InputDecoration(
            hintText: widget.hintText,
            border: const OutlineInputBorder(),
            isDense: true,
            prefixIcon: const Icon(Icons.psychology_outlined),
            suffixIcon: IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _addMemory(_controller.text),
            ),
          ),
          onSubmitted: _addMemory,
        ),
      ],
    );
  }
}
