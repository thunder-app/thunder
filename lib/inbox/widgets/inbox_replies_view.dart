import 'package:flutter/material.dart';

import 'package:lemmy_api_client/v3.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
  int? inboxReplyMarkedAsRead;
  List<int> inboxRepliesMarkedAsRead = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now().toUtc();

    if (widget.replies.isEmpty) {
      return Align(alignment: Alignment.topCenter, heightFactor: (MediaQuery.of(context).size.height / 27), child: const Text('No replies'));
    }

    return BlocListener<InboxBloc, InboxState>(
      listener: (context, state) {
        if (state.status == InboxStatus.success) {
          if (inboxReplyMarkedAsRead == null) return;

          setState(() {
            inboxRepliesMarkedAsRead.add(inboxReplyMarkedAsRead!);
            inboxReplyMarkedAsRead = null;
          });
        }
      },
      child: ListView.builder(
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
                now: now,
                onVoteAction: (int commentId, int voteType) => context.read<PostBloc>().add(VoteCommentEvent(commentId: commentId, score: voteType)),
                onSaveAction: (int commentId, bool save) => context.read<PostBloc>().add(SaveCommentEvent(commentId: commentId, save: save)),
                onDeleteAction: (int commentId, bool deleted) => context.read<PostBloc>().add(DeleteCommentEvent(deleted: deleted, commentId: commentId)),
                onReportAction: (int commentId) {
                  showReportCommentActionBottomSheet(
                    context,
                    commentId: commentId,
                  );
                },
                onReplyEditAction: (CommentView commentView, bool isEdit) async {
                  navigateToCreateCommentPage(
                    context,
                    parentCommentView: isEdit ? null : commentView,
                    commentView: isEdit ? commentView : null,
                    onCommentSuccess: (commentView) {
                      // TODO: Check to see if we edited our own comment, and update accordingly
                    },
                  );
                },
                isOwnComment: widget.replies[index].creator.id == context.read<AuthBloc>().state.account?.userId,
                child: widget.replies[index].commentReply.read == false && !inboxRepliesMarkedAsRead.contains(widget.replies[index].commentReply.id)
                    ? inboxReplyMarkedAsRead != widget.replies[index].commentReply.id
                        ? IconButton(
                            onPressed: () {
                              setState(() => inboxReplyMarkedAsRead = widget.replies[index].commentReply.id);
                              context.read<InboxBloc>().add(MarkReplyAsReadEvent(commentReplyId: widget.replies[index].commentReply.id, read: true, showAll: widget.showAll));
                            },
                            icon: const Icon(
                              Icons.check,
                              semanticLabel: 'Mark as read',
                            ),
                            visualDensity: VisualDensity.compact,
                          )
                        : const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.0),
                            child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator()),
                          )
                    : null,
              ),
            ],
          );
        },
      ),
    );
  }

  void onTapCommunityName(BuildContext context, int communityId) {
    navigateToFeedPage(context, feedType: FeedType.community, communityId: communityId);
  }
}
