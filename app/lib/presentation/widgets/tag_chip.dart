import 'package:flutter/material.dart';

/// 标签芯片组件
///
/// 显示单个标签
class TagChip extends StatelessWidget {
  /// 标签文本
  final String tag;

  /// 点击回调（可选）
  final VoidCallback? onTap;

  /// 删除回调（可选）
  final VoidCallback? onDelete;

  /// 是否可删除
  final bool deletable;

  const TagChip({
    super.key,
    required this.tag,
    this.onTap,
    this.deletable = false,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final chip = Chip(
      label: Text(
        tag,
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
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: chip);
    }

    return chip;
  }
}

/// 标签列表组件
///
/// 显示多个标签
class TagList extends StatelessWidget {
  /// 标签列表
  final List<String> tags;

  /// 点击标签回调
  final ValueChanged<String>? onTap;

  /// 删除标签回调
  final ValueChanged<String>? onDelete;

  /// 是否可删除
  final bool deletable;

  const TagList({
    super.key,
    required this.tags,
    this.onTap,
    this.deletable = false,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (tags.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: tags.map((tag) {
        return TagChip(
          tag: tag,
          onTap: onTap != null ? () => onTap!(tag) : null,
          deletable: deletable,
          onDelete: onDelete != null ? () => onDelete!(tag) : null,
        );
      }).toList(),
    );
  }
}

/// 标签输入组件
///
/// 用于输入和管理标签
class TagInputField extends StatefulWidget {
  /// 当前标签列表
  final List<String> tags;

  /// 标签变化回调
  final ValueChanged<List<String>> onChanged;

  /// 提示文本
  final String hintText;

  const TagInputField({
    super.key,
    required this.tags,
    required this.onChanged,
    this.hintText = '输入标签',
  });

  @override
  State<TagInputField> createState() => _TagInputFieldState();
}

class _TagInputFieldState extends State<TagInputField> {
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

  void _addTag(String tag) {
    final trimmed = tag.trim();
    if (trimmed.isNotEmpty && !widget.tags.contains(trimmed)) {
      widget.onChanged([...widget.tags, trimmed]);
    }
    _controller.clear();
  }

  void _removeTag(String tag) {
    widget.onChanged(widget.tags.where((t) => t != tag).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.tags.isNotEmpty) ...[
          TagList(tags: widget.tags, deletable: true, onDelete: _removeTag),
          const SizedBox(height: 8),
        ],
        TextField(
          controller: _controller,
          decoration: InputDecoration(
            hintText: widget.hintText,
            border: const OutlineInputBorder(),
            isDense: true,
            suffixIcon: IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _addTag(_controller.text),
            ),
          ),
          onSubmitted: _addTag,
        ),
      ],
    );
  }
}
