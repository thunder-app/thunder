import 'package:flutter/material.dart';

import 'package:thunder/src/core/domain/domain.dart';
import 'package:thunder/src/core/navigation/navigation_utils.dart';
import 'package:thunder/src/features/post/post.dart';
import 'package:thunder/src/core/config/global_context.dart';
import 'package:thunder/src/features/instance/domain/utils/instance_link_utils.dart';
import 'package:thunder/packages/ui/ui.dart';
import 'package:thunder/src/core/app/repository_factories.dart';

/// Defines the actions that can be taken on an instance
enum InstanceBottomSheetAction {
  visitCommunityInstance(
    icon: Icons.language_rounded,
    permissionType: PermissionType.all,
    requiresAuthentication: false,
  ),
  blockCommunityInstance(
    icon: Icons.block_rounded,
    permissionType: PermissionType.user,
    requiresAuthentication: true,
  ),
  unblockCommunityInstance(
    icon: Icons.block_rounded,
    permissionType: PermissionType.user,
    requiresAuthentication: true,
  ),
  visitUserInstance(
    icon: Icons.language_rounded,
    permissionType: PermissionType.all,
    requiresAuthentication: false,
  ),
  blockUserInstance(
    icon: Icons.block_rounded,
    permissionType: PermissionType.user,
    requiresAuthentication: true,
  ),
  unblockUserInstance(
    icon: Icons.block_rounded,
    permissionType: PermissionType.user,
    requiresAuthentication: true,
  );

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
class InstanceActionBottomSheet extends StatefulWidget {
  const InstanceActionBottomSheet({
    super.key,
    required this.context,
    required this.account,
    required this.blockedInstances,
    this.communityInstanceId,
    this.communityInstanceUrl,
    this.userInstanceId,
    this.userInstanceUrl,
    this.onAction,
  });

  /// The account to use for the instance actions
  final BuildContext context;

  /// The account to use for the instance actions
  final Account account;

  /// List of blocked instances
  final List<ThunderInstanceBlock> blockedInstances;

  /// The instance id for the given community
  final int? communityInstanceId;

  /// The community actor id
  final String? communityInstanceUrl;

  /// The instance id for the given user
  final int? userInstanceId;

  /// The user actor id
  final String? userInstanceUrl;

  /// Optional callback fired when a change occurs (e.g., block/unblock)
  final VoidCallback? onAction;

  @override
  State<InstanceActionBottomSheet> createState() => _InstanceActionBottomSheetState();
}

class _InstanceActionBottomSheetState extends State<InstanceActionBottomSheet> {
  Future<void> performAction(InstanceBottomSheetAction action) async {
    final l10n = GlobalContext.l10n;
    final repository = createInstanceRepository(widget.account);

    final userInstance = fetchInstanceNameFromUrl(widget.userInstanceUrl);
    final communityInstance = fetchInstanceNameFromUrl(widget.communityInstanceUrl);

    switch (action) {
      case InstanceBottomSheetAction.visitCommunityInstance:
        navigateToInstancePage(widget.context, account: widget.account, instanceHost: fetchInstanceNameFromUrl(widget.communityInstanceUrl)!, instanceId: widget.communityInstanceId);
        break;
      case InstanceBottomSheetAction.blockCommunityInstance:
        Navigator.of(context).pop();
        final blocked = await repository.block(widget.communityInstanceId!, true);
        if (blocked) {
          showThunderSnackbar(l10n.successfullyBlockedCommunity(communityInstance!));
        }
        widget.onAction?.call();
        break;
      case InstanceBottomSheetAction.unblockCommunityInstance:
        Navigator.of(context).pop();
        final blocked = await repository.block(widget.communityInstanceId!, false);
        if (!blocked) {
          showThunderSnackbar(l10n.successfullyUnblockedCommunity(communityInstance!));
        }
        widget.onAction?.call();
        break;
      case InstanceBottomSheetAction.visitUserInstance:
        navigateToInstancePage(widget.context, account: widget.account, instanceHost: fetchInstanceNameFromUrl(widget.userInstanceUrl)!, instanceId: widget.userInstanceId);
        break;
      case InstanceBottomSheetAction.blockUserInstance:
        Navigator.of(context).pop();
        final blocked = await repository.block(widget.userInstanceId!, true);
        if (blocked) showThunderSnackbar(l10n.successfullyBlockedUser(userInstance!));
        widget.onAction?.call();
        break;
      case InstanceBottomSheetAction.unblockUserInstance:
        Navigator.of(context).pop();
        final blocked = await repository.block(widget.userInstanceId!, false);
        if (!blocked) {
          showThunderSnackbar(l10n.successfullyUnblockedUser(userInstance!));
        }
        widget.onAction?.call();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    List<InstanceBottomSheetAction> userActions =
        InstanceBottomSheetAction.values.where((element) => element.permissionType == PermissionType.user || element.permissionType == PermissionType.all).toList();

    final userInstance = fetchInstanceNameFromUrl(widget.userInstanceUrl);
    final communityInstance = fetchInstanceNameFromUrl(widget.communityInstanceUrl);
    final accountInstance = widget.account.instance;

    final isCommunityInstanceBlocked = widget.blockedInstances.where((ibv) => ibv.instance['id'] == widget.communityInstanceId).isNotEmpty;
    final isUserInstanceBlocked = widget.blockedInstances.where((ibv) => ibv.instance['id'] == widget.userInstanceId).isNotEmpty;

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

    if (widget.account.anonymous) {
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

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...userActions.map<Widget>(
          (instancePostAction) => ThunderBottomSheetAction(
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
        ),
      ],
    );
  }
}
