import 'dart:io';

import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/image_label_result.dart';
import '../../domain/services/i_image_labeling_service.dart';
import '../../services/mlkit_image_labeling_service.dart';
import '../../services/logging_service.dart';

/// AI 图片标签识别基础类
///
/// 为需要图片标签识别功能的页面提供统一的基类
/// 替代之前的 Mixin 方案，提供更清晰的继承结构
abstract class ImageLabelingBase<T extends ConsumerStatefulWidget>
    extends ConsumerState<T> {
  final _logger = LoggingService();

  /// ML Kit 识别服务（可注入用于测试）
  IImageLabelingService? _injectedLabelingService;

  /// 获取当前使用的标签识别服务
  ///
  /// 优先使用注入的服务（用于单元测试），否则返回默认的 ML Kit 实例
  IImageLabelingService get labelingService =>
      _injectedLabelingService ?? MLKitImageLabelingService.instance;

  /// 注入标签识别服务（用于单元测试）
  ///
  /// 测试完成后应调用 [clearLabelingServiceInjection] 清理
  @visibleForTesting
  void injectLabelingService(IImageLabelingService service) {
    _injectedLabelingService = service;
  }

  /// 清除注入的标签识别服务
  @visibleForTesting
  void clearLabelingServiceInjection() {
    _injectedLabelingService = null;
  }

  /// 当前建议标签列表（由子类维护）
  List<ImageLabelResult> get suggestedTags;

  /// 更新建议标签列表（由子类实现）
  set suggestedTags(List<ImageLabelResult> value);

  /// 是否正在识别（由子类维护）
  bool get isLabeling;

  /// 更新识别状态（由子类实现）
  set isLabeling(bool value);

  /// 已有标签列表（由子类提供）
  List<String> get existingTags;

  /// 添加标签到现有标签（由子类实现）
  void addTag(String tag);

  /// 识别图片标签
  Future<void> labelImage(File imageFile) async {
    isLabeling = true;
    try {
      final results = await labelingService.labelImage(
        imageFile,
        existingTags: existingTags,
      );

      if (mounted) {
        // 合并新建议，去重
        final currentSuggestions = suggestedTags;
        final existingLabels = currentSuggestions.map((s) => s.label).toSet();
        final merged = <ImageLabelResult>[...currentSuggestions];

        for (final r in results) {
          if (!existingLabels.contains(r.label)) {
            merged.add(r);
          }
        }

        suggestedTags = merged;
        isLabeling = false;
      }
    } catch (e, stackTrace) {
      _logger.error(
        '图片标签识别失败',
        error: e,
        stackTrace: stackTrace,
      );
      if (mounted) {
        isLabeling = false;
        // 显示错误提示
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('AI 标签识别失败，请手动添加标签'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  /// 采纳建议标签
  void acceptSuggestion(ImageLabelResult suggestion) {
    // 创建防御性拷贝，避免直接修改原列表
    final updated = List<ImageLabelResult>.from(suggestedTags);
    updated.remove(suggestion);
    suggestedTags = updated;
    addTag(suggestion.label);
  }

  /// 忽略全部建议
  void dismissAllSuggestions() {
    suggestedTags = [];
  }
}
