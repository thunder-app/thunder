import 'package:flutter/material.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:thunder/utils/bottom_sheet_list_picker.dart';

const List<ListPickerItem<SortType>> defaultSortTypeItems = [
  ListPickerItem(
    payload: SortType.hot,
    icon: Icons.local_fire_department_rounded,
    label: 'Hot',
  ),
  ListPickerItem(
    payload: SortType.active,
    icon: Icons.rocket_launch_rounded,
    label: 'Active',
  ),
  ListPickerItem(
    payload: SortType.new_,
    icon: Icons.auto_awesome_rounded,
    label: 'New',
  ),
  ListPickerItem(
    payload: SortType.mostComments,
    icon: Icons.comment_bank_rounded,
    label: 'Most Comments',
  ),
  ListPickerItem(
    payload: SortType.newComments,
    icon: Icons.add_comment_rounded,
    label: 'New Comments',
  ),
];

const List<ListPickerItem<SortType>> topSortTypeItems = [
  ListPickerItem(
    payload: SortType.topHour,
    iconText: '1h',
    label: 'Top in Past Hour',
  ),
  ListPickerItem(
    payload: SortType.topSixHour,
    iconText: '6h',
    label: 'Top in Past 6 Hours',
  ),
  ListPickerItem(
    payload: SortType.topTwelveHour,
    iconText: '12h',
    label: 'Top in Past 12 Hours',
  ),
  ListPickerItem(
    payload: SortType.topDay,
    iconText: '24h',
    label: 'Top Today',
  ),
  ListPickerItem(
    payload: SortType.topWeek,
    iconText: '7d',
    label: 'Top Week',
  ),
  ListPickerItem(
    payload: SortType.topMonth,
    iconText: '30d',
    label: 'Top Month',
  ),
  ListPickerItem(
    payload: SortType.topYear,
    iconText: '1y',
    label: 'Top Year',
  ),
  ListPickerItem(
    payload: SortType.topAll,
    icon: Icons.military_tech,
    label: 'Top of all time',
  ),
];

const List<ListPickerItem<SortType>> allSortTypeItems = [...defaultSortTypeItems, ...topSortTypeItems];

class SortPicker extends BottomSheetListPicker<SortType> {
  const SortPicker({super.key, required super.onSelect, required super.title, super.items = defaultSortTypeItems});

  @override
  State<StatefulWidget> createState() => _SortPickerState();
}

class _SortPickerState extends State<SortPicker> {
  bool topSelected = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 100),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(opacity: animation, child: child);
        },
        child: topSelected ? topSortPicker() : defaultSortPicker(),
      ),
    );
  }

  Widget defaultSortPicker() {
    final theme = Theme.of(context);

    return Column(
      key: ValueKey<bool>(topSelected),
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0, left: 16.0, right: 16.0),
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
            ..._generateList(defaultSortTypeItems, theme),
            ListTile(
              leading: Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                child: const Icon(Icons.military_tech),
              ),
              title: const Text('Top'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                setState(() {
                  topSelected = true;
                });
              },
            ),
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
        GestureDetector(
          onTap: () {
            setState(() {
              topSelected = false;
            });
          },
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16.0, left: 12.0, right: 16.0),
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
                  Text(
                    'Sort by Top',
                    style: theme.textTheme.titleLarge!.copyWith(),
                  ),
                ],
              ),
            ),
          ),
        ),
        ListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            ..._generateList(topSortTypeItems, theme),
          ],
        ),
        const SizedBox(height: 16.0),
      ],
    );
  }

  List<ListTile> _generateList(List<ListPickerItem<SortType>> items, ThemeData theme) {
    return items
        .map(
          (item) => ListTile(
            title: Text(
              item.label,
              style: theme.textTheme.bodyMedium,
            ),
            leading: Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              child: item.iconText != null
                  ? Text(
                      item.iconText!,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    )
                  : Icon(item.icon),
            ),
            onTap: () {
              Navigator.of(context).pop();
              widget.onSelect(item);
            },
          ),
        )
        .toList();
  }
}
