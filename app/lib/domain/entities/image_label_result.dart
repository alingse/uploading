/// ML Kit 图片标签识别结果
class ImageLabelResult {
  /// 翻译后的标签（中文优先）
  final String label;

  /// 英文原始标签
  final String originalLabel;

  /// 置信度（0.0-1.0）
  final double confidence;

  /// 浮点数比较容差（用于相等性判断）
  static const double _epsilon = 1e-9;

  const ImageLabelResult({
    required this.label,
    required this.originalLabel,
    required this.confidence,
  });

  /// 检查两个浮点数是否在容差范围内相等
  bool _confidenceEquals(double a, double b) {
    return (a - b).abs() < _epsilon;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ImageLabelResult &&
          label == other.label &&
          originalLabel == other.originalLabel &&
          _confidenceEquals(confidence, other.confidence);

  @override
  int get hashCode => Object.hash(
        label,
        originalLabel,
        // 量化 confidence 到 epsilon 精度，确保与 == 操作符一致
        // 如果两个值在 epsilon 容差内相等，它们必须有相同的 hashCode
        (confidence / _epsilon).round(),
      );

  @override
  String toString() =>
      'ImageLabelResult(label: $label, original: $originalLabel, '
      'confidence: ${(confidence * 100).toStringAsFixed(1)}%)';
}
