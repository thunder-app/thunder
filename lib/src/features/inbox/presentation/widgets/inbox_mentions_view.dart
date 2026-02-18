// Flutter imports
import 'package:flutter/material.dart';

// Package imports
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/l10n/generated/app_localizations.dart';
import 'package:thunder/src/features/comment/comment.dart';
import 'package:thunder/src/features/feed/feed.dart';
import 'package:thunder/src/features/inbox/inbox.dart';
import 'package:thunder/src/features/comment/presentation/widgets/comment_reference.dart';
import 'package:thunder/packages/ui/ui.dart' show ThunderDivider;

class InboxMentionsView extends StatefulWidget {
  final List<ThunderComment> mentions;

  const InboxMentionsView({super.key, this.mentions = const []});

  @override
  State<InboxMentionsView> createState() => _InboxMentionsViewState();
}

class _InboxMentionsViewState extends State<InboxMentionsView> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = context.read<InboxBloc>().state;

    return Builder(builder: (context) {
      return CustomScrollView(
        key: PageStorageKey<String>(l10n.mention(10)),
        slivers: [
          SliverOverlapInjector(handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context)),
          if (state.status == InboxStatus.loading)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: CircularProgressIndicator()),
            ),
          if (state.status != InboxStatus.loading && widget.mentions.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: Text(l10n.noMentions)),
            ),
          SliverList.builder(
            itemCount: widget.mentions.length,
            itemBuilder: (context, index) {
              ThunderComment comment = widget.mentions[index];
              assert(comment.read != null, 'Comment should have a read status');

              return Column(
                key: ValueKey<int>(comment.replyMentionId!),
                children: [
                  CommentReference(
                    comment: comment,
                    child: IconButton(
                      onPressed: () =>
                          context.read<InboxBloc>().add(InboxItemActionEvent(action: CommentAction.read, personMentionId: comment.replyMentionId!, actionInput: ReadInboxActionInput(!comment.read!))),
                      icon: Icon(
                        Icons.check,
                        semanticLabel: l10n.markAsRead,
                        color: comment.read! ? Colors.green : null,
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                  if (index != widget.mentions.length - 1) const ThunderDivider(sliver: false, padding: false),
                ],
              );
            },
          ),
          if (state.hasReachedInboxMentionEnd && widget.mentions.isNotEmpty) const SliverToBoxAdapter(child: FeedReachedEnd()),
          if (widget.mentions.isNotEmpty)
            SliverToBoxAdapter(
              child: SizedBox(height: kBottomNavigationBarHeight),
            )
        ],
      );
    });
  }
}
