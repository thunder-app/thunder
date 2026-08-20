import 'package:flutter/material.dart';

import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/features/community/community.dart';
import 'package:thunder/src/features/post/post.dart';
import 'package:thunder/src/core/config/global_context.dart';
import 'package:thunder/src/features/instance/domain/utils/instance_link_utils.dart';
import 'package:thunder/src/core/navigation/navigation_utils.dart';
import 'package:thunder/packages/ui/ui.dart';
import 'package:thunder/src/core/app/repository_factories.dart';

/// Defines the actions that can be taken on a post
enum PostPostAction {
  reportPost(icon: Icons.flag_rounded, permissionType: PermissionType.user, requiresAuthentication: true),
  editPost(icon: Icons.edit_rounded, permissionType: PermissionType.user, requiresAuthentication: true),
  deletePost(icon: Icons.delete_rounded, permissionType: PermissionType.user, requiresAuthentication: true),
  restorePost(icon: Icons.restore_rounded, permissionType: PermissionType.user, requiresAuthentication: true),
  lockPost(icon: Icons.lock_rounded, permissionType: PermissionType.moderator, requiresAuthentication: true),
  unlockPost(icon: Icons.lock_open_rounded, permissionType: PermissionType.moderator, requiresAuthentication: true),
  removePost(icon: Icons.delete_rounded, permissionType: PermissionType.moderator, requiresAuthentication: true),
  restorePostAsModerator(icon: Icons.restore_rounded, permissionType: PermissionType.moderator, requiresAuthentication: true),
  pinPostToCommunity(icon: Icons.pin, permissionType: PermissionType.moderator, requiresAuthentication: true),
  unpinPostFromCommunity(icon: Icons.pin, permissionType: PermissionType.moderator, requiresAuthentication: true);

  String get name {
    final l10n = GlobalContext.l10n;

    return switch (this) {
      PostPostAction.reportPost => l10n.reportPost,
      PostPostAction.editPost => l10n.editPost,
      PostPostAction.deletePost => l10n.deletePost,
      PostPostAction.restorePost => l10n.restorePost,
      PostPostAction.lockPost => l10n.lockPost,
      PostPostAction.unlockPost => l10n.unlockPost,
      PostPostAction.removePost => l10n.removePost,
      PostPostAction.restorePostAsModerator => l10n.restorePost,
      PostPostAction.pinPostToCommunity => l10n.pinPostToCommunity,
      PostPostAction.unpinPostFromCommunity => l10n.unpinPostFromCommunity,
    };
  }

  /// The icon to use for the action
  final IconData icon;

  /// The permission type to use for the action
  final PermissionType permissionType;

  /// Whether or not the action requires user authentication
  final bool requiresAuthentication;

  const PostPostAction({required this.icon, required this.permissionType, required this.requiresAuthentication});
}

/// A bottom sheet that allows the user to perform actions on the post.
class PostPostActionBottomSheet extends StatefulWidget {
  const PostPostActionBottomSheet({super.key, required this.context, required this.account, required this.moderatedCommunities, required this.post, required this.onAction});

  /// The outer context
  final BuildContext context;

  /// The account that is performing the action
  final Account account;

  /// List of moderated communities
  final List<ThunderCommunity> moderatedCommunities;

  /// The post information
  final ThunderPost post;

  /// Called when an action is selected
  final Function(PostAction postAction, ThunderPost? post) onAction;

  @override
  State<PostPostActionBottomSheet> createState() => _PostPostActionBottomSheetState();
}

class _PostPostActionBottomSheetState extends State<PostPostActionBottomSheet> {
  void performAction(PostPostAction action) async {
    final l10n = GlobalContext.l10n;
    final repository = createPostRepository(widget.account);

    switch (action) {
      case PostPostAction.reportPost:
        showReportPostDialog();
        return;
      case PostPostAction.editPost:
        Navigator.of(context).pop();
        navigateToCreatePostPage(widget.context, account: widget.account, communityId: widget.post.community?.id, post: widget.post);
        return;
      case PostPostAction.deletePost:
        Navigator.of(context).pop();
        final deleted = await repository.delete(widget.post.id, true);
        if (deleted) showThunderSnackbar(l10n.deletedPost);
        widget.onAction(PostAction.delete, widget.post.copyWith(status: widget.post.status.copyWith(deleted: true)));
        break;
      case PostPostAction.restorePost:
        Navigator.of(context).pop();
        final deleted = await repository.delete(widget.post.id, false);
        if (!deleted) showThunderSnackbar(l10n.restoredPost);
        widget.onAction(PostAction.delete, widget.post.copyWith(status: widget.post.status.copyWith(deleted: false)));
        break;
      case PostPostAction.lockPost:
        Navigator.of(context).pop();
        final locked = await repository.lock(widget.post.id, true);
        if (locked) showThunderSnackbar(l10n.lockedPost);
        widget.onAction(PostAction.lock, widget.post.copyWith(status: widget.post.status.copyWith(locked: true)));
        break;
      case PostPostAction.unlockPost:
        Navigator.of(context).pop();
        final locked = await repository.lock(widget.post.id, false);
        if (!locked) showThunderSnackbar(l10n.unlockedPost);
        widget.onAction(PostAction.lock, widget.post.copyWith(status: widget.post.status.copyWith(locked: false)));
        break;
      case PostPostAction.removePost:
        showRemovePostReasonDialog();
        break;
      case PostPostAction.restorePostAsModerator:
        showRemovePostReasonDialog();
        break;
      case PostPostAction.pinPostToCommunity:
        Navigator.of(context).pop();
        final pinned = await repository.pinCommunity(widget.post.id, true);
        if (pinned) showThunderSnackbar(l10n.pinnedPostToCommunity);
        widget.onAction(PostAction.pinCommunity, widget.post.copyWith(status: widget.post.status.copyWith(featuredCommunity: true)));
        break;
      case PostPostAction.unpinPostFromCommunity:
        Navigator.of(context).pop();
        final pinned = await repository.pinCommunity(widget.post.id, false);
        if (!pinned) showThunderSnackbar(l10n.unpinnedPostFromCommunity);
        widget.onAction(PostAction.pinCommunity, widget.post.copyWith(status: widget.post.status.copyWith(featuredCommunity: false)));
        break;
    }
  }

  void showReportPostDialog() {
    Navigator.of(context).pop();
    final l10n = GlobalContext.l10n;
    final controller = TextEditingController();

    showThunderDialog(
      context: widget.context,
      title: l10n.reportPost,
      primaryButtonText: l10n.report(1),
      onPrimaryButtonPressed: (dialogContext, setPrimaryButtonEnabled) async {
        final repository = createPostRepository(widget.account);

        await repository.report(widget.post.id, controller.text);
        showThunderSnackbar(l10n.reportedPost);
        widget.onAction(PostAction.report, null);

        Navigator.of(dialogContext).pop();
      },
      secondaryButtonText: l10n.cancel,
      onSecondaryButtonPressed: (context) => Navigator.of(context).pop(),
      contentWidgetBuilder: (_) => TextFormField(
        decoration: InputDecoration(border: const OutlineInputBorder(), labelText: l10n.message(0)),
        autofocus: true,
        controller: controller,
        maxLines: 4,
      ),
    );
  }

  void showRemovePostReasonDialog() {
    Navigator.of(context).pop();
    final l10n = GlobalContext.l10n;
    final controller = TextEditingController();

    showThunderDialog(
      context: widget.context,
      title: widget.post.status.removed ? l10n.restorePost : l10n.removalReason,
      primaryButtonText: widget.post.status.removed ? l10n.restore : l10n.remove,
      onPrimaryButtonPressed: (dialogContext, setPrimaryButtonEnabled) async {
        final repository = createPostRepository(widget.account);

        final removed = await repository.remove(widget.post.id, !widget.post.status.removed, controller.text);
        removed ? showThunderSnackbar(l10n.removedPost) : showThunderSnackbar(l10n.restoredPost);
        widget.onAction(PostAction.remove, widget.post.copyWith(status: widget.post.status.copyWith(removed: !widget.post.status.removed)));

        Navigator.of(dialogContext).pop();
      },
      secondaryButtonText: l10n.cancel,
      onSecondaryButtonPressed: (context) => Navigator.of(context).pop(),
      contentWidgetBuilder: (_) => TextFormField(
        decoration: InputDecoration(border: const OutlineInputBorder(), labelText: l10n.message(0)),
        autofocus: true,
        controller: controller,
        maxLines: 4,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    List<PostPostAction> userActions = PostPostAction.values.where((element) => element.permissionType == PermissionType.user).toList();
    List<PostPostAction> moderatorActions = PostPostAction.values.where((element) => element.permissionType == PermissionType.moderator).toList();

    final isModerator = widget.moderatedCommunities.where((c) => c.actorId == widget.post.community?.actorId).isNotEmpty;

    final isPostLocked = widget.post.status.locked;
    final isPostPinnedToCommunity = widget.post.status.featuredCommunity; // Pin to community
    final isPostDeleted = widget.post.status.deleted; // Deleted by the user
    final isPostRemoved = widget.post.status.removed; // Removed by a moderator

    if (widget.account.anonymous) {
      userActions = userActions.where((action) => action.requiresAuthentication == false).toList();
    } else {
      if (widget.account.username == widget.post.creator?.name && widget.account.instance == fetchInstanceNameFromUrl(widget.post.creator?.actorId)) {
        userActions = userActions.where((action) => action != PostPostAction.reportPost).toList();
      } else {
        userActions = userActions.where((action) => action != PostPostAction.editPost && action != PostPostAction.deletePost && action != PostPostAction.restorePost).toList();
      }

      if (isPostDeleted) {
        userActions = userActions.where((action) => action != PostPostAction.deletePost).toList();
      } else {
        userActions = userActions.where((action) => action != PostPostAction.restorePost).toList();
      }

      if (isPostRemoved) {
        moderatorActions = moderatorActions.where((action) => action != PostPostAction.removePost).toList();
      } else {
        moderatorActions = moderatorActions.where((action) => action != PostPostAction.restorePostAsModerator).toList();
      }

      if (isPostLocked) {
        moderatorActions = moderatorActions.where((action) => action != PostPostAction.lockPost).toList();
      } else {
        moderatorActions = moderatorActions.where((action) => action != PostPostAction.unlockPost).toList();
      }

      if (isPostPinnedToCommunity) {
        moderatorActions = moderatorActions.where((action) => action != PostPostAction.pinPostToCommunity).toList();
      } else {
        moderatorActions = moderatorActions.where((action) => action != PostPostAction.unpinPostFromCommunity).toList();
      }
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...userActions.map<Widget>((postPostAction) => ThunderBottomSheetAction(leading: Icon(postPostAction.icon), title: postPostAction.name, onTap: () => performAction(postPostAction))),
        if (isModerator && moderatorActions.isNotEmpty) ...[
          const ThunderDivider(sliver: false, padding: false),
          ...moderatorActions.map<Widget>(
            (postPostAction) => ThunderBottomSheetAction(
              leading: Icon(postPostAction.icon),
              trailing: Padding(
                padding: const EdgeInsets.only(left: 1),
                child: Icon(ThunderIcon.shield, size: 20, color: Color.alphaBlend(theme.colorScheme.primary.withValues(alpha: 0.4), Colors.green)),
              ),
              title: postPostAction.name,
              onTap: () => performAction(postPostAction),
            ),
          ),
        ],
      ],
    );
  }
}
