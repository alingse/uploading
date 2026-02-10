import '../../domain/entities/s3_account.dart';

/// S3 账户数据模型
///
/// 用于 DAO 和 Entity 之间的转换
/// 注意：凭证（accessKey, secretKey）不再从数据库序列化/反序列化，
/// 仅通过 SecureStorage 获取
class S3AccountModel {
  final String id;
  final String accountName;
  final String endpoint;
  final String bucket;
  final String region;
  final bool isActive;
  final DateTime? lastSyncedAt;
  final DateTime createdAt;

  S3AccountModel({
    required this.id,
    required this.accountName,
    required this.endpoint,
    required this.bucket,
    required this.region,
    required this.isActive,
    this.lastSyncedAt,
    required this.createdAt,
  });

  /// 从实体创建模型
  factory S3AccountModel.fromEntity(S3Account entity) {
    return S3AccountModel(
      id: entity.id,
      accountName: entity.accountName,
      endpoint: entity.endpoint,
      bucket: entity.bucket,
      region: entity.region,
      isActive: entity.isActive,
      lastSyncedAt: entity.lastSyncedAt,
      createdAt: entity.createdAt,
    );
  }

  /// 从 JSON 创建模型（不包含凭证）
  factory S3AccountModel.fromJson(Map<String, dynamic> json) {
    return S3AccountModel(
      id: json['id'] as String,
      accountName: json['account_name'] as String,
      endpoint: json['endpoint'] as String,
      bucket: json['bucket'] as String,
      region: json['region'] as String,
      isActive: (json['is_active'] as int) == 1,
      lastSyncedAt: json['last_synced_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['last_synced_at'] as int)
          : null,
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['created_at'] as int),
    );
  }

  /// 从 JSON 创建模型（包含凭证）
  /// 用于向后兼容，从旧版本数据库迁移
  factory S3AccountModel.fromJsonWithCredentials(
    Map<String, dynamic> json, {
    String? accessKey,
    String? secretKey,
  }) {
    final model = S3AccountModel.fromJson(json);
    // 如果提供了凭证，可以后续通过其他方式使用
    // 注意：这个方法主要是为了迁移时兼容
    return model;
  }

  /// 转换为实体
  /// 注意：凭证需要从 SecureStorage 获取并传入
  S3Account toEntity({String? accessKey, String? secretKey}) {
    return S3Account(
      id: id,
      accountName: accountName,
      endpoint: endpoint,
      accessKey: accessKey ?? '',
      secretKey: secretKey ?? '',
      bucket: bucket,
      region: region,
      isActive: isActive,
      lastSyncedAt: lastSyncedAt,
      createdAt: createdAt,
    );
  }

  /// 转换为 JSON（不包含凭证）
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'account_name': accountName,
      'endpoint': endpoint,
      'bucket': bucket,
      'region': region,
      'is_active': isActive ? 1 : 0,
      'last_synced_at': lastSyncedAt?.millisecondsSinceEpoch,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  /// 复制并修改部分字段
  S3AccountModel copyWith({
    String? id,
    String? accountName,
    String? endpoint,
    String? bucket,
    String? region,
    bool? isActive,
    DateTime? lastSyncedAt,
    DateTime? createdAt,
  }) {
    return S3AccountModel(
      id: id ?? this.id,
      accountName: accountName ?? this.accountName,
      endpoint: endpoint ?? this.endpoint,
      bucket: bucket ?? this.bucket,
      region: region ?? this.region,
      isActive: isActive ?? this.isActive,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
