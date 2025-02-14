import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lemmy_api_client/v3.dart';

import 'package:thunder/community/bloc/community_bloc.dart';
import 'package:thunder/community/enums/community_action.dart';
import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/core/models/models.dart';
import 'package:thunder/core/models/post_view_media.dart';
import 'package:thunder/feed/feed.dart';
import 'package:thunder/post/enums/post_action.dart';
import 'package:thunder/post/widgets/post_action_bottom_sheet.dart';
import 'package:thunder/shared/bottom_sheet_action.dart';
import 'package:thunder/shared/divider.dart';
import 'package:thunder/thunder/thunder_icons.dart';

/// Defines the actions that can be taken on a community
enum CommunityPostAction {
  viewCommunity(icon: Icons.home_work_rounded, permissionType: PermissionType.user, requiresAuthentication: false),
  subscribeToCommunity(icon: Icons.add_circle_outline_rounded, permissionType: PermissionType.user, requiresAuthentication: true),
  unsubscribeFromCommunity(icon: Icons.remove_circle_outline_rounded, permissionType: PermissionType.user, requiresAuthentication: true),
  blockCommunity(icon: Icons.block_rounded, permissionType: PermissionType.user, requiresAuthentication: true),
  unblockCommunity(icon: Icons.block_rounded, permissionType: PermissionType.user, requiresAuthentication: true),
  ;

  String get name => switch (this) {
        CommunityPostAction.viewCommunity => l10n.visitCommunity,
        CommunityPostAction.subscribeToCommunity => l10n.subscribeToCommunity,
        CommunityPostAction.unsubscribeFromCommunity => l10n.unsubscribeFromCommunity,
        CommunityPostAction.blockCommunity => l10n.blockCommunity,
        CommunityPostAction.unblockCommunity => l10n.unblockCommunity,
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
  final Function(CommunityAction communityAction, CommunityView? communityView) onAction;

  @override
  State<CommunityPostActionBottomSheet> createState() => _CommunityPostActionBottomSheetState();
}

class _CommunityPostActionBottomSheetState extends State<CommunityPostActionBottomSheet> {
  CommunityAction? _communityAction;

  void performAction(CommunityPostAction action) {
    switch (action) {
      case CommunityPostAction.viewCommunity:
        Navigator.of(context).pop();
        navigateToFeedPage(context, feedType: FeedType.community, communityId: widget.postViewMedia.postView.community.id);
        break;
      case CommunityPostAction.subscribeToCommunity:
        context.read<CommunityBloc>().add(CommunityActionEvent(communityId: widget.postViewMedia.postView.community.id, communityAction: CommunityAction.follow, value: true));
        setState(() => _communityAction = CommunityAction.follow);
        break;
      case CommunityPostAction.unsubscribeFromCommunity:
        context.read<CommunityBloc>().add(CommunityActionEvent(communityId: widget.postViewMedia.postView.community.id, communityAction: CommunityAction.follow, value: false));
        break;
      case CommunityPostAction.blockCommunity:
        context.read<CommunityBloc>().add(CommunityActionEvent(communityId: widget.postViewMedia.postView.community.id, communityAction: CommunityAction.block, value: true));
        setState(() => _communityAction = CommunityAction.block);
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
    // List<CommunityPostAction> adminActions = CommunityPostAction.values.where((element) => element.permissionType == PermissionType.admin).toList();

    // final account = authState.getSiteResponse?.myUser?.localUserView.person;
    final moderatedCommunities = authState.getSiteResponse?.myUser?.moderates ?? [];
    final isModerator = moderatedCommunities.where((communityModeratorView) => communityModeratorView.community.actorId == widget.postViewMedia.postView.community.actorId).isNotEmpty;
    // final isAdmin = authState.getSiteResponse?.admins.where((personView) => personView.person.actorId == account?.actorId).isNotEmpty ?? false;

    final isLoggedIn = authState.isLoggedIn;
    final blockedCommunities = authState.getSiteResponse?.myUser?.communityBlocks ?? [];

    final isCommunityBlocked = blockedCommunities.where((cbv) => cbv.community.actorId == widget.postViewMedia.postView.community.actorId).isNotEmpty;
    final isSubscribedToCommunity = widget.postViewMedia.postView.subscribed != SubscribedType.notSubscribed;

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
          Navigator.of(context).pop();
          if (_communityAction != null) widget.onAction(_communityAction!, state.communityView);
          setState(() => _communityAction = null);
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
                        color: Color.alphaBlend(theme.colorScheme.primary.withValues(alpha: 0.4), Colors.green),
                      ),
                    ),
                    title: communityPostAction.name,
                    onTap: () => performAction(communityPostAction),
                  ),
                )
                .toList() as List<Widget>,
          ],
          // if (isAdmin && adminActions.isNotEmpty) ...[
          //   const ThunderDivider(sliver: false, padding: false),
          //   ...adminActions
          //       .map(
          //         (communityPostAction) => BottomSheetAction(
          //           leading: Icon(communityPostAction.icon),
          //           trailing: Padding(
          //             padding: const EdgeInsets.only(left: 1),
          //             child: Icon(
          //               Thunder.shield_crown,
          //               size: 20,
          //               color: Color.alphaBlend(theme.colorScheme.primary.withValues(alpha: 0.4), Colors.red),
          //             ),
          //           ),
          //           title: communityPostAction.name,
          //           onTap: () => performAction(communityPostAction),
          //         ),
          //       )
          //       .toList() as List<Widget>,
          // ],
        ],
      ),
    );
  }
}
