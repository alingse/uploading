// GENERATED CODE - DO NOT MODIFY BY HAND

part of 's3_account_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$s3AccountRepositoryHash() =>
    r'a1073ac00d3cea24e12940ef75d1d22765b4eceb';

/// S3 账户仓储 Provider
///
/// Copied from [s3AccountRepository].
@ProviderFor(s3AccountRepository)
final s3AccountRepositoryProvider =
    AutoDisposeProvider<S3AccountRepository>.internal(
  s3AccountRepository,
  name: r's3AccountRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$s3AccountRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef S3AccountRepositoryRef = AutoDisposeProviderRef<S3AccountRepository>;
String _$activeAccountHash() => r'70d262a9cac88b761ca525f0f44b46c7fcd6d99d';

/// 当前激活账户 Provider
///
/// 提供当前激活的 S3 账户
///
/// Copied from [activeAccount].
@ProviderFor(activeAccount)
final activeAccountProvider = AutoDisposeFutureProvider<S3Account?>.internal(
  activeAccount,
  name: r'activeAccountProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$activeAccountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ActiveAccountRef = AutoDisposeFutureProviderRef<S3Account?>;
String _$accountByIdHash() => r'3548bb6afa08ad95f8e4fb37b76857692229a406';

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

/// 根据 ID 获取账户 Provider
///
/// 提供根据 ID 获取单个账户的能力
///
/// Copied from [accountById].
@ProviderFor(accountById)
const accountByIdProvider = AccountByIdFamily();

/// 根据 ID 获取账户 Provider
///
/// 提供根据 ID 获取单个账户的能力
///
/// Copied from [accountById].
class AccountByIdFamily extends Family<AsyncValue<S3Account?>> {
  /// 根据 ID 获取账户 Provider
  ///
  /// 提供根据 ID 获取单个账户的能力
  ///
  /// Copied from [accountById].
  const AccountByIdFamily();

  /// 根据 ID 获取账户 Provider
  ///
  /// 提供根据 ID 获取单个账户的能力
  ///
  /// Copied from [accountById].
  AccountByIdProvider call(
    String id,
  ) {
    return AccountByIdProvider(
      id,
    );
  }

  @override
  AccountByIdProvider getProviderOverride(
    covariant AccountByIdProvider provider,
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
  String? get name => r'accountByIdProvider';
}

/// 根据 ID 获取账户 Provider
///
/// 提供根据 ID 获取单个账户的能力
///
/// Copied from [accountById].
class AccountByIdProvider extends AutoDisposeFutureProvider<S3Account?> {
  /// 根据 ID 获取账户 Provider
  ///
  /// 提供根据 ID 获取单个账户的能力
  ///
  /// Copied from [accountById].
  AccountByIdProvider(
    String id,
  ) : this._internal(
          (ref) => accountById(
            ref as AccountByIdRef,
            id,
          ),
          from: accountByIdProvider,
          name: r'accountByIdProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$accountByIdHash,
          dependencies: AccountByIdFamily._dependencies,
          allTransitiveDependencies:
              AccountByIdFamily._allTransitiveDependencies,
          id: id,
        );

  AccountByIdProvider._internal(
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
    FutureOr<S3Account?> Function(AccountByIdRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AccountByIdProvider._internal(
        (ref) => create(ref as AccountByIdRef),
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
  AutoDisposeFutureProviderElement<S3Account?> createElement() {
    return _AccountByIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AccountByIdProvider && other.id == id;
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
mixin AccountByIdRef on AutoDisposeFutureProviderRef<S3Account?> {
  /// The parameter `id` of this provider.
  String get id;
}

class _AccountByIdProviderElement
    extends AutoDisposeFutureProviderElement<S3Account?> with AccountByIdRef {
  _AccountByIdProviderElement(super.provider);

  @override
  String get id => (origin as AccountByIdProvider).id;
}

String _$accountListHash() => r'd29495d4f9da44e9691af773548377ab2b2d7b6f';

/// 账户列表 Provider
///
/// 管理所有 S3 账户的状态
///
/// Copied from [AccountList].
@ProviderFor(AccountList)
final accountListProvider =
    AutoDisposeAsyncNotifierProvider<AccountList, List<S3Account>>.internal(
  AccountList.new,
  name: r'accountListProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$accountListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AccountList = AutoDisposeAsyncNotifier<List<S3Account>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
