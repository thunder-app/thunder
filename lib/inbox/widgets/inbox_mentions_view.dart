// Flutter imports
import 'package:flutter/material.dart';

// Package imports
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// Project imports
import 'package:thunder/comment/enums/comment_action.dart';
import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/core/models/models.dart';
import 'package:thunder/feed/view/feed_page.dart';
import 'package:thunder/inbox/bloc/inbox_bloc.dart';
import 'package:thunder/shared/comment_reference.dart';
import 'package:thunder/shared/divider.dart';
import 'package:thunder/utils/convert.dart';

extension on PersonMentionView {
  CommentView toCommentView() {
    return CommentView(
      comment: comment,
      creator: creator,
      post: post,
      community: convertToCommunity(community)!,
      counts: counts,
      creatorBannedFromCommunity: creatorBannedFromCommunity,
      subscribed: convertToSubscribedType(subscribed)!,
      saved: saved,
      creatorBlocked: creatorBlocked,
    );
  }
}

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
          if (widget.mentions.isEmpty)
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
                    comment: personMentionView.toCommentView(),
                    isOwnComment: personMentionView.creator.id == context.read<AuthBloc>().state.account?.userId,
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
        ],
      );
    });
  }
}
