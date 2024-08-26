import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lemmy_api_client/v3.dart';

import 'package:thunder/community/bloc/community_bloc.dart';
import 'package:thunder/community/enums/community_action.dart';
import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/core/models/post_view_media.dart';
import 'package:thunder/feed/feed.dart';
import 'package:thunder/post/enums/post_action.dart';
import 'package:thunder/shared/bottom_sheet_action.dart';
import 'package:thunder/shared/divider.dart';
import 'package:thunder/thunder/thunder_icons.dart';

/// Defines the actions that can be taken on a community
enum CommunityPostAction {
  viewCommunity(icon: Icons.person, permissionType: PermissionType.user, requiresAuthentication: false),
  subscribeToCommunity(icon: Icons.add_circle_outline_rounded, permissionType: PermissionType.user, requiresAuthentication: true),
  unsubscribeFromCommunity(icon: Icons.remove_circle_outline_rounded, permissionType: PermissionType.user, requiresAuthentication: true),
  blockCommunity(icon: Icons.block, permissionType: PermissionType.user, requiresAuthentication: true),
  unblockCommunity(icon: Icons.block, permissionType: PermissionType.user, requiresAuthentication: true),
  ;

  String get name => switch (this) {
        CommunityPostAction.viewCommunity => "View Community",
        CommunityPostAction.subscribeToCommunity => "Subscribe To Community",
        CommunityPostAction.unsubscribeFromCommunity => "Unsubscribe From Community",
        CommunityPostAction.blockCommunity => "Block Community",
        CommunityPostAction.unblockCommunity => "Unblock Community",
      };

  /// The icon to use for the action
  final IconData icon;

  /// The permission type to use for the action
  final PermissionType permissionType;

  /// Whether or not the action requires user authentication
  final bool requiresAuthentication;

  const CommunityPostAction({required this.icon, required this.permissionType, required this.requiresAuthentication});
}

/// A bottom sheet that allows the user to perform actions on a community.
///
/// Given a [postViewMedia] and a [onAction] callback, this widget will display a list of actions that can be taken on the community.
/// The [onAction] callback will be triggered when an action is performed. This is useful if the parent widget requires an updated [CommunityView].
class CommunityPostActionBottomSheet extends StatefulWidget {
  const CommunityPostActionBottomSheet({super.key, required this.postViewMedia, required this.onAction});

  /// The post information
  final PostViewMedia postViewMedia;

  /// Called when an action is selected
  final Function(CommunityView? communityView) onAction;

  @override
  State<CommunityPostActionBottomSheet> createState() => _CommunityPostActionBottomSheetState();
}

class _CommunityPostActionBottomSheetState extends State<CommunityPostActionBottomSheet> {
  void performAction(CommunityPostAction action) {
    switch (action) {
      case CommunityPostAction.viewCommunity:
        context.pop();
        navigateToFeedPage(context, feedType: FeedType.community, communityId: widget.postViewMedia.postView.community.id);
        break;
      case CommunityPostAction.subscribeToCommunity:
        context.read<CommunityBloc>().add(CommunityActionEvent(communityId: widget.postViewMedia.postView.community.id, communityAction: CommunityAction.follow, value: true));
        break;
      case CommunityPostAction.unsubscribeFromCommunity:
        context.read<CommunityBloc>().add(CommunityActionEvent(communityId: widget.postViewMedia.postView.community.id, communityAction: CommunityAction.follow, value: false));
        break;
      case CommunityPostAction.blockCommunity:
        context.read<CommunityBloc>().add(CommunityActionEvent(communityId: widget.postViewMedia.postView.community.id, communityAction: CommunityAction.block, value: true));
        break;
      case CommunityPostAction.unblockCommunity:
        context.read<CommunityBloc>().add(CommunityActionEvent(communityId: widget.postViewMedia.postView.community.id, communityAction: CommunityAction.block, value: false));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = context.read<AuthBloc>().state;

    List<CommunityPostAction> userActions = CommunityPostAction.values.where((element) => element.permissionType == PermissionType.user).toList();
    List<CommunityPostAction> moderatorActions = CommunityPostAction.values.where((element) => element.permissionType == PermissionType.moderator).toList();
    List<CommunityPostAction> adminActions = CommunityPostAction.values.where((element) => element.permissionType == PermissionType.admin).toList();

    final account = authState.getSiteResponse?.myUser?.localUserView.person;
    final isModerator = authState.getSiteResponse?.myUser?.moderates.where((communityModeratorView) => communityModeratorView.moderator.actorId == account?.actorId).isNotEmpty ?? false;
    final isAdmin = authState.getSiteResponse?.admins.where((personView) => personView.person.actorId == account?.actorId).isNotEmpty ?? false;

    final isLoggedIn = authState.isLoggedIn;
    final blockedCommunities = authState.getSiteResponse?.myUser?.communityBlocks ?? [];
    final subscribedCommunities = authState.getSiteResponse?.myUser?.follows ?? [];

    final isCommunityBlocked = blockedCommunities.where((cbv) => cbv.community.actorId == widget.postViewMedia.postView.community.actorId).isNotEmpty;
    final isSubscribedToCommunity = subscribedCommunities.where((cfv) => cfv.community.actorId == widget.postViewMedia.postView.community.actorId).isNotEmpty;

    if (!isLoggedIn) {
      userActions = userActions.where((action) => action.requiresAuthentication == false).toList();
    } else {
      if (isSubscribedToCommunity) {
        userActions = userActions.where((action) => action != CommunityPostAction.subscribeToCommunity).toList();
      } else {
        userActions = userActions.where((action) => action != CommunityPostAction.unsubscribeFromCommunity).toList();
      }

      if (isCommunityBlocked) {
        userActions = userActions.where((action) => action != CommunityPostAction.blockCommunity).toList();
      } else {
        userActions = userActions.where((action) => action != CommunityPostAction.unblockCommunity).toList();
      }
    }

    return BlocListener<CommunityBloc, CommunityState>(
      listener: (context, state) {
        if (state.status == CommunityStatus.success) {
          context.pop();
          widget.onAction(state.communityView);
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...userActions
              .map(
                (communityPostAction) => BottomSheetAction(
                  leading: Icon(communityPostAction.icon),
                  title: communityPostAction.name,
                  onTap: () => performAction(communityPostAction),
                ),
              )
              .toList() as List<Widget>,
          if (isModerator && moderatorActions.isNotEmpty) ...[
            const ThunderDivider(sliver: false, padding: false),
            ...moderatorActions
                .map(
                  (communityPostAction) => BottomSheetAction(
                    leading: Icon(communityPostAction.icon),
                    trailing: Padding(
                      padding: const EdgeInsets.only(left: 1),
                      child: Icon(
                        Thunder.shield,
                        size: 20,
                        color: Color.alphaBlend(theme.colorScheme.primary.withOpacity(0.4), Colors.green),
                      ),
                    ),
                    title: communityPostAction.name,
                    onTap: () => performAction(communityPostAction),
                  ),
                )
                .toList() as List<Widget>,
          ],
          if (isAdmin && adminActions.isNotEmpty) ...[
            const ThunderDivider(sliver: false, padding: false),
            ...adminActions
                .map(
                  (communityPostAction) => BottomSheetAction(
                    leading: Icon(communityPostAction.icon),
                    trailing: Padding(
                      padding: const EdgeInsets.only(left: 1),
                      child: Icon(
                        Thunder.shield_crown,
                        size: 20,
                        color: Color.alphaBlend(theme.colorScheme.primary.withOpacity(0.4), Colors.red),
                      ),
                    ),
                    title: communityPostAction.name,
                    onTap: () => performAction(communityPostAction),
                  ),
                )
                .toList() as List<Widget>,
          ],
        ],
      ),
    );
  }
}
