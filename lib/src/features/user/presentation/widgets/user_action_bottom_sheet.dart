import 'package:flutter/material.dart';
import 'package:thunder/src/foundation/primitives/primitives.dart';

import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/features/community/community.dart';
import 'package:thunder/src/features/feed/feed.dart';
import 'package:thunder/src/features/user/user.dart';
import 'package:thunder/src/features/post/post.dart';
import 'package:thunder/src/features/instance/domain/utils/instance_link_utils.dart';
import 'package:thunder/src/features/identity/presentation/widgets/avatars/user_avatar.dart';
import 'package:thunder/src/shared/widgets/chips/user_chip.dart';
import 'package:thunder/src/foundation/config/global_context.dart';
import 'package:thunder/src/app/shell/navigation/navigation_utils.dart';
import 'package:thunder/packages/ui/ui.dart' show BottomSheetAction, Thunder, ThunderDivider, showSnackbar, showThunderDialog;

/// Defines the actions that can be taken on a user
enum UserBottomSheetAction {
  viewProfile(
    icon: Icons.person_search_rounded,
    permissionType: PermissionType.all,
    requiresAuthentication: false,
  ),
  blockUser(
    icon: Icons.block_rounded,
    permissionType: PermissionType.user,
    requiresAuthentication: true,
  ),
  unblockUser(
    icon: Icons.block_rounded,
    permissionType: PermissionType.user,
    requiresAuthentication: true,
  ),
  addUserLabel(
    icon: Icons.label_rounded,
    permissionType: PermissionType.all,
    requiresAuthentication: false,
  ),
  banUserFromCommunity(
    icon: Icons.block,
    permissionType: PermissionType.moderator,
    requiresAuthentication: true,
  ),
  unbanUserFromCommunity(
    icon: Icons.block,
    permissionType: PermissionType.moderator,
    requiresAuthentication: true,
  ),
  addUserAsCommunityModerator(
    icon: Icons.person_add_rounded,
    permissionType: PermissionType.moderator,
    requiresAuthentication: true,
  ),
  removeUserAsCommunityModerator(
    icon: Icons.person_remove_rounded,
    permissionType: PermissionType.moderator,
    requiresAuthentication: true,
  );

  String get name => switch (this) {
        UserBottomSheetAction.viewProfile => GlobalContext.l10n.visitUserProfile,
        UserBottomSheetAction.blockUser => GlobalContext.l10n.blockUser,
        UserBottomSheetAction.unblockUser => GlobalContext.l10n.unblockUser,
        UserBottomSheetAction.addUserLabel => GlobalContext.l10n.addUserLabel,
        UserBottomSheetAction.banUserFromCommunity => GlobalContext.l10n.banFromCommunity,
        UserBottomSheetAction.unbanUserFromCommunity => GlobalContext.l10n.unbanFromCommunity,
        UserBottomSheetAction.addUserAsCommunityModerator => GlobalContext.l10n.addAsCommunityModerator,
        UserBottomSheetAction.removeUserAsCommunityModerator => GlobalContext.l10n.removeAsCommunityModerator,
      };

  /// The icon to use for the action
  final IconData icon;

  /// The permission type to use for the action
  final PermissionType permissionType;

  /// Whether or not the action requires user authentication
  final bool requiresAuthentication;

  const UserBottomSheetAction({required this.icon, required this.permissionType, required this.requiresAuthentication});
}

/// A bottom sheet that allows the current user to perform actions on another user.
class UserActionBottomSheet extends StatefulWidget {
  const UserActionBottomSheet({
    super.key,
    required this.context,
    required this.account,
    required this.blockedUsers,
    required this.moderatedCommunities,
    required this.user,
    this.communityId,
    this.isUserCommunityModerator,
    this.isUserBannedFromCommunity,
    required this.onAction,
  });

  /// The outer context
  final BuildContext context;

  /// The account that is performing the action
  final Account account;

  /// List of blocked users
  final List<ThunderUser> blockedUsers;

  /// List of moderated communities
  final List<ThunderCommunity> moderatedCommunities;

  /// The user that we are interacting with
  final ThunderUser user;

  /// The community that the user has interacted with
  /// This is useful for community-specific actions such as banning/unbanning the user from a community, or adding/removing them as a moderator of a community
  final int? communityId;

  /// Whether or not the user is a moderator of the community. This is only applicable if [communityId] is not null
  final bool? isUserCommunityModerator;

  /// Whether or not the user is banned from the community. This is only applicable if [communityId] is not null
  final bool? isUserBannedFromCommunity;

  /// Called when an action is selected
  final Function(UserAction userAction, ThunderUser? user) onAction;

  @override
  State<UserActionBottomSheet> createState() => _UserActionBottomSheetState();
}

class _UserActionBottomSheetState extends State<UserActionBottomSheet> {
  void performAction(UserBottomSheetAction action) async {
    final l10n = GlobalContext.l10n;
    final userRepository = UserRepositoryImpl(account: widget.account);
    final communityRepository = CommunityRepositoryImpl(account: widget.account);

    switch (action) {
      case UserBottomSheetAction.viewProfile:
        Navigator.of(context).pop();
        navigateToFeedPage(context, feedType: FeedType.user, userId: widget.user.id);
        break;
      case UserBottomSheetAction.blockUser:
        Navigator.of(context).pop();
        await userRepository.block(widget.user.id, true);
        showSnackbar(l10n.successfullyBlockedUser(widget.user.displayNameOrName));
        widget.onAction(UserAction.block, null);
        break;
      case UserBottomSheetAction.unblockUser:
        Navigator.of(context).pop();
        await userRepository.block(widget.user.id, false);
        showSnackbar(l10n.successfullyUnblockedUser(widget.user.displayNameOrName));
        widget.onAction(UserAction.block, null);
        break;
      case UserBottomSheetAction.addUserLabel:
        Navigator.of(context).pop();
        await showUserLabelEditorDialog(context, UserLabel.usernameFromParts(widget.user.displayNameOrName, widget.user.actorId));
        widget.onAction(UserAction.setUserLabel, null);
        break;
      case UserBottomSheetAction.banUserFromCommunity:
        showBanUserDialog();
        break;
      case UserBottomSheetAction.unbanUserFromCommunity:
        Navigator.of(context).pop();
        final user = await communityRepository.banUserFromCommunity(userId: widget.user.id, communityId: widget.communityId!, ban: false);
        if (!user.banned) {
          showSnackbar(l10n.unbannedUserFromCommunity(widget.user.displayNameOrName));
        }
        widget.onAction(UserAction.banFromCommunity, null);
        break;
      case UserBottomSheetAction.addUserAsCommunityModerator:
        Navigator.of(context).pop();
        final moderators = await communityRepository.addModerator(userId: widget.user.id, communityId: widget.communityId!, added: true);
        if (moderators.where((m) => m.id == widget.user.id).isNotEmpty) {
          showSnackbar(l10n.addedUserAsCommunityModerator(widget.user.displayNameOrName));
        }
        widget.onAction(UserAction.addModerator, null);
        break;
      case UserBottomSheetAction.removeUserAsCommunityModerator:
        Navigator.of(context).pop();
        final moderators = await communityRepository.addModerator(userId: widget.user.id, communityId: widget.communityId!, added: false);
        if (moderators.where((m) => m.id == widget.user.id).isEmpty) {
          showSnackbar(l10n.removedUserAsCommunityModerator(widget.user.displayNameOrName));
        }
        widget.onAction(UserAction.addModerator, null);
        break;
    }
  }

  void showBanUserDialog() {
    final l10n = GlobalContext.l10n;
    final controller = TextEditingController();

    /// Whether or not the user data (posts and comments) should be removed from the community
    bool removeData = false;

    showThunderDialog(
      context: widget.context,
      title: l10n.banFromCommunity,
      primaryButtonText: l10n.ban,
      onPrimaryButtonPressed: (dialogContext, setPrimaryButtonEnabled) async {
        final communityRepository = CommunityRepositoryImpl(account: widget.account);

        final user = await communityRepository.banUserFromCommunity(userId: widget.user.id, communityId: widget.communityId!, ban: true, reason: controller.text, removeData: removeData);
        if (user.banned) {
          showSnackbar(l10n.successfullyBannedUser(widget.user.displayNameOrName));
        }
        widget.onAction(UserAction.banFromCommunity, null);

        Navigator.of(dialogContext).pop();
      },
      secondaryButtonText: l10n.cancel,
      onSecondaryButtonPressed: (context) => Navigator.of(context).pop(),
      contentWidgetBuilder: (_) => StatefulBuilder(
        builder: (context, setState) {
          return Column(
            spacing: 16.0,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              UserChip(
                user: widget.user,
                personAvatar: UserAvatar(user: widget.user),
                userGroups: const [UserType.op],
                includeInstance: true,
              ),
              TextFormField(
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: l10n.message(0),
                ),
                autofocus: true,
                controller: controller,
                maxLines: 2,
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(l10n.removeUserData),
                  Switch(value: removeData, onChanged: (value) => setState(() => removeData = value)),
                ],
              )
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    List<UserBottomSheetAction> userActions = UserBottomSheetAction.values.where((element) => element.permissionType == PermissionType.user || element.permissionType == PermissionType.all).toList();
    List<UserBottomSheetAction> moderatorActions = UserBottomSheetAction.values.where((element) => element.permissionType == PermissionType.moderator).toList();

    final isModerator = widget.moderatedCommunities.where((c) => c.id == widget.communityId).isNotEmpty;
    final isUserBlocked = widget.blockedUsers.where((u) => u.actorId == widget.user.actorId).isNotEmpty;

    final isUserCommunityModerator = widget.isUserCommunityModerator ?? false;
    final isUserBannedFromCommunity = widget.isUserBannedFromCommunity ?? false;

    if (widget.account.anonymous) {
      userActions = userActions.where((action) => action.requiresAuthentication == false).toList();
    } else {
      if (widget.account.username == widget.user.name && widget.account.instance == fetchInstanceNameFromUrl(widget.user.actorId)) {
        userActions = userActions.where((action) => action != UserBottomSheetAction.blockUser && action != UserBottomSheetAction.unblockUser).toList();
        moderatorActions = moderatorActions.where((action) => action != UserBottomSheetAction.addUserAsCommunityModerator && action != UserBottomSheetAction.removeUserAsCommunityModerator).toList();
      }

      if (isUserBlocked) {
        userActions = userActions.where((action) => action != UserBottomSheetAction.blockUser).toList();
      } else {
        userActions = userActions.where((action) => action != UserBottomSheetAction.unblockUser).toList();
      }

      if (isUserCommunityModerator) {
        moderatorActions = moderatorActions.where((action) => action != UserBottomSheetAction.addUserAsCommunityModerator).toList();
        moderatorActions = moderatorActions.where((action) => action != UserBottomSheetAction.banUserFromCommunity && action != UserBottomSheetAction.unbanUserFromCommunity).toList();
      } else {
        moderatorActions = moderatorActions.where((action) => action != UserBottomSheetAction.removeUserAsCommunityModerator).toList();
      }

      if (isUserBannedFromCommunity) {
        moderatorActions = moderatorActions.where((action) => action != UserBottomSheetAction.banUserFromCommunity).toList();
      } else {
        moderatorActions = moderatorActions.where((action) => action != UserBottomSheetAction.unbanUserFromCommunity).toList();
      }
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...userActions.map<Widget>(
          (userPostAction) => BottomSheetAction(
            leading: Icon(userPostAction.icon),
            title: userPostAction.name,
            onTap: () => performAction(userPostAction),
          ),
        ),
        if (isModerator && moderatorActions.isNotEmpty) ...[
          const ThunderDivider(sliver: false, padding: false),
          ...moderatorActions.map<Widget>(
            (userPostAction) => BottomSheetAction(
              leading: Icon(userPostAction.icon),
              trailing: Padding(
                padding: const EdgeInsets.only(left: 1),
                child: Icon(
                  Thunder.shield,
                  size: 20,
                  color: Color.alphaBlend(theme.colorScheme.primary.withValues(alpha: 0.4), Colors.green),
                ),
              ),
              title: userPostAction.name,
              onTap: () => performAction(userPostAction),
            ),
          ),
        ],
      ],
    );
  }
}
