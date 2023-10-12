import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:share_plus/share_plus.dart';
import 'package:thunder/post/bloc/post_bloc.dart';
import 'package:thunder/post/widgets/report_comment_dialog.dart';
import 'package:thunder/shared/multi_picker_item.dart';
import 'package:thunder/shared/picker_item.dart';
import 'package:thunder/shared/snackbar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:thunder/utils/global_context.dart';

import '../../core/auth/bloc/auth_bloc.dart';

enum CommentCardAction {
  save,
  copyText,
  shareLink,
  delete,
  upvote,
  downvote,
  reply,
  edit,
  report,
}

class ExtendedCommentCardActions {
  const ExtendedCommentCardActions({
    required this.commentCardAction,
    required this.icon,
    required this.label,
    this.color,
    this.getForegroundColor,
    this.getOverrideIcon,
    this.shouldShow,
    this.shouldEnable,
  });

  final CommentCardAction commentCardAction;
  final IconData icon;
  final String label;
  final Color? color;
  final Color? Function(CommentView commentView)? getForegroundColor;
  final IconData? Function(CommentView commentView)? getOverrideIcon;
  final bool Function(BuildContext context, CommentView commentView)? shouldShow;
  final bool Function(bool isUserLoggedIn)? shouldEnable;
}

final List<ExtendedCommentCardActions> commentCardDefaultActionItems = [
  ExtendedCommentCardActions(
    commentCardAction: CommentCardAction.copyText,
    icon: Icons.copy_rounded,
    label: AppLocalizations.of(GlobalContext.context)!.copyText,
  ),
  ExtendedCommentCardActions(
    commentCardAction: CommentCardAction.shareLink,
    icon: Icons.share_rounded,
    label: AppLocalizations.of(GlobalContext.context)!.shareLink,
  ),
  ExtendedCommentCardActions(
    commentCardAction: CommentCardAction.report,
    icon: Icons.report_outlined,
    label: AppLocalizations.of(GlobalContext.context)!.reportComment,
  ),
];

final List<ExtendedCommentCardActions> commentCardDefaultMultiActionItems = [
  ExtendedCommentCardActions(
    commentCardAction: CommentCardAction.upvote,
    label: AppLocalizations.of(GlobalContext.context)!.upvote,
    icon: Icons.arrow_upward_rounded,
    color: Colors.orange,
    getForegroundColor: (commentView) => commentView.myVote == VoteType.up ? Colors.orange : null,
    shouldEnable: (isUserLoggedIn) => isUserLoggedIn,
  ),
  ExtendedCommentCardActions(
    commentCardAction: CommentCardAction.downvote,
    label: AppLocalizations.of(GlobalContext.context)!.downvote,
    icon: Icons.arrow_downward_rounded,
    color: Colors.blue,
    getForegroundColor: (commentView) => commentView.myVote == VoteType.down ? Colors.blue : null,
    shouldShow: (context, commentView) => context.read<AuthBloc>().state.downvotesEnabled,
    shouldEnable: (isUserLoggedIn) => isUserLoggedIn,
  ),
  ExtendedCommentCardActions(
    commentCardAction: CommentCardAction.save,
    label: AppLocalizations.of(GlobalContext.context)!.save,
    icon: Icons.star_border_rounded,
    color: Colors.purple,
    getForegroundColor: (commentView) => commentView.saved ? Colors.purple : null,
    getOverrideIcon: (commentView) => commentView.saved ? Icons.star_rounded : null,
    shouldEnable: (isUserLoggedIn) => isUserLoggedIn,
  ),
  ExtendedCommentCardActions(
    commentCardAction: CommentCardAction.reply,
    label: AppLocalizations.of(GlobalContext.context)!.reply(0),
    icon: Icons.reply_rounded,
    shouldEnable: (isUserLoggedIn) => isUserLoggedIn,
  ),
  ExtendedCommentCardActions(
    commentCardAction: CommentCardAction.edit,
    label: AppLocalizations.of(GlobalContext.context)!.edit,
    icon: Icons.edit,
    shouldShow: (context, commentView) => commentView.creator.id == context.read<AuthBloc>().state.account?.userId,
    shouldEnable: (isUserLoggedIn) => isUserLoggedIn,
  ),
];

void showCommentActionBottomModalSheet(
    BuildContext context, CommentView commentView, Function onSaveAction, Function onDeleteAction, Function onVoteAction, Function onReplyEditAction, Function onReportAction) {
  final theme = Theme.of(context);
  final bool isUserLoggedIn = context.read<AuthBloc>().state.isLoggedIn;
  List<ExtendedCommentCardActions> commentCardActionItems = _updateDefaultCommentActionItems(context, commentView);

  showModalBottomSheet<void>(
    showDragHandle: true,
    isScrollControlled: true,
    context: context,
    builder: (BuildContext bottomSheetContext) {
      return SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0, left: 26.0, right: 16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  AppLocalizations.of(context)!.actions,
                  style: theme.textTheme.titleLarge!.copyWith(),
                ),
              ),
            ),
            MultiPickerItem(
              pickerItems: [
                ...commentCardDefaultMultiActionItems.where((a) => a.shouldShow?.call(context, commentView) ?? true).map(
                  (a) {
                    return PickerItemData(
                      label: a.label,
                      icon: a.getOverrideIcon?.call(commentView) ?? a.icon,
                      backgroundColor: a.color,
                      foregroundColor: a.getForegroundColor?.call(commentView),
                      onSelected: (a.shouldEnable?.call(isUserLoggedIn) ?? true)
                          ? () => onSelected(
                                context,
                                a.commentCardAction,
                                commentView,
                                onSaveAction,
                                onDeleteAction,
                                onVoteAction,
                                onReplyEditAction,
                                onReportAction,
                              )
                          : null,
                    );
                  },
                ),
              ],
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: commentCardActionItems.length,
              itemBuilder: (BuildContext itemBuilderContext, int index) {
                return PickerItem(
                  label: commentCardActionItems[index].label,
                  icon: commentCardActionItems[index].icon,
                  onSelected: (commentCardActionItems[index].shouldEnable?.call(isUserLoggedIn) ?? true)
                      ? () => onSelected(
                            context,
                            commentCardActionItems[index].commentCardAction,
                            commentView,
                            onSaveAction,
                            onDeleteAction,
                            onVoteAction,
                            onReplyEditAction,
                            onReportAction,
                          )
                      : null,
                );
              },
            ),
            const SizedBox(height: 16.0),
          ],
        ),
      );
    },
  );
}

void onSelected(
  BuildContext context,
  CommentCardAction commentCardAction,
  CommentView commentView,
  Function onSaveAction,
  Function onDeleteAction,
  Function onUpvoteAction,
  Function onReplyEditAction,
  Function onReportAction,
) async {
  Navigator.of(context).pop();

  switch (commentCardAction) {
    case CommentCardAction.save:
      onSaveAction(commentView.comment.id, !(commentView.saved));
      break;
    case CommentCardAction.copyText:
      Clipboard.setData(ClipboardData(text: commentView.comment.content)).then((_) {
        showSnackbar(context, AppLocalizations.of(context)!.copiedToClipboard);
      });
      break;
    case CommentCardAction.shareLink:
      Share.share(commentView.comment.apId);
      break;
    case CommentCardAction.delete:
      onDeleteAction(commentView.comment.id, !(commentView.comment.deleted));
    case CommentCardAction.upvote:
      onUpvoteAction(commentView.comment.id, commentView.myVote == VoteType.up ? VoteType.none : VoteType.up);
      break;
    case CommentCardAction.downvote:
      onUpvoteAction(commentView.comment.id, commentView.myVote == VoteType.down ? VoteType.none : VoteType.down);
      break;
    case CommentCardAction.reply:
      onReplyEditAction(commentView, false);
      break;
    case CommentCardAction.edit:
      onReplyEditAction(commentView, true);
      break;
    case CommentCardAction.report:
      onReportAction(commentView.comment.id);
      break;
  }
}

List<ExtendedCommentCardActions> _updateDefaultCommentActionItems(BuildContext context, CommentView commentView) {
  final bool isOwnComment = commentView.creator.id == context.read<AuthBloc>().state.account?.userId;
  bool isDeleted = commentView.comment.deleted;
  List<ExtendedCommentCardActions> updatedList = [...commentCardDefaultActionItems];

  if (isOwnComment) {
    updatedList.add(ExtendedCommentCardActions(
      commentCardAction: CommentCardAction.delete,
      icon: isDeleted ? Icons.restore_from_trash_rounded : Icons.delete_rounded,
      label: isDeleted ? AppLocalizations.of(GlobalContext.context)!.restore : AppLocalizations.of(GlobalContext.context)!.delete,
    ));
  }
  return updatedList;
}

void showReportCommentActionBottomSheet(
  BuildContext context, {
  required int commentId,
}) {
  showModalBottomSheet(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (_) => BlocProvider.value(
      value: context.read<PostBloc>(),
      child: ReportCommentDialog(
        commentId: commentId,
      ),
    ),
  );
}
