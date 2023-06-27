import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lemmy_api_client/v3.dart';

import 'package:thunder/inbox/bloc/inbox_bloc.dart';
import 'package:thunder/shared/common_markdown_body.dart';
import 'package:thunder/utils/date_time.dart';

class InboxPrivateMessagesView extends StatelessWidget {
  const InboxPrivateMessagesView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    List<PrivateMessageView> privateMessages = context.read<InboxBloc>().state.privateMessages;

    if (privateMessages.isEmpty) {
      return const Center(child: Text('No private messages'));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: privateMessages.length,
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
                          privateMessages[index].creator.name,
                          style: theme.textTheme.titleSmall?.copyWith(color: Colors.greenAccent),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Icon(Icons.arrow_forward_rounded, size: 14),
                        ),
                        Text(
                          privateMessages[index].recipient.name,
                          style: theme.textTheme.titleSmall?.copyWith(color: Colors.greenAccent),
                        ),
                      ],
                    ),
                    Text(formatTimeToString(dateTime: privateMessages[index].privateMessage.published.toIso8601String()))
                  ],
                ),
                const SizedBox(height: 10),
                CommonMarkdownBody(body: privateMessages[index].privateMessage.content),
              ],
            ),
          ),
        );
      },
    );
  }
}
