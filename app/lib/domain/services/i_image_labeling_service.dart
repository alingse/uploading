import 'dart:io';
import '../entities/image_label_result.dart';

/// 图片标签识别服务抽象接口
///
/// 定义图片标签识别的契约，遵循依赖倒置原则（DIP）
/// 具体实现可以替换为不同的 ML 框架（ML Kit、TFLite 等）
abstract class IImageLabelingService {
  /// 识别图片中的物品标签
  ///
  /// [imageFile] 图片文件
  /// [existingTags] 已有标签（用于去重）
  /// [confidenceThreshold] 置信度阈值（可选）
  /// [maxLabels] 最大返回标签数（可选）
  Future<List<ImageLabelResult>> labelImage(
    File imageFile, {
    List<String> existingTags = const [],
    double? confidenceThreshold,
    int? maxLabels,
  });

  /// 释放资源
  ///
  /// 通常在应用退出时调用
  void dispose();
}
