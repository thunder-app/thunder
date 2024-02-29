import 'package:flutter/material.dart';

import 'package:lemmy_api_client/v3.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:thunder/shared/picker_item.dart';
import 'package:thunder/utils/bottom_sheet_list_picker.dart';
import 'package:thunder/utils/global_context.dart';

enum ModlogActionTypeFilterCategory { all, post, comment, community, instance }

List<ListPickerItem<ModlogActionType>> postModlogActionTypeItems = [
  ListPickerItem(
    payload: ModlogActionType.modRemovePost,
    icon: Icons.delete_rounded,
    label: AppLocalizations.of(GlobalContext.context)!.modRemovePost,
  ),
  ListPickerItem(
    payload: ModlogActionType.modLockPost,
    icon: Icons.lock_person_rounded,
    label: AppLocalizations.of(GlobalContext.context)!.modLockPost,
  ),
  ListPickerItem(
    payload: ModlogActionType.modFeaturePost,
    icon: Icons.push_pin_rounded,
    label: AppLocalizations.of(GlobalContext.context)!.modFeaturePost,
  ),
];

List<ListPickerItem<ModlogActionType>> commentModlogActionTypeItems = [
  ListPickerItem(
    payload: ModlogActionType.modRemoveComment,
    icon: Icons.comments_disabled_rounded,
    label: AppLocalizations.of(GlobalContext.context)!.modRemoveComment,
  ),
];

List<ListPickerItem<ModlogActionType>> communityModlogActionTypeItems = [
  ListPickerItem(
    payload: ModlogActionType.modRemoveCommunity,
    icon: Icons.domain_disabled_rounded,
    label: AppLocalizations.of(GlobalContext.context)!.modRemoveCommunity,
  ),
  ListPickerItem(
    payload: ModlogActionType.modBanFromCommunity,
    icon: Icons.person_off_rounded,
    label: AppLocalizations.of(GlobalContext.context)!.modBanFromCommunity,
  ),
  ListPickerItem(
    payload: ModlogActionType.modAddCommunity,
    icon: Icons.person_add_alt_1_rounded,
    label: AppLocalizations.of(GlobalContext.context)!.modAddCommunity,
  ),
  ListPickerItem(
    payload: ModlogActionType.modTransferCommunity,
    icon: Icons.swap_horiz_rounded,
    label: AppLocalizations.of(GlobalContext.context)!.modTransferCommunity,
  ),
];

List<ListPickerItem<ModlogActionType>> instanceModlogActionTypeItems = [
  ListPickerItem(
    payload: ModlogActionType.modAdd,
    icon: Icons.person_add_alt_1_rounded,
    label: AppLocalizations.of(GlobalContext.context)!.modAdd,
  ),
  ListPickerItem(
    payload: ModlogActionType.modBan,
    icon: Icons.person_off_rounded,
    label: AppLocalizations.of(GlobalContext.context)!.modBan,
  ),
];

/// Creates a [ModlogActionTypePicker] which holds a list of modlog action types.
/// The modlog action type is used to filter the modlog events.
class ModlogActionTypePicker extends BottomSheetListPicker<ModlogActionType> {
  static List<ListPickerItem<ModlogActionType>> getDefaultModlogActionTypeItems() => [
        ListPickerItem(
          payload: ModlogActionType.all,
          icon: Icons.check_box_outline_blank,
          label: AppLocalizations.of(GlobalContext.context)!.all,
        ),
        // ListPickerItem(
        //   payload: ModlogActionType.modHideCommunity,
        //   icon: Icons.disabled_visible,
        //   label: AppLocalizations.of(GlobalContext.context)!.modHideCommunity,
        // ),
        // ListPickerItem(
        //   payload: ModlogActionType.adminPurgePerson,
        //   icon: Icons.person_off,
        //   label: AppLocalizations.of(GlobalContext.context)!.adminPurgePerson,
        // ),
        // ListPickerItem(
        //   payload: ModlogActionType.adminPurgeCommunity,
        //   icon: Icons.domain_disabled,
        //   label: AppLocalizations.of(GlobalContext.context)!.adminPurgeCommunity,
        // ),
        // ListPickerItem(
        //   payload: ModlogActionType.adminPurgePost,
        //   icon: Icons.delete,
        //   label: AppLocalizations.of(GlobalContext.context)!.adminPurgePost,
        // ),
        // ListPickerItem(
        //   payload: ModlogActionType.adminPurgeComment,
        //   icon: Icons.delete,
        //   label: AppLocalizations.of(GlobalContext.context)!.adminPurgeComment,
        // )
      ];

  ModlogActionTypePicker({
    super.key,
    required super.onSelect,
    required super.title,
    List<ListPickerItem<ModlogActionType>>? items,
    super.previouslySelected,
  }) : super(items: items ?? getDefaultModlogActionTypeItems());

  @override
  State<StatefulWidget> createState() => _ModlogActionTypePickerState();
}

class _ModlogActionTypePickerState extends State<ModlogActionTypePicker> {
  ModlogActionTypeFilterCategory category = ModlogActionTypeFilterCategory.all;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 100),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: switch (category) {
            ModlogActionTypeFilterCategory.all => defaultModlogActionTypePicker(),
            ModlogActionTypeFilterCategory.community => communityModlogActionTypePicker(),
            ModlogActionTypeFilterCategory.instance => instanceModlogActionTypePicker(),
            ModlogActionTypeFilterCategory.post => postModlogActionTypePicker(),
            ModlogActionTypeFilterCategory.comment => commentModlogActionTypePicker(),
          }),
    );
  }

  Widget defaultModlogActionTypePicker() {
    final theme = Theme.of(context);

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
            ..._generateList(ModlogActionTypePicker.getDefaultModlogActionTypeItems(), theme),
            PickerItem(
              label: AppLocalizations.of(GlobalContext.context)!.posts,
              icon: Icons.military_tech,
              onSelected: () {
                setState(() {
                  category = ModlogActionTypeFilterCategory.post;
                });
              },
              isSelected: postModlogActionTypeItems.map((item) => item.payload).contains(widget.previouslySelected),
              trailingIcon: Icons.chevron_right,
            ),
            PickerItem(
              label: AppLocalizations.of(GlobalContext.context)!.comments,
              icon: Icons.military_tech,
              onSelected: () {
                setState(() {
                  category = ModlogActionTypeFilterCategory.comment;
                });
              },
              isSelected: commentModlogActionTypeItems.map((item) => item.payload).contains(widget.previouslySelected),
              trailingIcon: Icons.chevron_right,
            ),
            PickerItem(
              label: AppLocalizations.of(GlobalContext.context)!.communities,
              icon: Icons.military_tech,
              onSelected: () {
                setState(() {
                  category = ModlogActionTypeFilterCategory.community;
                });
              },
              isSelected: communityModlogActionTypeItems.map((item) => item.payload).contains(widget.previouslySelected),
              trailingIcon: Icons.chevron_right,
            ),
            PickerItem(
              label: AppLocalizations.of(GlobalContext.context)!.instance,
              icon: Icons.military_tech,
              onSelected: () {
                setState(() {
                  category = ModlogActionTypeFilterCategory.instance;
                });
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

  Widget postModlogActionTypePicker() {
    final theme = Theme.of(context);

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
            ..._generateList(postModlogActionTypeItems, theme),
          ],
        ),
        const SizedBox(height: 16.0),
      ],
    );
  }

  Widget commentModlogActionTypePicker() {
    final theme = Theme.of(context);

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
            ..._generateList(commentModlogActionTypeItems, theme),
          ],
        ),
        const SizedBox(height: 16.0),
      ],
    );
  }

  Widget communityModlogActionTypePicker() {
    final theme = Theme.of(context);

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
            ..._generateList(commentModlogActionTypeItems, theme),
          ],
        ),
        const SizedBox(height: 16.0),
      ],
    );
  }

  Widget instanceModlogActionTypePicker() {
    final theme = Theme.of(context);

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
            ..._generateList(instanceModlogActionTypeItems, theme),
          ],
        ),
        const SizedBox(height: 16.0),
      ],
    );
  }

  List<Widget> _generateList(List<ListPickerItem<ModlogActionType>> items, ThemeData theme) {
    return items
        .map((item) => PickerItem(
            label: item.label,
            icon: item.icon,
            onSelected: () {
              Navigator.of(context).pop();
              widget.onSelect(item);
            },
            isSelected: widget.previouslySelected == item.payload))
        .toList();
  }
}
