// Flutter imports
import 'package:flutter/material.dart';

// Package imports
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports
import 'package:thunder/l10n/generated/app_localizations.dart';
import 'package:thunder/src/features/comment/comment.dart';
import 'package:thunder/src/features/feed/feed.dart';
import 'package:thunder/src/features/inbox/inbox.dart';
import 'package:thunder/src/features/comment/presentation/widgets/comment_reference.dart';
import 'package:thunder/packages/ui/ui.dart';

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

    return Builder(
      builder: (context) {
        return CustomScrollView(
          key: PageStorageKey<String>(l10n.reply(10)),
          slivers: [
            SliverOverlapInjector(handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context)),
            if (state.status == InboxStatus.loading) const SliverFillRemaining(hasScrollBody: false, child: Center(child: CircularProgressIndicator())),
            if (state.status != InboxStatus.loading && widget.replies.isEmpty) SliverFillRemaining(hasScrollBody: false, child: Center(child: Text(l10n.noReplies))),
            SliverList.builder(
              itemCount: widget.replies.length,
              itemBuilder: (context, index) {
                ThunderComment reply = widget.replies[index];
                assert(reply.notification != null, 'Reply should have notification metadata');
                final notification = reply.notification!;

                return Column(
                  key: ValueKey<int>(notification.id),
                  children: [
                    CommentReference(
                      comment: reply,
                      child: IconButton(
                        onPressed: () =>
                            context.read<InboxBloc>().add(InboxItemActionEvent(action: CommentAction.read, commentReplyId: notification.id, actionInput: ReadInboxActionInput(!notification.read))),
                        icon: Icon(Icons.check, semanticLabel: l10n.markAsRead, color: notification.read ? Colors.green : null),
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                    if (index != widget.replies.length - 1) const ThunderDivider(sliver: false, padding: false),
                  ],
                );
              },
            ),
            if (state.hasReachedInboxReplyEnd && widget.replies.isNotEmpty) const SliverToBoxAdapter(child: FeedReachedEnd()),
            if (widget.replies.isNotEmpty) SliverToBoxAdapter(child: SizedBox(height: kBottomNavigationBarHeight)),
          ],
        );
      },
    );
  }
}
