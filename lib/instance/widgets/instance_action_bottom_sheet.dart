import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/instance/bloc/instance_bloc.dart';
import 'package:thunder/instance/enums/instance_action.dart';
import 'package:thunder/instance/utils/navigate_instance.dart';
import 'package:thunder/post/enums/post_action.dart';
import 'package:thunder/shared/bottom_sheet_action.dart';
import 'package:thunder/utils/global_context.dart';
import 'package:thunder/utils/instance.dart';

/// Defines the actions that can be taken on an instance
enum InstanceBottomSheetAction {
  visitCommunityInstance(icon: Icons.language_rounded, permissionType: PermissionType.user, requiresAuthentication: false),
  blockCommunityInstance(icon: Icons.block_rounded, permissionType: PermissionType.user, requiresAuthentication: true),
  unblockCommunityInstance(icon: Icons.block_rounded, permissionType: PermissionType.user, requiresAuthentication: true),
  visitUserInstance(icon: Icons.language_rounded, permissionType: PermissionType.user, requiresAuthentication: false),
  blockUserInstance(icon: Icons.block_rounded, permissionType: PermissionType.user, requiresAuthentication: true),
  unblockUserInstance(icon: Icons.block_rounded, permissionType: PermissionType.user, requiresAuthentication: true),
  ;

  String get name => switch (this) {
        InstanceBottomSheetAction.visitCommunityInstance => GlobalContext.l10n.visitCommunityInstance,
        InstanceBottomSheetAction.blockCommunityInstance => GlobalContext.l10n.blockCommunityInstance,
        InstanceBottomSheetAction.unblockCommunityInstance => GlobalContext.l10n.unblockCommunityInstance,
        InstanceBottomSheetAction.visitUserInstance => GlobalContext.l10n.visitUserInstance,
        InstanceBottomSheetAction.blockUserInstance => GlobalContext.l10n.blockUserInstance,
        InstanceBottomSheetAction.unblockUserInstance => GlobalContext.l10n.unblockUserInstance,
      };

  /// The icon to use for the action
  final IconData icon;

  /// The permission type to use for the action
  final PermissionType permissionType;

  /// Whether or not the action requires user authentication
  final bool requiresAuthentication;

  const InstanceBottomSheetAction({required this.icon, required this.permissionType, required this.requiresAuthentication});
}

/// A bottom sheet that allows the user to perform actions on a instance.
///
/// Given an [onAction] callback, this widget will display a list of actions that can be taken on the instance.
class InstanceActionBottomSheet extends StatefulWidget {
  const InstanceActionBottomSheet({
    super.key,
    this.communityInstanceId,
    this.communityInstanceUrl,
    this.userInstanceId,
    this.userInstanceUrl,
    required this.onAction,
  });

  /// The instance id for the given community
  final int? communityInstanceId;

  /// The community actor id
  final String? communityInstanceUrl;

  /// The instance id for the given user
  final int? userInstanceId;

  /// The user actor id
  final String? userInstanceUrl;

  /// Called when an action is selected
  final Function() onAction;

  @override
  State<InstanceActionBottomSheet> createState() => _InstanceActionBottomSheetState();
}

class _InstanceActionBottomSheetState extends State<InstanceActionBottomSheet> {
  void performAction(InstanceBottomSheetAction action) {
    switch (action) {
      case InstanceBottomSheetAction.visitCommunityInstance:
        navigateToInstancePage(context, instanceHost: fetchInstanceNameFromUrl(widget.communityInstanceUrl)!, instanceId: widget.communityInstanceId);
        break;
      case InstanceBottomSheetAction.blockCommunityInstance:
        context.read<InstanceBloc>().add(InstanceActionEvent(
              instanceAction: InstanceAction.block,
              instanceId: widget.communityInstanceId!,
              domain: fetchInstanceNameFromUrl(widget.communityInstanceUrl),
              value: true,
            ));
        break;
      case InstanceBottomSheetAction.unblockCommunityInstance:
        context.read<InstanceBloc>().add(InstanceActionEvent(
              instanceAction: InstanceAction.block,
              instanceId: widget.communityInstanceId!,
              domain: fetchInstanceNameFromUrl(widget.communityInstanceUrl),
              value: false,
            ));
        break;
      case InstanceBottomSheetAction.visitUserInstance:
        navigateToInstancePage(context, instanceHost: fetchInstanceNameFromUrl(widget.userInstanceUrl)!, instanceId: widget.userInstanceId);
        break;
      case InstanceBottomSheetAction.blockUserInstance:
        context.read<InstanceBloc>().add(InstanceActionEvent(
              instanceAction: InstanceAction.block,
              instanceId: widget.userInstanceId!,
              domain: fetchInstanceNameFromUrl(widget.userInstanceUrl),
              value: true,
            ));
        break;
      case InstanceBottomSheetAction.unblockUserInstance:
        context.read<InstanceBloc>().add(InstanceActionEvent(
              instanceAction: InstanceAction.block,
              instanceId: widget.userInstanceId!,
              domain: fetchInstanceNameFromUrl(widget.userInstanceUrl),
              value: false,
            ));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;

    List<InstanceBottomSheetAction> userActions = InstanceBottomSheetAction.values.where((element) => element.permissionType == PermissionType.user).toList();
    // List<InstancePostAction> moderatorActions = InstancePostAction.values.where((element) => element.permissionType == PermissionType.moderator).toList();
    // List<InstancePostAction> adminActions = InstancePostAction.values.where((element) => element.permissionType == PermissionType.admin).toList();

    final account = authState.getSiteResponse?.myUser?.localUserView.person;
    // final moderatedCommunities = authState.getSiteResponse?.myUser?.moderates ?? [];
    // final isModerator = moderatedCommunities.where((communityModeratorView) => communityModeratorView.community.actorId == widget.postViewMedia.postView.community.actorId).isNotEmpty;
    // final isAdmin = authState.getSiteResponse?.admins.where((personView) => personView.person.actorId == account?.actorId).isNotEmpty ?? false;

    final isLoggedIn = authState.isLoggedIn;
    final blockedInstances = authState.getSiteResponse?.myUser?.instanceBlocks ?? [];

    final communityInstance = fetchInstanceNameFromUrl(widget.communityInstanceUrl);
    final userInstance = fetchInstanceNameFromUrl(widget.userInstanceUrl);
    final accountInstance = fetchInstanceNameFromUrl(account?.actorId);

    final isCommunityInstanceBlocked = blockedInstances.where((ibv) => ibv.instance.id == widget.communityInstanceId).isNotEmpty;
    final isUserInstanceBlocked = blockedInstances.where((ibv) => ibv.instance.id == widget.userInstanceId).isNotEmpty;

    // Filter out actions that don't have the proper information passed in
    if (widget.communityInstanceId == null || widget.communityInstanceUrl == null) {
      userActions = userActions
          .where(
            (action) =>
                action != InstanceBottomSheetAction.visitCommunityInstance &&
                action != InstanceBottomSheetAction.blockCommunityInstance &&
                action != InstanceBottomSheetAction.unblockCommunityInstance,
          )
          .toList();
    }

    if (widget.userInstanceId == null || widget.userInstanceUrl == null) {
      userActions = userActions
          .where((action) => action != InstanceBottomSheetAction.visitUserInstance && action != InstanceBottomSheetAction.blockUserInstance && action != InstanceBottomSheetAction.unblockUserInstance)
          .toList();
    }

    if (!isLoggedIn) {
      userActions = userActions.where((action) => action.requiresAuthentication == false).toList();
    } else {
      // Filter out actions that the user can't perform
      if (isCommunityInstanceBlocked) {
        userActions = userActions.where((action) => action != InstanceBottomSheetAction.blockCommunityInstance).toList();
      } else {
        userActions = userActions.where((action) => action != InstanceBottomSheetAction.unblockCommunityInstance).toList();
      }

      if (isUserInstanceBlocked) {
        userActions = userActions.where((action) => action != InstanceBottomSheetAction.blockUserInstance).toList();
      } else {
        userActions = userActions.where((action) => action != InstanceBottomSheetAction.unblockUserInstance).toList();
      }
    }

    // Remove duplicate actions
    if (userInstance == communityInstance) {
      userActions.removeWhere((action) => action == InstanceBottomSheetAction.visitUserInstance || action == InstanceBottomSheetAction.blockUserInstance);
    }

    // Filter out any instances that match the account instance, and prevent the user from blocking their own instance
    if (communityInstance == accountInstance) {
      userActions.removeWhere((action) => action == InstanceBottomSheetAction.blockCommunityInstance);
    }

    if (userInstance == accountInstance) {
      userActions.removeWhere((action) => action == InstanceBottomSheetAction.blockUserInstance);
    }

    return BlocListener<InstanceBloc, InstanceState>(
      listener: (context, state) {
        if (state.status == InstanceStatus.success) {
          Navigator.of(context).pop();
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
                    InstanceBottomSheetAction.visitCommunityInstance => communityInstance,
                    InstanceBottomSheetAction.blockCommunityInstance => communityInstance,
                    InstanceBottomSheetAction.unblockCommunityInstance => communityInstance,
                    InstanceBottomSheetAction.visitUserInstance => userInstance,
                    InstanceBottomSheetAction.blockUserInstance => userInstance,
                    InstanceBottomSheetAction.unblockUserInstance => userInstance,
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
