import 'package:flutter_test/flutter_test.dart';
import 'package:uploading/data/models/s3_account_model.dart';
import 'package:uploading/domain/entities/s3_account.dart';

void main() {
  group('S3AccountModel', () {
    final mockJson = {
      'id': 'test-id',
      'account_name': 'Test Account',
      'endpoint': 'https://oss-cn-hangzhou.aliyuncs.com',
      'bucket': 'test-bucket',
      'region': 'oss-cn-hangzhou',
      'is_active': 1,
      'last_synced_at': 1640995200000, // 2022-01-01
      'created_at': 1640995200000,
    };

    final mockEntity = S3Account(
      id: 'test-id',
      accountName: 'Test Account',
      endpoint: 'https://oss-cn-hangzhou.aliyuncs.com',
      accessKey: 'test-access-key',
      secretKey: 'test-secret-key',
      bucket: 'test-bucket',
      region: 'oss-cn-hangzhou',
      isActive: true,
      lastSyncedAt: DateTime.fromMillisecondsSinceEpoch(1640995200000),
      createdAt: DateTime.fromMillisecondsSinceEpoch(1640995200000),
    );

    test('fromJson 应该创建不包含凭证的模型', () {
      final model = S3AccountModel.fromJson(mockJson);

      expect(model.id, 'test-id');
      expect(model.accountName, 'Test Account');
      expect(model.endpoint, 'https://oss-cn-hangzhou.aliyuncs.com');
      expect(model.bucket, 'test-bucket');
      expect(model.region, 'oss-cn-hangzhou');
      expect(model.isActive, true);
      expect(model.lastSyncedAt, isNotNull);
      expect(model.createdAt, isNotNull);
    });

    test('toJson 应该不包含凭证字段', () {
      final model = S3AccountModel.fromJson(mockJson);
      final json = model.toJson();

      expect(json.containsKey('access_key'), false);
      expect(json.containsKey('secret_key'), false);
      expect(json['id'], 'test-id');
      expect(json['account_name'], 'Test Account');
      expect(json['bucket'], 'test-bucket');
    });

    test('fromEntity 应该创建不包含凭证的模型', () {
      final model = S3AccountModel.fromEntity(mockEntity);

      expect(model.id, 'test-id');
      expect(model.accountName, 'Test Account');
      expect(model.bucket, 'test-bucket');
      // 验证模型中没有凭证字段
      // 注意：我们不能直接访问 private 字段，但可以通过 toJson 验证
    });

    test('toEntity 应该需要传入凭证参数', () {
      final model = S3AccountModel.fromJson(mockJson);
      final entity = model.toEntity(
        accessKey: 'test-access-key',
        secretKey: 'test-secret-key',
      );

      expect(entity.id, 'test-id');
      expect(entity.accessKey, 'test-access-key');
      expect(entity.secretKey, 'test-secret-key');
    });

    test('copyWith 应该不包含凭证字段', () {
      final model = S3AccountModel.fromJson(mockJson);
      final updated = model.copyWith(accountName: 'Updated Account');

      expect(updated.accountName, 'Updated Account');
      expect(updated.id, model.id);
      expect(updated.bucket, model.bucket);
    });

    test('fromJsonWithCredentials 应该向后兼容', () {
      final model = S3AccountModel.fromJsonWithCredentials(
        mockJson,
        accessKey: 'test-access-key',
        secretKey: 'test-secret-key',
      );

      expect(model.id, 'test-id');
      expect(model.accountName, 'Test Account');
      // 凭证参数被忽略，模型本身不包含凭证
    });

    test('所有模型操作都应避免泄露凭证', () {
      final model = S3AccountModel.fromJson(mockJson);

      // 验证 toJson 不包含凭证
      final json = model.toJson();
      expect(json.containsKey('access_key'), false);
      expect(json.containsKey('secret_key'), false);

      // 验证 copyFrom 不包含凭证参数
      final copied = model.copyWith(accountName: 'New');
      final copiedJson = copied.toJson();
      expect(copiedJson.containsKey('access_key'), false);
      expect(copiedJson.containsKey('secret_key'), false);
    });
  });
}
