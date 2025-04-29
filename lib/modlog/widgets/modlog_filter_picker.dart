import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:thunder/modlog/modlog.dart';
import 'package:thunder/shared/picker_item.dart';
import 'package:thunder/utils/bottom_sheet_list_picker.dart';
import 'package:thunder/utils/global_context.dart';

List<ListPickerItem<ModlogActionType>> defaultModlogActionTypeItems = [
  ListPickerItem(
    payload: ModlogActionType.all,
    icon: Icons.check_box_outline_blank,
    label: GlobalContext.l10n.all,
  ),
];

List<ListPickerItem<ModlogActionType>> postModlogActionTypeItems = [
  ListPickerItem(
    payload: ModlogActionType.modRemovePost,
    icon: Icons.delete_rounded,
    label: GlobalContext.l10n.modRemovePost,
  ),
  ListPickerItem(
    payload: ModlogActionType.modLockPost,
    icon: Icons.lock_person_rounded,
    label: GlobalContext.l10n.modLockPost,
  ),
  ListPickerItem(
    payload: ModlogActionType.modFeaturePost,
    icon: Icons.push_pin_rounded,
    label: GlobalContext.l10n.modFeaturePost,
  ),
];

List<ListPickerItem<ModlogActionType>> commentModlogActionTypeItems = [
  ListPickerItem(
    payload: ModlogActionType.modRemoveComment,
    icon: Icons.comments_disabled_rounded,
    label: GlobalContext.l10n.modRemoveComment,
  ),
];

List<ListPickerItem<ModlogActionType>> communityModlogActionTypeItems = [
  ListPickerItem(
    payload: ModlogActionType.modRemoveCommunity,
    icon: Icons.domain_disabled_rounded,
    label: GlobalContext.l10n.modRemoveCommunity,
  ),
  ListPickerItem(
    payload: ModlogActionType.modBanFromCommunity,
    icon: Icons.person_off_rounded,
    label: GlobalContext.l10n.modBanFromCommunity,
  ),
  ListPickerItem(
    payload: ModlogActionType.modAddCommunity,
    icon: Icons.person_add_alt_1_rounded,
    label: GlobalContext.l10n.modAddCommunity,
  ),
  ListPickerItem(
    payload: ModlogActionType.modTransferCommunity,
    icon: Icons.swap_horiz_rounded,
    label: GlobalContext.l10n.modTransferCommunity,
  ),
];

List<ListPickerItem<ModlogActionType>> instanceModlogActionTypeItems = [
  ListPickerItem(
    payload: ModlogActionType.modAdd,
    icon: Icons.person_add_alt_1_rounded,
    label: GlobalContext.l10n.modAdd,
  ),
  ListPickerItem(
    payload: ModlogActionType.modBan,
    icon: Icons.person_off_rounded,
    label: GlobalContext.l10n.modBan,
  ),
];

/// Creates a [ModlogActionTypePicker] which holds a list of modlog action types.
/// The modlog action type is used to filter the modlog events.
class ModlogActionTypePicker extends BottomSheetListPicker<ModlogActionType> {
  ModlogActionTypePicker({
    super.key,
    required super.onSelect,
    required super.title,
    List<ListPickerItem<ModlogActionType>>? items,
    super.previouslySelected,
  }) : super(items: items ?? defaultModlogActionTypeItems);

  @override
  State<StatefulWidget> createState() => _ModlogActionTypePickerState();
}

class _ModlogActionTypePickerState extends State<ModlogActionTypePicker> {
  ModlogActionTypeCategory category = ModlogActionTypeCategory.all;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: AnimatedSize(
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
        child: switch (category) {
          ModlogActionTypeCategory.all => defaultModlogActionTypePicker(),
          ModlogActionTypeCategory.post => ModlogSubFilterPicker(
              title: GlobalContext.l10n.posts,
              items: postModlogActionTypeItems,
              onNavigateBack: () => setState(() => category = ModlogActionTypeCategory.all),
              onSelect: (item) => widget.onSelect?.call(item),
              previouslySelectedItem: widget.previouslySelected,
            ),
          ModlogActionTypeCategory.comment => ModlogSubFilterPicker(
              title: GlobalContext.l10n.comments,
              items: commentModlogActionTypeItems,
              onNavigateBack: () => setState(() => category = ModlogActionTypeCategory.all),
              onSelect: (item) => widget.onSelect?.call(item),
              previouslySelectedItem: widget.previouslySelected,
            ),
          ModlogActionTypeCategory.community => ModlogSubFilterPicker(
              title: GlobalContext.l10n.community,
              items: communityModlogActionTypeItems,
              onNavigateBack: () => setState(() => category = ModlogActionTypeCategory.all),
              onSelect: (item) => widget.onSelect?.call(item),
              previouslySelectedItem: widget.previouslySelected,
            ),
          ModlogActionTypeCategory.instance => ModlogSubFilterPicker(
              title: GlobalContext.l10n.instance(1),
              items: instanceModlogActionTypeItems,
              onNavigateBack: () => setState(() => category = ModlogActionTypeCategory.all),
              onSelect: (item) => widget.onSelect?.call(item),
              previouslySelectedItem: widget.previouslySelected,
            ),
        },
      ),
    );
  }

  Widget defaultModlogActionTypePicker() {
    final theme = Theme.of(context);
    final l10n = GlobalContext.l10n;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0, left: 26.0, right: 16.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              widget.title,
              style: theme.textTheme.titleLarge,
            ),
          ),
        ),
        ListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            ...defaultModlogActionTypeItems.map(
              (item) => PickerItem<ModlogActionType>(
                label: item.label,
                icon: item.icon,
                onSelected: () {
                  HapticFeedback.mediumImpact();
                  Navigator.of(context).pop();
                  widget.onSelect?.call(item);
                },
                isSelected: widget.previouslySelected == item.payload,
              ),
            ),
            PickerItem(
              label: l10n.posts,
              icon: Icons.splitscreen_rounded,
              onSelected: () {
                HapticFeedback.mediumImpact();
                setState(() => category = ModlogActionTypeCategory.post);
              },
              isSelected: postModlogActionTypeItems.map((item) => item.payload).contains(widget.previouslySelected),
              trailingIcon: Icons.chevron_right,
            ),
            PickerItem(
              label: l10n.comments,
              icon: Icons.comment_rounded,
              onSelected: () {
                HapticFeedback.mediumImpact();
                setState(() => category = ModlogActionTypeCategory.comment);
              },
              isSelected: commentModlogActionTypeItems.map((item) => item.payload).contains(widget.previouslySelected),
              trailingIcon: Icons.chevron_right,
            ),
            PickerItem(
              label: l10n.communities,
              icon: Icons.people_rounded,
              onSelected: () {
                HapticFeedback.mediumImpact();
                setState(() => category = ModlogActionTypeCategory.community);
              },
              isSelected: communityModlogActionTypeItems.map((item) => item.payload).contains(widget.previouslySelected),
              trailingIcon: Icons.chevron_right,
            ),
            PickerItem(
              label: GlobalContext.l10n.instance(1),
              icon: Icons.language_rounded,
              onSelected: () {
                HapticFeedback.mediumImpact();
                setState(() => category = ModlogActionTypeCategory.instance);
              },
              isSelected: instanceModlogActionTypeItems.map((item) => item.payload).contains(widget.previouslySelected),
              trailingIcon: Icons.chevron_right,
            )
          ],
        ),
        const SizedBox(height: 16.0),
      ],
    );
  }
}

class ModlogSubFilterPicker extends StatelessWidget {
  /// The title of the [ModlogSubFilterPicker].
  final String title;

  /// The list of modlog action types.
  final List<ListPickerItem<ModlogActionType>> items;

  /// The callback when the back button is pressed.
  final VoidCallback onNavigateBack;

  /// The callback when a modlog action type is selected.
  final void Function(ListPickerItem<ModlogActionType>) onSelect;

  /// The previously selected modlog action type.
  final ModlogActionType? previouslySelectedItem;

  const ModlogSubFilterPicker({
    super.key,
    required this.title,
    required this.items,
    required this.onNavigateBack,
    required this.onSelect,
    this.previouslySelectedItem,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = GlobalContext.l10n;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        Semantics(
          label: '$title, ${l10n.backButton}',
          child: Padding(
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: Material(
              borderRadius: BorderRadius.circular(50),
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(50),
                onTap: () {
                  HapticFeedback.mediumImpact();
                  onNavigateBack();
                },
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12.0, 10, 16.0, 10.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        const Icon(Icons.chevron_left, size: 30),
                        const SizedBox(width: 12),
                        Semantics(
                          excludeSemantics: true,
                          child: Text(
                            title,
                            style: theme.textTheme.titleLarge,
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
          children: items
              .map(
                (item) => PickerItem<ModlogActionType>(
                    label: item.label,
                    icon: item.icon,
                    onSelected: () {
                      HapticFeedback.mediumImpact();
                      Navigator.of(context).pop();
                      onSelect(item);
                    },
                    isSelected: previouslySelectedItem == item.payload),
              )
              .toList(),
        ),
        const SizedBox(height: 16.0),
      ],
    );
  }
}
