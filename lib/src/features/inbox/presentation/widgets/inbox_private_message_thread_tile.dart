import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/src/core/domain/domain.dart';
import 'package:thunder/src/core/navigation/navigation_private_message.dart';
import 'package:thunder/src/core/utils/utils.dart';
import 'package:thunder/src/features/inbox/presentation/state/inbox_bloc.dart';
import 'package:thunder/src/features/instance/domain/utils/instance_link_utils.dart';
import 'package:thunder/src/features/private_message/domain/models/private_message_thread.dart';
import 'package:thunder/src/shared/avatars/user_avatar.dart';
import 'package:thunder/src/shared/name/full_name_widgets.dart';

/// List row for a grouped direct-message thread in the inbox.
class InboxPrivateMessageThreadTile extends StatelessWidget {
  /// Creates a direct-message thread row.
  const InboxPrivateMessageThreadTile({super.key, required this.account, required this.thread});

  /// Account that owns the inbox.
  final Account account;

  /// Grouped thread summary to display.
  final PrivateMessageThread thread;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final participant = thread.participant;

    return ListTile(
      key: ValueKey<String>(participant.actorId),
      leading: UserAvatar(user: participant, radius: 24.0),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: UserFullNameWidget(name: participant.name, displayName: participant.displayName, instance: fetchInstanceNameFromUrl(participant.actorId), includeInstance: true),
          ),
          Text(formatTimeToString(dateTime: thread.latestMessage.published.toIso8601String()), style: theme.textTheme.labelSmall),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 2.0),
          Text(
            thread.latestMessage.content.replaceAll('\n', ' '),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: thread.unreadCount > 0
                ? theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)
                : theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
          ),
        ],
      ),
      onTap: () {
        navigateToPrivateMessageThreadPage(
          context,
          account: account,
          participant: participant,
          initialMessages: thread.messages,
          conversationId: thread.conversationId,
          onThreadUpdated: (messages) {
            if (!context.mounted) return;
            context.read<InboxBloc>().add(InboxPrivateMessageThreadUpdatedEvent(messages));
          },
        );
      },
    );
  }
}
