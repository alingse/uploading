import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/datasources/local/dao/item_dao.dart';
import '../../../data/datasources/local/dao/photo_dao.dart';
import '../../../data/datasources/local/dao/tag_dao.dart';
import '../../../data/datasources/local/dao/time_event_dao.dart';
import '../../../data/repositories/item_repository_impl.dart';
import '../../../domain/entities/item.dart';
import '../../../domain/repositories/item_repository.dart';

part 'item_provider.g.dart';

/// 物品仓储 Provider
@riverpod
ItemRepository itemRepository(ItemRepositoryRef ref) {
  return ItemRepositoryImpl(
    itemDao: ItemDao(),
    photoDao: PhotoDao(),
    tagDao: TagDao(),
    timeEventDao: TimeEventDao(),
  );
}

/// 物品列表 Provider
///
/// 管理所有物品的状态
@riverpod
class ItemList extends _$ItemList {
  @override
  Future<List<Item>> build() async {
    final repo = ref.read(itemRepositoryProvider);
    return await repo.getAllItems();
  }

  /// 添加物品
  Future<void> addItem(Item item) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(itemRepositoryProvider);
      await repo.addItem(item);
      return await repo.getAllItems();
    });
  }

  /// 更新物品
  Future<void> updateItem(Item item) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(itemRepositoryProvider);
      await repo.updateItem(item);
      return await repo.getAllItems();
    });
  }

  /// 删除物品
  Future<void> deleteItem(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(itemRepositoryProvider);
      await repo.deleteItem(id);
      return await repo.getAllItems();
    });
  }

  /// 根据 presence 筛选物品
  Future<void> filterByPresence(String presence) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(itemRepositoryProvider);
      return await repo.getItemsByPresence(presence);
    });
  }

  /// 搜索物品
  Future<void> search(String keyword) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(itemRepositoryProvider);
      return await repo.searchItems(keyword);
    });
  }

  /// 刷新列表
  Future<void> refresh() async {
    ref.invalidate(itemListProvider);
  }
}

/// 根据 ID 获取物品 Provider
///
/// 提供根据 ID 获取单个物品的能力
@riverpod
Future<Item?> itemById(ItemByIdRef ref, String id) async {
  final repo = ref.read(itemRepositoryProvider);
  return await repo.getItemById(id);
}

/// 物品数量 Provider
///
/// 提供物品总数统计
@riverpod
Future<int> itemCount(ItemCountRef ref) async {
  final repo = ref.read(itemRepositoryProvider);
  return await repo.getItemCount();
}
