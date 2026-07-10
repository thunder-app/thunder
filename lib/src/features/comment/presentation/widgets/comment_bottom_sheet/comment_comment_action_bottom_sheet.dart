import 'package:flutter/material.dart';

import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/features/comment/comment.dart';
import 'package:thunder/src/features/community/community.dart';
import 'package:thunder/src/features/modlog/modlog.dart';
import 'package:thunder/src/features/post/post.dart';
import 'package:thunder/src/shared/text/selectable_text_modal.dart';
import 'package:thunder/src/core/config/global_context.dart';
import 'package:thunder/src/features/instance/domain/utils/instance_link_utils.dart';
import 'package:thunder/src/core/navigation/navigation_utils.dart';
import 'package:thunder/packages/ui/ui.dart';
import 'package:thunder/src/core/app/repository_factories.dart';

/// Defines the actions that can be taken on a comment
enum CommentBottomSheetAction {
  selectCommentText(
    icon: Icons.select_all_rounded,
    permissionType: PermissionType.all,
    requiresAuthentication: false,
  ),
  viewCommentSource(
    icon: Icons.code_rounded,
    permissionType: PermissionType.all,
    requiresAuthentication: false,
  ),
  viewCommentMarkdown(
    icon: Icons.code_rounded,
    permissionType: PermissionType.all,
    requiresAuthentication: false,
  ),
  viewModlog(
    icon: Icons.history_rounded,
    permissionType: PermissionType.all,
    requiresAuthentication: true,
  ),
  reportComment(
    icon: Icons.flag_rounded,
    permissionType: PermissionType.user,
    requiresAuthentication: true,
  ),
  editComment(
    icon: Icons.edit_rounded,
    permissionType: PermissionType.user,
    requiresAuthentication: true,
  ),
  deleteComment(
    icon: Icons.delete_rounded,
    permissionType: PermissionType.user,
    requiresAuthentication: true,
  ),
  restoreComment(
    icon: Icons.restore_rounded,
    permissionType: PermissionType.user,
    requiresAuthentication: true,
  );

  String get name {
    final l10n = GlobalContext.l10n;

    return switch (this) {
      CommentBottomSheetAction.selectCommentText => l10n.selectText,
      CommentBottomSheetAction.viewCommentSource => l10n.viewCommentSource,
      CommentBottomSheetAction.viewCommentMarkdown => l10n.viewOriginal,
      CommentBottomSheetAction.viewModlog => l10n.viewModlog,
      CommentBottomSheetAction.reportComment => l10n.reportComment,
      CommentBottomSheetAction.editComment => l10n.editComment,
      CommentBottomSheetAction.deleteComment => l10n.deleteComment,
      CommentBottomSheetAction.restoreComment => l10n.restoreComment,
    };
  }

  /// The icon to use for the action
  final IconData icon;

  /// The permission type to use for the action
  final PermissionType permissionType;

  /// Whether or not the action requires user authentication
  final bool requiresAuthentication;

  const CommentBottomSheetAction({required this.icon, required this.permissionType, required this.requiresAuthentication});
}

/// A bottom sheet that allows the user to perform actions on the comment.
class CommentCommentActionBottomSheet extends StatefulWidget {
  const CommentCommentActionBottomSheet({
    super.key,
    required this.context,
    required this.account,
    required this.moderatedCommunities,
    required this.comment,
    this.isShowingSource = false,
    required this.onAction,
  });

  /// The outer context
  final BuildContext context;

  /// The account that is performing the action
  final Account account;

  /// List of moderated communities
  final List<ThunderCommunity> moderatedCommunities;

  /// The comment information
  final ThunderComment comment;

  /// Whether the source of the comment is being shown
  final bool isShowingSource;

  /// Called when an action is selected
  final Function(CommentAction commentAction, ThunderComment comment) onAction;

  @override
  State<CommentCommentActionBottomSheet> createState() => _CommentCommentActionBottomSheetState();
}

class _CommentCommentActionBottomSheetState extends State<CommentCommentActionBottomSheet> {
  void performAction(CommentBottomSheetAction action) async {
    final l10n = GlobalContext.l10n;
    final repository = createCommentRepository(widget.account);

    switch (action) {
      case CommentBottomSheetAction.selectCommentText:
        Navigator.of(context).pop();
        showSelectableTextModal(widget.context, text: widget.comment.content);
        return;
      case CommentBottomSheetAction.viewCommentSource:
      case CommentBottomSheetAction.viewCommentMarkdown:
        Navigator.of(context).pop();

        widget.onAction(CommentAction.viewSource, widget.comment);
        break;
      case CommentBottomSheetAction.viewModlog:
        Navigator.of(context).pop();
        await navigateToModlogPage(widget.context, account: widget.account, subtitle: l10n.removedComment, modlogActionType: ModlogActionType.modRemoveComment, commentId: widget.comment.id);
        return;
      case CommentBottomSheetAction.reportComment:
        showReportCommentDialog();
        return;
      case CommentBottomSheetAction.editComment:
        Navigator.of(context).pop();
        widget.onAction(CommentAction.edit, widget.comment);
        return;
      case CommentBottomSheetAction.deleteComment:
        Navigator.of(context).pop();
        final updatedComment = await repository.delete(widget.comment, true);
        if (updatedComment.status.deleted) showThunderSnackbar(l10n.deletedComment);
        widget.onAction(CommentAction.delete, widget.comment.copyWith(status: widget.comment.status.copyWith(deleted: true)));
        break;
      case CommentBottomSheetAction.restoreComment:
        Navigator.of(context).pop();
        final updatedComment = await repository.delete(widget.comment, false);
        if (!updatedComment.status.deleted) showThunderSnackbar(l10n.restoredComment);
        widget.onAction(CommentAction.delete, widget.comment.copyWith(status: widget.comment.status.copyWith(deleted: false)));
        break;
    }
  }

  void showReportCommentDialog() {
    Navigator.of(context).pop();
    final l10n = GlobalContext.l10n;
    final controller = TextEditingController();

    showThunderDialog(
      context: widget.context,
      title: l10n.reportComment,
      primaryButtonText: l10n.report(1),
      onPrimaryButtonPressed: (dialogContext, setPrimaryButtonEnabled) async {
        final repository = createCommentRepository(widget.account);

        await repository.report(widget.comment.id, controller.text);
        showThunderSnackbar(l10n.reportedComment);
        widget.onAction(CommentAction.report, widget.comment);

        Navigator.of(dialogContext).pop();
      },
      secondaryButtonText: l10n.cancel,
      onSecondaryButtonPressed: (context) => Navigator.of(context).pop(),
      contentWidgetBuilder: (_) => TextFormField(
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: l10n.message(0),
        ),
        autofocus: true,
        controller: controller,
        maxLines: 4,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    List<CommentBottomSheetAction> userActions =
        CommentBottomSheetAction.values.where((element) => element.permissionType == PermissionType.user || element.permissionType == PermissionType.all).toList();
    List<CommentBottomSheetAction> moderatorActions = CommentBottomSheetAction.values.where((element) => element.permissionType == PermissionType.moderator).toList();

    final isModerator = widget.moderatedCommunities.where((c) => c.actorId == widget.comment.community?.actorId).isNotEmpty;

    final isCommentDeleted = widget.comment.status.deleted;
    final isCommentRemoved = widget.comment.status.removed;

    if (widget.account.anonymous) {
      userActions = userActions.where((action) => action.requiresAuthentication == false).toList();
    } else {
      if (widget.account.username == widget.comment.creator?.name && widget.account.instance == fetchInstanceNameFromUrl(widget.comment.creator?.actorId)) {
        userActions = userActions.where((action) => action != CommentBottomSheetAction.reportComment).toList();
      } else {
        userActions = userActions.where((action) => action != CommentBottomSheetAction.editComment).toList();
        userActions = userActions.where((action) => action != CommentBottomSheetAction.deleteComment).toList();
        userActions = userActions.where((action) => action != CommentBottomSheetAction.restoreComment).toList();
      }

      if (isCommentDeleted) {
        userActions = userActions.where((action) => action != CommentBottomSheetAction.deleteComment).toList();
      } else {
        userActions = userActions.where((action) => action != CommentBottomSheetAction.restoreComment).toList();
      }

      if (!isCommentRemoved) {
        userActions = userActions.where((action) => action != CommentBottomSheetAction.viewModlog).toList();
      }
    }

    if (widget.isShowingSource) {
      userActions = userActions.where((action) => action != CommentBottomSheetAction.viewCommentSource).toList();
    } else {
      userActions = userActions.where((action) => action != CommentBottomSheetAction.viewCommentMarkdown).toList();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...userActions.map<Widget>(
          (commentBottomSheetAction) => ThunderBottomSheetAction(
            leading: Icon(commentBottomSheetAction.icon),
            title: commentBottomSheetAction.name,
            onTap: () => performAction(commentBottomSheetAction),
          ),
        ),
        if (isModerator && moderatorActions.isNotEmpty) ...[
          const ThunderDivider(sliver: false, padding: false),
          ...moderatorActions.map<Widget>(
            (commentBottomSheetAction) => ThunderBottomSheetAction(
              leading: Icon(commentBottomSheetAction.icon),
              trailing: Padding(
                padding: const EdgeInsets.only(left: 1),
                child: Icon(
                  ThunderIcon.shield,
                  size: 20,
                  color: Color.alphaBlend(theme.colorScheme.primary.withValues(alpha: 0.4), Colors.green),
                ),
              ),
              title: commentBottomSheetAction.name,
              onTap: () => performAction(commentBottomSheetAction),
            ),
          ),
        ],
      ],
    );
  }
}
