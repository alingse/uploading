import '../../domain/entities/photo.dart';

/// 照片数据模型
///
/// 用于 DAO 和 Entity 之间的转换
class PhotoModel {
  final String id;
  final String? itemId;
  final String s3Key;
  final String? localPath;
  final UploadStatus uploadStatus;
  final DateTime? createdAt;

  PhotoModel({
    required this.id,
    this.itemId,
    required this.s3Key,
    this.localPath,
    required this.uploadStatus,
    this.createdAt,
  });

  /// 从实体创建模型
  factory PhotoModel.fromEntity(Photo entity) {
    return PhotoModel(
      id: entity.id,
      itemId: entity.itemId,
      s3Key: entity.s3Key,
      localPath: entity.localPath,
      uploadStatus: entity.uploadStatus,
      createdAt: entity.createdAt,
    );
  }

  /// 从 JSON 创建模型
  factory PhotoModel.fromJson(Map<String, dynamic> json) {
    return PhotoModel(
      id: json['id'] as String,
      itemId: json['item_id'] as String?,
      s3Key: json['s3_key'] as String,
      localPath: json['local_path'] as String?,
      uploadStatus: UploadStatus.values.firstWhere(
        (e) => e.name == json['upload_status'],
        orElse: () => UploadStatus.pending,
      ),
      createdAt: json['created_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['created_at'] as int)
          : null,
    );
  }

  /// 转换为实体
  Photo toEntity() {
    return Photo(
      id: id,
      itemId: itemId,
      s3Key: s3Key,
      localPath: localPath,
      uploadStatus: uploadStatus,
      createdAt: createdAt,
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'item_id': itemId,
      's3_key': s3Key,
      'local_path': localPath,
      'upload_status': uploadStatus.name,
      'created_at': createdAt?.millisecondsSinceEpoch,
    };
  }

  /// 复制并修改部分字段
  PhotoModel copyWith({
    String? id,
    String? itemId,
    String? s3Key,
    String? localPath,
    UploadStatus? uploadStatus,
    DateTime? createdAt,
  }) {
    return PhotoModel(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      s3Key: s3Key ?? this.s3Key,
      localPath: localPath ?? this.localPath,
      uploadStatus: uploadStatus ?? this.uploadStatus,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
