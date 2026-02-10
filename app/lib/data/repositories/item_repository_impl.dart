import '../../domain/entities/item.dart';
import '../../domain/repositories/item_repository.dart';
import '../datasources/local/dao/item_dao.dart';
import '../datasources/local/dao/photo_dao.dart';
import '../datasources/local/dao/tag_dao.dart';
import '../datasources/local/dao/time_event_dao.dart';
import '../models/item_model.dart';
import '../models/photo_model.dart';
import '../models/time_event_model.dart';

/// 物品仓储实现
///
/// 组合使用 ItemDao, PhotoDao, TagDao, TimeEventDao
/// - 物品基础信息存储在 items 表
/// - 照片信息存储在 photos 表
/// - 时间事件存储在 time_events 表
/// - 标签存储在 tags 表
class ItemRepositoryImpl implements ItemRepository {
  final ItemDao _itemDao;
  final PhotoDao _photoDao;
  final TagDao _tagDao;
  final TimeEventDao _timeEventDao;

  ItemRepositoryImpl({
    required ItemDao itemDao,
    required PhotoDao photoDao,
    required TagDao tagDao,
    required TimeEventDao timeEventDao,
  }) : _itemDao = itemDao,
       _photoDao = photoDao,
       _tagDao = tagDao,
       _timeEventDao = timeEventDao;

  @override
  Future<List<Item>> getAllItems() async {
    final itemMaps = await _itemDao.getAll();
    return await _mapToItems(itemMaps);
  }

  @override
  Future<Item?> getItemById(String id) async {
    final itemMap = await _itemDao.getById(id);
    if (itemMap == null) return null;
    final items = await _mapToItems([itemMap]);
    return items.isNotEmpty ? items.first : null;
  }

  @override
  Future<List<Item>> getItemsByPresence(String presence) async {
    final itemMaps = await _itemDao.getByPresence(presence);
    return await _mapToItems(itemMaps);
  }

  @override
  Future<void> addItem(Item item) async {
    final model = ItemModel.fromEntity(item);
    await _itemDao.insert(model.toJson());

    // 保存关联数据
    await _saveRelatedData(item.id, item);
  }

  @override
  Future<void> updateItem(Item item) async {
    final model = ItemModel.fromEntity(item);
    await _itemDao.update(item.id, model.toJson());

    // 删除旧的关联数据
    await _photoDao.deleteByItemId(item.id);
    await _timeEventDao.deleteByItemId(item.id);
    await _tagDao.deleteByItemId(item.id);

    // 保存新的关联数据
    await _saveRelatedData(item.id, item);
  }

  @override
  Future<void> deleteItem(String id) async {
    // 删除关联数据
    await _photoDao.deleteByItemId(id);
    await _timeEventDao.deleteByItemId(id);
    await _tagDao.deleteByItemId(id);

    // 删除物品
    await _itemDao.delete(id);
  }

  @override
  Future<List<Item>> searchItems(String keyword) async {
    final itemMaps = await _itemDao.search(keyword);
    return await _mapToItems(itemMaps);
  }

  @override
  Future<int> getItemCount() async {
    return await _itemDao.count();
  }

  /// 将数据库映射转换为物品实体列表
  Future<List<Item>> _mapToItems(List<Map<String, dynamic>> itemMaps) async {
    final List<Item> items = [];

    for (final itemMap in itemMaps) {
      final itemId = itemMap['id'] as String;

      // 获取关联的照片
      final photoMaps = await _photoDao.getByItemId(itemId);

      // 获取关联的时间事件
      final timeEventMaps = await _timeEventDao.getByItemId(itemId);

      // 获取关联的标签
      final tagMaps = await _tagDao.getByItemId(itemId);
      final tags = tagMaps.map((map) => map['tag_name'] as String).toList();

      // 组装完整物品
      final itemModel = ItemModel.fromJson(itemMap).copyWith(
        photos: photoMaps.map((map) => PhotoModel.fromJson(map)).toList(),
        timeEvents: timeEventMaps
            .map((map) => TimeEventModel.fromJson(map))
            .toList(),
        tags: tags,
      );

      items.add(itemModel.toEntity());
    }

    return items;
  }

  /// 保存关联数据（照片、时间事件、标签）
  Future<void> _saveRelatedData(String itemId, Item item) async {
    // 保存照片
    for (final photo in item.photos) {
      final photoModel = PhotoModel.fromEntity(photo).copyWith(itemId: itemId);
      await _photoDao.insert(photoModel.toJson());
    }

    // 保存时间事件
    for (final timeEvent in item.timeEvents) {
      final timeEventModel = TimeEventModel.fromEntity(timeEvent, itemId);
      await _timeEventDao.insert(timeEventModel.toJson());
    }

    // 保存标签
    for (final tag in item.tags) {
      await _tagDao.insert({'item_id': itemId, 'tag_name': tag});
    }
  }
}
