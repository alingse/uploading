import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../../data/datasources/local/dao/item_dao.dart';
import '../../../data/datasources/local/dao/photo_dao.dart';
import '../../../domain/entities/item.dart';
import '../../../domain/entities/photo.dart';
import '../../../domain/entities/presence.dart';
import '../providers/s3_account_provider.dart';
import 'error_log_page.dart';

/// 拍照页面
class CameraPage extends ConsumerStatefulWidget {
  const CameraPage({super.key});

  @override
  ConsumerState<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends ConsumerState<CameraPage> {
  final _picker = ImagePicker();
  final _notesController = TextEditingController();
  final _tagsController = TextEditingController();

  File? _imageFile;
  bool _isSaving = false;
  Presence _selectedPresence = Presence.physical;

  @override
  void dispose() {
    _notesController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  /// 拍照
  Future<void> _takePicture() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (photo != null && mounted) {
        setState(() => _imageFile = File(photo.path));
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
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (photo != null && mounted) {
        setState(() => _imageFile = File(photo.path));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('选择图片失败: $e')));
      }
    }
  }

  /// 保存物品
  Future<void> _saveItem() async {
    if (_imageFile == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请先拍照或选择图片')));
      return;
    }

    setState(() => _isSaving = true);

    try {
      final itemId = const Uuid().v4();
      final photoId = const Uuid().v4();
      final now = DateTime.now();

      // 获取当前激活的账户 ID
      final activeAccount = await ref.read(activeAccountProvider.future);
      final accountId = activeAccount?.id ?? 'default';

      // 创建照片 S3 Key（使用激活账户 ID）
      final s3Key = 'accounts/$accountId/photos/$photoId';

      // 创建照片
      final photo = Photo(
        id: photoId,
        itemId: itemId,
        s3Key: s3Key,
        localPath: _imageFile!.path,
        uploadStatus: UploadStatus.pending,
        createdAt: now,
      );

      // 解析标签（逗号分隔）
      final tags = _tagsController.text
          .split(',')
          .map((t) => t.trim())
          .where((t) => t.isNotEmpty)
          .toList();

      // 创建物品
      final item = Item(
        id: itemId,
        photos: [photo],
        presence: _selectedPresence,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        tags: tags,
        createdAt: now,
      );

      // 保存到数据库
      final itemDao = ItemDao();
      final photoDao = PhotoDao();

      // 保存物品
      await itemDao.insert(item.toDbMap());

      // 保存照片
      await photoDao.insert(photo.toDbMap());

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('保存成功')));
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
        title: const Text('记录物品'),
        actions: [
          if (_imageFile != null)
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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 图片区域
          if (_imageFile != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                _imageFile!,
                height: 300,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () {
                setState(() => _imageFile = null);
              },
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              label: const Text('删除图片', style: TextStyle(color: Colors.red)),
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
    );
  }
}
