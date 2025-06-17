import 'package:flutter/material.dart';

import 'package:thunder/core/enums/post_sort_type.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/shared/picker_item.dart';
import 'package:thunder/utils/bottom_sheet_list_picker.dart';
import 'package:thunder/localizations/app_localizations.dart';
import 'package:thunder/utils/global_context.dart';
import 'package:version/version.dart';

List<ListPickerItem<PostSortType>> topPostSortTypeItems = [
  ListPickerItem(
    payload: PostSortType.topHour,
    icon: Icons.check_box_outline_blank,
    label: AppLocalizations.of(GlobalContext.context)!.topHour,
  ),
  ListPickerItem(
    payload: PostSortType.topSixHour,
    icon: Icons.calendar_view_month,
    label: AppLocalizations.of(GlobalContext.context)!.topSixHour,
  ),
  ListPickerItem(
    payload: PostSortType.topTwelveHour,
    icon: Icons.calendar_view_week,
    label: AppLocalizations.of(GlobalContext.context)!.topTwelveHour,
  ),
  ListPickerItem(
    payload: PostSortType.topDay,
    icon: Icons.today,
    label: AppLocalizations.of(GlobalContext.context)!.topDay,
  ),
  ListPickerItem(
    payload: PostSortType.topWeek,
    icon: Icons.view_week_sharp,
    label: AppLocalizations.of(GlobalContext.context)!.topWeek,
  ),
  ListPickerItem(
    payload: PostSortType.topMonth,
    icon: Icons.calendar_month,
    label: AppLocalizations.of(GlobalContext.context)!.topMonth,
  ),
  ListPickerItem(
    payload: PostSortType.topThreeMonths,
    icon: Icons.calendar_month_outlined,
    label: AppLocalizations.of(GlobalContext.context)!.topThreeMonths,
  ),
  ListPickerItem(
    payload: PostSortType.topSixMonths,
    icon: Icons.calendar_today_outlined,
    label: AppLocalizations.of(GlobalContext.context)!.topSixMonths,
  ),
  ListPickerItem(
    payload: PostSortType.topNineMonths,
    icon: Icons.calendar_view_day_outlined,
    label: AppLocalizations.of(GlobalContext.context)!.topNineMonths,
  ),
  ListPickerItem(
    payload: PostSortType.topYear,
    icon: Icons.calendar_today,
    label: AppLocalizations.of(GlobalContext.context)!.topYear,
  ),
  ListPickerItem(
    payload: PostSortType.topAll,
    icon: Icons.military_tech,
    label: AppLocalizations.of(GlobalContext.context)!.topAll,
  ),
];

List<ListPickerItem<PostSortType>> allPostSortTypeItems = [...SortPicker.getDefaultPostSortTypeItems(minimumVersion: LemmyClient.maxVersion), ...topPostSortTypeItems];

class SortPicker extends BottomSheetListPicker<PostSortType> {
  final Version? minimumVersion;

  static List<ListPickerItem<PostSortType>> getDefaultPostSortTypeItems({required Version? minimumVersion}) => [
        ListPickerItem(
          payload: PostSortType.hot,
          icon: Icons.local_fire_department_rounded,
          label: AppLocalizations.of(GlobalContext.context)!.hot,
        ),
        ListPickerItem(
          payload: PostSortType.active,
          icon: Icons.rocket_launch_rounded,
          label: AppLocalizations.of(GlobalContext.context)!.active,
        ),
        if (LemmyClient.versionSupportsFeature(minimumVersion, LemmyFeature.postSortTypeScaled))
          ListPickerItem(
            payload: PostSortType.scaled,
            icon: Icons.line_weight_rounded,
            label: AppLocalizations.of(GlobalContext.context)!.scaled,
          ),
        if (LemmyClient.versionSupportsFeature(minimumVersion, LemmyFeature.postSortTypeControversial))
          ListPickerItem(
            payload: PostSortType.controversial,
            icon: Icons.warning_rounded,
            label: AppLocalizations.of(GlobalContext.context)!.controversial,
          ),
        ListPickerItem(
          payload: PostSortType.new_,
          icon: Icons.auto_awesome_rounded,
          label: AppLocalizations.of(GlobalContext.context)!.new_,
        ),
        ListPickerItem(
          payload: PostSortType.old,
          icon: Icons.access_time_outlined,
          label: AppLocalizations.of(GlobalContext.context)!.old,
        ),
        ListPickerItem(
          payload: PostSortType.mostComments,
          icon: Icons.comment_bank_rounded,
          label: AppLocalizations.of(GlobalContext.context)!.mostComments,
        ),
        ListPickerItem(
          payload: PostSortType.newComments,
          icon: Icons.add_comment_rounded,
          label: AppLocalizations.of(GlobalContext.context)!.newComments,
        ),
      ];

  /// Create a picker which allows selecting a valid sort type.
  /// Specify a [minimumVersion] to determine which sort types will be displayed.
  /// Pass `null` to NOT show any version-specific types (e.g., Scaled).
  /// Pass [LemmyClient.maxVersion] to show ALL types.
  SortPicker({
    super.key,
    required super.onSelect,
    required super.title,
    List<ListPickerItem<PostSortType>>? items,
    super.previouslySelected,
    required this.minimumVersion,
  }) : super(items: items ?? getDefaultPostSortTypeItems(minimumVersion: minimumVersion));

  @override
  State<StatefulWidget> createState() => _SortPickerState();
}

class _SortPickerState extends State<SortPicker> {
  bool topSelected = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: AnimatedSize(
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
        child: topSelected ? topSortPicker() : defaultSortPicker(minimumVersion: widget.minimumVersion),
      ),
    );
  }

  Widget defaultSortPicker({required Version? minimumVersion}) {
    final theme = Theme.of(context);

    return Column(
      key: ValueKey<bool>(topSelected),
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0, left: 26.0, right: 16.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              widget.title,
              style: theme.textTheme.titleLarge!.copyWith(),
            ),
          ),
        ),
        ListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            ..._generateList(SortPicker.getDefaultPostSortTypeItems(minimumVersion: widget.minimumVersion), theme),
            PickerItem(
              label: AppLocalizations.of(GlobalContext.context)!.top,
              icon: Icons.military_tech,
              onSelected: () {
                setState(() {
                  topSelected = true;
                });
              },
              isSelected: topPostSortTypeItems.map((item) => item.payload).contains(widget.previouslySelected),
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

    return Column(
      key: ValueKey<bool>(topSelected),
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        Semantics(
          label: '${AppLocalizations.of(context)!.sortByTop},${AppLocalizations.of(context)!.backButton}',
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
                        const Icon(
                          Icons.chevron_left,
                          size: 30,
                        ),
                        const SizedBox(
                          width: 12,
                        ),
                        Semantics(
                          excludeSemantics: true,
                          child: Text(
                            AppLocalizations.of(context)!.sortByTop,
                            style: theme.textTheme.titleLarge!.copyWith(),
                          ),
                        ),
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
          children: [
            ..._generateList(topPostSortTypeItems, theme),
          ],
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
