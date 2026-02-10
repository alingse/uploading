import 'package:flutter/material.dart';
import '../../../domain/entities/item.dart';
import '../../../domain/entities/time_event.dart';
import 'presence_chip.dart';
import 'tag_chip.dart';

/// 物品卡片组件
///
/// 显示单个物品的信息
class ItemCard extends StatelessWidget {
  /// 物品信息
  final Item item;

  /// 点击回调
  final VoidCallback onTap;

  /// 是否可以滑动删除
  final bool enableSlideToDelete;

  /// 删除回调
  final VoidCallback? onDelete;

  const ItemCard({
    super.key,
    required this.item,
    required this.onTap,
    this.enableSlideToDelete = true,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget cardChild = Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 第一行：存在性标签 + 照片数量
              Row(
                children: [
                  PresenceChip(presence: item.presence),
                  const SizedBox(width: 8),
                  if (item.photos.isNotEmpty) ...[
                    Icon(
                      Icons.photo_library_outlined,
                      size: 16,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${item.photos.length}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                      ),
                    ),
                  ],
                  const Spacer(),
                  _formatDate(item.createdAt),
                ],
              ),
              // 备注
              if (item.notes != null && item.notes!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  item.notes!,
                  style: theme.textTheme.bodyMedium,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              // 标签
              if (item.tags.isNotEmpty) ...[
                const SizedBox(height: 8),
                TagList(tags: item.tags.take(5).toList()),
                if (item.tags.length > 5) ...[
                  const SizedBox(height: 4),
                  Text(
                    '+${item.tags.length - 5} 个标签',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ],
              // 时间事件预览
              if (item.timeEvents.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: item.timeEvents.take(2).map((event) {
                    return _TimeEventChip(event: event);
                  }).toList(),
                ),
                if (item.timeEvents.length > 2) ...[
                  const SizedBox(height: 4),
                  Text(
                    '+${item.timeEvents.length - 2} 个时间事件',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );

    if (enableSlideToDelete && onDelete != null) {
      return Dismissible(
        key: Key(item.id),
        direction: DismissDirection.endToStart,
        onDismissed: (_) => onDelete!(),
        background: Container(
          alignment: AlignmentDirectional.centerEnd,
          padding: const EdgeInsets.only(right: 20),
          color: theme.colorScheme.error,
          child: Icon(Icons.delete, color: theme.colorScheme.onError),
        ),
        child: cardChild,
      );
    }

    return cardChild;
  }

  Widget _formatDate(DateTime date) {
    return Text(
      _formatDateShort(date),
      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
    );
  }

  String _formatDateShort(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return '今天';
    } else if (difference.inDays == 1) {
      return '昨天';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}天前';
    } else {
      return '${date.month}月${date.day}日';
    }
  }
}

/// 时间事件芯片（用于卡片预览）
class _TimeEventChip extends StatelessWidget {
  final TimeEvent event;

  const _TimeEventChip({required this.event});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(event.label, style: theme.textTheme.labelSmall),
          if (event.value.isNotEmpty) ...[
            const SizedBox(width: 4),
            Text(
              ': ${event.value}',
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
