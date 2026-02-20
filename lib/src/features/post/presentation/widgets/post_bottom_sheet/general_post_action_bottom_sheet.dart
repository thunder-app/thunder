import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/foundation/primitives/primitives.dart';
import 'package:thunder/src/features/post/post.dart';
import 'package:thunder/src/features/settings/api.dart';
import 'package:thunder/src/foundation/config/global_context.dart';
import 'package:thunder/src/features/instance/domain/utils/instance_link_utils.dart';
import 'package:thunder/src/shared/full_name_copy_utils.dart';
import 'package:thunder/packages/ui/ui.dart' show BottomSheetAction, MultiPickerItem, PickerItemData;

/// Defines the general actions that can be taken on a post
enum GeneralPostAction {
  general(icon: Icons.more_horiz),
  post(icon: Icons.splitscreen_rounded),
  user(icon: Icons.person_rounded),
  community(icon: Icons.people_rounded),
  instance(icon: Icons.language_rounded),
  share(icon: Icons.share);

  String get name {
    final l10n = GlobalContext.l10n;

    return switch (this) {
      GeneralPostAction.post => l10n.post,
      GeneralPostAction.user => l10n.user,
      GeneralPostAction.community => l10n.community,
      GeneralPostAction.instance => l10n.instance(1),
      GeneralPostAction.share => l10n.share,
      GeneralPostAction.general => l10n.actions,
    };
  }

  /// The title to use for the action. This is shown when the given page is active
  String get title {
    final l10n = GlobalContext.l10n;

    return switch (this) {
      GeneralPostAction.post => l10n.postActions,
      GeneralPostAction.user => l10n.userActions,
      GeneralPostAction.community => l10n.communityActions,
      GeneralPostAction.instance => l10n.instanceActions,
      GeneralPostAction.share => l10n.share,
      GeneralPostAction.general => l10n.actions,
    };
  }

  /// The icon to use for the action
  final IconData icon;

  const GeneralPostAction({required this.icon});
}

enum GeneralQuickPostAction {
  upvote(
    enabledIcon: Icons.arrow_upward_rounded,
    disabledIcon: Icons.arrow_upward_rounded,
    permissionType: PermissionType.user,
    requiresAuthentication: true,
  ),
  downvote(
    enabledIcon: Icons.arrow_downward_rounded,
    disabledIcon: Icons.arrow_downward_rounded,
    permissionType: PermissionType.user,
    requiresAuthentication: true,
  ),
  save(
    enabledIcon: Icons.star_rounded,
    disabledIcon: Icons.star_outline_rounded,
    permissionType: PermissionType.user,
    requiresAuthentication: true,
  ),
  read(
    enabledIcon: Icons.mark_email_read_outlined,
    disabledIcon: Icons.mark_email_unread_rounded,
    permissionType: PermissionType.user,
    requiresAuthentication: true,
  ),
  hide(
    enabledIcon: Icons.visibility_off_rounded,
    disabledIcon: Icons.visibility_rounded,
    permissionType: PermissionType.user,
    requiresAuthentication: true,
  );

  /// The icon to use for the action when it is enabled
  final IconData enabledIcon;

  /// The icon to use for the action when it is disabled
  final IconData disabledIcon;

  /// The permission type to use for the action
  final PermissionType permissionType;

  /// Whether or not the action requires user authentication
  final bool requiresAuthentication;

  const GeneralQuickPostAction({required this.enabledIcon, required this.disabledIcon, required this.permissionType, required this.requiresAuthentication});
}

/// Defines the general top-levelactions that can be taken on a post.
class GeneralPostActionBottomSheetPage extends StatefulWidget {
  const GeneralPostActionBottomSheetPage({
    super.key,
    required this.context,
    required this.account,
    required this.post,
    required this.downvotesEnabled,
    required this.onSwitchActivePage,
    required this.onAction,
  });

  /// The outer context
  final BuildContext context;

  /// The account that is performing the action
  final Account account;

  /// The post information
  final ThunderPost post;

  /// Whether or not the downvotes are enabled
  final bool downvotesEnabled;

  /// Called when the active page is changed
  final Function(GeneralPostAction page) onSwitchActivePage;

  /// Called when an action is selected
  final Function(PostAction postAction, ThunderPost? post) onAction;

  @override
  State<GeneralPostActionBottomSheetPage> createState() => _GeneralPostActionBottomSheetPageState();
}

class _GeneralPostActionBottomSheetPageState extends State<GeneralPostActionBottomSheetPage> {
  String? generateSubtitle(GeneralPostAction page) {
    final post = widget.post;

    final userInstance = fetchInstanceNameFromUrl(post.creator?.actorId);
    final communityInstance = fetchInstanceNameFromUrl(post.community?.actorId);

    switch (page) {
      case GeneralPostAction.user:
        return generateUserFullName(context, post.creator?.name, post.creator?.displayName, userInstance);
      case GeneralPostAction.community:
        return generateCommunityFullName(context, post.community?.name, post.community?.title, communityInstance);
      case GeneralPostAction.instance:
        return (communityInstance == userInstance) ? '$communityInstance' : '$communityInstance • $userInstance';
      default:
        return null;
    }
  }

  void performAction(GeneralQuickPostAction action) async {
    final repository = PostRepositoryImpl(account: widget.account);

    switch (action) {
      case GeneralQuickPostAction.upvote:
        Navigator.of(context).pop();
        final post = await repository.vote(widget.post, widget.post.myVote == 1 ? 0 : 1);
        widget.onAction(PostAction.vote, post);
        break;
      case GeneralQuickPostAction.downvote:
        Navigator.of(context).pop();
        final post = await repository.vote(widget.post, widget.post.myVote == -1 ? 0 : -1);
        widget.onAction(PostAction.vote, post);
        break;
      case GeneralQuickPostAction.save:
        Navigator.of(context).pop();
        final post = await repository.save(widget.post, !(widget.post.saved ?? false));
        widget.onAction(PostAction.save, post);
        break;
      case GeneralQuickPostAction.read:
        Navigator.of(context).pop();
        final success = await repository.read(widget.post.id, !(widget.post.read ?? false));
        widget.onAction(PostAction.read, widget.post.copyWith(read: success ? !(widget.post.read ?? false) : null));
        break;
      case GeneralQuickPostAction.hide:
        Navigator.of(context).pop();
        final hidden = await repository.hide(widget.post.id, !(widget.post.hidden ?? false));
        widget.onAction(PostAction.hide, widget.post.copyWith(hidden: hidden));
        break;
    }
  }

  IconData getIcon(GeneralQuickPostAction action) {
    final post = widget.post;

    switch (action) {
      case GeneralQuickPostAction.upvote:
        return post.myVote == 1 ? GeneralQuickPostAction.upvote.enabledIcon : GeneralQuickPostAction.upvote.disabledIcon;
      case GeneralQuickPostAction.downvote:
        return post.myVote == -1 ? GeneralQuickPostAction.downvote.enabledIcon : GeneralQuickPostAction.downvote.disabledIcon;
      case GeneralQuickPostAction.save:
        return post.saved == true ? GeneralQuickPostAction.save.enabledIcon : GeneralQuickPostAction.save.disabledIcon;
      case GeneralQuickPostAction.read:
        return post.read == true ? GeneralQuickPostAction.read.enabledIcon : GeneralQuickPostAction.read.disabledIcon;
      case GeneralQuickPostAction.hide:
        return post.hidden == true ? GeneralQuickPostAction.hide.enabledIcon : GeneralQuickPostAction.hide.disabledIcon;
    }
  }

  String getLabel(GeneralQuickPostAction action) {
    final l10n = GlobalContext.l10n;
    final post = widget.post;

    switch (action) {
      case GeneralQuickPostAction.upvote:
        return post.myVote == 1 ? l10n.upvoted : l10n.upvote;
      case GeneralQuickPostAction.downvote:
        return post.myVote == -1 ? l10n.downvoted : l10n.downvote;
      case GeneralQuickPostAction.save:
        return post.saved == true ? l10n.saved : l10n.save;
      case GeneralQuickPostAction.read:
        return post.read == true ? l10n.read : l10n.markAsRead;
      case GeneralQuickPostAction.hide:
        return post.hidden == true ? l10n.hidden : l10n.hide;
    }
  }

  Color? getBackgroundColor(GeneralQuickPostAction action) {
    final themeState = context.read<ThemePreferencesCubit>().state;

    switch (action) {
      case GeneralQuickPostAction.upvote:
        return themeState.upvoteColor.color;
      case GeneralQuickPostAction.downvote:
        return themeState.downvoteColor.color;
      case GeneralQuickPostAction.save:
        return themeState.saveColor.color;
      case GeneralQuickPostAction.read:
        return themeState.markReadColor.color;
      case GeneralQuickPostAction.hide:
        return themeState.hideColor.color;
    }
  }

  Color? getForegroundColor(GeneralQuickPostAction action) {
    final themeState = context.read<ThemePreferencesCubit>().state;
    final post = widget.post;

    switch (action) {
      case GeneralQuickPostAction.upvote:
        return post.myVote == 1 ? themeState.upvoteColor.color : null;
      case GeneralQuickPostAction.downvote:
        return post.myVote == -1 ? themeState.downvoteColor.color : null;
      case GeneralQuickPostAction.save:
        return post.saved == true ? themeState.saveColor.color : null;
      case GeneralQuickPostAction.read:
        return post.read == true ? themeState.markReadColor.color : null;
      case GeneralQuickPostAction.hide:
        return post.hidden == true ? themeState.hideColor.color : null;
    }
  }

  @override
  Widget build(BuildContext context) {
    List<GeneralQuickPostAction> quickActions = GeneralQuickPostAction.values.where((element) => element.permissionType == PermissionType.user).toList();

    if (widget.account.anonymous) {
      quickActions = quickActions.where((action) => action.requiresAuthentication == false).toList();
    } else {
      // Hide hide action if account is not Lemmy platform
      if (widget.account.platform != ThreadiversePlatform.lemmy) {
        quickActions = quickActions.where((action) => action != GeneralQuickPostAction.hide).toList();
      }
    }

    // Determine the available sub-menus to display
    List<GeneralPostAction> submenus = GeneralPostAction.values.where((page) => page != GeneralPostAction.general).toList();
    if (widget.account.anonymous) {
      submenus = submenus.where((action) => action != GeneralPostAction.post).toList();
    }

    return Column(
      children: [
        if (quickActions.isNotEmpty)
          MultiPickerItem(
            pickerItems: quickActions.map<PickerItemData>((quickPostAction) {
              Function()? onSelected;

              if (quickPostAction == GeneralQuickPostAction.downvote && !widget.downvotesEnabled) {
                onSelected = null;
              } else {
                onSelected = widget.account.anonymous ? null : () => performAction(quickPostAction);
              }

              return PickerItemData(
                icon: getIcon(quickPostAction),
                label: getLabel(quickPostAction),
                foregroundColor: getForegroundColor(quickPostAction),
                backgroundColor: getBackgroundColor(quickPostAction),
                onSelected: onSelected,
              );
            }).toList(),
          ),
        ...submenus.map<Widget>(
          (page) => BottomSheetAction(
            leading: Icon(page.icon),
            trailing: const Icon(Icons.chevron_right_rounded),
            title: page.name,
            subtitle: generateSubtitle(page),
            onTap: () => widget.onSwitchActivePage(page),
            onLongPress: switch (page) {
              GeneralPostAction.user => () => copyActivityPubFullName(
                    type: ActivityPubFullNameType.user,
                    name: widget.post.creator?.name,
                    displayName: widget.post.creator?.displayName,
                    instance: fetchInstanceNameFromUrl(widget.post.creator?.actorId),
                  ),
              GeneralPostAction.community => () => copyActivityPubFullName(
                    type: ActivityPubFullNameType.community,
                    name: widget.post.community?.name,
                    displayName: widget.post.community?.title,
                    instance: fetchInstanceNameFromUrl(widget.post.community?.actorId),
                  ),
              _ => null,
            },
          ),
        ),
      ],
    );
  }
}
