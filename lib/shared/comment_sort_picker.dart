import 'package:flutter/material.dart';

import 'package:thunder/account/account.dart';
import 'package:thunder/core/enums/comment_sort_type.dart';
import 'package:thunder/shared/picker_item.dart';
import 'package:thunder/utils/bottom_sheet_list_picker.dart';
import 'package:thunder/utils/global_context.dart';

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

/// Create a picker which allows selecting a valid comment sort type.
class CommentSortPicker extends BottomSheetListPicker<CommentSortType> {
  final Account? account;

  CommentSortPicker({
    super.key,
    this.account,
    required super.onSelect,
    required super.title,
    super.previouslySelected,
  }) : super(items: getCommentSortTypeItems(account: account));

  @override
  State<StatefulWidget> createState() => _SortPickerState();
}

class _SortPickerState extends State<CommentSortPicker> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: AnimatedSize(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubicEmphasized,
        child: defaultSortPicker(),
      ),
    );
  }

  Widget defaultSortPicker() {
    final theme = Theme.of(context);

    return Column(
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
          children: [..._generateList(getCommentSortTypeItems(account: widget.account), theme)],
        ),
        const SizedBox(height: 16.0),
      ],
    );
  }

  List<Widget> _generateList(List<ListPickerItem<CommentSortType>> items, ThemeData theme) {
    return items
        .map((item) => PickerItem(
              label: item.label,
              icon: item.icon,
              onSelected: () {
                Navigator.of(context).pop();
                widget.onSelect?.call(item);
              },
              isSelected: widget.previouslySelected == item.payload,
            ))
        .toList();
  }
}
