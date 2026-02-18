import 'package:flutter/material.dart';

import 'package:thunder/src/features/account/api.dart';
import 'package:thunder/src/foundation/primitives/primitives.dart';
import 'package:thunder/src/foundation/config/global_context.dart';
import 'package:thunder/packages/ui/ui.dart' show BottomSheetListPicker, ListPickerItem, PickerItem;

// ============================================================================
// Post Sort Type Items
// ============================================================================

/// Returns the "Top" sort type items for posts (TopHour, TopDay, etc.)
List<ListPickerItem<PostSortType>> getTopPostSortTypeItems({Account? account}) {
  final l10n = GlobalContext.l10n;
  final platform = account?.platform;

  List<ListPickerItem<PostSortType>> topPostSortTypeItems = [
    ListPickerItem(
      payload: PostSortType.topHour,
      icon: Icons.check_box_outline_blank,
      label: l10n.topHour,
    ),
    ListPickerItem(
      payload: PostSortType.topSixHour,
      icon: Icons.calendar_view_month,
      label: l10n.topSixHour,
    ),
    ListPickerItem(
      payload: PostSortType.topTwelveHour,
      icon: Icons.calendar_view_week,
      label: l10n.topTwelveHour,
    ),
    ListPickerItem(
      payload: PostSortType.topDay,
      icon: Icons.today,
      label: l10n.topDay,
    ),
    ListPickerItem(
      payload: PostSortType.topWeek,
      icon: Icons.view_week_sharp,
      label: l10n.topWeek,
    ),
    ListPickerItem(
      payload: PostSortType.topMonth,
      icon: Icons.calendar_month,
      label: l10n.topMonth,
    ),
    ListPickerItem(
      payload: PostSortType.topThreeMonths,
      icon: Icons.calendar_month_outlined,
      label: l10n.topThreeMonths,
    ),
    ListPickerItem(
      payload: PostSortType.topSixMonths,
      icon: Icons.calendar_today_outlined,
      label: l10n.topSixMonths,
    ),
    ListPickerItem(
      payload: PostSortType.topNineMonths,
      icon: Icons.calendar_view_day_outlined,
      label: l10n.topNineMonths,
    ),
    ListPickerItem(
      payload: PostSortType.topYear,
      icon: Icons.calendar_today,
      label: l10n.topYear,
    ),
    ListPickerItem(
      payload: PostSortType.topAll,
      icon: Icons.military_tech,
      label: l10n.topAll,
    ),
  ];

  if (platform == null) return topPostSortTypeItems;

  // Only return the sort types that are available for the platform (or all platforms).
  return topPostSortTypeItems.where((item) => item.payload.platform == platform || item.payload.platform == null).toList();
}

/// Returns the default (non-Top) sort type items for posts
List<ListPickerItem<PostSortType>> getDefaultPostSortTypeItems({Account? account}) {
  final l10n = GlobalContext.l10n;
  final platform = account?.platform;

  List<ListPickerItem<PostSortType>> defaultPostSortTypeItems = [
    ListPickerItem(
      payload: PostSortType.hot,
      icon: Icons.local_fire_department_rounded,
      label: l10n.hot,
    ),
    ListPickerItem(
      payload: PostSortType.active,
      icon: Icons.rocket_launch_rounded,
      label: l10n.active,
    ),
    ListPickerItem(
      payload: PostSortType.scaled,
      icon: Icons.line_weight_rounded,
      label: l10n.scaled,
    ),
    ListPickerItem(
      payload: PostSortType.controversial,
      icon: Icons.warning_rounded,
      label: l10n.controversial,
    ),
    ListPickerItem(
      payload: PostSortType.new_,
      icon: Icons.auto_awesome_rounded,
      label: l10n.new_,
    ),
    ListPickerItem(
      payload: PostSortType.old,
      icon: Icons.access_time_outlined,
      label: l10n.old,
    ),
    ListPickerItem(
      payload: PostSortType.mostComments,
      icon: Icons.comment_bank_rounded,
      label: l10n.mostComments,
    ),
    ListPickerItem(
      payload: PostSortType.newComments,
      icon: Icons.add_comment_rounded,
      label: l10n.newComments,
    ),
  ];

  if (platform == null) return defaultPostSortTypeItems;

  // Only return the sort types that are available for the platform (or all platforms).
  return defaultPostSortTypeItems.where((item) => item.payload.platform == platform || item.payload.platform == null).toList();
}

/// All post sort type items (default + top) combined.
List<ListPickerItem<PostSortType>> allPostSortTypeItems = [...getDefaultPostSortTypeItems(), ...getTopPostSortTypeItems()];

// ============================================================================
// Comment Sort Type Items
// ============================================================================

/// Returns the sort type items for comments
List<ListPickerItem<CommentSortType>> getCommentSortTypeItems({Account? account}) {
  final l10n = GlobalContext.l10n;
  final platform = account?.platform;

  List<ListPickerItem<CommentSortType>> commentSortTypeItems = [
    ListPickerItem(
      payload: CommentSortType.hot,
      icon: Icons.local_fire_department,
      label: l10n.hot,
    ),
    ListPickerItem(
      payload: CommentSortType.top,
      icon: Icons.military_tech,
      label: l10n.top,
    ),
    ListPickerItem(
      payload: CommentSortType.controversial,
      icon: Icons.warning_rounded,
      label: l10n.controversial,
    ),
    ListPickerItem(
      payload: CommentSortType.new_,
      icon: Icons.auto_awesome_rounded,
      label: l10n.new_,
    ),
    ListPickerItem(
      payload: CommentSortType.old,
      icon: Icons.access_time_outlined,
      label: l10n.old,
    ),
  ];

  if (platform == null) return commentSortTypeItems;

  // Only return the sort types that are available for the platform (or all platforms).
  return commentSortTypeItems.where((item) => item.payload.platform == platform || item.payload.platform == null).toList();
}

// ============================================================================
// Search Sort Type Items
// ============================================================================

/// Returns the "Top" sort type items for search (TopHour, TopDay, etc.)
List<ListPickerItem<SearchSortType>> getTopSearchSortTypeItems({Account? account}) {
  final l10n = GlobalContext.l10n;
  final platform = account?.platform;

  List<ListPickerItem<SearchSortType>> topSearchSortTypeItems = [
    ListPickerItem(
      payload: SearchSortType.topHour,
      icon: Icons.check_box_outline_blank,
      label: l10n.topHour,
    ),
    ListPickerItem(
      payload: SearchSortType.topSixHour,
      icon: Icons.calendar_view_month,
      label: l10n.topSixHour,
    ),
    ListPickerItem(
      payload: SearchSortType.topTwelveHour,
      icon: Icons.calendar_view_week,
      label: l10n.topTwelveHour,
    ),
    ListPickerItem(
      payload: SearchSortType.topDay,
      icon: Icons.today,
      label: l10n.topDay,
    ),
    ListPickerItem(
      payload: SearchSortType.topWeek,
      icon: Icons.view_week_sharp,
      label: l10n.topWeek,
    ),
    ListPickerItem(
      payload: SearchSortType.topMonth,
      icon: Icons.calendar_month,
      label: l10n.topMonth,
    ),
    ListPickerItem(
      payload: SearchSortType.topThreeMonths,
      icon: Icons.calendar_month_outlined,
      label: l10n.topThreeMonths,
    ),
    ListPickerItem(
      payload: SearchSortType.topSixMonths,
      icon: Icons.calendar_today_outlined,
      label: l10n.topSixMonths,
    ),
    ListPickerItem(
      payload: SearchSortType.topNineMonths,
      icon: Icons.calendar_view_day_outlined,
      label: l10n.topNineMonths,
    ),
    ListPickerItem(
      payload: SearchSortType.topYear,
      icon: Icons.calendar_today,
      label: l10n.topYear,
    ),
    ListPickerItem(
      payload: SearchSortType.topAll,
      icon: Icons.military_tech,
      label: l10n.topAll,
    ),
  ];

  if (platform == null) return topSearchSortTypeItems;

  // Only return the sort types that are available for the platform (or all platforms).
  return topSearchSortTypeItems.where((item) => item.payload.platform == platform || item.payload.platform == null).toList();
}

/// Returns the default (non-Top) sort type items for search
List<ListPickerItem<SearchSortType>> getDefaultSearchSortTypeItems({Account? account}) {
  final l10n = GlobalContext.l10n;
  final platform = account?.platform;

  List<ListPickerItem<SearchSortType>> defaultSearchSortTypeItems = [
    ListPickerItem(
      payload: SearchSortType.new_,
      icon: Icons.auto_awesome_rounded,
      label: l10n.new_,
    ),
    ListPickerItem(
      payload: SearchSortType.old,
      icon: Icons.access_time_outlined,
      label: l10n.old,
    ),
    ListPickerItem(
      payload: SearchSortType.controversial,
      icon: Icons.warning_rounded,
      label: l10n.controversial,
    ),
  ];

  if (platform == null) return defaultSearchSortTypeItems;

  // Only return the sort types that are available for the platform (or all platforms).
  return defaultSearchSortTypeItems.where((item) => item.payload.platform == platform || item.payload.platform == null).toList();
}

/// All search sort type items (default + top) combined.
List<ListPickerItem<SearchSortType>> allSearchSortTypeItems = [...getDefaultSearchSortTypeItems(), ...getTopSearchSortTypeItems()];

// ============================================================================
// Unified Sort Picker Widget
// ============================================================================

/// A unified sort picker that works with PostSortType, CommentSortType, and SearchSortType.
///
/// Usage:
/// ```dart
/// // For posts
/// SortPicker<PostSortType>(
///   title: 'Sort Options',
///   onSelect: (selected) => print(selected.payload),
///   previouslySelected: PostSortType.hot,
/// )
///
/// // For comments
/// SortPicker<CommentSortType>(
///   title: 'Sort Options',
///   onSelect: (selected) => print(selected.payload),
///   previouslySelected: CommentSortType.hot,
/// )
///
/// // For search
/// SortPicker<SearchSortType>(
///   title: 'Sort Options',
///   onSelect: (selected) => print(selected.payload),
///   previouslySelected: SearchSortType.topYear,
/// )
/// ```
class SortPicker<T> extends BottomSheetListPicker<T> {
  /// The account that triggered the sort picker. Used to filter sort options by platform.
  final Account? account;

  /// Create a picker which allows selecting a valid sort type.
  SortPicker({
    super.key,
    this.account,
    required super.onSelect,
    required super.title,
    super.previouslySelected,
  }) : super(items: _getItems<T>(account));

  /// Get the appropriate items based on the generic type T.
  static List<ListPickerItem<T>> _getItems<T>(Account? account) {
    if (T == PostSortType) {
      return getDefaultPostSortTypeItems(account: account) as List<ListPickerItem<T>>;
    } else if (T == CommentSortType) {
      return getCommentSortTypeItems(account: account) as List<ListPickerItem<T>>;
    } else if (T == SearchSortType) {
      return getDefaultSearchSortTypeItems(account: account) as List<ListPickerItem<T>>;
    }
    throw ArgumentError('Unsupported sort type: $T. Must be PostSortType, CommentSortType, or SearchSortType.');
  }

  @override
  State<StatefulWidget> createState() => _SortPickerState<T>();
}

class _SortPickerState<T> extends State<SortPicker<T>> {
  bool topSelected = false;

  /// Whether this sort type has a "Top" submenu (only PostSortType and SearchSortType have this).
  bool get hasTopSubmenu => T == PostSortType || T == SearchSortType;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: AnimatedSize(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubicEmphasized,
        child: hasTopSubmenu && topSelected ? topSortPicker() : defaultSortPicker(),
      ),
    );
  }

  Widget defaultSortPicker() {
    final theme = Theme.of(context);
    final l10n = GlobalContext.l10n;

    return Column(
      key: ValueKey<bool>(topSelected),
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0, left: 26.0, right: 16.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(widget.title, style: theme.textTheme.titleLarge),
          ),
        ),
        ListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            ..._generateList(_getDefaultItems(), theme),
            if (hasTopSubmenu)
              PickerItem(
                label: l10n.top,
                icon: Icons.military_tech,
                onSelected: () => setState(() => topSelected = true),
                isSelected: _isTopItemSelected(),
                trailingIcon: Icons.chevron_right,
              )
          ],
        ),
        const SizedBox(height: 16.0),
      ],
    );
  }

  Widget topSortPicker() {
    final theme = Theme.of(context);
    final l10n = GlobalContext.l10n;

    return Column(
      key: ValueKey<bool>(topSelected),
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        Semantics(
          label: '${l10n.sortByTop},${l10n.backButton}',
          child: Padding(
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: Material(
              borderRadius: BorderRadius.circular(50),
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(50),
                onTap: () {
                  setState(() {
                    topSelected = false;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12.0, 10, 16.0, 10.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        const Icon(Icons.chevron_left, size: 30),
                        const SizedBox(width: 12),
                        Semantics(excludeSemantics: true, child: Text(l10n.sortByTop, style: theme.textTheme.titleLarge)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        ListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [..._generateList(_getTopItems(), theme)],
        ),
        const SizedBox(height: 16.0),
      ],
    );
  }

  /// Get the default (non-Top) items for the current sort type.
  List<ListPickerItem<T>> _getDefaultItems() {
    if (T == PostSortType) {
      return getDefaultPostSortTypeItems(account: widget.account) as List<ListPickerItem<T>>;
    } else if (T == CommentSortType) {
      return getCommentSortTypeItems(account: widget.account) as List<ListPickerItem<T>>;
    } else if (T == SearchSortType) {
      return getDefaultSearchSortTypeItems(account: widget.account) as List<ListPickerItem<T>>;
    }
    return [];
  }

  /// Get the "Top" items for the current sort type.
  List<ListPickerItem<T>> _getTopItems() {
    if (T == PostSortType) {
      return getTopPostSortTypeItems(account: widget.account) as List<ListPickerItem<T>>;
    } else if (T == SearchSortType) {
      return getTopSearchSortTypeItems(account: widget.account) as List<ListPickerItem<T>>;
    }
    return [];
  }

  /// Check if a "Top" item is currently selected.
  bool _isTopItemSelected() {
    final topItems = _getTopItems();
    return topItems.map((item) => item.payload).contains(widget.previouslySelected);
  }

  List<Widget> _generateList(List<ListPickerItem<T>> items, ThemeData theme) {
    return items
        .map((item) => PickerItem(
            label: item.label,
            icon: item.icon,
            onSelected: () {
              Navigator.of(context).pop();
              widget.onSelect?.call(item);
            },
            isSelected: widget.previouslySelected == item.payload))
        .toList();
  }
}
