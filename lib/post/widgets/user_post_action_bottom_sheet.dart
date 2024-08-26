import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lemmy_api_client/v3.dart';

import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/core/models/post_view_media.dart';
import 'package:thunder/feed/utils/utils.dart';
import 'package:thunder/feed/view/feed_page.dart';
import 'package:thunder/post/enums/post_action.dart';
import 'package:thunder/post/utils/comment_action_helpers.dart';
import 'package:thunder/shared/bottom_sheet_action.dart';
import 'package:thunder/shared/divider.dart';
import 'package:thunder/thunder/thunder_icons.dart';
import 'package:thunder/user/bloc/user_bloc.dart';
import 'package:thunder/user/enums/user_action.dart';

// Defines the actions that can be taken on a user
enum UserPostAction {
  viewProfile(icon: Icons.person, permissionType: PermissionType.user, requiresAuthentication: false),
  blockUser(icon: Icons.block, permissionType: PermissionType.user, requiresAuthentication: true),
  unblockUser(icon: Icons.block, permissionType: PermissionType.user, requiresAuthentication: true),
  banUserFromCommunity(icon: Icons.block, permissionType: PermissionType.moderator, requiresAuthentication: true),
  unbanUserFromCommunity(icon: Icons.block, permissionType: PermissionType.moderator, requiresAuthentication: true),
  addUserAsCommunityModerator(icon: Icons.person_add_rounded, permissionType: PermissionType.moderator, requiresAuthentication: true),
  removeUserAsCommunityModerator(icon: Icons.person_remove_rounded, permissionType: PermissionType.moderator, requiresAuthentication: true),
  // banUser(icon: Icons.block, permissionType: PermissionType.admin, requiresAuthentication: true),
  // unbanUser(icon: Icons.block, permissionType: PermissionType.admin, requiresAuthentication: true),
  // purgeUser(icon: Icons.delete_rounded, permissionType: PermissionType.admin, requiresAuthentication: true),
  // addUserAsAdmin(icon: Icons.person_add_rounded, permissionType: PermissionType.admin, requiresAuthentication: true),
  // removeUserAsAdmin(icon: Icons.person_remove_rounded, permissionType: PermissionType.admin, requiresAuthentication: true),
  ;

  String get name => switch (this) {
        UserPostAction.viewProfile => l10n.visitUserProfile,
        UserPostAction.blockUser => l10n.blockUser,
        UserPostAction.unblockUser => "Unblock User",
        UserPostAction.banUserFromCommunity => "Ban From Community",
        UserPostAction.unbanUserFromCommunity => "Unban From Community",
        UserPostAction.addUserAsCommunityModerator => "Add As Community Moderator",
        UserPostAction.removeUserAsCommunityModerator => "Remove As Community Moderator",
        // UserPostAction.banUser => "Ban From Instance",
        // UserPostAction.unbanUser => "Unban User From Instance",
        // UserPostAction.purgeUser => "Purge User",
        // UserPostAction.addUserAsAdmin => "Add As Admin",
        // UserPostAction.removeUserAsAdmin => "Remove As Admin",
      };

  /// The icon to use for the action
  final IconData icon;

  /// The permission type to use for the action
  final PermissionType permissionType;

  /// Whether or not the action requires user authentication
  final bool requiresAuthentication;

  const UserPostAction({required this.icon, required this.permissionType, required this.requiresAuthentication});
}

/// A bottom sheet that allows the user to perform actions on a user.
///
/// Given a [postViewMedia] and a [onAction] callback, this widget will display a list of actions that can be taken on the user.
/// The [onAction] callback will be triggered when an action is performed. This is useful if the parent widget requires an updated [PersonView].
class UserPostActionBottomSheet extends StatefulWidget {
  const UserPostActionBottomSheet({super.key, required this.postViewMedia, required this.onAction});

  /// The post information
  final PostViewMedia postViewMedia;

  /// Called when an action is selected
  final Function(PersonView? personView) onAction;

  @override
  State<UserPostActionBottomSheet> createState() => _UserPostActionBottomSheetState();
}

class _UserPostActionBottomSheetState extends State<UserPostActionBottomSheet> {
  void performAction(UserPostAction action) {
    switch (action) {
      case UserPostAction.viewProfile:
        context.pop();
        navigateToFeedPage(context, feedType: FeedType.user, userId: widget.postViewMedia.postView.creator.id);
        break;
      case UserPostAction.blockUser:
        context.read<UserBloc>().add(UserActionEvent(userId: widget.postViewMedia.postView.creator.id, userAction: UserAction.block, value: true));
        break;
      case UserPostAction.unblockUser:
        context.read<UserBloc>().add(UserActionEvent(userId: widget.postViewMedia.postView.creator.id, userAction: UserAction.block, value: false));
        break;
      case UserPostAction.banUserFromCommunity:
        context.read<UserBloc>().add(UserActionEvent(userId: widget.postViewMedia.postView.creator.id, userAction: UserAction.banFromCommunity, value: true));
        break;
      case UserPostAction.unbanUserFromCommunity:
        context.read<UserBloc>().add(UserActionEvent(userId: widget.postViewMedia.postView.creator.id, userAction: UserAction.banFromCommunity, value: false));
        break;
      case UserPostAction.addUserAsCommunityModerator:
        context.read<UserBloc>().add(UserActionEvent(
              userId: widget.postViewMedia.postView.creator.id,
              userAction: UserAction.addModerator,
              value: true,
              metadata: {"communityId": widget.postViewMedia.postView.community.id},
            ));
        break;
      case UserPostAction.removeUserAsCommunityModerator:
        context.read<UserBloc>().add(UserActionEvent(
              userId: widget.postViewMedia.postView.creator.id,
              userAction: UserAction.addModerator,
              value: false,
              metadata: {"communityId": widget.postViewMedia.postView.community.id},
            ));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = context.read<AuthBloc>().state;

    List<UserPostAction> userActions = UserPostAction.values.where((element) => element.permissionType == PermissionType.user).toList();
    List<UserPostAction> moderatorActions = UserPostAction.values.where((element) => element.permissionType == PermissionType.moderator).toList();
    List<UserPostAction> adminActions = UserPostAction.values.where((element) => element.permissionType == PermissionType.admin).toList();

    final account = authState.getSiteResponse?.myUser?.localUserView.person;
    final isModerator = authState.getSiteResponse?.myUser?.moderates.where((communityModeratorView) => communityModeratorView.moderator.actorId == account?.actorId).isNotEmpty ?? false;
    final isAdmin = authState.getSiteResponse?.admins.where((personView) => personView.person.actorId == account?.actorId).isNotEmpty ?? false;

    final isLoggedIn = authState.isLoggedIn;
    final blockedUsers = authState.getSiteResponse?.myUser?.personBlocks ?? [];

    final isUserBlocked = blockedUsers.where((personBlockView) => personBlockView.person.actorId == widget.postViewMedia.postView.creator.actorId).isNotEmpty;
    final isUserCommunityModerator = widget.postViewMedia.postView.creatorIsModerator ?? false;
    final isUserBannedFromCommunity = widget.postViewMedia.postView.creatorBannedFromCommunity;
    final isUserBannedFromInstance = widget.postViewMedia.postView.creator.banned;
    final isUserAdmin = widget.postViewMedia.postView.creatorIsAdmin ?? false;

    if (!isLoggedIn) {
      userActions = userActions.where((action) => action.requiresAuthentication == false).toList();
    } else {
      if (isUserBlocked) {
        userActions = userActions.where((action) => action != UserPostAction.blockUser).toList();
      } else {
        userActions = userActions.where((action) => action != UserPostAction.unblockUser).toList();
      }

      if (isUserCommunityModerator) {
        moderatorActions = moderatorActions.where((action) => action != UserPostAction.addUserAsCommunityModerator).toList();
        moderatorActions = moderatorActions.where((action) => action != UserPostAction.banUserFromCommunity && action != UserPostAction.unbanUserFromCommunity).toList();
      } else {
        moderatorActions = moderatorActions.where((action) => action != UserPostAction.removeUserAsCommunityModerator).toList();
      }

      if (!isUserBannedFromCommunity) {
        moderatorActions = moderatorActions.where((action) => action != UserPostAction.banUserFromCommunity).toList();
      } else {
        moderatorActions = moderatorActions.where((action) => action != UserPostAction.unbanUserFromCommunity).toList();
      }

      // if (isUserBannedFromInstance) {
      //   adminActions = adminActions.where((action) => action != UserPostAction.banUser).toList();
      // } else {
      //   adminActions = adminActions.where((action) => action != UserPostAction.unbanUser).toList();
      // }

      // if (isUserAdmin) {
      //   adminActions = adminActions.where((action) => action != UserPostAction.addUserAsAdmin).toList();
      // } else {
      //   adminActions = adminActions.where((action) => action != UserPostAction.removeUserAsAdmin).toList();
      // }
    }

    return BlocListener<UserBloc, UserState>(
      listener: (context, state) {
        if (state.status == UserStatus.success) {
          context.pop();
          widget.onAction(state.personView);
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...userActions
              .map(
                (userPostAction) => BottomSheetAction(
                  leading: Icon(userPostAction.icon),
                  title: userPostAction.name,
                  onTap: () => performAction(userPostAction),
                ),
              )
              .toList() as List<Widget>,
          if (isModerator && moderatorActions.isNotEmpty) ...[
            const ThunderDivider(sliver: false, padding: false),
            ...moderatorActions
                .map(
                  (userPostAction) => BottomSheetAction(
                    leading: Icon(userPostAction.icon),
                    trailing: Padding(
                      padding: const EdgeInsets.only(left: 1),
                      child: Icon(
                        Thunder.shield,
                        size: 20,
                        color: Color.alphaBlend(theme.colorScheme.primary.withOpacity(0.4), Colors.green),
                      ),
                    ),
                    title: userPostAction.name,
                    onTap: () => performAction(userPostAction),
                  ),
                )
                .toList() as List<Widget>,
          ],
          if (isAdmin && adminActions.isNotEmpty) ...[
            const ThunderDivider(sliver: false, padding: false),
            ...adminActions
                .map(
                  (userPostAction) => BottomSheetAction(
                    leading: Icon(userPostAction.icon),
                    trailing: Padding(
                      padding: const EdgeInsets.only(left: 1),
                      child: Icon(
                        Thunder.shield_crown,
                        size: 20,
                        color: Color.alphaBlend(theme.colorScheme.primary.withOpacity(0.4), Colors.red),
                      ),
                    ),
                    title: userPostAction.name,
                    onTap: () => performAction(userPostAction),
                  ),
                )
                .toList() as List<Widget>,
          ],
        ],
      ),
    );
  }
}
