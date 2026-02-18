import 'package:flutter/material.dart';

import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/features/community/community.dart';
import 'package:thunder/src/foundation/primitives/primitives.dart';
import 'package:thunder/src/features/feed/feed.dart';
import 'package:thunder/src/features/post/post.dart';
import 'package:thunder/src/foundation/config/global_context.dart';
import 'package:thunder/src/app/shell/navigation/navigation_utils.dart';
import 'package:thunder/packages/ui/ui.dart' show BottomSheetAction, Thunder, ThunderDivider, showSnackbar;

/// Defines the actions that can be taken on a community
enum CommunityPostAction {
  viewCommunity(
    icon: Icons.home_work_rounded,
    permissionType: PermissionType.all,
    requiresAuthentication: false,
  ),
  subscribeToCommunity(
    icon: Icons.add_circle_outline_rounded,
    permissionType: PermissionType.user,
    requiresAuthentication: true,
  ),
  unsubscribeFromCommunity(
    icon: Icons.remove_circle_outline_rounded,
    permissionType: PermissionType.user,
    requiresAuthentication: true,
  ),
  blockCommunity(
    icon: Icons.block_rounded,
    permissionType: PermissionType.user,
    requiresAuthentication: true,
  ),
  unblockCommunity(
    icon: Icons.block_rounded,
    permissionType: PermissionType.user,
    requiresAuthentication: true,
  );

  String get name {
    final l10n = GlobalContext.l10n;

    return switch (this) {
      CommunityPostAction.viewCommunity => l10n.visitCommunity,
      CommunityPostAction.subscribeToCommunity => l10n.subscribeToCommunity,
      CommunityPostAction.unsubscribeFromCommunity => l10n.unsubscribeFromCommunity,
      CommunityPostAction.blockCommunity => l10n.blockCommunity,
      CommunityPostAction.unblockCommunity => l10n.unblockCommunity,
    };
  }

  /// The icon to use for the action
  final IconData icon;

  /// The permission type to use for the action
  final PermissionType permissionType;

  /// Whether or not the action requires user authentication
  final bool requiresAuthentication;

  const CommunityPostAction({required this.icon, required this.permissionType, required this.requiresAuthentication});
}

/// A bottom sheet that allows the user to perform actions on a community.
class CommunityPostActionBottomSheet extends StatefulWidget {
  const CommunityPostActionBottomSheet({
    super.key,
    required this.post,
    required this.account,
    required this.moderatedCommunities,
    required this.blockedCommunities,
    required this.subscribedCommunities,
    required this.onAction,
  });

  /// The post information
  final ThunderPost post;

  /// The account that is performing the action
  final Account account;

  /// List of moderated communities
  final List<ThunderCommunity> moderatedCommunities;

  /// List of blocked communities
  final List<ThunderCommunity> blockedCommunities;

  /// List of subscribed communities
  final List<ThunderCommunity> subscribedCommunities;

  /// Called when an action is selected
  final Function(CommunityAction communityAction, ThunderCommunity? community) onAction;

  @override
  State<CommunityPostActionBottomSheet> createState() => _CommunityPostActionBottomSheetState();
}

class _CommunityPostActionBottomSheetState extends State<CommunityPostActionBottomSheet> {
  void performAction(CommunityPostAction action) async {
    final l10n = GlobalContext.l10n;
    final repository = CommunityRepositoryImpl(account: widget.account);

    switch (action) {
      case CommunityPostAction.viewCommunity:
        Navigator.of(context).pop();
        navigateToFeedPage(context, feedType: FeedType.community, communityId: widget.post.community!.id);
        break;
      case CommunityPostAction.subscribeToCommunity:
        Navigator.of(context).pop();
        final community = await repository.subscribe(widget.post.community!.id, true);
        if (community.subscribed != SubscriptionStatus.notSubscribed) {
          showSnackbar('Subscribed to ${community.titleOrName}');
        }
        widget.onAction(CommunityAction.follow, community);
        break;
      case CommunityPostAction.unsubscribeFromCommunity:
        Navigator.of(context).pop();
        final community = await repository.subscribe(widget.post.community!.id, false);
        if (community.subscribed == SubscriptionStatus.notSubscribed) {
          showSnackbar('Unsubscribed from ${community.titleOrName}');
        }
        widget.onAction(CommunityAction.follow, community);
        break;
      case CommunityPostAction.blockCommunity:
        Navigator.of(context).pop();
        final community = await repository.block(widget.post.community!.id, true);
        if (community.blocked == true) {
          showSnackbar(l10n.successfullyBlockedCommunity(community.titleOrName));
        }
        widget.onAction(CommunityAction.block, community);
        break;
      case CommunityPostAction.unblockCommunity:
        Navigator.of(context).pop();
        final community = await repository.block(widget.post.community!.id, false);
        if (community.blocked == false) {
          showSnackbar(l10n.successfullyUnblockedCommunity(community.titleOrName));
        }
        widget.onAction(CommunityAction.block, community);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    List<CommunityPostAction> userActions = CommunityPostAction.values.where((element) => element.permissionType == PermissionType.user || element.permissionType == PermissionType.all).toList();
    List<CommunityPostAction> moderatorActions = CommunityPostAction.values.where((element) => element.permissionType == PermissionType.moderator).toList();

    final isModerator = widget.moderatedCommunities.where((c) => c.actorId == widget.post.community?.actorId).isNotEmpty;
    final isCommunityBlocked = widget.blockedCommunities.where((c) => c.actorId == widget.post.community?.actorId).isNotEmpty;
    final isSubscribedToCommunity = widget.subscribedCommunities.where((c) => c.actorId == widget.post.community?.actorId).isNotEmpty;

    if (widget.account.anonymous) {
      userActions = userActions.where((action) => action.requiresAuthentication == false).toList();
    } else {
      // Should not be able to subscribe/unsubscribe/block/unblock if you are a moderator of that community
      if (isModerator) {
        userActions = userActions.where((action) => action != CommunityPostAction.subscribeToCommunity).toList();
        userActions = userActions.where((action) => action != CommunityPostAction.unsubscribeFromCommunity).toList();
        userActions = userActions.where((action) => action != CommunityPostAction.blockCommunity).toList();
        userActions = userActions.where((action) => action != CommunityPostAction.unblockCommunity).toList();
      }

      // Should not be able to subscribe/block/unblock if you are already subscribed to the community
      if (isSubscribedToCommunity) {
        userActions = userActions.where((action) => action != CommunityPostAction.subscribeToCommunity).toList();
        userActions = userActions.where((action) => action != CommunityPostAction.blockCommunity).toList();
        userActions = userActions.where((action) => action != CommunityPostAction.unblockCommunity).toList();
      } else {
        userActions = userActions.where((action) => action != CommunityPostAction.unsubscribeFromCommunity).toList();
      }

      // Should not be able to subscribe/unsubscribe/block if you are blocked from the community
      if (isCommunityBlocked) {
        userActions = userActions.where((action) => action != CommunityPostAction.blockCommunity).toList();
        userActions = userActions.where((action) => action != CommunityPostAction.subscribeToCommunity).toList();
        userActions = userActions.where((action) => action != CommunityPostAction.unsubscribeFromCommunity).toList();
      } else {
        userActions = userActions.where((action) => action != CommunityPostAction.unblockCommunity).toList();
      }
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...userActions.map<Widget>(
          (communityPostAction) => BottomSheetAction(
            leading: Icon(communityPostAction.icon),
            title: communityPostAction.name,
            onTap: () => performAction(communityPostAction),
          ),
        ),
        if (isModerator && moderatorActions.isNotEmpty) ...[
          const ThunderDivider(sliver: false, padding: false),
          ...moderatorActions.map<Widget>(
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
          ),
        ],
      ],
    );
  }
}
