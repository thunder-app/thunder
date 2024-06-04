// Flutter imports
import 'package:flutter/material.dart';

// Package imports
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lemmy_api_client/v3.dart';

// Project imports
import 'package:thunder/comment/utils/navigate_comment.dart';
import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/feed/utils/utils.dart';
import 'package:thunder/feed/view/feed_page.dart';
import 'package:thunder/inbox/bloc/inbox_bloc.dart';
import 'package:thunder/post/bloc/post_bloc.dart';
import 'package:thunder/post/utils/comment_action_helpers.dart';
import 'package:thunder/shared/comment_reference.dart';

extension on CommentReplyView {
  CommentView toCommentView() {
    return CommentView(
      comment: comment,
      creator: creator,
      post: post,
      community: community,
      counts: counts,
      creatorBannedFromCommunity: creatorBannedFromCommunity,
      subscribed: subscribed,
      saved: saved,
      creatorBlocked: creatorBlocked,
    );
  }
}

class InboxRepliesView extends StatefulWidget {
  final List<CommentReplyView> replies;
  final bool showAll;

  const InboxRepliesView({super.key, this.replies = const [], required this.showAll});

  @override
  State<InboxRepliesView> createState() => _InboxRepliesViewState();
}

class _InboxRepliesViewState extends State<InboxRepliesView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.replies.isEmpty) {
      return Align(alignment: Alignment.topCenter, heightFactor: (MediaQuery.of(context).size.height / 27), child: Text(l10n.noReplies));
    }

    return ListView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.replies.length,
      itemBuilder: (context, index) {
        return Column(
          children: [
            Divider(
              height: 1.0,
              thickness: 1.0,
              color: ElevationOverlay.applySurfaceTint(
                Theme.of(context).colorScheme.surface,
                Theme.of(context).colorScheme.surfaceTint,
                10,
              ),
            ),
            CommentReference(
              comment: widget.replies[index].toCommentView(),
              onVoteAction: (int commentId, int voteType) => context.read<PostBloc>().add(VoteCommentEvent(commentId: commentId, score: voteType)),
              onSaveAction: (int commentId, bool save) => context.read<PostBloc>().add(SaveCommentEvent(commentId: commentId, save: save)),
              onDeleteAction: (int commentId, bool deleted) => context.read<PostBloc>().add(DeleteCommentEvent(deleted: deleted, commentId: commentId)),
              onReportAction: (int commentId) {
                showReportCommentActionBottomSheet(
                  context,
                  commentId: commentId,
                );
              },
              onReplyEditAction: (CommentView commentView, bool isEdit) async => navigateToCreateCommentPage(
                context,
                commentView: isEdit ? commentView : null,
                parentCommentView: isEdit ? null : commentView,
                onCommentSuccess: (commentView, userChanged) {
                  if (!userChanged) {
                    context.read<PostBloc>().add(UpdateCommentEvent(commentView: commentView, isEdit: isEdit));
                  }
                },
              ),
              isOwnComment: widget.replies[index].creator.id == context.read<AuthBloc>().state.account?.userId,
              child: IconButton(
                onPressed: () {
                  context.read<InboxBloc>().add(MarkReplyAsReadEvent(commentReplyId: widget.replies[index].commentReply.id, read: !widget.replies[index].commentReply.read, showAll: widget.showAll));
                },
                icon: Icon(
                  Icons.check,
                  semanticLabel: l10n.markAsRead,
                  color: widget.replies[index].commentReply.read ? Colors.green : null,
                ),
                visualDensity: VisualDensity.compact,
              ),
            ),
          ],
        );
      },
    );
  }

  void onTapCommunityName(BuildContext context, int communityId) {
    navigateToFeedPage(context, feedType: FeedType.community, communityId: communityId);
  }
}
