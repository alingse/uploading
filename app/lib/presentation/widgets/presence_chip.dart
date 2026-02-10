import 'package:flutter/material.dart';
import '../../../domain/entities/presence.dart';

/// 存在性标签组件
///
/// 显示物品的存在性状态（实物保留/电子永生/待决策）
class PresenceChip extends StatelessWidget {
  /// 存在性状态
  final Presence presence;

  /// 点击回调（可选）
  final VoidCallback? onTap;

  const PresenceChip({super.key, required this.presence, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color backgroundColor;
    Color textColor;
    IconData icon;

    switch (presence) {
      case Presence.physical:
        backgroundColor = theme.colorScheme.primaryContainer;
        textColor = theme.colorScheme.onPrimaryContainer;
        icon = Icons.inventory_2_outlined;
        break;
      case Presence.electronic:
        backgroundColor = theme.colorScheme.tertiaryContainer;
        textColor = theme.colorScheme.onTertiaryContainer;
        icon = Icons.cloud_outlined;
        break;
      case Presence.pending:
        backgroundColor = theme.colorScheme.secondaryContainer;
        textColor = theme.colorScheme.onSecondaryContainer;
        icon = Icons.pending_outlined;
        break;
    }

    final chip = Chip(
      avatar: Icon(icon, size: 18, color: textColor),
      label: Text(
        presence.displayName,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      backgroundColor: backgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      visualDensity: VisualDensity.compact,
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: chip);
    }

    return chip;
  }
}

/// 存在性选择器组件
///
/// 用于选择存在性状态
class PresenceSelector extends StatelessWidget {
  /// 当前选中的状态
  final Presence selected;

  /// 选择回调
  final ValueChanged<Presence> onSelected;

  const PresenceSelector({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<Presence>(
      segments: Presence.values
          .map(
            (presence) => ButtonSegment<Presence>(
              value: presence,
              label: Text(presence.displayName),
              icon: Icon(_getIcon(presence)),
            ),
          )
          .toList(),
      selected: {selected},
      onSelectionChanged: (Set<Presence> newSelection) {
        onSelected(newSelection.first);
      },
    );
  }

  IconData _getIcon(Presence presence) {
    switch (presence) {
      case Presence.physical:
        return Icons.inventory_2_outlined;
      case Presence.electronic:
        return Icons.cloud_outlined;
      case Presence.pending:
        return Icons.pending_outlined;
    }
  }
}
