import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:uploading/core/config/app_config.dart';
import 'package:uploading/core/utils/path_utils.dart';

/// 图片压缩结果
class ImageCompressResult {
  final File file;
  final int originalSize;
  final int compressedSize;
  final String format;

  ImageCompressResult({
    required this.file,
    required this.originalSize,
    required this.compressedSize,
    required this.format,
  });

  /// 压缩率（百分比）
  double get compressionRatio =>
      originalSize > 0 ? (1 - compressedSize / originalSize) * 100 : 0;

  @override
  String toString() {
    return 'ImageCompressResult(format: $format, original: ${_formatSize(originalSize)}, '
        'compressed: ${_formatSize(compressedSize)}, ratio: ${compressionRatio.toStringAsFixed(1)}%)';
  }

  static String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

/// 图片压缩进度
class CompressProgress {
  final int current;
  final int total;

  const CompressProgress({required this.current, required this.total});

  double get progress => total > 0 ? current / total : 0;
}

/// 图片双轨压缩结果
///
/// 包含原图文件和缩略图文件
class ImageCompressDualResult {
  final File originalFile;
  final File thumbnailFile;

  ImageCompressDualResult({
    required this.originalFile,
    required this.thumbnailFile,
  });

  /// 原图大小
  Future<int> get originalSize async => await originalFile.length();

  /// 缩略图大小
  Future<int> get thumbnailSize async => await thumbnailFile.length();

  @override
  String toString() {
    return 'ImageCompressDualResult(original: ${originalFile.path}, thumbnail: ${thumbnailFile.path})';
  }

  /// 获取缩略图本地路径
  ///
  /// 从原图路径推导缩略图路径
  /// 原图: /path/to/image.jpg
  /// 缩略图: /path/to/image-thumb.jpg
  static String getThumbnailPath(String originalPath) {
    return PathUtils.getThumbnailLocalPath(originalPath);
  }
}

/// 图片压缩服务
///
/// 功能：
/// - HEIC → JPEG 格式转换
/// - 尺寸压缩（最大 1920x1920）
/// - 质量压缩（90%）
/// - 智能判断：小于 500KB 的图片不压缩
/// - 双轨压缩：原图 + 缩略图
class ImageCompressService {
  ImageCompressService._();

  static final ImageCompressService instance = ImageCompressService._();

  /// 压缩单张图片
  ///
  /// [file] 原始图片文件
  /// [progress] 可选的进度回调
  Future<ImageCompressResult> compressImage(
    File file, {
    void Function(CompressProgress)? progress,
  }) async {
    final originalSize = await file.length();
    final originalPath = file.path;

    // 检查文件扩展名（使用 PathUtils 统一处理）
    final extension = PathUtils.getExtension(originalPath);
    // PathUtils 返回空字符串表示没有扩展名，使用默认值 'jpg'
    final normalizedExt = extension.isEmpty ? 'jpg' : extension;

    // 如果文件小于阈值，直接返回
    if (originalSize < AppConfig.maxUncompressedImageSize) {
      progress?.call(CompressProgress(current: 1, total: 1));
      return ImageCompressResult(
        file: file,
        originalSize: originalSize,
        compressedSize: originalSize,
        format: normalizedExt,
      );
    }

    progress?.call(CompressProgress(current: 0, total: 1));

    // 确定输出格式（HEIC/HEIF 转换为 JPEG）
    final outputFormat = _isHeicFormat(normalizedExt)
        ? CompressFormat.jpeg
        : _getCompressFormat(normalizedExt);

    // 确定输出文件路径
    final outputPath = _getOutputPath(originalPath, outputFormat);

    // 执行压缩
    final result = await FlutterImageCompress.compressAndGetFile(
      originalPath,
      outputPath,
      format: outputFormat,
      quality: AppConfig.imageQuality,
      keepExif: true, // 保留 EXIF 信息
      minWidth: AppConfig.maxImageWidth ~/ 2, // 设置最小宽度，避免过度压缩
      minHeight: AppConfig.maxImageHeight ~/ 2,
    );

    if (result == null) {
      // 压缩失败，返回原文件
      return ImageCompressResult(
        file: file,
        originalSize: originalSize,
        compressedSize: originalSize,
        format: normalizedExt,
      );
    }

    final compressedFile = File(result.path);
    final compressedSize = await compressedFile.length();

    progress?.call(CompressProgress(current: 1, total: 1));

    return ImageCompressResult(
      file: compressedFile,
      originalSize: originalSize,
      compressedSize: compressedSize,
      format: _getFormatName(outputFormat),
    );
  }

  /// 批量压缩图片
  ///
  /// [files] 原始图片文件列表
  /// [progress] 可选的进度回调
  Future<List<ImageCompressResult>> compressImages(
    List<File> files, {
    void Function(CompressProgress)? progress,
  }) async {
    final results = <ImageCompressResult>[];

    for (int i = 0; i < files.length; i++) {
      final result = await compressImage(
        files[i],
        progress: (p) => progress?.call(
          CompressProgress(current: i + p.current, total: files.length),
        ),
      );
      results.add(result);
    }

    return results;
  }

  /// 同时生成缩略图和保留原图
  ///
  /// 返回原图文件路径和缩略图文件路径
  /// - 原图：保持原始质量
  /// - 缩略图：压缩到 800x800px 以内，质量 85%
  Future<ImageCompressDualResult> compressDual(
    File originalFile, {
    void Function(CompressProgress)? progress,
  }) async {
    progress?.call(const CompressProgress(current: 0, total: 2));

    // 1. 生成缩略图
    final thumbnailResult = await _compressThumbnail(originalFile);
    progress?.call(const CompressProgress(current: 1, total: 2));

    // 2. 返回原图和缩略图
    progress?.call(const CompressProgress(current: 2, total: 2));

    return ImageCompressDualResult(
      originalFile: originalFile,
      thumbnailFile: thumbnailResult.file,
    );
  }

  /// 压缩生成缩略图
  ///
  /// - 最大尺寸: 800x800px
  /// - 质量: 85%
  /// - 格式: JPEG (HEIC 自动转换)
  Future<ImageCompressResult> _compressThumbnail(File file) async {
    final originalSize = await file.length();
    final originalPath = file.path;

    // 检查文件扩展名（使用 PathUtils 统一处理）
    final extension = PathUtils.getExtension(originalPath);
    // PathUtils 返回空字符串表示没有扩展名，使用默认值 'jpg'
    final normalizedExt = extension.isEmpty ? 'jpg' : extension;

    // 确定输出格式（HEIC/HEIF 转换为 JPEG）
    final outputFormat = _isHeicFormat(normalizedExt)
        ? CompressFormat.jpeg
        : _getCompressFormat(normalizedExt);

    // 确定缩略图输出文件路径
    final thumbnailPath = ImageCompressDualResult.getThumbnailPath(originalPath);

    // 执行缩略图压缩
    final result = await FlutterImageCompress.compressAndGetFile(
      originalPath,
      thumbnailPath,
      format: outputFormat,
      quality: 85, // 缩略图质量
      keepExif: false, // 缩略图不需要 EXIF
      minWidth: 400, // 设置最小宽度，保持图片质量
      minHeight: 400,
    );

    if (result == null) {
      // 压缩失败，返回原图作为缩略图（降级处理）
      return ImageCompressResult(
        file: file,
        originalSize: originalSize,
        compressedSize: originalSize,
        format: normalizedExt,
      );
    }

    final thumbnailFile = File(result.path);
    final thumbnailSize = await thumbnailFile.length();

    return ImageCompressResult(
      file: thumbnailFile,
      originalSize: originalSize,
      compressedSize: thumbnailSize,
      format: _getFormatName(outputFormat),
    );
  }

  /// 判断是否为 HEIC/HEIF 格式
  static bool _isHeicFormat(String extension) {
    return extension == 'heic' || extension == 'heif';
  }

  /// 获取压缩格式
  static CompressFormat _getCompressFormat(String extension) {
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return CompressFormat.jpeg;
      case 'png':
        return CompressFormat.png;
      case 'webp':
        return CompressFormat.webp;
      case 'heic':
      case 'heif':
        return CompressFormat.heic;
      default:
        return CompressFormat.jpeg;
    }
  }

  /// 获取格式名称
  static String _getFormatName(CompressFormat format) {
    switch (format) {
      case CompressFormat.jpeg:
        return 'jpeg';
      case CompressFormat.png:
        return 'png';
      case CompressFormat.webp:
        return 'webp';
      case CompressFormat.heic:
        return 'heic';
    }
  }

  /// 生成输出文件路径
  static String _getOutputPath(String originalPath, CompressFormat format) {
    final pathWithoutExtension = originalPath.replaceAll(RegExp(r'\.\w+$'), '');
    final extension = _getFormatName(format);
    return '${pathWithoutExtension}_compressed.$extension';
  }
}
