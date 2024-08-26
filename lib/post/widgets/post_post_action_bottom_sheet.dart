import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/core/models/post_view_media.dart';
import 'package:thunder/feed/bloc/feed_bloc.dart';
import 'package:thunder/post/enums/post_action.dart';
import 'package:thunder/post/utils/comment_action_helpers.dart';
import 'package:thunder/shared/bottom_sheet_action.dart';
import 'package:thunder/shared/dialogs.dart';
import 'package:thunder/shared/divider.dart';
import 'package:thunder/thunder/thunder_icons.dart';

/// Defines the actions that can be taken on a user
/// TODO: Implement admin-level actions
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
  unpinPostFromCommunity(icon: Icons.pin, permissionType: PermissionType.moderator, requiresAuthentication: true),
  // pinPostToInstance(icon: Icons.pin, permissionType: PermissionType.admin, requiresAuthentication: true),
  // unpinPostFromInstance(icon: Icons.pin, permissionType: PermissionType.admin, requiresAuthentication: true),
  ;

  String get name => switch (this) {
        PostPostAction.reportPost => "Report Post",
        PostPostAction.editPost => l10n.editPost,
        PostPostAction.deletePost => "Delete Post",
        PostPostAction.restorePost => l10n.restorePost,
        PostPostAction.lockPost => l10n.lockPost,
        PostPostAction.unlockPost => l10n.unlockPost,
        PostPostAction.removePost => l10n.removePost,
        PostPostAction.restorePostAsModerator => "Restore Post",
        PostPostAction.pinPostToCommunity => "Pin Post To Community",
        PostPostAction.unpinPostFromCommunity => "Unpin Post From Community",
        // PostPostAction.pinPostToInstance => "Pin Post To Instance",
        // PostPostAction.unpinPostFromInstance => "Unpin Post From Instance",
      };

  /// The icon to use for the action
  final IconData icon;

  /// The permission type to use for the action
  final PermissionType permissionType;

  /// Whether or not the action requires user authentication
  final bool requiresAuthentication;

  const PostPostAction({required this.icon, required this.permissionType, required this.requiresAuthentication});
}

/// A bottom sheet that allows the user to perform actions on the post.
///
/// Given a [postViewMedia] and a [onAction] callback, this widget will display a list of actions that can be taken on the post.
/// The [onAction] callback will be triggered when an action is performed.
class PostPostActionBottomSheet extends StatefulWidget {
  const PostPostActionBottomSheet({super.key, required this.context, required this.postViewMedia, required this.onAction});

  /// The outer context
  final BuildContext context;

  /// The post information
  final PostViewMedia postViewMedia;

  /// Called when an action is selected
  final Function() onAction;

  @override
  State<PostPostActionBottomSheet> createState() => _PostPostActionBottomSheetState();
}

class _PostPostActionBottomSheetState extends State<PostPostActionBottomSheet> {
  void performAction(PostPostAction action) {
    final postViewMedia = widget.postViewMedia;

    switch (action) {
      case PostPostAction.reportPost:
        showReportPostDialog();
        return;
      case PostPostAction.editPost:
        context.pop();
        return;
      case PostPostAction.deletePost:
        context.pop();
        widget.context.read<FeedBloc>().add(FeedItemActionedEvent(postAction: PostAction.delete, postId: postViewMedia.postView.post.id, value: true));
        break;
      case PostPostAction.restorePost:
        context.pop();
        widget.context.read<FeedBloc>().add(FeedItemActionedEvent(postAction: PostAction.delete, postId: postViewMedia.postView.post.id, value: false));
        break;
      case PostPostAction.lockPost:
        context.pop();
        widget.context.read<FeedBloc>().add(FeedItemActionedEvent(postAction: PostAction.lock, postId: postViewMedia.postView.post.id, value: true));
        break;
      case PostPostAction.unlockPost:
        context.pop();
        widget.context.read<FeedBloc>().add(FeedItemActionedEvent(postAction: PostAction.lock, postId: postViewMedia.postView.post.id, value: false));
        break;
      case PostPostAction.removePost:
        showRemovePostReasonDialog();
        break;
      case PostPostAction.restorePostAsModerator:
        showRemovePostReasonDialog();
        break;
      case PostPostAction.pinPostToCommunity:
        context.pop();
        widget.context.read<FeedBloc>().add(FeedItemActionedEvent(postAction: PostAction.pinCommunity, postId: postViewMedia.postView.post.id, value: true));
        break;
      case PostPostAction.unpinPostFromCommunity:
        context.pop();
        widget.context.read<FeedBloc>().add(FeedItemActionedEvent(postAction: PostAction.pinCommunity, postId: postViewMedia.postView.post.id, value: false));
        break;
      // case PostPostAction.pinPostToInstance:
      //   context.pop();
      //   return;
      // case PostPostAction.unpinPostFromInstance:
      //   context.pop();
      //   return;
    }
  }

  void showReportPostDialog() {
    context.pop();
    final TextEditingController messageController = TextEditingController();

    showThunderDialog(
      context: widget.context,
      title: "Report Post",
      primaryButtonText: "Report",
      onPrimaryButtonPressed: (dialogContext, setPrimaryButtonEnabled) {
        widget.context.read<FeedBloc>().add(
              FeedItemActionedEvent(
                postAction: PostAction.report,
                postId: widget.postViewMedia.postView.post.id,
                value: messageController.text,
              ),
            );
        dialogContext.pop();
      },
      secondaryButtonText: l10n.cancel,
      onSecondaryButtonPressed: (context) => context.pop(),
      contentWidgetBuilder: (_) => TextFormField(
        decoration: InputDecoration(
          isDense: true,
          border: const OutlineInputBorder(),
          labelText: l10n.message(0),
        ),
        autofocus: true,
        controller: messageController,
        maxLines: 4,
      ),
    );
  }

  void showRemovePostReasonDialog() {
    context.pop();
    final TextEditingController messageController = TextEditingController();

    showThunderDialog(
      context: widget.context,
      title: widget.postViewMedia.postView.post.removed ? l10n.restorePost : l10n.removalReason,
      primaryButtonText: widget.postViewMedia.postView.post.removed ? l10n.restore : l10n.remove,
      onPrimaryButtonPressed: (dialogContext, setPrimaryButtonEnabled) {
        widget.context.read<FeedBloc>().add(
              FeedItemActionedEvent(
                postAction: PostAction.remove,
                postId: widget.postViewMedia.postView.post.id,
                value: {
                  'remove': !widget.postViewMedia.postView.post.removed,
                  'reason': messageController.text,
                },
              ),
            );
        dialogContext.pop();
      },
      secondaryButtonText: l10n.cancel,
      onSecondaryButtonPressed: (context) => context.pop(),
      contentWidgetBuilder: (_) => TextFormField(
        decoration: InputDecoration(
          isDense: true,
          border: const OutlineInputBorder(),
          labelText: l10n.message(0),
        ),
        autofocus: true,
        controller: messageController,
        maxLines: 4,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = context.read<AuthBloc>().state;

    List<PostPostAction> userActions = PostPostAction.values.where((element) => element.permissionType == PermissionType.user).toList();
    List<PostPostAction> moderatorActions = PostPostAction.values.where((element) => element.permissionType == PermissionType.moderator).toList();
    List<PostPostAction> adminActions = PostPostAction.values.where((element) => element.permissionType == PermissionType.admin).toList();

    final account = authState.getSiteResponse?.myUser?.localUserView.person;
    final isModerator =
        authState.getSiteResponse?.myUser?.moderates.where((communityModeratorView) => communityModeratorView.community.actorId == widget.postViewMedia.postView.community.actorId).isNotEmpty ?? false;
    final isAdmin = authState.getSiteResponse?.admins.where((personView) => personView.person.actorId == account?.actorId).isNotEmpty ?? false;

    final isLoggedIn = authState.isLoggedIn;
    final isPostLocked = widget.postViewMedia.postView.post.locked;
    final isPostPinnedToCommunity = widget.postViewMedia.postView.post.featuredCommunity; // Pin to community
    final isPostPinnedToInstance = widget.postViewMedia.postView.post.featuredLocal; // Pin to instance
    final isPostDeleted = widget.postViewMedia.postView.post.deleted; // Deleted by the user
    final isPostRemoved = widget.postViewMedia.postView.post.removed; // Removed by a moderator

    if (!isLoggedIn) {
      userActions = userActions.where((action) => action.requiresAuthentication == false).toList();
    } else {
      if (account?.actorId == widget.postViewMedia.postView.creator.actorId) {
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

      // if (isPostPinnedToInstance) {
      //   adminActions = adminActions.where((action) => action != PostPostAction.pinPostToInstance).toList();
      // } else {
      //   adminActions = adminActions.where((action) => action != PostPostAction.unpinPostFromInstance).toList();
      // }
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...userActions
            .map(
              (postPostAction) => BottomSheetAction(
                leading: Icon(postPostAction.icon),
                title: postPostAction.name,
                onTap: () => performAction(postPostAction),
              ),
            )
            .toList() as List<Widget>,
        if (isModerator && moderatorActions.isNotEmpty) ...[
          const ThunderDivider(sliver: false, padding: false),
          ...moderatorActions
              .map(
                (postPostAction) => BottomSheetAction(
                  leading: Icon(postPostAction.icon),
                  trailing: Padding(
                    padding: const EdgeInsets.only(left: 1),
                    child: Icon(
                      Thunder.shield,
                      size: 20,
                      color: Color.alphaBlend(theme.colorScheme.primary.withOpacity(0.4), Colors.green),
                    ),
                  ),
                  title: postPostAction.name,
                  onTap: () => performAction(postPostAction),
                ),
              )
              .toList() as List<Widget>,
        ],
        if (isAdmin && adminActions.isNotEmpty) ...[
          const ThunderDivider(sliver: false, padding: false),
          ...adminActions
              .map(
                (postPostAction) => BottomSheetAction(
                  leading: Icon(postPostAction.icon),
                  trailing: Padding(
                    padding: const EdgeInsets.only(left: 1),
                    child: Icon(
                      Thunder.shield_crown,
                      size: 20,
                      color: Color.alphaBlend(theme.colorScheme.primary.withOpacity(0.4), Colors.red),
                    ),
                  ),
                  title: postPostAction.name,
                  onTap: () => performAction(postPostAction),
                ),
              )
              .toList() as List<Widget>,
        ],
      ],
    );
  }
}
