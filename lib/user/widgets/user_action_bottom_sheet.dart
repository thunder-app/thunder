import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lemmy_api_client/v3.dart';

import 'package:thunder/account/models/user_label.dart';
import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/core/enums/user_type.dart';
import 'package:thunder/feed/utils/utils.dart';
import 'package:thunder/feed/view/feed_page.dart';
import 'package:thunder/post/enums/post_action.dart';
import 'package:thunder/post/utils/user_label_utils.dart';
import 'package:thunder/shared/avatars/user_avatar.dart';
import 'package:thunder/shared/bottom_sheet_action.dart';
import 'package:thunder/shared/chips/user_chip.dart';
import 'package:thunder/shared/dialogs.dart';
import 'package:thunder/shared/divider.dart';
import 'package:thunder/thunder/thunder_icons.dart';
import 'package:thunder/user/bloc/user_bloc.dart';
import 'package:thunder/user/enums/user_action.dart';
import 'package:thunder/utils/global_context.dart';

/// Defines the actions that can be taken on a user
/// TODO: Implement admin-level actions
enum UserBottomSheetAction {
  viewProfile(icon: Icons.person_search_rounded, permissionType: PermissionType.user, requiresAuthentication: false),
  blockUser(icon: Icons.block_rounded, permissionType: PermissionType.user, requiresAuthentication: true),
  unblockUser(icon: Icons.block_rounded, permissionType: PermissionType.user, requiresAuthentication: true),
  addUserLabel(icon: Icons.label_rounded, permissionType: PermissionType.user, requiresAuthentication: false),
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
        UserBottomSheetAction.viewProfile => GlobalContext.l10n.visitUserProfile,
        UserBottomSheetAction.blockUser => GlobalContext.l10n.blockUser,
        UserBottomSheetAction.unblockUser => GlobalContext.l10n.unblockUser,
        UserBottomSheetAction.addUserLabel => GlobalContext.l10n.addUserLabel,
        UserBottomSheetAction.banUserFromCommunity => GlobalContext.l10n.banFromCommunity,
        UserBottomSheetAction.unbanUserFromCommunity => GlobalContext.l10n.unbanFromCommunity,
        UserBottomSheetAction.addUserAsCommunityModerator => GlobalContext.l10n.addAsCommunityModerator,
        UserBottomSheetAction.removeUserAsCommunityModerator => GlobalContext.l10n.removeAsCommunityModerator,
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

  const UserBottomSheetAction({required this.icon, required this.permissionType, required this.requiresAuthentication});
}

/// A bottom sheet that allows the current user to perform actions on another user.
///
/// Given an [onAction] callback, this widget will display a list of actions that can be taken on the user.
/// The [onAction] callback will be triggered when an action is performed. This is useful if the parent widget requires an updated [PersonView].
class UserActionBottomSheet extends StatefulWidget {
  const UserActionBottomSheet({super.key, required this.context, required this.user, this.communityId, this.isUserCommunityModerator, this.isUserBannedFromCommunity, required this.onAction});

  /// The outer context
  final BuildContext context;

  /// The user that we are interacting with
  final Person user;

  /// The community that the user has interacted with
  /// This is useful for community-specific actions such as banning/unbanning the user from a community, or adding/removing them as a moderator of a community
  final int? communityId;

  /// Whether or not the user is a moderator of the community. This is only applicable if [communityId] is not null
  final bool? isUserCommunityModerator;

  /// Whether or not the user is banned from the community. This is only applicable if [communityId] is not null
  final bool? isUserBannedFromCommunity;

  /// Called when an action is selected
  final Function(UserAction userAction, PersonView? personView) onAction;

  @override
  State<UserActionBottomSheet> createState() => _UserActionBottomSheetState();
}

class _UserActionBottomSheetState extends State<UserActionBottomSheet> {
  UserAction? _userAction;

  void performAction(UserBottomSheetAction action) async {
    switch (action) {
      case UserBottomSheetAction.viewProfile:
        Navigator.of(context).pop();
        navigateToFeedPage(context, feedType: FeedType.user, userId: widget.user.id);
        break;
      case UserBottomSheetAction.blockUser:
        context.read<UserBloc>().add(UserActionEvent(userId: widget.user.id, userAction: UserAction.block, value: true));
        setState(() => _userAction = UserAction.block);
        break;
      case UserBottomSheetAction.unblockUser:
        context.read<UserBloc>().add(UserActionEvent(userId: widget.user.id, userAction: UserAction.block, value: false));
        setState(() => _userAction = UserAction.block);
        break;
      case UserBottomSheetAction.addUserLabel:
        await showUserLabelEditorDialog(context, UserLabel.usernameFromParts(widget.user.name, widget.user.actorId));
        widget.onAction(UserAction.setUserLabel, null);
        Navigator.of(context).pop();
        break;
      case UserBottomSheetAction.banUserFromCommunity:
        showBanUserDialog();
        break;
      case UserBottomSheetAction.unbanUserFromCommunity:
        context.read<UserBloc>().add(
              UserActionEvent(
                userId: widget.user.id,
                userAction: UserAction.banFromCommunity,
                value: false,
                metadata: {
                  "communityId": widget.communityId,
                },
              ),
            );
        setState(() => _userAction = UserAction.banFromCommunity);
        break;
      case UserBottomSheetAction.addUserAsCommunityModerator:
        context.read<UserBloc>().add(UserActionEvent(
              userId: widget.user.id,
              userAction: UserAction.addModerator,
              value: true,
              metadata: {"communityId": widget.communityId},
            ));
        setState(() => _userAction = UserAction.addModerator);
        break;
      case UserBottomSheetAction.removeUserAsCommunityModerator:
        context.read<UserBloc>().add(UserActionEvent(
              userId: widget.user.id,
              userAction: UserAction.addModerator,
              value: false,
              metadata: {"communityId": widget.communityId},
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
      title: GlobalContext.l10n.banFromCommunity,
      primaryButtonText: "Ban",
      onPrimaryButtonPressed: (dialogContext, setPrimaryButtonEnabled) {
        widget.context.read<UserBloc>().add(
              UserActionEvent(
                userId: widget.user.id,
                userAction: UserAction.banFromCommunity,
                value: true,
                metadata: {
                  "communityId": widget.communityId,
                  "reason": messageController.text,
                  "removeData": removeData,
                },
              ),
            );
        setState(() => _userAction = UserAction.banFromCommunity);
        Navigator.of(dialogContext).pop();
      },
      secondaryButtonText: GlobalContext.l10n.cancel,
      onSecondaryButtonPressed: (context) => Navigator.of(context).pop(),
      contentWidgetBuilder: (_) => StatefulBuilder(
        builder: (context, setState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              UserChip(
                person: widget.user,
                personAvatar: UserAvatar(person: widget.user),
                userGroups: const [UserType.op],
                includeInstance: true,
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: GlobalContext.l10n.message(0),
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

    List<UserBottomSheetAction> userActions = UserBottomSheetAction.values.where((element) => element.permissionType == PermissionType.user).toList();
    List<UserBottomSheetAction> moderatorActions = UserBottomSheetAction.values.where((element) => element.permissionType == PermissionType.moderator).toList();
    // List<UserPostAction> adminActions = UserPostAction.values.where((element) => element.permissionType == PermissionType.admin).toList();

    final account = authState.getSiteResponse?.myUser?.localUserView.person;
    final moderatedCommunities = authState.getSiteResponse?.myUser?.moderates ?? [];
    final isModerator = moderatedCommunities.where((communityModeratorView) => communityModeratorView.community.id == widget.communityId).isNotEmpty;
    // final isAdmin = authState.getSiteResponse?.admins.where((personView) => personView.person.actorId == account?.actorId).isNotEmpty ?? false;

    final isLoggedIn = authState.isLoggedIn;
    final blockedUsers = authState.getSiteResponse?.myUser?.personBlocks ?? [];

    final isUserBlocked = blockedUsers.where((personBlockView) => personBlockView.person.actorId == widget.user.actorId).isNotEmpty;
    final isUserCommunityModerator = widget.isUserCommunityModerator ?? false;
    final isUserBannedFromCommunity = widget.isUserBannedFromCommunity ?? false;
    // final isUserBannedFromInstance = widget.postViewMedia.postView.creator.banned;
    // final isUserAdmin = widget.postViewMedia.postView.creatorIsAdmin ?? false;

    if (!isLoggedIn) {
      userActions = userActions.where((action) => action.requiresAuthentication == false).toList();
    } else {
      if (account?.actorId == widget.user.actorId) {
        userActions = userActions.where((action) => action != UserBottomSheetAction.blockUser && action != UserBottomSheetAction.unblockUser).toList();
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
