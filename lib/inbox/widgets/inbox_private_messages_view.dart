import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:lemmy_api_client/v3.dart';

import 'package:thunder/feed/view/feed_page.dart';
import 'package:thunder/inbox/bloc/inbox_bloc.dart';
import 'package:thunder/shared/common_markdown_body.dart';
import 'package:thunder/utils/date_time.dart';

class InboxPrivateMessagesView extends StatefulWidget {
  final List<PrivateMessageView> privateMessages;

  const InboxPrivateMessagesView({super.key, this.privateMessages = const []});

  @override
  State<InboxPrivateMessagesView> createState() => _InboxPrivateMessagesViewState();
}

class _InboxPrivateMessagesViewState extends State<InboxPrivateMessagesView> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final state = context.read<InboxBloc>().state;

    return Builder(builder: (context) {
      return CustomScrollView(
        key: PageStorageKey<String>(l10n.message(10)),
        slivers: [
          SliverOverlapInjector(handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context)),
          if (state.status == InboxStatus.loading)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: CircularProgressIndicator()),
            ),
          if (widget.privateMessages.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: Text(l10n.noMessages)),
            ),
          SliverList.builder(
            itemCount: widget.privateMessages.length,
            itemBuilder: (context, index) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.privateMessages[index].creator.name,
                                style: theme.textTheme.titleSmall?.copyWith(color: Colors.greenAccent),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8.0),
                                child: Icon(Icons.arrow_forward_rounded, size: 14),
                              ),
                              Text(
                                widget.privateMessages[index].recipient.name,
                                style: theme.textTheme.titleSmall?.copyWith(color: Colors.greenAccent),
                              ),
                            ],
                          ),
                          Text(formatTimeToString(dateTime: widget.privateMessages[index].privateMessage.published.toIso8601String()))
                        ],
                      ),
                      const SizedBox(height: 10),
                      CommonMarkdownBody(body: widget.privateMessages[index].privateMessage.content),
                    ],
                  ),
                ),
              );
            },
          ),
          if (state.hasReachedInboxMentionEnd && widget.privateMessages.isNotEmpty) const SliverToBoxAdapter(child: FeedReachedEnd()),
        ],
      );
    });
  }
}
