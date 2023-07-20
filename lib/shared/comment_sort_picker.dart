import 'package:flutter/material.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:thunder/utils/bottom_sheet_list_picker.dart';

const List<ListPickerItem<CommentSortType>> commentSortTypeItems = [
  ListPickerItem(
    payload: CommentSortType.top,
    icon: Icons.military_tech,
    label: 'Top',
  ),
  ListPickerItem(
    payload: CommentSortType.old,
    icon: Icons.access_time_outlined,
    label: 'Old',
  ),
  ListPickerItem(
    payload: CommentSortType.new_,
    icon: Icons.auto_awesome_rounded,
    label: 'New',
  ),
  ListPickerItem(
    payload: CommentSortType.hot,
    icon: Icons.local_fire_department,
    label: 'Hot',
  ),
  //
  // ListPickerItem(
  //   payload: CommentSortType.chat,
  //   icon: Icons.chat,
  //   label: 'Chat',
  // ),
];

class CommentSortPicker extends BottomSheetListPicker<CommentSortType> {
  const CommentSortPicker(
      {super.key,
      required super.onSelect,
      required super.title,
      super.items = commentSortTypeItems});

  @override
  State<StatefulWidget> createState() => _SortPickerState();
}

class _SortPickerState extends State<CommentSortPicker> {
  bool topSelected = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 100),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(opacity: animation, child: child);
        },
        child: defaultSortPicker(),
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
            ..._generateList(commentSortTypeItems, theme),
          ],
        ),
        const SizedBox(height: 16.0),
      ],
    );
  }

  List<ListTile> _generateList(
      List<ListPickerItem<CommentSortType>> items, ThemeData theme) {
    return items
        .map(
          (item) => ListTile(
            title: Text(
              item.label,
              style: theme.textTheme.bodyMedium,
            ),
            leading: Icon(item.icon),
            onTap: () {
              Navigator.of(context).pop();
              widget.onSelect(item);
            },
          ),
        )
        .toList();
  }
}
