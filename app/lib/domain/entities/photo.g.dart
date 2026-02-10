// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'photo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PhotoImpl _$$PhotoImplFromJson(Map<String, dynamic> json) => _$PhotoImpl(
      id: json['id'] as String,
      itemId: json['itemId'] as String?,
      s3Key: json['s3Key'] as String,
      localPath: json['localPath'] as String?,
      uploadStatus:
          $enumDecodeNullable(_$UploadStatusEnumMap, json['uploadStatus']) ??
              UploadStatus.pending,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$PhotoImplToJson(_$PhotoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'itemId': instance.itemId,
      's3Key': instance.s3Key,
      'localPath': instance.localPath,
      'uploadStatus': _$UploadStatusEnumMap[instance.uploadStatus]!,
      'createdAt': instance.createdAt?.toIso8601String(),
    };

const _$UploadStatusEnumMap = {
  UploadStatus.pending: 'pending',
  UploadStatus.uploading: 'uploading',
  UploadStatus.completed: 'completed',
  UploadStatus.failed: 'failed',
};
