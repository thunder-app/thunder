import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/core/models/post_view_media.dart';
import 'package:thunder/instance/bloc/instance_bloc.dart';
import 'package:thunder/instance/enums/instance_action.dart';
import 'package:thunder/instance/utils/navigate_instance.dart';
import 'package:thunder/post/enums/post_action.dart';
import 'package:thunder/post/utils/comment_action_helpers.dart';
import 'package:thunder/shared/bottom_sheet_action.dart';
// import 'package:thunder/shared/divider.dart';
// import 'package:thunder/thunder/thunder_icons.dart';
import 'package:thunder/utils/instance.dart';

/// Defines the actions that can be taken on a community
enum InstancePostAction {
  visitCommunityInstance(icon: Icons.language_rounded, permissionType: PermissionType.user, requiresAuthentication: false),
  blockCommunityInstance(icon: Icons.block_rounded, permissionType: PermissionType.user, requiresAuthentication: true),
  unblockCommunityInstance(icon: Icons.block_rounded, permissionType: PermissionType.user, requiresAuthentication: true),
  visitUserInstance(icon: Icons.language_rounded, permissionType: PermissionType.user, requiresAuthentication: false),
  blockUserInstance(icon: Icons.block_rounded, permissionType: PermissionType.user, requiresAuthentication: true),
  unblockUserInstance(icon: Icons.block_rounded, permissionType: PermissionType.user, requiresAuthentication: true),
  ;

  String get name => switch (this) {
        InstancePostAction.visitCommunityInstance => l10n.visitCommunityInstance,
        InstancePostAction.blockCommunityInstance => l10n.blockCommunityInstance,
        InstancePostAction.unblockCommunityInstance => l10n.unblockCommunityInstance,
        InstancePostAction.visitUserInstance => l10n.visitUserInstance,
        InstancePostAction.blockUserInstance => l10n.blockUserInstance,
        InstancePostAction.unblockUserInstance => l10n.unblockUserInstance,
      };

  /// The icon to use for the action
  final IconData icon;

  /// The permission type to use for the action
  final PermissionType permissionType;

  /// Whether or not the action requires user authentication
  final bool requiresAuthentication;

  const InstancePostAction({required this.icon, required this.permissionType, required this.requiresAuthentication});
}

/// A bottom sheet that allows the user to perform actions on a instance.
///
/// Given a [postViewMedia] and a [onAction] callback, this widget will display a list of actions that can be taken on the instance.
class InstancePostActionBottomSheet extends StatefulWidget {
  const InstancePostActionBottomSheet({super.key, required this.postViewMedia, required this.onAction});

  /// The post information
  final PostViewMedia postViewMedia;

  /// Called when an action is selected
  final Function() onAction;

  @override
  State<InstancePostActionBottomSheet> createState() => _InstancePostActionBottomSheetState();
}

class _InstancePostActionBottomSheetState extends State<InstancePostActionBottomSheet> {
  void performAction(InstancePostAction action) {
    switch (action) {
      case InstancePostAction.visitCommunityInstance:
        navigateToInstancePage(context, instanceHost: fetchInstanceNameFromUrl(widget.postViewMedia.postView.community.actorId)!, instanceId: widget.postViewMedia.postView.community.instanceId);
        break;
      case InstancePostAction.blockCommunityInstance:
        context.read<InstanceBloc>().add(InstanceActionEvent(
              instanceAction: InstanceAction.block,
              instanceId: widget.postViewMedia.postView.community.instanceId,
              domain: fetchInstanceNameFromUrl(widget.postViewMedia.postView.community.actorId),
              value: true,
            ));
        break;
      case InstancePostAction.unblockCommunityInstance:
        context.read<InstanceBloc>().add(InstanceActionEvent(
              instanceAction: InstanceAction.block,
              instanceId: widget.postViewMedia.postView.community.instanceId,
              domain: fetchInstanceNameFromUrl(widget.postViewMedia.postView.community.actorId),
              value: false,
            ));
        break;
      case InstancePostAction.visitUserInstance:
        navigateToInstancePage(context, instanceHost: fetchInstanceNameFromUrl(widget.postViewMedia.postView.creator.actorId)!, instanceId: widget.postViewMedia.postView.creator.instanceId);
        break;
      case InstancePostAction.blockUserInstance:
        context.read<InstanceBloc>().add(InstanceActionEvent(
              instanceAction: InstanceAction.block,
              instanceId: widget.postViewMedia.postView.creator.instanceId,
              domain: fetchInstanceNameFromUrl(widget.postViewMedia.postView.creator.actorId),
              value: true,
            ));
        break;
      case InstancePostAction.unblockUserInstance:
        context.read<InstanceBloc>().add(InstanceActionEvent(
              instanceAction: InstanceAction.block,
              instanceId: widget.postViewMedia.postView.creator.instanceId,
              domain: fetchInstanceNameFromUrl(widget.postViewMedia.postView.creator.actorId),
              value: false,
            ));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;

    List<InstancePostAction> userActions = InstancePostAction.values.where((element) => element.permissionType == PermissionType.user).toList();
    // List<InstancePostAction> moderatorActions = InstancePostAction.values.where((element) => element.permissionType == PermissionType.moderator).toList();
    // List<InstancePostAction> adminActions = InstancePostAction.values.where((element) => element.permissionType == PermissionType.admin).toList();

    final account = authState.getSiteResponse?.myUser?.localUserView.person;
    // final moderatedCommunities = authState.getSiteResponse?.myUser?.moderates ?? [];
    // final isModerator = moderatedCommunities.where((communityModeratorView) => communityModeratorView.community.actorId == widget.postViewMedia.postView.community.actorId).isNotEmpty;
    // final isAdmin = authState.getSiteResponse?.admins.where((personView) => personView.person.actorId == account?.actorId).isNotEmpty ?? false;

    final isLoggedIn = authState.isLoggedIn;
    final blockedInstances = authState.getSiteResponse?.myUser?.instanceBlocks ?? [];

    final communityInstance = fetchInstanceNameFromUrl(widget.postViewMedia.postView.community.actorId);
    final userInstance = fetchInstanceNameFromUrl(widget.postViewMedia.postView.creator.actorId);
    final accountInstance = fetchInstanceNameFromUrl(account?.actorId);

    final isCommunityInstanceBlocked = blockedInstances.where((ibv) => ibv.instance.id == widget.postViewMedia.postView.community.instanceId).isNotEmpty;
    final isUserInstanceBlocked = blockedInstances.where((ibv) => ibv.instance.id == widget.postViewMedia.postView.creator.instanceId).isNotEmpty;

    if (!isLoggedIn) {
      userActions = userActions.where((action) => action.requiresAuthentication == false).toList();
    } else {
      if (isCommunityInstanceBlocked) {
        userActions = userActions.where((action) => action != InstancePostAction.blockCommunityInstance).toList();
      } else {
        userActions = userActions.where((action) => action != InstancePostAction.unblockCommunityInstance).toList();
      }

      if (isUserInstanceBlocked) {
        userActions = userActions.where((action) => action != InstancePostAction.blockUserInstance).toList();
      } else {
        userActions = userActions.where((action) => action != InstancePostAction.unblockUserInstance).toList();
      }
    }

    if (communityInstance == userInstance) {
      userActions.removeWhere((action) => action == InstancePostAction.visitUserInstance || action == InstancePostAction.blockUserInstance);
    }

    if (communityInstance == accountInstance) {
      userActions.removeWhere((action) => action == InstancePostAction.blockCommunityInstance);
    }

    if (userInstance == accountInstance) {
      userActions.removeWhere((action) => action == InstancePostAction.blockUserInstance);
    }

    return BlocListener<InstanceBloc, InstanceState>(
      listener: (context, state) {
        if (state.status == InstanceStatus.success) {
          context.pop();
          widget.onAction();
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...userActions
              .map(
                (instancePostAction) => BottomSheetAction(
                  leading: Icon(instancePostAction.icon),
                  subtitle: switch (instancePostAction) {
                    InstancePostAction.visitCommunityInstance => communityInstance,
                    InstancePostAction.blockCommunityInstance => communityInstance,
                    InstancePostAction.unblockCommunityInstance => communityInstance,
                    InstancePostAction.visitUserInstance => userInstance,
                    InstancePostAction.blockUserInstance => userInstance,
                    InstancePostAction.unblockUserInstance => userInstance,
                  },
                  title: instancePostAction.name,
                  onTap: () => performAction(instancePostAction),
                ),
              )
              .toList() as List<Widget>,
          // if (isModerator && moderatorActions.isNotEmpty) ...[
          //   const ThunderDivider(sliver: false, padding: false),
          //   ...moderatorActions
          //       .map(
          //         (instancePostAction) => BottomSheetAction(
          //           leading: Icon(instancePostAction.icon),
          //           trailing: Padding(
          //             padding: const EdgeInsets.only(left: 1),
          //             child: Icon(
          //               Thunder.shield,
          //               size: 20,
          //               color: Color.alphaBlend(theme.colorScheme.primary.withOpacity(0.4), Colors.green),
          //             ),
          //           ),
          //           title: instancePostAction.name,
          //           onTap: () => performAction(instancePostAction),
          //         ),
          //       )
          //       .toList() as List<Widget>,
          // ],
          // if (isAdmin && adminActions.isNotEmpty) ...[
          //   const ThunderDivider(sliver: false, padding: false),
          //   ...adminActions
          //       .map(
          //         (instancePostAction) => BottomSheetAction(
          //           leading: Icon(instancePostAction.icon),
          //           trailing: Padding(
          //             padding: const EdgeInsets.only(left: 1),
          //             child: Icon(
          //               Thunder.shield_crown,
          //               size: 20,
          //               color: Color.alphaBlend(theme.colorScheme.primary.withOpacity(0.4), Colors.red),
          //             ),
          //           ),
          //           title: instancePostAction.name,
          //           onTap: () => performAction(instancePostAction),
          //         ),
          //       )
          //       .toList() as List<Widget>,
          // ],
        ],
      ),
    );
  }
}
