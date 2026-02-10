// GENERATED CODE - DO NOT MODIFY BY HAND

part of 's3_account.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$S3AccountImpl _$$S3AccountImplFromJson(Map<String, dynamic> json) =>
    _$S3AccountImpl(
      id: json['id'] as String,
      accountName: json['accountName'] as String,
      endpoint: json['endpoint'] as String,
      accessKey: json['accessKey'] as String,
      secretKey: json['secretKey'] as String,
      bucket: json['bucket'] as String,
      region: json['region'] as String,
      isActive: json['isActive'] as bool? ?? false,
      lastSyncedAt: json['lastSyncedAt'] == null
          ? null
          : DateTime.parse(json['lastSyncedAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$S3AccountImplToJson(_$S3AccountImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'accountName': instance.accountName,
      'endpoint': instance.endpoint,
      'accessKey': instance.accessKey,
      'secretKey': instance.secretKey,
      'bucket': instance.bucket,
      'region': instance.region,
      'isActive': instance.isActive,
      'lastSyncedAt': instance.lastSyncedAt?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
    };
