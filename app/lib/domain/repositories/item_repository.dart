import '../entities/item.dart';

/// 物品仓储接口
///
/// 定义物品数据访问的抽象操作
abstract class ItemRepository {
  /// 获取所有物品
  Future<List<Item>> getAllItems();

  /// 根据 ID 获取物品
  Future<Item?> getItemById(String id);

  /// 根据 presence 状态获取物品
  Future<List<Item>> getItemsByPresence(String presence);

  /// 添加新物品
  Future<void> addItem(Item item);

  /// 更新物品
  Future<void> updateItem(Item item);

  /// 删除物品
  Future<void> deleteItem(String id);

  /// 根据关键字搜索物品
  Future<List<Item>> searchItems(String keyword);

  /// 获取物品数量
  Future<int> getItemCount();
}
