import 'package:flutter/material.dart';
import 'package:lemmy_api_client/v3.dart';

class SortTypeItem {
  const SortTypeItem({
    required this.sortType,
    required this.icon,
    required this.label
  });

  final SortType sortType;
  final IconData icon;
  final String label;
}

const defaultSortTypeItems = [
  SortTypeItem(
    sortType: SortType.hot,
    icon: Icons.local_fire_department_rounded,
    label: 'Hot',
  ),
  SortTypeItem(
    sortType: SortType.active,
    icon: Icons.rocket_launch_rounded,
    label: 'Active',
  ),
  SortTypeItem(
    sortType: SortType.new_,
    icon: Icons.auto_awesome_rounded,
    label: 'New',
  ),
  SortTypeItem(
    sortType: SortType.mostComments,
    icon: Icons.comment_bank_rounded,
    label: 'Most Comments',
  ),
  SortTypeItem(
    sortType: SortType.newComments,
    icon: Icons.add_comment_rounded,
    label: 'New Comments',
  ),
];

const topSortTypeItems = [
  SortTypeItem(
    sortType: SortType.topDay,
    icon: Icons.today,
    label: 'Top Today',
  ),
  SortTypeItem(
    sortType: SortType.topWeek,
    icon: Icons.view_week_sharp,
    label: 'Top Week',
  ),
  SortTypeItem(
    sortType: SortType.topMonth,
    icon: Icons.calendar_month,
    label: 'Top Month',
  ),
  SortTypeItem(
    sortType: SortType.topYear,
    icon: Icons.calendar_today,
    label: 'Top Month',
  ),
  SortTypeItem(
    sortType: SortType.topAll,
    icon: Icons.military_tech,
    label: 'Top of all time',
  ),
];

const allSortTypeItems = [
  ...defaultSortTypeItems,
  ...topSortTypeItems
];

class SortPicker extends StatefulWidget {
  final Function(SortTypeItem) onSelect;

  const SortPicker({super.key, required this.onSelect});

  @override
  State<StatefulWidget> createState() => _SortPickerState();
}

class _SortPickerState extends State<SortPicker> {
  bool topSelected = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: topSelected ? topSortPicker() : defaultSortPicker());
  }

  Widget defaultSortPicker() {
    final theme = Theme.of(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0, left: 16.0, right: 16.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Sort Options',
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
              leading: const Icon(Icons.military_tech),
              title: const Text("Top"),
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
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0, left: 16.0, right: 16.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Sort by Top',
              style: theme.textTheme.titleLarge!.copyWith(),
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

  List<ListTile> _generateList(List<SortTypeItem> items, ThemeData theme) {
    return items
        .map((item) => ListTile(
          title: Text(
          item.label,
          style: theme.textTheme.bodyMedium,
          ),
          leading: Icon(item.icon),
          onTap: () {
          // context.read<CommunityBloc>().add(
          //   GetCommunityPostsEvent(
          //     sortType: item.sortType,
          //     reset: true,
          //     listingType: state.communityId != null ? null : state.listingType,
          //     communityId: widget.communityId ?? state.communityId,
          //   ),
          // );
          Navigator.of(context).pop();
          widget.onSelect(item);
          },
          ))
          .toList();
  }
}
