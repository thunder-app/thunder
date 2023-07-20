import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/auth/bloc/auth_bloc.dart';
import '../../core/models/comment_view_tree.dart';

enum CommentCardAction { save, copyText, shareLink, delete }

class ExtendedCommentCardActions {
  const ExtendedCommentCardActions(
      {required this.commentCardAction,
      required this.icon,
      required this.label});

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

void showCommentActionBottomModalSheet(
    BuildContext context,
    CommentViewTree commentViewTree,
    Function onSaveAction,
    Function onDeleteAction) {
  final theme = Theme.of(context);
  List<ExtendedCommentCardActions> commentCardActionItems =
      _updateDefaultCommentActionItems(context, commentViewTree);

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
              padding:
                  const EdgeInsets.only(bottom: 16.0, left: 16.0, right: 16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Actions',
                  style: theme.textTheme.titleLarge!.copyWith(),
                ),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: commentCardActionItems.length,
              itemBuilder: (BuildContext itemBuilderContext, int index) {
                return ListTile(
                  title: Text(
                    commentCardActionItems[index].label,
                    style: theme.textTheme.bodyMedium,
                  ),
                  leading: Icon(commentCardActionItems[index].icon),
                  onTap: () async {
                    Navigator.of(context).pop();

                    CommentCardAction commentCardAction =
                        commentCardActionItems[index].commentCardAction;

                    switch (commentCardAction) {
                      case CommentCardAction.save:
                        onSaveAction(commentViewTree.commentView!.comment.id,
                            !(commentViewTree.commentView!.saved));
                        break;
                      case CommentCardAction.copyText:
                        Clipboard.setData(ClipboardData(
                                text: commentViewTree
                                    .commentView!.comment.content))
                            .then((_) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("Copied to clipboard"),
                                  behavior: SnackBarBehavior.floating));
                        });
                        break;
                      case CommentCardAction.shareLink:
                        Share.share(commentViewTree.commentView!.comment.apId);
                        break;
                      case CommentCardAction.delete:
                        onDeleteAction(commentViewTree.commentView!.comment.id,
                            !(commentViewTree.commentView!.comment.deleted));
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

List<ExtendedCommentCardActions> _updateDefaultCommentActionItems(
    BuildContext context, CommentViewTree commentViewTree) {
  final bool isOwnComment = commentViewTree.commentView?.creator.id ==
      context.read<AuthBloc>().state.account?.userId;
  bool isDeleted = commentViewTree.commentView!.comment.deleted;
  List<ExtendedCommentCardActions> updatedList = [
    ...commentCardDefaultActionItems
  ];

  if (isOwnComment) {
    updatedList.add(ExtendedCommentCardActions(
      commentCardAction: CommentCardAction.delete,
      icon: isDeleted ? Icons.restore_from_trash_rounded : Icons.delete_rounded,
      label: isDeleted ? 'Restore' : 'Delete',
    ));
  }
  return updatedList;
}
