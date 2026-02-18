import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/photo.dart';
import '../../../services/oss_service.dart';
import '../../../services/logging_service.dart';
import '../providers/s3_account_provider.dart';

/// 照片网格组件
///
/// 显示物品的照片网格
class PhotoGrid extends ConsumerWidget {
  /// 照片列表
  final List<Photo> photos;

  /// 点击照片回调
  final ValueChanged<int>? onTap;

  /// 每行显示的照片数量
  final int crossAxisCount;

  /// 照片间距
  final double spacing;

  /// 照片宽高比
  final double aspectRatio;

  /// 是否启用编辑模式
  final bool editable;

  /// 添加照片回调
  final VoidCallback? onAddPhoto;

  /// 删除照片回调
  final ValueChanged<int>? onDeletePhoto;

  /// 最大照片数
  final int maxPhotos;

  const PhotoGrid({
    super.key,
    required this.photos,
    this.onTap,
    this.crossAxisCount = 3,
    this.spacing = 4,
    this.aspectRatio = 1,
    this.editable = false,
    this.onAddPhoto,
    this.onDeletePhoto,
    this.maxPhotos = 10,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (photos.isEmpty) {
      return _buildEmptyState(context);
    }

    final itemCount = _calculateItemCount();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: aspectRatio,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        // 编辑模式下，最后一个位置显示添加按钮
        if (editable && onAddPhoto != null && index == photos.length) {
          return _buildAddButton(context);
        }
        return _buildPhotoItem(context, ref, index, photos[index]);
      },
    );
  }

  /// 计算网格项数量（编辑模式下 +1 用于添加按钮）
  int _calculateItemCount() {
    if (editable && onAddPhoto != null && photos.length < maxPhotos) {
      return photos.length + 1;
    }
    return photos.length;
  }

  Widget _buildPhotoItem(BuildContext context, WidgetRef ref, int index, Photo photo) {
    final Widget photoWidget = Stack(
      fit: StackFit.expand,
      children: [
        _buildPhotoThumbnail(context, ref, photo),
        if (photo.uploadStatus != UploadStatus.completed)
          _buildUploadStatusOverlay(photo.uploadStatus),
        // 编辑模式下显示删除按钮
        if (editable && onDeletePhoto != null) _buildDeleteButton(index),
      ],
    );

    return GestureDetector(
      onTap: onTap != null ? () => onTap!(index) : null,
      child: photoWidget,
    );
  }

  /// 构建删除按钮
  Widget _buildDeleteButton(int index) {
    return Positioned(
      top: 4,
      right: 4,
      child: GestureDetector(
        onTap: () => onDeletePhoto!(index),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.6),
            shape: BoxShape.circle,
          ),
          padding: const EdgeInsets.all(4),
          child: const Icon(
            Icons.close,
            color: Colors.white,
            size: 18,
          ),
        ),
      ),
    );
  }

  /// 构建添加照片按钮
  Widget _buildAddButton(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onAddPhoto,
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.5),
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate_outlined,
              size: 32,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 4),
            Text(
              '添加',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoThumbnail(BuildContext context, WidgetRef ref, Photo photo) {
    // 如果已上传到云端，优先使用 S3
    if (photo.uploadStatus == UploadStatus.completed) {
      return _buildOssImage(context, ref, photo);
    }

    // 未上传完成，使用本地文件
    if (photo.localPath != null) {
      return Image.file(
        File(photo.localPath!),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          LoggingService().error(
            '本地图片加载失败（未上传）',
            context: {
              'photoId': photo.id,
              'localPath': photo.localPath,
              'uploadStatus': photo.uploadStatus.name,
            },
            error: error,
            stackTrace: stackTrace,
          );
          return _buildPlaceholder();
        },
      );
    }

    // 既没上传也没本地文件，显示占位符
    return _buildPlaceholder();
  }

  /// 从 OSS 加载图片
  Widget _buildOssImage(BuildContext context, WidgetRef ref, Photo photo) {
    final activeAccountAsync = ref.watch(activeAccountProvider);
    return activeAccountAsync.when(
      data: (account) {
        if (account == null) {
          LoggingService().warning(
            '照片已上传但未配置账户',
            context: {'photoId': photo.id, 's3Key': photo.s3Key},
          );
          return _buildPlaceholder();
        }
        final ossService = OssService.fromAccount(account);
        final imageUrl = ossService.getPublicUrl(photo.s3Key);
        return Image.network(
          imageUrl,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return _buildLoadingPlaceholder();
          },
          errorBuilder: (context, error, stackTrace) {
            LoggingService().error(
              'OSS 图片加载失败',
              context: {
                'photoId': photo.id,
                's3Key': photo.s3Key,
                'imageUrl': imageUrl,
                'account': account.bucket,
              },
              error: error,
              stackTrace: stackTrace,
            );
            // OSS 加载失败，尝试降级到本地文件
            if (photo.localPath != null) {
              LoggingService().info('降级到本地文件', context: {'localPath': photo.localPath});
              return Image.file(
                File(photo.localPath!),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildPlaceholder(),
              );
            }
            return _buildPlaceholder();
          },
        );
      },
      loading: () => _buildLoadingPlaceholder(),
      error: (_, __) => _buildPlaceholder(),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: const Icon(Icons.image_outlined, size: 32, color: Colors.grey),
    );
  }

  Widget _buildLoadingPlaceholder() {
    return Container(
      color: Colors.grey[100],
      child: const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }

  Widget _buildUploadStatusOverlay(UploadStatus status) {
    Color color;
    IconData icon;

    switch (status) {
      case UploadStatus.pending:
        color = Colors.orange.withValues(alpha: 0.8);
        icon = Icons.cloud_upload_outlined;
        break;
      case UploadStatus.uploading:
        color = Colors.blue.withValues(alpha: 0.8);
        icon = Icons.cloud_sync;
        break;
      case UploadStatus.completed:
        return const SizedBox.shrink();
      case UploadStatus.failed:
        color = Colors.red.withValues(alpha: 0.8);
        icon = Icons.error_outline;
        break;
    }

    return Container(
      color: color,
      child: Center(child: Icon(icon, color: Colors.white, size: 24)),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    final Widget content = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.add_photo_alternate_outlined,
          size: 32,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
        ),
        const SizedBox(height: 8),
        Text(
          editable ? '点击添加照片' : '暂无照片',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );

    final container = Container(
      height: 120,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.5),
          style: BorderStyle.solid,
        ),
      ),
      child: Center(child: content),
    );

    // 编辑模式下可点击添加
    if (editable && onAddPhoto != null) {
      return GestureDetector(
        onTap: onAddPhoto,
        child: container,
      );
    }

    return container;
  }
}

/// 照片预览对话框
///
/// 点击照片后全屏预览
class PhotoPreviewDialog extends ConsumerWidget {
  /// 照片列表
  final List<Photo> photos;

  /// 初始显示的索引
  final int initialIndex;

  const PhotoPreviewDialog({
    super.key,
    required this.photos,
    required this.initialIndex,
  });

  static void show(BuildContext context, List<Photo> photos, int index) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            PhotoPreviewDialog(photos: photos, initialIndex: index),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: PageView.builder(
        controller: PageController(initialPage: initialIndex),
        itemCount: photos.length,
        itemBuilder: (context, index) {
          return Center(child: _buildFullScreenPhoto(context, ref, photos[index]));
        },
      ),
    );
  }

  Widget _buildFullScreenPhoto(BuildContext context, WidgetRef ref, Photo photo) {
    // 如果已上传到云端，优先使用 S3
    if (photo.uploadStatus == UploadStatus.completed) {
      return _buildFullScreenOssImage(context, ref, photo);
    }

    // 未上传完成，使用本地文件
    if (photo.localPath != null) {
      return Image.file(
        File(photo.localPath!),
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          LoggingService().error(
            '全屏预览本地图片加载失败（未上传）',
            context: {
              'photoId': photo.id,
              'localPath': photo.localPath,
              'uploadStatus': photo.uploadStatus.name,
            },
            error: error,
            stackTrace: stackTrace,
          );
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, color: Colors.white, size: 48),
                SizedBox(height: 16),
                Text('图片加载失败', style: TextStyle(color: Colors.white)),
              ],
            ),
          );
        },
      );
    }

    // 既没上传也没本地文件
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.cloud_off, color: Colors.white, size: 48),
          SizedBox(height: 16),
          Text('图片未上传', style: TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  /// 从 OSS 加载全屏图片
  Widget _buildFullScreenOssImage(BuildContext context, WidgetRef ref, Photo photo) {
    final activeAccountAsync = ref.watch(activeAccountProvider);

    return activeAccountAsync.when(
      data: (account) {
        if (account == null) {
          return const Center(
            child: Text(
              '未配置云存储账户',
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        final ossService = OssService.fromAccount(account);
        final imageUrl = ossService.getPublicUrl(photo.s3Key);

        return Image.network(
          imageUrl,
          fit: BoxFit.contain,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            LoggingService().error(
              '全屏预览 OSS 图片加载失败',
              context: {
                'photoId': photo.id,
                's3Key': photo.s3Key,
                'imageUrl': imageUrl,
                'account': account.bucket,
              },
              error: error,
              stackTrace: stackTrace,
            );
            // OSS 加载失败，尝试降级到本地文件
            if (photo.localPath != null) {
              LoggingService().info('降级到本地文件', context: {'localPath': photo.localPath});
              return Image.file(
                File(photo.localPath!),
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline, color: Colors.white, size: 48),
                      SizedBox(height: 16),
                      Text('图片加载失败', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              );
            }
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, color: Colors.white, size: 48),
                  SizedBox(height: 16),
                  Text('图片加载失败', style: TextStyle(color: Colors.white)),
                ],
              ),
            );
          },
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
      error: (_, __) => const Center(
        child: Text(
          '加载账户信息失败',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
