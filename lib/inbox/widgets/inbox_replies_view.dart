// Flutter imports
import 'package:flutter/material.dart';

// Package imports
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports
import 'package:thunder/comment/models/thunder_comment.dart';
import 'package:thunder/localizations/app_localizations.dart';
import 'package:thunder/account/account.dart';
import 'package:thunder/comment/comment.dart';
import 'package:thunder/utils/navigation.dart';
import 'package:thunder/feed/view/feed_page.dart';
import 'package:thunder/inbox/bloc/inbox_bloc.dart';
import 'package:thunder/shared/comment_reference.dart';
import 'package:thunder/shared/divider.dart';

class InboxRepliesView extends StatefulWidget {
  final List<ThunderComment> replies;

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
          if (state.status != InboxStatus.loading && widget.replies.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: Text(l10n.noReplies)),
            ),
          SliverList.builder(
            itemCount: widget.replies.length,
            itemBuilder: (context, index) {
              ThunderComment reply = widget.replies[index];
              assert(reply.read != null, 'Reply should have a read status');

              return Column(
                children: [
                  CommentReference(
                    comment: reply,
                    isOwnComment: reply.creatorId == context.read<ProfileBloc>().state.account.userId,
                    onVoteAction: (int commentId, int voteType) => context.read<InboxBloc>().add(
                          InboxItemActionEvent(
                            action: CommentAction.vote,
                            commentReplyId: reply.id,
                            value: switch (voteType) {
                              1 => reply.myVote == 1 ? 0 : 1,
                              -1 => reply.myVote == -1 ? 0 : -1,
                              _ => 0,
                            },
                          ),
                        ),
                    onSaveAction: (int commentId, bool save) => context.read<InboxBloc>().add(InboxItemActionEvent(action: CommentAction.save, commentReplyId: reply.id, value: save)),
                    onDeleteAction: (int commentId, bool deleted) => context.read<InboxBloc>().add(InboxItemActionEvent(action: CommentAction.delete, commentReplyId: reply.id, value: deleted)),
                    onReplyEditAction: (ThunderComment comment, bool isEdit) {
                      return navigateToCreateCommentPage(
                        context,
                        comment: isEdit ? comment : null,
                        parentComment: isEdit ? null : comment,
                      );
                    },
                    child: IconButton(
                      onPressed: () => context.read<InboxBloc>().add(InboxItemActionEvent(action: CommentAction.read, commentReplyId: reply.id, value: !reply.read!)),
                      icon: Icon(
                        Icons.check,
                        semanticLabel: l10n.markAsRead,
                        color: reply.read! ? Colors.green : null,
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
          if (widget.replies.isNotEmpty)
            SliverToBoxAdapter(
              child: SizedBox(height: kBottomNavigationBarHeight),
            )
        ],
      );
    });
  }
}
