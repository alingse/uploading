import 'package:flutter/material.dart';

import '../../domain/entities/image_label_result.dart';

/// AI 建议标签组件
class SuggestedTags extends StatelessWidget {
  final List<ImageLabelResult> suggestions;
  final bool isLoading;
  final ValueChanged<ImageLabelResult> onAccept;
  final VoidCallback onDismissAll;
  final String? errorMessage;

  const SuggestedTags({
    super.key,
    required this.suggestions,
    required this.isLoading,
    required this.onAccept,
    required this.onDismissAll,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    // 只在没有任何内容需要显示时隐藏
    if (!isLoading && suggestions.isEmpty && errorMessage == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.auto_awesome,
                size: 16, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 4),
            Text(
              'AI 建议标签',
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            if (suggestions.isNotEmpty)
              GestureDetector(
                onTap: onDismissAll,
                child: Text(
                  '忽略全部',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (isLoading)
          Row(
            children: [
              SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '正在识别...',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        if (errorMessage != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, size: 16, color: Colors.red.withValues(alpha: 0.7)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    errorMessage!,
                    style: TextStyle(fontSize: 12, color: Colors.red.withValues(alpha: 0.9)),
                  ),
                ),
              ],
            ),
          ),
        if (suggestions.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: suggestions.map((s) {
              return ActionChip(
                avatar: const Icon(Icons.add, size: 16),
                label: Text(
                  '${s.label} ${(s.confidence * 100).toInt()}%',
                  style: const TextStyle(fontSize: 12),
                ),
                onPressed: () => onAccept(s),
              );
            }).toList(),
          ),
        const SizedBox(height: 8),
      ],
    );
  }
}
