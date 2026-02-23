import 'dart:io';

import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:path/path.dart' as path;

import '../core/config/app_config.dart';
import '../core/config/label_translations.dart';
import '../domain/services/i_image_labeling_service.dart';
import '../domain/entities/image_label_result.dart';
import 'logging_service.dart';

/// 图片标签识别服务
///
/// 使用 Google ML Kit Image Labeling（bundled 模型）
/// 离线可用，识别 400+ 种物品标签
class MLKitImageLabelingService implements IImageLabelingService {
  MLKitImageLabelingService._() {
    _labeler = ImageLabeler(
      options: ImageLabelerOptions(
        confidenceThreshold: AppConfig.mlKitConfidenceThreshold,
      ),
    );
  }

  static final MLKitImageLabelingService instance = MLKitImageLabelingService._();

  final _logger = LoggingService();

  late final ImageLabeler _labeler;

  @override
  Future<List<ImageLabelResult>> labelImage(
    File imageFile, {
    List<String> existingTags = const [],
    double? confidenceThreshold,
    int? maxLabels,
  }) async {
    try {
      final inputImage = InputImage.fromFilePath(imageFile.path);
      final labels = await _labeler.processImage(inputImage);

      // 已有标签的小写集合（用于去重）
      final existingLower = existingTags.map((t) => t.toLowerCase()).toSet();

      final results = <ImageLabelResult>[];
      final maxCount = maxLabels ?? AppConfig.mlKitMaxLabels;
      final threshold = confidenceThreshold ?? AppConfig.mlKitConfidenceThreshold;

      for (final label in labels) {
        // 过滤低置信度标签
        if (label.confidence < threshold) continue;

        final translated = LabelTranslations.translate(label.label);
        final originalLower = label.label.toLowerCase();

        // 跳过已有标签（匹配中英文）
        if (existingLower.contains(originalLower) ||
            existingLower.contains(translated.toLowerCase())) {
          continue;
        }

        results.add(ImageLabelResult(
          label: translated,
          originalLabel: label.label,
          confidence: label.confidence,
        ));

        if (results.length >= maxCount) break;
      }

      _logger.info('ML Kit 识别完成', context: {
        'file': path.basename(imageFile.path),
        'labelsFound': labels.length,
        'afterFilter': results.length,
      });

      return results;
    } catch (e, stackTrace) {
      _logger.error(
        'ML Kit 识别失败',
        error: e,
        stackTrace: stackTrace,
      );
      return [];
    }
  }

  @override
  void dispose() {
    // 单例模式，不关闭 labeler 以便跨页面复用
    // ML Kit 的 ImageLabeler 可以安全地保持打开状态
    // _labeler.close();
  }
}
