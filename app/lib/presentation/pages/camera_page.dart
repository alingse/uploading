import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../../core/config/app_config.dart';
import '../../../data/datasources/local/dao/item_dao.dart';
import '../../../data/datasources/local/dao/photo_dao.dart';
import '../../../domain/entities/image_label_result.dart';
import '../../../domain/entities/item.dart';
import '../../../domain/entities/memory.dart';
import '../../../domain/entities/photo.dart';
import '../../../domain/entities/presence.dart';
import '../../../services/auto_sync_manager.dart';
import '../../../services/image_compress_service.dart';
import '../providers/s3_account_provider.dart';
import '../widgets/image_labeling_base.dart';
import '../widgets/memory_chip.dart';
import '../widgets/suggested_tags.dart';
import 'error_log_page.dart';

/// 拍照页面
class CameraPage extends ConsumerStatefulWidget {
  const CameraPage({super.key});

  @override
  ConsumerState<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends ImageLabelingBase<CameraPage> {
  final _picker = ImagePicker();
  final _notesController = TextEditingController();
  final _tagsController = TextEditingController();

  // ignore: prefer_final_fields
  List<File> _originalFiles = []; // 原图文件
  // ignore: prefer_final_fields
  List<File> _thumbnailFiles = []; // 缩略图文件
  bool _isSaving = false;
  String? _compressStatus;
  Presence _selectedPresence = Presence.physical;
  List<Memory> _memories = [];
  // ignore: prefer_final_fields
  List<ImageLabelResult> _suggestedTags = []; // 会被 setState 修改
  bool _isLabeling = false;

  // ========== ImageLabelingMixin 实现 ==========

  @override
  List<ImageLabelResult> get suggestedTags => _suggestedTags;

  @override
  set suggestedTags(List<ImageLabelResult> value) {
    setState(() => _suggestedTags = value);
  }

  @override
  bool get isLabeling => _isLabeling;

  @override
  set isLabeling(bool value) {
    setState(() => _isLabeling = value);
  }

  @override
  List<String> get existingTags {
    return _tagsController.text
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();
  }

  @override
  void addTag(String tag) {
    final current = _tagsController.text.trim();
    if (current.isEmpty) {
      _tagsController.text = tag;
    } else {
      _tagsController.text = '$current, $tag';
    }
  }

  // ============================================

  @override
  void dispose() {
    _notesController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  /// 检查是否可以添加照片
  bool _canAddPhoto() {
    if (_originalFiles.length >= AppConfig.maxPhotosPerItem) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('最多只能添加 ${AppConfig.maxPhotosPerItem} 张照片')),
        );
      }
      return false;
    }
    return true;
  }

  /// 拍照
  Future<void> _takePicture() async {
    if (!_canAddPhoto()) return;

    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
      );

      if (photo != null) {
        await _processAndAddImage(File(photo.path));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('拍照失败: $e')));
      }
    }
  }

  /// 从相册选择
  Future<void> _pickFromGallery() async {
    if (!_canAddPhoto()) return;

    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.gallery,
      );

      if (photo != null) {
        await _processAndAddImage(File(photo.path));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('选择图片失败: $e')));
      }
    }
  }

  /// 删除照片
  void _removePhoto(int index) {
    setState(() {
      _originalFiles.removeAt(index);
      _thumbnailFiles.removeAt(index);
    });
  }

  /// 处理并添加图片（包含压缩逻辑）
  Future<void> _processAndAddImage(File imageFile) async {
    if (!mounted) return;

    setState(() => _compressStatus = '正在处理图片...');

    try {
      // 使用双轨压缩服务（原图 + 缩略图）
      final result = await ImageCompressService.instance.compressDual(
        imageFile,
        progress: (progress) {
          if (mounted) {
            setState(() {
              _compressStatus = '处理中 ${((progress.progress * 100).toInt())}%';
            });
          }
        },
      );

      if (mounted) {
        setState(() {
          _originalFiles.add(result.originalFile);
          _thumbnailFiles.add(result.thumbnailFile);
          _compressStatus = null;
        });

        // 显示处理完成提示
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('图片已处理'),
              duration: Duration(seconds: 1),
            ),
          );
        }

        // 触发 AI 标签识别
        labelImage(result.originalFile);
      }
    } catch (e) {
      // 处理失败，使用原图（降级处理）
      if (mounted) {
        setState(() {
          _originalFiles.add(imageFile);
          // 生成缩略图路径作为占位
          final thumbPath = ImageCompressDualResult.getThumbnailPath(imageFile.path);
          _thumbnailFiles.add(File(thumbPath));
          _compressStatus = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('图片处理失败，使用原图: $e')),
        );
      }
    }
  }

  /// 保存物品
  Future<void> _saveItem() async {
    if (_originalFiles.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请先拍照或选择图片')));
      return;
    }

    setState(() => _isSaving = true);

    try {
      final itemId = const Uuid().v4();
      final now = DateTime.now();

      // 获取当前激活的账户 ID
      final activeAccount = await ref.read(activeAccountProvider.future);
      final accountId = activeAccount?.id ?? 'default';

      // 创建多个照片实体（原图 + 缩略图）
      final photos = <Photo>[];
      for (int i = 0; i < _originalFiles.length; i++) {
        final originalFile = _originalFiles[i];
        final thumbnailFile = _thumbnailFiles[i];

        photos.add(PhotoDbConverter.createForUpload(
          originalLocalPath: originalFile.path,
          thumbnailLocalPath: thumbnailFile.path,
          itemId: itemId,
          accountId: accountId,
          buildS3Key: AppConfig.buildPhotoKey,
          buildThumbnailKey: AppConfig.buildThumbnailKey,
        ));
      }

      // 解析标签（逗号分隔）
      final tags = _tagsController.text
          .split(',')
          .map((t) => t.trim())
          .where((t) => t.isNotEmpty)
          .toList();

      // 创建物品
      final item = Item(
        id: itemId,
        photos: photos,
        presence: _selectedPresence,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        tags: tags,
        createdAt: now,
        memories: _memories,
      );

      // 保存到数据库
      final itemDao = ItemDao();
      final photoDao = PhotoDao();

      // 保存物品
      await itemDao.insert(item.toDbMap());

      // 批量保存照片
      await photoDao.insertBatch(photos.map((p) => p.toDbMap()).toList());

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('保存成功，正在同步...')),
        );

        // 触发自动同步
        final syncManager = AutoSyncManager.instance;
        await syncManager.requestSync(accountId);
      }
    } catch (e, stackTrace) {
      if (mounted) {
        // 显示简短提示
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('保存失败'),
            duration: const Duration(seconds: 2),
            action: SnackBarAction(
              label: '查看详情',
              onPressed: () {
                ErrorLogPage.show(
                  context,
                  error: e.toString(),
                  stackTrace: stackTrace.toString(),
                );
              },
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('记录物品${_originalFiles.isNotEmpty ? ' (${_originalFiles.length}/${AppConfig.maxPhotosPerItem})' : ''}'),
        actions: [
          if (_originalFiles.isNotEmpty)
            TextButton(
              onPressed: _isSaving ? null : _saveItem,
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('保存'),
            ),
        ],
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 压缩状态遮罩层
              if (_compressStatus != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(_compressStatus!),
                    ],
                  ),
                ),
              // 图片区域
              if (_originalFiles.isNotEmpty) ...[
            // 已选照片水平滚动列表
            SizedBox(
              height: 200,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _originalFiles.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  return _PhotoThumbnail(
                    imageFile: _thumbnailFiles[index], // 显示缩略图
                    index: index,
                    onDelete: () => _removePhoto(index),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            // 添加更多照片按钮
            if (_originalFiles.length < AppConfig.maxPhotosPerItem)
              Row(
                children: [
                  FilledButton.icon(
                    onPressed: _takePicture,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('拍照'),
                  ),
                  const SizedBox(width: 16),
                  FilledButton.tonalIcon(
                    onPressed: _pickFromGallery,
                    icon: const Icon(Icons.photo_library),
                    label: const Text('相册'),
                  ),
                ],
              )
            else
              Text(
                '已达到最大照片数量 (${AppConfig.maxPhotosPerItem})',
                style: TextStyle(color: Colors.grey[600]),
              ),
          ] else ...[
            // 拍照/选择按钮
            Container(
              height: 300,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.camera_alt_outlined,
                    size: 64,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 16),
                  Text('添加照片', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FilledButton.icon(
                        onPressed: _takePicture,
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('拍照'),
                      ),
                      const SizedBox(width: 16),
                      FilledButton.tonalIcon(
                        onPressed: _pickFromGallery,
                        icon: const Icon(Icons.photo_library),
                        label: const Text('相册'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),

          // AI 建议标签
          SuggestedTags(
            suggestions: _suggestedTags,
            isLoading: _isLabeling,
            onAccept: acceptSuggestion,
            onDismissAll: dismissAllSuggestions,
          ),

          // 备注输入
          TextField(
            controller: _notesController,
            decoration: const InputDecoration(
              labelText: '备注',
              hintText: '记录这个物品...',
              prefixIcon: Icon(Icons.note),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 16),

          // 记忆点输入
          MemoryInputField(
            memories: _memories,
            onChanged: (value) => setState(() => _memories = value),
            hintText: '添加记忆点...',
          ),
          const SizedBox(height: 16),

          // 标签输入
          TextField(
            controller: _tagsController,
            decoration: const InputDecoration(
              labelText: '标签',
              hintText: '如：数码产品, 办公（用逗号分隔）',
              prefixIcon: Icon(Icons.tag),
            ),
          ),
          const SizedBox(height: 16),

          // 存在性选择
          DropdownButtonFormField<Presence>(
            value: _selectedPresence,
            decoration: const InputDecoration(
              labelText: '存在性',
              prefixIcon: Icon(Icons.inventory_2),
            ),
            items: const [
              DropdownMenuItem(value: Presence.physical, child: Text('实物保留')),
              DropdownMenuItem(value: Presence.electronic, child: Text('电子永生')),
              DropdownMenuItem(value: Presence.pending, child: Text('待决策')),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedPresence = value);
              }
            },
          ),
        ],
      ),
    ],
  ),
);
  }
}

/// 照片缩略图组件
class _PhotoThumbnail extends StatelessWidget {
  final File imageFile;
  final int index;
  final VoidCallback onDelete;

  const _PhotoThumbnail({
    required this.imageFile,
    required this.index,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            imageFile,
            height: 200,
            width: 200,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: onDelete,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(4),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 8,
          left: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${index + 1}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
