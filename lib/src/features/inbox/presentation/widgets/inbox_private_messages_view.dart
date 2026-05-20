import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/src/features/inbox/inbox.dart';
import 'package:thunder/src/features/inbox/presentation/widgets/inbox_private_message_thread_tile.dart';
import 'package:thunder/src/features/private_message/domain/utils/private_message_thread_utils.dart';
import 'package:thunder/src/foundation/config/global_context.dart';

/// Displays direct messages grouped into participant threads.
class InboxPrivateMessagesView extends StatelessWidget {
  /// Creates a direct-message inbox view.
  const InboxPrivateMessagesView({super.key, this.privateMessages = const []});

  /// Private messages loaded for the inbox.
  final List<ThunderPrivateMessage> privateMessages;

  @override
  Widget build(BuildContext context) {
    final l10n = GlobalContext.l10n;

    final inboxBloc = context.read<InboxBloc>();
    final state = inboxBloc.state;
    final threads = groupPrivateMessagesByParticipant(privateMessages, inboxBloc.account);

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
          if (state.status != InboxStatus.loading && threads.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: Text(l10n.noMessages)),
            ),
          SliverList.builder(
            itemCount: threads.length,
            itemBuilder: (context, index) {
              final thread = threads[index];
              return InboxPrivateMessageThreadTile(
                account: inboxBloc.account,
                thread: thread,
              );
            },
          ),
          if (threads.isNotEmpty)
            SliverToBoxAdapter(
              child: SizedBox(height: kBottomNavigationBarHeight),
            )
        ],
      );
    });
  }
}
