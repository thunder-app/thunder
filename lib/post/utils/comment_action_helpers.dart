import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:share_plus/share_plus.dart';
import 'package:thunder/shared/picker_item.dart';
import 'package:thunder/shared/snackbar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../core/auth/bloc/auth_bloc.dart';
import '../../core/models/comment_view_tree.dart';

enum CommentCardAction { save, copyText, shareLink, delete }

class ExtendedCommentCardActions {
  const ExtendedCommentCardActions({required this.commentCardAction, required this.icon, required this.label});

  final CommentCardAction commentCardAction;
  final IconData icon;
  final String label;
}

const commentCardDefaultActionItems = [
  ExtendedCommentCardActions(
    commentCardAction: CommentCardAction.save,
    icon: Icons.star_rounded,
    label: 'Save',
  ),
  ExtendedCommentCardActions(
    commentCardAction: CommentCardAction.copyText,
    icon: Icons.copy_rounded,
    label: 'Copy Text',
  ),
  ExtendedCommentCardActions(
    commentCardAction: CommentCardAction.shareLink,
    icon: Icons.share_rounded,
    label: 'Share Link',
  ),
];

void showCommentActionBottomModalSheet(BuildContext context, CommentView commentView, Function onSaveAction, Function onDeleteAction) {
  final theme = Theme.of(context);
  List<ExtendedCommentCardActions> commentCardActionItems = _updateDefaultCommentActionItems(context, commentView);

  showModalBottomSheet<void>(
    showDragHandle: true,
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
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: commentCardActionItems.length,
              itemBuilder: (BuildContext itemBuilderContext, int index) {
                return PickerItem(
                  label: commentCardActionItems[index].label,
                  icon: commentCardActionItems[index].icon,
                  onSelected: () async {
                    Navigator.of(context).pop();

                    CommentCardAction commentCardAction = commentCardActionItems[index].commentCardAction;

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
                    }
                  },
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

List<ExtendedCommentCardActions> _updateDefaultCommentActionItems(BuildContext context, CommentView commentView) {
  final bool isOwnComment = commentView.creator.id == context.read<AuthBloc>().state.account?.userId;
  bool isDeleted = commentView.comment.deleted;
  List<ExtendedCommentCardActions> updatedList = [...commentCardDefaultActionItems];

  if (isOwnComment) {
    updatedList.add(ExtendedCommentCardActions(
      commentCardAction: CommentCardAction.delete,
      icon: isDeleted ? Icons.restore_from_trash_rounded : Icons.delete_rounded,
      label: isDeleted ? 'Restore' : 'Delete',
    ));
  }
  return updatedList;
}
