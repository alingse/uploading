import 'package:freezed_annotation/freezed_annotation.dart';

part 's3_account.freezed.dart';
part 's3_account.g.dart';

/// S3 账户实体
///
/// 表示一个 S3 兼容存储的账户配置
@freezed
class S3Account with _$S3Account {
  const factory S3Account({
    /// 唯一标识
    required String id,

    /// 账户名称（用户自定义，便于识别）
    required String accountName,

    /// S3 端点（如阿里云 OSS: https://oss-cn-hangzhou.aliyuncs.com）
    required String endpoint,

    /// Access Key ID
    required String accessKey,

    /// Secret Access Key
    required String secretKey,

    /// Bucket 名称
    required String bucket,

    /// 区域
    required String region,

    /// 是否为当前激活的账户
    @Default(false) bool isActive,

    /// 最后同步时间（可选）
    DateTime? lastSyncedAt,

    /// 创建时间
    required DateTime createdAt,
  }) = _S3Account;

  factory S3Account.fromJson(Map<String, dynamic> json) =>
      _$S3AccountFromJson(json);
}
