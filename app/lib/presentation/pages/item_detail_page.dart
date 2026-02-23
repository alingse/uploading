import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/config/app_config.dart';
import '../../../domain/entities/image_label_result.dart';
import '../../../domain/entities/item.dart';
import '../../../domain/entities/memory.dart';
import '../../../domain/entities/photo.dart';
import '../../../domain/entities/presence.dart';
import '../../../domain/entities/time_event.dart';
import '../../../services/auto_sync_manager.dart';
import '../../../services/image_compress_service.dart';
import '../providers/item_provider.dart';
import '../widgets/image_labeling_base.dart';
import '../providers/s3_account_provider.dart';
import '../widgets/memory_chip.dart';
import '../widgets/photo_grid.dart';
import '../widgets/presence_chip.dart';
import '../widgets/suggested_tags.dart';
import '../widgets/tag_chip.dart';
import '../widgets/time_event_list.dart';
import 'error_log_page.dart';

/// 物品详情/编辑页面
///
/// 显示物品详情，支持编辑模式
class ItemDetailPage extends ConsumerStatefulWidget {
  /// 物品 ID
  final String itemId;

  /// 是否直接进入编辑模式
  final bool startInEditMode;

  const ItemDetailPage({
    super.key,
    required this.itemId,
    this.startInEditMode = false,
  });

  @override
  ConsumerState<ItemDetailPage> createState() => _ItemDetailPageState();
}

class _ItemDetailPageState extends ImageLabelingBase<ItemDetailPage> {
  /// 是否处于编辑模式
  bool _isEditing = false;

  /// 表单控制器
  late final TextEditingController _notesController;
  late Presence _presence;
  late List<String> _tags;
  late List<TimeEvent> _timeEvents;
  late List<Photo> _photos;
  late List<Memory> _memories;

  /// 图片选择器
  final _picker = ImagePicker();

  /// AI 标签建议
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
  List<String> get existingTags => _tags;

  @override
  void addTag(String tag) {
    setState(() => _tags.add(tag));
  }

  // ============================================

  /// 原始物品（用于比对）
  Item? _originalItem;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController();
    _presence = Presence.pending;
    _tags = [];
    _timeEvents = [];
    _photos = [];
    _memories = [];
    _isEditing = widget.startInEditMode;
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final itemAsync = ref.watch(itemByIdProvider(widget.itemId));

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? '编辑物品' : '物品详情'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (!_isEditing && _originalItem != null)
            TextButton.icon(
              icon: const Icon(Icons.edit, size: 18),
              label: const Text('编辑'),
              onPressed: () => _toggleEditMode(true),
            ),
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.close),
              tooltip: '取消',
              onPressed: () => _toggleEditMode(false),
            ),
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.save),
              tooltip: '保存',
              onPressed: _save,
            ),
        ],
      ),
      body: itemAsync.when(
        data: (item) {
          if (item == null) {
            return const Center(child: Text('物品不存在'));
          }

          // 首次加载数据时初始化表单
          if (_originalItem == null) {
            _originalItem = item;
            _presence = item.presence;
            _notesController.text = item.notes ?? '';
            _tags = List.from(item.tags);
            _timeEvents = List.from(item.timeEvents);
            _photos = List.from(item.photos);
            _memories = List.from(item.memories);
          }

          return _buildContent(context, item);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('加载失败', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, Item item) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 存在性状态
        if (_isEditing) ...[
          const Text(
            '存在性',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          PresenceSelector(
            selected: _presence,
            onSelected: (value) {
              setState(() => _presence = value);
            },
          ),
          const SizedBox(height: 16),
        ] else ...[
          PresenceChip(presence: item.presence),
          const SizedBox(height: 16),
        ],

        // 照片网格
        const Text(
          '照片',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        PhotoGrid(
          photos: _isEditing ? _photos : item.photos,
          editable: _isEditing,
          onAddPhoto: _isEditing ? _addPhoto : null,
          onDeletePhoto: _isEditing ? _removePhoto : null,
          maxPhotos: AppConfig.maxPhotosPerItem,
          onTap: (index) {
            PhotoPreviewDialog.show(context, _isEditing ? _photos : item.photos, index);
          },
        ),
        const SizedBox(height: 16),

        // 备注
        Row(
          children: [
            const Text(
              '备注',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            if (!_isEditing && (item.notes?.isEmpty ?? true))
              Text(
                '暂无备注',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (_isEditing)
          TextField(
            controller: _notesController,
            decoration: const InputDecoration(
              hintText: '输入备注信息...',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          )
        else
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              item.notes ?? '暂无备注',
              style: TextStyle(
                color: item.notes != null
                    ? Theme.of(context).colorScheme.onSurface
                    : Colors.grey[600],
              ),
            ),
          ),
        const SizedBox(height: 16),

        // 标签
        const Text(
          '标签',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        if (_isEditing) ...[
          SuggestedTags(
            suggestions: _suggestedTags,
            isLoading: _isLabeling,
            onAccept: acceptSuggestion,
            onDismissAll: dismissAllSuggestions,
          ),
          TagInputField(
            tags: _tags,
            onChanged: (value) {
              setState(() => _tags = value);
            },
            hintText: '添加标签',
          ),
        ] else ...[
          TagList(tags: item.tags),
        ],
        const SizedBox(height: 16),

        // 记忆点
        Row(
          children: [
            const Text(
              '记忆点',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            if (!_isEditing && item.memories.isEmpty)
              Text(
                '暂无记忆点',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (_isEditing)
          MemoryInputField(
            memories: _memories,
            onChanged: (value) => setState(() => _memories = value),
            hintText: '添加记忆点...',
          )
        else
          MemoryList(memories: item.memories),
        const SizedBox(height: 16),

        // 时间事件
        Row(
          children: [
            const Text(
              '时间事件',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            if (_isEditing)
              TextButton.icon(
                onPressed: () => _addTimeEvent(),
                icon: const Icon(Icons.add),
                label: const Text('添加'),
              ),
          ],
        ),
        const SizedBox(height: 8),
        TimeEventList(
          events: _isEditing ? _timeEvents : item.timeEvents,
          editable: _isEditing,
          onTap: _isEditing ? _editTimeEvent : null,
          onDelete: _isEditing ? _removeTimeEvent : null,
        ),

        // 底部安全距离
        const SizedBox(height: 80),
      ],
    );
  }

  void _toggleEditMode(bool editing) {
    setState(() {
      _isEditing = editing;
      if (!editing && _originalItem != null) {
        // 取消编辑，恢复原始数据
        _presence = _originalItem!.presence;
        _notesController.text = _originalItem!.notes ?? '';
        _tags = List.from(_originalItem!.tags);
        _timeEvents = List.from(_originalItem!.timeEvents);
        _photos = List.from(_originalItem!.photos);
        _memories = List.from(_originalItem!.memories);
        _suggestedTags = [];
        _isLabeling = false;
      }
    });
  }

  Future<void> _save() async {
    if (_originalItem == null) return;

    final updatedItem = Item(
      id: _originalItem!.id,
      presence: _presence,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      createdAt: _originalItem!.createdAt,
      lastSyncedAt: _originalItem!.lastSyncedAt,
      photos: _photos,
      tags: _tags,
      timeEvents: _timeEvents,
      memories: _memories,
    );

    try {
      await ref.read(itemListProvider.notifier).updateItem(updatedItem);

      if (mounted) {
        setState(() {
          _originalItem = updatedItem;
          _isEditing = false;
        });

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('保存成功')));

        // 触发自动同步
        final activeAccount = await ref.read(activeAccountProvider.future);
        final accountId = activeAccount?.id ?? 'default';
        await AutoSyncManager.instance.requestSync(accountId);
      }
    } catch (e, stackTrace) {
      if (mounted) {
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
    }
  }

  Future<void> _addTimeEvent() async {
    final event = await TimeEventDialog.show(context);
    if (event != null) {
      setState(() {
        _timeEvents.add(event);
      });
    }
  }

  Future<void> _editTimeEvent(TimeEvent event) async {
    final updatedEvent = await TimeEventDialog.show(context, event);
    if (updatedEvent != null) {
      setState(() {
        final index = _timeEvents.indexWhere((e) => e.id == event.id);
        if (index >= 0) {
          _timeEvents[index] = updatedEvent;
        }
      });
    }
  }

  void _removeTimeEvent(TimeEvent event) {
    setState(() {
      _timeEvents.removeWhere((e) => e.id == event.id);
    });
  }

  /// 添加照片
  Future<void> _addPhoto() async {
    if (_photos.length >= AppConfig.maxPhotosPerItem) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('最多只能添加 ${AppConfig.maxPhotosPerItem} 张照片')),
        );
      }
      return;
    }

    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (photo != null && mounted) {
        final activeAccount = await ref.read(activeAccountProvider.future);
        final accountId = activeAccount?.id ?? 'default';

        // 使用双轨压缩生成原图和缩略图
        final result = await ImageCompressService.instance.compressDual(
          File(photo.path),
        );

        final newPhoto = PhotoDbConverter.createForUpload(
          originalLocalPath: result.originalFile.path,
          thumbnailLocalPath: result.thumbnailFile.path,
          itemId: widget.itemId,
          accountId: accountId,
          buildS3Key: AppConfig.buildPhotoKey,
          buildThumbnailKey: AppConfig.buildThumbnailKey,
        );
        setState(() => _photos.add(newPhoto));

        // 触发 AI 标签识别
        labelImage(result.originalFile);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('添加照片失败: $e')));
      }
    }
  }

  /// 删除照片
  void _removePhoto(int index) {
    if (_photos.length <= 1) {
      // 显示确认对话框
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('确认删除'),
          content: const Text('这是最后一张照片，确定要删除吗？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                setState(() => _photos.removeAt(index));
                Navigator.pop(context);
              },
              child: const Text('删除', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
      return;
    }
    setState(() => _photos.removeAt(index));
  }
}
