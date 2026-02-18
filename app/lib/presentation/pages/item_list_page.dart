import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/item.dart';
import '../../../domain/entities/presence.dart';
import '../providers/item_provider.dart';
import '../widgets/item_card.dart';
import '../widgets/sync_status_indicator.dart';
import 'item_detail_page.dart';
import 'app_logs_page.dart';
import 'account_list_page.dart';

/// 物品列表页面
///
/// 显示所有已记录的物品
class ItemListPage extends ConsumerStatefulWidget {
  const ItemListPage({super.key});

  @override
  ConsumerState<ItemListPage> createState() => _ItemListPageState();
}

class _ItemListPageState extends ConsumerState<ItemListPage> {
  /// 当前筛选状态
  Presence? _filterPresence;

  /// 搜索关键字
  String _searchKeyword = '';

  /// 是否显示搜索栏
  bool _showSearch = false;

  @override
  Widget build(BuildContext context) {
    final itemsAsync = ref.watch(itemListProvider);

    return Scaffold(
      appBar: AppBar(
        title: _showSearch ? _buildSearchField() : const Text('物品列表'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          // 同步状态指示器
          const SyncStatusIndicator(),
          IconButton(
            icon: Icon(_showSearch ? Icons.close : Icons.search),
            tooltip: '搜索',
            onPressed: () {
              setState(() {
                _showSearch = !_showSearch;
                if (!_showSearch) {
                  _searchKeyword = '';
                  _applyFilters();
                }
              });
            },
          ),
          PopupMenuButton<Presence?>(
            icon: const Icon(Icons.filter_list),
            tooltip: '筛选',
            onSelected: (presence) {
              setState(() {
                _filterPresence = presence;
                _applyFilters();
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: null, child: Text('全部')),
              ...Presence.values.map(
                (presence) => PopupMenuItem(
                  value: presence,
                  child: Row(
                    children: [
                      Icon(
                        _getPresenceIcon(presence),
                        size: 20,
                        color: _getPresenceColor(presence),
                      ),
                      const SizedBox(width: 8),
                      Text(presence.displayName),
                    ],
                  ),
                ),
              ),
            ],
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            tooltip: '更多',
            onSelected: (value) {
              switch (value) {
                case 'logs':
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const AppLogsPage()),
                  );
                  break;
                case 'accounts':
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const AccountListPage()),
                  );
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'logs',
                child: Row(
                  children: [
                    Icon(Icons.notes_outlined),
                    SizedBox(width: 8),
                    Text('查看日志'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'accounts',
                child: Row(
                  children: [
                    Icon(Icons.account_circle_outlined),
                    SizedBox(width: 8),
                    Text('云账户管理'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: itemsAsync.when(
        data: (items) {
          final filteredItems = _applyLocalFilters(items);

          if (filteredItems.isEmpty) {
            return _buildEmptyState(items.isEmpty);
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: filteredItems.length,
            itemBuilder: (context, index) {
              return ItemCard(
                item: filteredItems[index],
                onTap: () =>
                    _navigateToDetail(context, filteredItems[index].id),
                onLongPress: () =>
                    _navigateToDetailForEdit(context, filteredItems[index].id),
                onDelete: () =>
                    _confirmDelete(context, filteredItems[index].id),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('加载失败', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () {
                  ref.invalidate(itemListProvider);
                },
                icon: const Icon(Icons.refresh),
                label: const Text('重试'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      autofocus: true,
      decoration: const InputDecoration(
        hintText: '搜索物品...',
        border: InputBorder.none,
      ),
      onChanged: (value) {
        _searchKeyword = value;
        _applyFilters();
      },
    );
  }

  List<Item> _applyLocalFilters(List<Item> items) {
    var result = items;

    if (_searchKeyword.isNotEmpty) {
      result = result.where((item) {
        return (item.notes?.toLowerCase().contains(
                  _searchKeyword.toLowerCase(),
                ) ??
                false) ||
            item.tags.any(
              (tag) => tag.toLowerCase().contains(_searchKeyword.toLowerCase()),
            );
      }).toList();
    }

    return result;
  }

  void _applyFilters() {
    if (_filterPresence != null) {
      ref
          .read(itemListProvider.notifier)
          .filterByPresence(_filterPresence!.key);
    } else if (_searchKeyword.isNotEmpty) {
      ref.read(itemListProvider.notifier).search(_searchKeyword);
    } else {
      ref.invalidate(itemListProvider);
    }
  }

  Widget _buildEmptyState(bool trulyEmpty) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            trulyEmpty ? Icons.inventory_2_outlined : Icons.search_off,
            size: 80,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 24),
          Text(
            trulyEmpty ? '还没有记录物品' : '没有找到匹配的物品',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            trulyEmpty ? '点击拍照按钮开始记录' : '尝试其他搜索关键字',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToDetail(BuildContext context, String itemId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ItemDetailPage(itemId: itemId)),
    );
  }

  void _navigateToDetailForEdit(BuildContext context, String itemId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ItemDetailPage(
          itemId: itemId,
          startInEditMode: true,
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, String itemId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除这个物品吗？此操作无法撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ref.read(itemListProvider.notifier).deleteItem(itemId);
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('物品已删除')));
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('删除失败: $e')));
                }
              }
            },
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  IconData _getPresenceIcon(Presence presence) {
    switch (presence) {
      case Presence.physical:
        return Icons.inventory_2_outlined;
      case Presence.electronic:
        return Icons.cloud_outlined;
      case Presence.pending:
        return Icons.pending_outlined;
    }
  }

  Color _getPresenceColor(Presence presence) {
    switch (presence) {
      case Presence.physical:
        return Colors.blue;
      case Presence.electronic:
        return Colors.green;
      case Presence.pending:
        return Colors.orange;
    }
  }
}
