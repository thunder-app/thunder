import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/models/comment_view_tree.dart';

enum CommentCardAction { save, copyText, shareLink }

class ExtendedCommentCardActions {
  const ExtendedCommentCardActions({required this.commentCardAction, required this.icon, required this.label});

  final CommentCardAction commentCardAction;
  final IconData icon;
  final String label;
}

const commentCardActionItems = [
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

void showCommentActionBottomModalSheet(BuildContext context, CommentViewTree commentViewTree, Function onSaveAction) {
  final theme = Theme.of(context);

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
              padding: const EdgeInsets.only(bottom: 16.0, left: 16.0, right: 16.0),
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

                    CommentCardAction commentCardAction = commentCardActionItems[index].commentCardAction;

                    switch (commentCardAction) {
                      case CommentCardAction.save:
                        onSaveAction(commentViewTree.commentView!.comment.id, !(commentViewTree.commentView!.saved));
                        break;
                      case CommentCardAction.copyText:
                        Clipboard.setData(ClipboardData(text: commentViewTree.commentView!.comment.content)).then((_) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Copied to clipboard"), behavior: SnackBarBehavior.floating));
                        });
                        break;
                      case CommentCardAction.shareLink:
                        Share.share(commentViewTree.commentView!.comment.apId);
                        break;
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
