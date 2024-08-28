// Flutter imports
import 'package:flutter/material.dart';

// Package imports
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// Project imports
import 'package:thunder/comment/enums/comment_action.dart';
import 'package:thunder/comment/utils/navigate_comment.dart';
import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/feed/view/feed_page.dart';
import 'package:thunder/inbox/bloc/inbox_bloc.dart';
import 'package:thunder/shared/comment_reference.dart';
import 'package:thunder/shared/divider.dart';

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
      myVote: myVote as int?,
    );
  }
}

class InboxRepliesView extends StatefulWidget {
  final List<CommentReplyView> replies;

  const InboxRepliesView({super.key, this.replies = const []});

  @override
  State<InboxRepliesView> createState() => _InboxRepliesViewState();
}

class _InboxRepliesViewState extends State<InboxRepliesView> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = context.read<InboxBloc>().state;

    return Builder(builder: (context) {
      return CustomScrollView(
        key: PageStorageKey<String>(l10n.reply(10)),
        slivers: [
          SliverOverlapInjector(handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context)),
          if (state.status == InboxStatus.loading)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: CircularProgressIndicator()),
            ),
          if (widget.replies.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: Text(l10n.noReplies)),
            ),
          SliverList.builder(
            itemCount: widget.replies.length,
            itemBuilder: (context, index) {
              CommentReplyView commentReplyView = widget.replies[index];
              CommentReply commentReply = commentReplyView.commentReply;

              return Column(
                children: [
                  CommentReference(
                    comment: commentReplyView.toCommentView(),
                    isOwnComment: commentReplyView.creator.id == context.read<AuthBloc>().state.account?.userId,
                    onVoteAction: (int commentId, int voteType) => context.read<InboxBloc>().add(
                          InboxItemActionEvent(
                            action: CommentAction.vote,
                            commentReplyId: commentReply.id,
                            value: switch (voteType) {
                              1 => commentReplyView.myVote == 1 ? 0 : 1,
                              -1 => commentReplyView.myVote == -1 ? 0 : -1,
                              _ => 0,
                            },
                          ),
                        ),
                    onSaveAction: (int commentId, bool save) => context.read<InboxBloc>().add(InboxItemActionEvent(action: CommentAction.save, commentReplyId: commentReply.id, value: save)),
                    onDeleteAction: (int commentId, bool deleted) => context.read<InboxBloc>().add(InboxItemActionEvent(action: CommentAction.delete, commentReplyId: commentReply.id, value: deleted)),
                    onReplyEditAction: (CommentView commentView, bool isEdit) {
                      return navigateToCreateCommentPage(
                        context,
                        commentView: isEdit ? commentView : null,
                        parentCommentView: isEdit ? null : commentView,
                      );
                    },
                    child: IconButton(
                      onPressed: () => context.read<InboxBloc>().add(InboxItemActionEvent(action: CommentAction.read, commentReplyId: commentReply.id, value: !commentReply.read)),
                      icon: Icon(
                        Icons.check,
                        semanticLabel: l10n.markAsRead,
                        color: commentReply.read ? Colors.green : null,
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                  if (index != widget.replies.length - 1) const ThunderDivider(sliver: false, padding: false),
                ],
              );
            },
          ),
          if (state.hasReachedInboxReplyEnd && widget.replies.isNotEmpty) const SliverToBoxAdapter(child: FeedReachedEnd()),
        ],
      );
    });
  }
}
