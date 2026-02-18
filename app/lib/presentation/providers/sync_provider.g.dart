// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$autoSyncManagerHash() => r'5f64aafb28ca58e68803a70e5d500f03886b5831';

/// 自动同步管理器 Provider
///
/// 提供 AutoSyncManager 单例
///
/// Copied from [autoSyncManager].
@ProviderFor(autoSyncManager)
final autoSyncManagerProvider = AutoDisposeProvider<AutoSyncManager>.internal(
  autoSyncManager,
  name: r'autoSyncManagerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$autoSyncManagerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AutoSyncManagerRef = AutoDisposeProviderRef<AutoSyncManager>;
String _$lastSyncTimeHash() => r'0e0debfb2a8b28fe013ca0686218395866fc8724';

/// 最后同步时间 Provider
///
/// 提供最后同步的时间戳
///
/// Copied from [lastSyncTime].
@ProviderFor(lastSyncTime)
final lastSyncTimeProvider = AutoDisposeProvider<DateTime?>.internal(
  lastSyncTime,
  name: r'lastSyncTimeProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$lastSyncTimeHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LastSyncTimeRef = AutoDisposeProviderRef<DateTime?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
