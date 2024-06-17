// Flutter imports
import 'package:flutter/material.dart';

// Package imports
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// Project imports
import 'package:thunder/core/auth/bloc/auth_bloc.dart';
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
                    child: IconButton(
                      onPressed: () => context.read<InboxBloc>().add(MarkReplyAsReadEvent(commentReplyId: commentReply.id, read: !commentReply.read, showAll: !state.showUnreadOnly)),
                      icon: Icon(
                        Icons.check,
                        semanticLabel: l10n.markAsRead,
                        color: commentReply.read ? Colors.green : null,
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                  const ThunderDivider(sliver: false, padding: false),
                ],
              );
            },
          ),
          if (state.hasReachedInboxReplyEnd && widget.replies.isNotEmpty)
            SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40.0),
                  child: Text(l10n.reachedTheBottom),
                ),
              ),
            ),
        ],
      );
    });
  }
}
