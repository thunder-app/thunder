// Flutter imports
import 'package:flutter/material.dart';

// Package imports
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:thunder/localizations/app_localizations.dart';
import 'package:thunder/account/account.dart';

// Project imports
import 'package:thunder/comment/comment.dart';
import 'package:thunder/feed/view/feed_page.dart';
import 'package:thunder/inbox/bloc/inbox_bloc.dart';
import 'package:thunder/shared/comment_reference.dart';
import 'package:thunder/shared/divider.dart';
import 'package:thunder/core/extensions/person_mention_view.dart';

class InboxMentionsView extends StatefulWidget {
  final List<PersonMentionView> mentions;

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
              PersonMentionView personMentionView = widget.mentions[index];
              PersonMention personMention = personMentionView.personMention;

              return Column(
                children: [
                  CommentReference(
                    comment: personMentionView.toComment(),
                    isOwnComment: personMentionView.creator.id == context.read<ProfileBloc>().state.account?.userId,
                    child: IconButton(
                      onPressed: () => context.read<InboxBloc>().add(InboxItemActionEvent(action: CommentAction.read, personMentionId: personMention.id, value: !personMention.read)),
                      icon: Icon(
                        Icons.check,
                        semanticLabel: l10n.markAsRead,
                        color: personMention.read ? Colors.green : null,
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
