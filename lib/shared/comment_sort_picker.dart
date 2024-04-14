import 'package:flutter/material.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/shared/picker_item.dart';
import 'package:thunder/utils/bottom_sheet_list_picker.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:thunder/utils/global_context.dart';
import 'package:version/version.dart';

/// Create a picker which allows selecting a valid comment sort type.
/// Specify a [minimumVersion] to determine which sort types will be displayed.
/// Pass `null` to NOT show any version-specific types (e.g., Scaled).
/// Pass [LemmyClient.maxVersion] to show ALL types.
class CommentSortPicker extends BottomSheetListPicker<CommentSortType> {
  final Version? minimumVersion;

  static List<ListPickerItem<CommentSortType>> getCommentSortTypeItems({required Version? minimumVersion}) => [
        ListPickerItem(
          payload: CommentSortType.hot,
          icon: Icons.local_fire_department,
          label: AppLocalizations.of(GlobalContext.context)!.hot,
        ),
        ListPickerItem(
          payload: CommentSortType.top,
          icon: Icons.military_tech,
          label: AppLocalizations.of(GlobalContext.context)!.top,
        ),
        if (LemmyClient.versionSupportsFeature(minimumVersion, LemmyFeature.commentSortTypeControversial))
          ListPickerItem(
            payload: CommentSortType.controversial,
            icon: Icons.warning_rounded,
            label: AppLocalizations.of(GlobalContext.context)!.controversial,
          ),
        ListPickerItem(
          payload: CommentSortType.new_,
          icon: Icons.auto_awesome_rounded,
          label: AppLocalizations.of(GlobalContext.context)!.new_,
        ),
        ListPickerItem(
          payload: CommentSortType.old,
          icon: Icons.access_time_outlined,
          label: AppLocalizations.of(GlobalContext.context)!.old,
        ),
      ];

  CommentSortPicker({
    super.key,
    required super.onSelect,
    required super.title,
    List<ListPickerItem<CommentSortType>>? items,
    super.previouslySelected,
    required this.minimumVersion,
  }) : super(items: items ?? CommentSortPicker.getCommentSortTypeItems(minimumVersion: minimumVersion));

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
            ..._generateList(CommentSortPicker.getCommentSortTypeItems(minimumVersion: widget.minimumVersion), theme),
          ],
        ),
        const SizedBox(height: 16.0),
      ],
    );
  }

  List<Widget> _generateList(List<ListPickerItem<CommentSortType>> items, ThemeData theme) {
    return items
        .map(
          (item) => PickerItem(
            label: item.label,
            icon: item.icon,
            onSelected: () {
              Navigator.of(context).pop();
              widget.onSelect?.call(item);
            },
            isSelected: widget.previouslySelected == item.payload,
          ),
        )
        .toList();
  }
}
