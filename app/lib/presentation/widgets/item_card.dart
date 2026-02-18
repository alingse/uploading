import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/item.dart';
import '../../../domain/entities/photo.dart';
import '../../../domain/entities/time_event.dart';
import '../../../services/oss_service.dart';
import '../../../services/logging_service.dart';
import '../providers/s3_account_provider.dart';
import 'presence_chip.dart';
import 'tag_chip.dart';

/// 物品卡片组件
///
/// 显示单个物品的信息，带缩略图预览
class ItemCard extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    Widget cardChild = Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 左侧缩略图
              _buildThumbnail(ref),
              const SizedBox(width: 12),
              // 右侧内容
              Expanded(
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
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    // 标签
                    if (item.tags.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      TagList(tags: item.tags.take(3).toList()),
                      if (item.tags.length > 3) ...[
                        const SizedBox(height: 4),
                        Text(
                          '+${item.tags.length - 3} 个标签',
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
                        children: item.timeEvents.take(1).map((event) {
                          return _TimeEventChip(event: event);
                        }).toList(),
                      ),
                      if (item.timeEvents.length > 1) ...[
                        const SizedBox(height: 4),
                        Text(
                          '+${item.timeEvents.length - 1} 个时间事件',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
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

  /// 构建缩略图
  Widget _buildThumbnail(WidgetRef ref) {
    if (item.photos.isEmpty) {
      return _buildThumbnailPlaceholder();
    }

    final firstPhoto = item.photos.first;
    return SizedBox(
      width: 80,
      height: 80,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: _buildPhotoImage(ref, firstPhoto),
      ),
    );
  }

  /// 构建图片
  Widget _buildPhotoImage(WidgetRef ref, Photo photo) {
    // 如果已上传到云端，优先使用 S3
    if (photo.uploadStatus == UploadStatus.completed) {
      return _buildOssImage(ref, photo);
    }

    // 未上传完成，使用本地文件
    if (photo.localPath != null) {
      final file = File(photo.localPath!);
      return Image.file(
        file,
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          LoggingService().error(
            '卡片本地图片加载失败（未上传）',
            context: {
              'photoId': photo.id,
              'localPath': photo.localPath,
              'uploadStatus': photo.uploadStatus.name,
            },
            error: error,
            stackTrace: stackTrace,
          );
          return _buildThumbnailPlaceholder();
        },
      );
    }

    return _buildThumbnailPlaceholder();
  }

  /// 从 OSS 加载图片
  Widget _buildOssImage(WidgetRef ref, Photo photo) {
    final activeAccountAsync = ref.watch(activeAccountProvider);
    return activeAccountAsync.when(
      data: (account) {
        if (account == null) {
          return _buildThumbnailPlaceholder();
        }
        final ossService = OssService.fromAccount(account);
        final imageUrl = ossService.getPublicUrl(photo.s3Key);
        return Image.network(
          imageUrl,
          width: 80,
          height: 80,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return _buildThumbnailLoadingPlaceholder();
          },
          errorBuilder: (context, error, stackTrace) {
            LoggingService().error(
              '卡片 OSS 图片加载失败',
              context: {
                'photoId': photo.id,
                's3Key': photo.s3Key,
                'imageUrl': imageUrl,
                'account': account.bucket,
              },
              error: error,
              stackTrace: stackTrace,
            );
            // OSS 失败，尝试降级到本地
            if (photo.localPath != null) {
              return Image.file(
                File(photo.localPath!),
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildThumbnailPlaceholder(),
              );
            }
            return _buildThumbnailPlaceholder();
          },
        );
      },
      loading: () => _buildThumbnailLoadingPlaceholder(),
      error: (_, __) => _buildThumbnailPlaceholder(),
    );
  }

  /// 缩略图占位符
  Widget _buildThumbnailPlaceholder() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.image_outlined, size: 32, color: Colors.grey),
    );
  }

  /// 缩略图加载中占位符
  Widget _buildThumbnailLoadingPlaceholder() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }

  /// 格式化日期
  Widget _formatDate(DateTime date) {
    return Text(
      _formatDateShort(date),
      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
    );
  }

  /// 格式化日期字符串
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
