import 'package:flutter/material.dart';

import 'package:thunder/account/account.dart';
import 'package:thunder/core/enums/post_sort_type.dart';
import 'package:thunder/shared/picker_item.dart';
import 'package:thunder/utils/bottom_sheet_list_picker.dart';
import 'package:thunder/utils/global_context.dart';

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

List<ListPickerItem<PostSortType>> allPostSortTypeItems = [...getDefaultPostSortTypeItems(), ...getTopPostSortTypeItems()];

class SortPicker extends BottomSheetListPicker<PostSortType> {
  /// The account that triggered the sort picker.
  final Account? account;

  /// Create a picker which allows selecting a valid sort type.
  SortPicker({
    super.key,
    this.account,
    required super.onSelect,
    required super.title,
    super.previouslySelected,
  }) : super(items: getDefaultPostSortTypeItems(account: account));

  @override
  State<StatefulWidget> createState() => _SortPickerState();
}

class _SortPickerState extends State<SortPicker> {
  bool topSelected = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: AnimatedSize(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubicEmphasized,
        child: topSelected ? topSortPicker() : defaultSortPicker(),
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
            ..._generateList(getDefaultPostSortTypeItems(account: widget.account), theme),
            PickerItem(
              label: l10n.top,
              icon: Icons.military_tech,
              onSelected: () => setState(() => topSelected = true),
              isSelected: getTopPostSortTypeItems(account: widget.account).map((item) => item.payload).contains(widget.previouslySelected),
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
          children: [..._generateList(getTopPostSortTypeItems(account: widget.account), theme)],
        ),
        const SizedBox(height: 16.0),
      ],
    );
  }

  List<Widget> _generateList(List<ListPickerItem<PostSortType>> items, ThemeData theme) {
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
