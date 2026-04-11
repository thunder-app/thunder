import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/l10n/generated/app_localizations.dart';
import 'package:thunder/src/foundation/primitives/primitives.dart';
import 'package:thunder/src/features/comment/comment.dart';
import 'package:thunder/src/features/feed/feed.dart';
import 'package:thunder/src/features/inbox/inbox.dart';
import 'package:thunder/src/shared/markdown/common_markdown_body.dart';
import 'package:thunder/src/shared/name/full_name_widgets.dart';
import 'package:thunder/src/foundation/utils/utils.dart';
import 'package:thunder/src/features/instance/domain/utils/instance_link_utils.dart';
import 'package:thunder/packages/ui/ui.dart' show ThunderDivider;

class InboxPrivateMessagesView extends StatefulWidget {
  final List<ThunderPrivateMessage> privateMessages;

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
    final textStyle = theme.textTheme.bodyMedium;

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
          if (state.status != InboxStatus.loading && widget.privateMessages.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: Text(l10n.noMessages)),
            ),
          SliverList.builder(
            itemCount: widget.privateMessages.length,
            itemBuilder: (context, index) {
              return Card(
                key: ValueKey<int>(widget.privateMessages[index].id),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                UserFullNameWidget(
                                    name: widget.privateMessages[index].creator?.name,
                                    displayName: widget.privateMessages[index].creator?.displayName,
                                    instance: fetchInstanceNameFromUrl(widget.privateMessages[index].creator?.actorId),
                                    includeInstance: true),
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Icon(Icons.arrow_forward_rounded, size: 14),
                                ),
                                UserFullNameWidget(
                                    name: widget.privateMessages[index].recipient?.name,
                                    displayName: widget.privateMessages[index].recipient?.displayName,
                                    instance: fetchInstanceNameFromUrl(widget.privateMessages[index].recipient?.actorId),
                                    includeInstance: true),
                              ],
                            ),
                          ),
                          Text(
                            formatTimeToString(dateTime: widget.privateMessages[index].published.toIso8601String()),
                            style: textStyle!.copyWith(fontSize: MediaQuery.textScalerOf(context).scale((textStyle.fontSize!) * (FontScale.base.textScaleFactor))),
                          )
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: CommonMarkdownBody(body: widget.privateMessages[index].content),
                      ),
                      ThunderDivider(sliver: false, padding: false),
                      Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          visualDensity: VisualDensity.compact,
                          onPressed: () => context.read<InboxBloc>().add(
                                InboxItemActionEvent(
                                  action: CommentAction.read,
                                  privateMessageId: widget.privateMessages[index].id,
                                  actionInput: ReadInboxActionInput(!widget.privateMessages[index].read),
                                ),
                              ),
                          icon: Icon(
                            Icons.check,
                            semanticLabel: l10n.markAsRead,
                            color: widget.privateMessages[index].read ? Colors.green : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          if (state.hasReachedInboxMentionEnd && widget.privateMessages.isNotEmpty) const SliverToBoxAdapter(child: FeedReachedEnd()),
          if (widget.privateMessages.isNotEmpty)
            SliverToBoxAdapter(
              child: SizedBox(height: kBottomNavigationBarHeight),
            )
        ],
      );
    });
  }
}
