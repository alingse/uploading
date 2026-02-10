import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/config/app_config.dart';
import '../../../domain/entities/s3_account.dart';
import '../providers/s3_account_provider.dart';

/// 添加/编辑账户页面
class AccountEditPage extends ConsumerStatefulWidget {
  /// 账户 ID，null 表示新增，有值表示编辑
  final String? accountId;

  const AccountEditPage({super.key, this.accountId});

  @override
  ConsumerState<AccountEditPage> createState() => _AccountEditPageState();
}

class _AccountEditPageState extends ConsumerState<AccountEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _accountNameController = TextEditingController();
  final _bucketController = TextEditingController();
  final _accessKeyController = TextEditingController();
  final _secretKeyController = TextEditingController();

  String? _selectedRegion;
  bool _isLoading = false;
  S3Account? _originalAccount;

  @override
  void initState() {
    super.initState();
    _selectedRegion = AppConfig.defaultS3Region;
    if (widget.accountId != null) {
      _loadAccount();
    }
  }

  @override
  void dispose() {
    _accountNameController.dispose();
    _bucketController.dispose();
    _accessKeyController.dispose();
    _secretKeyController.dispose();
    super.dispose();
  }

  /// 加载账户信息（编辑模式）
  Future<void> _loadAccount() async {
    setState(() => _isLoading = true);

    try {
      final account = await ref.read(
        accountByIdProvider(widget.accountId!).future,
      );
      if (account != null && mounted) {
        // 验证 region 是否在可用选项中，如果不在则使用默认值
        final validRegion =
            AppConfig.ossRegionEndpoints.containsKey(account.region)
            ? account.region
            : AppConfig.defaultS3Region;

        setState(() {
          _originalAccount = account;
          _accountNameController.text = account.accountName;
          _bucketController.text = account.bucket;
          _accessKeyController.text = account.accessKey;
          _secretKeyController.text = account.secretKey;
          _selectedRegion = validRegion;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('加载账户失败: $e')));
        Navigator.pop(context);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// 保存账户
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 获取 endpoint，如果区域不在预设列表中则自动生成
      final endpoint = AppConfig.ossRegionEndpoints.containsKey(_selectedRegion)
          ? AppConfig.getEndpointForRegion(_selectedRegion!)
          : 'https://oss-$_selectedRegion.aliyuncs.com';
      final now = DateTime.now();

      final account = S3Account(
        id: widget.accountId ?? const Uuid().v4(),
        accountName: _accountNameController.text.trim(),
        endpoint: endpoint,
        bucket: _bucketController.text.trim(),
        region: _selectedRegion!,
        accessKey: _accessKeyController.text.trim(),
        secretKey: _secretKeyController.text.trim(),
        isActive: _originalAccount?.isActive ?? false,
        lastSyncedAt: _originalAccount?.lastSyncedAt,
        createdAt: _originalAccount?.createdAt ?? now,
      );

      if (widget.accountId == null) {
        await ref.read(accountListProvider.notifier).addAccount(account);
      } else {
        await ref.read(accountListProvider.notifier).updateAccount(account);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.accountId == null ? '账户已添加' : '账户已更新')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('保存失败: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.accountId != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? '编辑账户' : '添加账户')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // 账户名称
                  TextFormField(
                    controller: _accountNameController,
                    decoration: const InputDecoration(
                      labelText: '账户名称',
                      hintText: '如：我的阿里云',
                      prefixIcon: Icon(Icons.account_circle),
                    ),
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return '请输入账户名称';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // 区域选择（支持手动输入）
                  Autocomplete<String>(
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text.isEmpty) {
                        return AppConfig.ossRegionEndpoints.keys.toList();
                      }
                      return AppConfig.ossRegionEndpoints.keys
                          .where(
                            (region) => region.toLowerCase().contains(
                              textEditingValue.text.toLowerCase(),
                            ),
                          )
                          .toList();
                    },
                    initialValue: TextEditingValue(text: _selectedRegion ?? ''),
                    fieldViewBuilder:
                        (context, controller, focusNode, onSubmitted) {
                          // 同步更新 _selectedRegion
                          controller.text = _selectedRegion ?? '';
                          controller.selection = TextSelection.fromPosition(
                            TextPosition(offset: controller.text.length),
                          );

                          return TextFormField(
                            controller: controller,
                            focusNode: focusNode,
                            decoration: const InputDecoration(
                              labelText: '区域',
                              hintText: '如：cn-hangzhou，或手动输入自定义区域',
                              prefixIcon: Icon(Icons.location_on),
                            ),
                            onChanged: (value) {
                              setState(() => _selectedRegion = value);
                            },
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return '请输入区域';
                              }
                              return null;
                            },
                          );
                        },
                    onSelected: (value) {
                      setState(() => _selectedRegion = value);
                    },
                    optionsViewBuilder: (context, onSelected, options) {
                      return Align(
                        alignment: Alignment.topLeft,
                        child: Material(
                          elevation: 4,
                          child: SizedBox(
                            height: 200,
                            child: ListView.builder(
                              itemCount: options.length,
                              itemBuilder: (context, index) {
                                final region = options.elementAt(index);
                                return ListTile(
                                  title: Text(region),
                                  subtitle: Text(_getRegionDisplayName(region)),
                                  onTap: () => onSelected(region),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // Bucket
                  TextFormField(
                    controller: _bucketController,
                    decoration: const InputDecoration(
                      labelText: 'Bucket 名称',
                      hintText: '如：my-inventory-bucket',
                      prefixIcon: Icon(Icons.storage),
                    ),
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return '请输入 Bucket 名称';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Access Key
                  TextFormField(
                    controller: _accessKeyController,
                    decoration: const InputDecoration(
                      labelText: 'Access Key ID',
                      hintText: 'LTAI5t...',
                      prefixIcon: Icon(Icons.key),
                    ),
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return '请输入 Access Key';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Secret Key
                  TextFormField(
                    controller: _secretKeyController,
                    decoration: const InputDecoration(
                      labelText: 'Secret Access Key',
                      hintText: '••••••••',
                      prefixIcon: Icon(Icons.lock),
                    ),
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _save(),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return '请输入 Secret Key';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Endpoint 预览（自动生成）
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: theme.colorScheme.onSecondaryContainer,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Endpoint（自动生成）',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onSecondaryContainer,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _selectedRegion != null
                                    ? AppConfig.getEndpointForRegion(
                                        _selectedRegion!,
                                      )
                                    : '请选择区域',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSecondaryContainer,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // 保存按钮
                  FilledButton.icon(
                    onPressed: _isLoading ? null : _save,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.save),
                    label: Text(_isLoading ? '保存中...' : '保存'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  /// 获取区域显示名称
  String _getRegionDisplayName(String region) {
    final displayNames = {
      'cn-hangzhou': '华东1（杭州）',
      'cn-beijing': '华北2（北京）',
      'cn-shanghai': '华东2（上海）',
      'cn-shenzhen': '华南1（深圳）',
      'cn-chengdu': '西南1（成都）',
      'cn-guangzhou': '华南2（广州）',
      'cn-nanjing': '华东5（南京）',
      'cn-wuhan': '华中1（武汉）',
      'us-west-1': '美国西部1（硅谷）',
      'us-east-1': '美国东部1（弗吉尼亚）',
      'eu-central-1': '欧洲中部1（法兰克福）',
    };
    return displayNames[region] ?? region;
  }
}
