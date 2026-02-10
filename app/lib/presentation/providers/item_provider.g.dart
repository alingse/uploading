// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$itemRepositoryHash() => r'87122aa0044f1e80e5124d83121dcbe4d20721e4';

/// 物品仓储 Provider
///
/// Copied from [itemRepository].
@ProviderFor(itemRepository)
final itemRepositoryProvider = AutoDisposeProvider<ItemRepository>.internal(
  itemRepository,
  name: r'itemRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$itemRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ItemRepositoryRef = AutoDisposeProviderRef<ItemRepository>;
String _$itemByIdHash() => r'f26a1ed3912fdd5fed35d17b5e6b0ad974675676';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// 根据 ID 获取物品 Provider
///
/// 提供根据 ID 获取单个物品的能力
///
/// Copied from [itemById].
@ProviderFor(itemById)
const itemByIdProvider = ItemByIdFamily();

/// 根据 ID 获取物品 Provider
///
/// 提供根据 ID 获取单个物品的能力
///
/// Copied from [itemById].
class ItemByIdFamily extends Family<AsyncValue<Item?>> {
  /// 根据 ID 获取物品 Provider
  ///
  /// 提供根据 ID 获取单个物品的能力
  ///
  /// Copied from [itemById].
  const ItemByIdFamily();

  /// 根据 ID 获取物品 Provider
  ///
  /// 提供根据 ID 获取单个物品的能力
  ///
  /// Copied from [itemById].
  ItemByIdProvider call(
    String id,
  ) {
    return ItemByIdProvider(
      id,
    );
  }

  @override
  ItemByIdProvider getProviderOverride(
    covariant ItemByIdProvider provider,
  ) {
    return call(
      provider.id,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'itemByIdProvider';
}

/// 根据 ID 获取物品 Provider
///
/// 提供根据 ID 获取单个物品的能力
///
/// Copied from [itemById].
class ItemByIdProvider extends AutoDisposeFutureProvider<Item?> {
  /// 根据 ID 获取物品 Provider
  ///
  /// 提供根据 ID 获取单个物品的能力
  ///
  /// Copied from [itemById].
  ItemByIdProvider(
    String id,
  ) : this._internal(
          (ref) => itemById(
            ref as ItemByIdRef,
            id,
          ),
          from: itemByIdProvider,
          name: r'itemByIdProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$itemByIdHash,
          dependencies: ItemByIdFamily._dependencies,
          allTransitiveDependencies: ItemByIdFamily._allTransitiveDependencies,
          id: id,
        );

  ItemByIdProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
  }) : super.internal();

  final String id;

  @override
  Override overrideWith(
    FutureOr<Item?> Function(ItemByIdRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ItemByIdProvider._internal(
        (ref) => create(ref as ItemByIdRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        id: id,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Item?> createElement() {
    return _ItemByIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ItemByIdProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ItemByIdRef on AutoDisposeFutureProviderRef<Item?> {
  /// The parameter `id` of this provider.
  String get id;
}

class _ItemByIdProviderElement extends AutoDisposeFutureProviderElement<Item?>
    with ItemByIdRef {
  _ItemByIdProviderElement(super.provider);

  @override
  String get id => (origin as ItemByIdProvider).id;
}

String _$itemCountHash() => r'2f1a4a94c1c008739c0c7c4954a3a1bc5621f2aa';

/// 物品数量 Provider
///
/// 提供物品总数统计
///
/// Copied from [itemCount].
@ProviderFor(itemCount)
final itemCountProvider = AutoDisposeFutureProvider<int>.internal(
  itemCount,
  name: r'itemCountProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$itemCountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ItemCountRef = AutoDisposeFutureProviderRef<int>;
String _$itemListHash() => r'8287ad1325479d1d11dd18203901e574714002dd';

/// 物品列表 Provider
///
/// 管理所有物品的状态
///
/// Copied from [ItemList].
@ProviderFor(ItemList)
final itemListProvider =
    AutoDisposeAsyncNotifierProvider<ItemList, List<Item>>.internal(
  ItemList.new,
  name: r'itemListProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$itemListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ItemList = AutoDisposeAsyncNotifier<List<Item>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
