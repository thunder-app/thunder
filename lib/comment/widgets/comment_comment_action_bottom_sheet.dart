import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lemmy_api_client/v3.dart';

import 'package:thunder/comment/enums/comment_action.dart';
import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/modlog/utils/navigate_modlog.dart';
import 'package:thunder/post/enums/post_action.dart';
import 'package:thunder/shared/bottom_sheet_action.dart';
import 'package:thunder/shared/dialogs.dart';
import 'package:thunder/shared/divider.dart';
import 'package:thunder/shared/text/selectable_text_modal.dart';
import 'package:thunder/thunder/thunder_icons.dart';
import 'package:thunder/utils/global_context.dart';

/// Defines the actions that can be taken on a comment
/// TODO: Implement admin-level actions
enum CommentBottomSheetAction {
  selectCommentText(icon: Icons.select_all_rounded, permissionType: PermissionType.all, requiresAuthentication: false),
  viewCommentSource(icon: Icons.code_rounded, permissionType: PermissionType.all, requiresAuthentication: false),
  viewCommentMarkdown(icon: Icons.code_rounded, permissionType: PermissionType.all, requiresAuthentication: false),
  viewModlog(icon: Icons.history_rounded, permissionType: PermissionType.all, requiresAuthentication: true),
  reportComment(icon: Icons.flag_rounded, permissionType: PermissionType.user, requiresAuthentication: true),
  editComment(icon: Icons.edit_rounded, permissionType: PermissionType.user, requiresAuthentication: true),
  deleteComment(icon: Icons.delete_rounded, permissionType: PermissionType.user, requiresAuthentication: true),
  restoreComment(icon: Icons.restore_rounded, permissionType: PermissionType.user, requiresAuthentication: true),
  removeComment(icon: Icons.delete_rounded, permissionType: PermissionType.moderator, requiresAuthentication: true),
  restoreCommentAsModerator(icon: Icons.restore_rounded, permissionType: PermissionType.moderator, requiresAuthentication: true),
  ;

  String get name => switch (this) {
        CommentBottomSheetAction.selectCommentText => GlobalContext.l10n.selectText,
        CommentBottomSheetAction.viewCommentSource => GlobalContext.l10n.viewCommentSource,
        CommentBottomSheetAction.viewCommentMarkdown => GlobalContext.l10n.viewOriginal,
        CommentBottomSheetAction.viewModlog => GlobalContext.l10n.viewModlog,
        CommentBottomSheetAction.reportComment => GlobalContext.l10n.reportComment,
        CommentBottomSheetAction.editComment => GlobalContext.l10n.editComment,
        CommentBottomSheetAction.deleteComment => GlobalContext.l10n.deleteComment,
        CommentBottomSheetAction.restoreComment => GlobalContext.l10n.restoreComment,
        CommentBottomSheetAction.removeComment => GlobalContext.l10n.removeComment,
        CommentBottomSheetAction.restoreCommentAsModerator => GlobalContext.l10n.restoreComment,
      };

  /// The icon to use for the action
  final IconData icon;

  /// The permission type to use for the action
  final PermissionType permissionType;

  /// Whether or not the action requires user authentication
  final bool requiresAuthentication;

  const CommentBottomSheetAction({required this.icon, required this.permissionType, required this.requiresAuthentication});
}

/// A bottom sheet that allows the user to perform actions on the comment.
///
/// Given a [commentView] and a [onAction] callback, this widget will display a list of actions that can be taken on the comment.
/// The [onAction] callback will be triggered when an action is performed.
class CommentCommentActionBottomSheet extends StatefulWidget {
  const CommentCommentActionBottomSheet({super.key, required this.context, required this.commentView, this.isShowingSource = false, required this.onAction});

  /// The outer context
  final BuildContext context;

  /// The comment information
  final CommentView commentView;

  /// Whether the source of the comment is being shown
  final bool isShowingSource;

  /// Called when an action is selected
  final Function(CommentAction commentAction, CommentView? commentView, dynamic value) onAction;

  @override
  State<CommentCommentActionBottomSheet> createState() => _CommentCommentActionBottomSheetState();
}

class _CommentCommentActionBottomSheetState extends State<CommentCommentActionBottomSheet> {
  void performAction(CommentBottomSheetAction action) async {
    final commentView = widget.commentView;

    switch (action) {
      case CommentBottomSheetAction.selectCommentText:
        Navigator.of(context).pop();
        showSelectableTextModal(context, text: commentView.comment.content);
        return;
      case CommentBottomSheetAction.viewCommentSource:
      case CommentBottomSheetAction.viewCommentMarkdown:
        widget.onAction(CommentAction.viewSource, commentView, null);
        break;
      case CommentBottomSheetAction.viewModlog:
        Navigator.of(context).pop();
        await navigateToModlogPage(
          context,
          subtitle: Text(GlobalContext.l10n.removedComment),
          modlogActionType: ModlogActionType.modRemoveComment,
          commentId: widget.commentView.comment.id,
        );
        return;
      case CommentBottomSheetAction.reportComment:
        showReportCommentDialog();
        return;
      case CommentBottomSheetAction.editComment:
        Navigator.of(context).pop();
        widget.onAction(CommentAction.edit, commentView, null);
        return;
      case CommentBottomSheetAction.deleteComment:
        widget.onAction(CommentAction.delete, commentView, true);
        break;
      case CommentBottomSheetAction.restoreComment:
        widget.onAction(CommentAction.delete, commentView, false);
        break;
      case CommentBottomSheetAction.removeComment:
        // TODO: Implement remove comment
        break;
      case CommentBottomSheetAction.restoreCommentAsModerator:
        // TODO: Implement restore comment as moderator
        break;
    }

    Navigator.of(context).pop();
  }

  void showReportCommentDialog() {
    Navigator.of(context).pop();
    final TextEditingController messageController = TextEditingController();

    showThunderDialog(
      context: widget.context,
      title: GlobalContext.l10n.reportComment,
      primaryButtonText: GlobalContext.l10n.report(1),
      onPrimaryButtonPressed: (dialogContext, setPrimaryButtonEnabled) {
        widget.onAction(CommentAction.report, widget.commentView, messageController.text);
        Navigator.of(dialogContext).pop();
      },
      secondaryButtonText: GlobalContext.l10n.cancel,
      onSecondaryButtonPressed: (context) => Navigator.of(context).pop(),
      contentWidgetBuilder: (_) => TextFormField(
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: GlobalContext.l10n.message(0),
        ),
        autofocus: true,
        controller: messageController,
        maxLines: 4,
      ),
    );
  }

  // void showRemovePostReasonDialog() {
  //   Navigator.of(context).pop();
  //   final TextEditingController messageController = TextEditingController();

  //   showThunderDialog(
  //     context: widget.context,
  //     title: widget.postViewMedia.postView.post.removed ?GlobalContext.l10n.restorePost :GlobalContext.l10n.removalReason,
  //     primaryButtonText: widget.postViewMedia.postView.post.removed ?GlobalContext.l10n.restore :GlobalContext.l10n.remove,
  //     onPrimaryButtonPressed: (dialogContext, setPrimaryButtonEnabled) {
  //       widget.context.read<FeedBloc>().add(
  //             FeedItemActionedEvent(
  //               postAction: PostAction.remove,
  //               postId: widget.postViewMedia.postView.post.id,
  //               value: {
  //                 'remove': !widget.postViewMedia.postView.post.removed,
  //                 'reason': messageController.text,
  //               },
  //             ),
  //           );
  //       Navigator.of(dialogContext).pop();
  //     },
  //     secondaryButtonText:GlobalContext.l10n.cancel,
  //     onSecondaryButtonPressed: (context) => Navigator.of(context).pop(),
  //     contentWidgetBuilder: (_) => TextFormField(
  //       decoration: InputDecoration(
  //         border: const OutlineInputBorder(),
  //         labelText:GlobalContext.l10n.message(0),
  //       ),
  //       autofocus: true,
  //       controller: messageController,
  //       maxLines: 4,
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = context.read<AuthBloc>().state;

    List<CommentBottomSheetAction> generalActions = CommentBottomSheetAction.values.where((element) => element.permissionType == PermissionType.all).toList();
    List<CommentBottomSheetAction> userActions = CommentBottomSheetAction.values.where((element) => element.permissionType == PermissionType.user).toList();
    List<CommentBottomSheetAction> moderatorActions = CommentBottomSheetAction.values.where((element) => element.permissionType == PermissionType.moderator).toList();
    // List<CommentBottomSheetAction> adminActions = CommentBottomSheetAction.values.where((element) => element.permissionType == PermissionType.admin).toList();

    final account = authState.getSiteResponse?.myUser?.localUserView.person;
    final moderatedCommunities = authState.getSiteResponse?.myUser?.moderates ?? [];
    final isModerator = moderatedCommunities.where((communityModeratorView) => communityModeratorView.community.actorId == widget.commentView.community.actorId).isNotEmpty;
    // final isAdmin = authState.getSiteResponse?.admins.where((personView) => personView.person.actorId == account?.actorId).isNotEmpty ?? false;

    final isLoggedIn = authState.isLoggedIn;
    final isCommentDeleted = widget.commentView.comment.deleted; // Deleted by the user
    final isCommentRemoved = widget.commentView.comment.removed; // Removed by a moderator

    if (!isLoggedIn) {
      userActions = userActions.where((action) => action.requiresAuthentication == false).toList();
    } else {
      if (account?.actorId == widget.commentView.creator.actorId) {
        userActions = userActions.where((action) => action != CommentBottomSheetAction.reportComment).toList();
      } else {
        userActions = userActions
            .where((action) => action != CommentBottomSheetAction.editComment && action != CommentBottomSheetAction.deleteComment && action != CommentBottomSheetAction.restoreComment)
            .toList();
      }

      if (isCommentDeleted) {
        userActions = userActions.where((action) => action != CommentBottomSheetAction.deleteComment).toList();
      } else {
        userActions = userActions.where((action) => action != CommentBottomSheetAction.restoreComment).toList();
      }

      if (isCommentRemoved) {
        moderatorActions = moderatorActions.where((action) => action != CommentBottomSheetAction.removeComment).toList();
      } else {
        generalActions = generalActions.where((action) => action != CommentBottomSheetAction.viewModlog).toList();
        moderatorActions = moderatorActions.where((action) => action != CommentBottomSheetAction.restoreCommentAsModerator).toList();
      }
    }

    if (widget.isShowingSource) {
      generalActions = generalActions.where((action) => action != CommentBottomSheetAction.viewCommentSource).toList();
    } else {
      generalActions = generalActions.where((action) => action != CommentBottomSheetAction.viewCommentMarkdown).toList();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...generalActions
            .map(
              (postPostAction) => BottomSheetAction(
                leading: Icon(postPostAction.icon),
                title: postPostAction.name,
                onTap: () => performAction(postPostAction),
              ),
            )
            .toList() as List<Widget>,
        if (userActions.isNotEmpty) ...[
          const ThunderDivider(sliver: false, padding: false),
          ...userActions
              .map(
                (postPostAction) => BottomSheetAction(
                  leading: Icon(postPostAction.icon),
                  title: postPostAction.name,
                  onTap: () => performAction(postPostAction),
                ),
              )
              .toList() as List<Widget>
        ],
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
                      color: Color.alphaBlend(theme.colorScheme.primary.withValues(alpha: 0.4), Colors.green),
                    ),
                  ),
                  title: postPostAction.name,
                  onTap: () => performAction(postPostAction),
                ),
              )
              .toList() as List<Widget>,
        ],
        // if (isAdmin && adminActions.isNotEmpty) ...[
        //   const ThunderDivider(sliver: false, padding: false),
        //   ...adminActions
        //       .map(
        //         (postPostAction) => BottomSheetAction(
        //           leading: Icon(postPostAction.icon),
        //           trailing: Padding(
        //             padding: const EdgeInsets.only(left: 1),
        //             child: Icon(
        //               Thunder.shield_crown,
        //               size: 20,
        //               color: Color.alphaBlend(theme.colorScheme.primary.withValues(alpha: 0.4), Colors.red),
        //             ),
        //           ),
        //           title: postPostAction.name,
        //           onTap: () => performAction(postPostAction),
        //         ),
        //       )
        //       .toList() as List<Widget>,
        // ],
      ],
    );
  }
}
