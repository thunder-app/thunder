import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lemmy_api_client/v3.dart';

import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/core/enums/user_type.dart';
import 'package:thunder/core/models/post_view_media.dart';
import 'package:thunder/feed/utils/utils.dart';
import 'package:thunder/feed/view/feed_page.dart';
import 'package:thunder/post/enums/post_action.dart';
import 'package:thunder/post/utils/comment_action_helpers.dart';
import 'package:thunder/shared/avatars/user_avatar.dart';
import 'package:thunder/shared/bottom_sheet_action.dart';
import 'package:thunder/shared/chips/user_chip.dart';
import 'package:thunder/shared/dialogs.dart';
import 'package:thunder/shared/divider.dart';
import 'package:thunder/thunder/thunder_icons.dart';
import 'package:thunder/user/bloc/user_bloc.dart';
import 'package:thunder/user/enums/user_action.dart';

/// Defines the actions that can be taken on a user
/// TODO: Implement admin-level actions
enum UserPostAction {
  viewProfile(icon: Icons.person_search_rounded, permissionType: PermissionType.user, requiresAuthentication: false),
  blockUser(icon: Icons.block_rounded, permissionType: PermissionType.user, requiresAuthentication: true),
  unblockUser(icon: Icons.block_rounded, permissionType: PermissionType.user, requiresAuthentication: true),
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
        UserPostAction.unblockUser => l10n.unblockUser,
        UserPostAction.banUserFromCommunity => l10n.banFromCommunity,
        UserPostAction.unbanUserFromCommunity => l10n.unbanFromCommunity,
        UserPostAction.addUserAsCommunityModerator => l10n.addAsCommunityModerator,
        UserPostAction.removeUserAsCommunityModerator => l10n.removeAsCommunityModerator,
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
  const UserPostActionBottomSheet({super.key, required this.context, required this.postViewMedia, required this.onAction});

  /// The outer context
  final BuildContext context;

  /// The post information
  final PostViewMedia postViewMedia;

  /// Called when an action is selected
  final Function(UserAction userAction, PersonView? personView) onAction;

  @override
  State<UserPostActionBottomSheet> createState() => _UserPostActionBottomSheetState();
}

class _UserPostActionBottomSheetState extends State<UserPostActionBottomSheet> {
  UserAction? _userAction;

  void performAction(UserPostAction action) {
    switch (action) {
      case UserPostAction.viewProfile:
        Navigator.of(context).pop();
        navigateToFeedPage(context, feedType: FeedType.user, userId: widget.postViewMedia.postView.creator.id);
        break;
      case UserPostAction.blockUser:
        context.read<UserBloc>().add(UserActionEvent(userId: widget.postViewMedia.postView.creator.id, userAction: UserAction.block, value: true));
        setState(() => _userAction = UserAction.block);
        break;
      case UserPostAction.unblockUser:
        context.read<UserBloc>().add(UserActionEvent(userId: widget.postViewMedia.postView.creator.id, userAction: UserAction.block, value: false));
        setState(() => _userAction = UserAction.block);
        break;
      case UserPostAction.banUserFromCommunity:
        showBanUserDialog();
        break;
      case UserPostAction.unbanUserFromCommunity:
        context.read<UserBloc>().add(
              UserActionEvent(
                userId: widget.postViewMedia.postView.creator.id,
                userAction: UserAction.banFromCommunity,
                value: false,
                metadata: {
                  "communityId": widget.postViewMedia.postView.community.id,
                },
              ),
            );
        setState(() => _userAction = UserAction.banFromCommunity);
        break;
      case UserPostAction.addUserAsCommunityModerator:
        context.read<UserBloc>().add(UserActionEvent(
              userId: widget.postViewMedia.postView.creator.id,
              userAction: UserAction.addModerator,
              value: true,
              metadata: {"communityId": widget.postViewMedia.postView.community.id},
            ));
        setState(() => _userAction = UserAction.addModerator);
        break;
      case UserPostAction.removeUserAsCommunityModerator:
        context.read<UserBloc>().add(UserActionEvent(
              userId: widget.postViewMedia.postView.creator.id,
              userAction: UserAction.addModerator,
              value: false,
              metadata: {"communityId": widget.postViewMedia.postView.community.id},
            ));
        setState(() => _userAction = UserAction.addModerator);
        break;
    }
  }

  void showBanUserDialog() {
    /// The controller for the message
    TextEditingController messageController = TextEditingController();

    /// Whether or not the user data (posts and comments) should be removed from the community
    bool removeData = false;

    showThunderDialog(
      context: widget.context,
      title: l10n.banFromCommunity,
      primaryButtonText: "Ban",
      onPrimaryButtonPressed: (dialogContext, setPrimaryButtonEnabled) {
        widget.context.read<UserBloc>().add(
              UserActionEvent(
                userId: widget.postViewMedia.postView.creator.id,
                userAction: UserAction.banFromCommunity,
                value: true,
                metadata: {
                  "communityId": widget.postViewMedia.postView.community.id,
                  "reason": messageController.text,
                  "removeData": removeData,
                },
              ),
            );
        setState(() => _userAction = UserAction.banFromCommunity);
        Navigator.of(dialogContext).pop();
      },
      secondaryButtonText: l10n.cancel,
      onSecondaryButtonPressed: (context) => Navigator.of(context).pop(),
      contentWidgetBuilder: (_) => StatefulBuilder(
        builder: (context, setState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              UserChip(
                person: widget.postViewMedia.postView.creator,
                personAvatar: UserAvatar(person: widget.postViewMedia.postView.creator),
                userGroups: const [UserType.op],
                includeInstance: true,
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: l10n.message(0),
                ),
                autofocus: true,
                controller: messageController,
                maxLines: 2,
              ),
              const SizedBox(height: 16.0),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Remove user data'),
                  Switch(
                    value: removeData,
                    onChanged: (value) {
                      setState(() => removeData = value);
                    },
                  ),
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
    final authState = context.read<AuthBloc>().state;

    List<UserPostAction> userActions = UserPostAction.values.where((element) => element.permissionType == PermissionType.user).toList();
    List<UserPostAction> moderatorActions = UserPostAction.values.where((element) => element.permissionType == PermissionType.moderator).toList();
    // List<UserPostAction> adminActions = UserPostAction.values.where((element) => element.permissionType == PermissionType.admin).toList();

    final account = authState.getSiteResponse?.myUser?.localUserView.person;
    final moderatedCommunities = authState.getSiteResponse?.myUser?.moderates ?? [];
    final isModerator = moderatedCommunities.where((communityModeratorView) => communityModeratorView.community.actorId == widget.postViewMedia.postView.community.actorId).isNotEmpty;
    // final isAdmin = authState.getSiteResponse?.admins.where((personView) => personView.person.actorId == account?.actorId).isNotEmpty ?? false;

    final isLoggedIn = authState.isLoggedIn;
    final blockedUsers = authState.getSiteResponse?.myUser?.personBlocks ?? [];

    final isUserBlocked = blockedUsers.where((personBlockView) => personBlockView.person.actorId == widget.postViewMedia.postView.creator.actorId).isNotEmpty;
    final isUserCommunityModerator = widget.postViewMedia.postView.creatorIsModerator ?? false;
    final isUserBannedFromCommunity = widget.postViewMedia.postView.creatorBannedFromCommunity;
    // final isUserBannedFromInstance = widget.postViewMedia.postView.creator.banned;
    // final isUserAdmin = widget.postViewMedia.postView.creatorIsAdmin ?? false;

    if (!isLoggedIn) {
      userActions = userActions.where((action) => action.requiresAuthentication == false).toList();
    } else {
      if (account?.actorId == widget.postViewMedia.postView.creator.actorId) {
        userActions = userActions.where((action) => action != UserPostAction.blockUser && action != UserPostAction.unblockUser).toList();
      }

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

      if (isUserBannedFromCommunity) {
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
          Navigator.of(context).pop();
          if (_userAction != null) widget.onAction(_userAction!, state.personView);
          setState(() => _userAction = null);
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
          // if (isAdmin && adminActions.isNotEmpty) ...[
          //   const ThunderDivider(sliver: false, padding: false),
          //   ...adminActions
          //       .map(
          //         (userPostAction) => BottomSheetAction(
          //           leading: Icon(userPostAction.icon),
          //           trailing: Padding(
          //             padding: const EdgeInsets.only(left: 1),
          //             child: Icon(
          //               Thunder.shield_crown,
          //               size: 20,
          //               color: Color.alphaBlend(theme.colorScheme.primary.withOpacity(0.4), Colors.red),
          //             ),
          //           ),
          //           title: userPostAction.name,
          //           onTap: () => performAction(userPostAction),
          //         ),
          //       )
          //       .toList() as List<Widget>,
          // ],
        ],
      ),
    );
  }
}
