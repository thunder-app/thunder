import 'package:flutter/material.dart';
import 'package:lemmy_api_client/v3.dart';

import 'package:thunder/shared/common_markdown_body.dart';
import 'package:thunder/utils/date_time.dart';

class InboxPrivateMessagesView extends StatelessWidget {
  final List<PrivateMessageView> privateMessages;

  const InboxPrivateMessagesView({super.key, this.privateMessages = const []});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (privateMessages.isEmpty) {
      return Align(
          alignment: Alignment.topCenter,
          heightFactor: (MediaQuery.of(context).size.height / 27),
          child: const Text('No messages'));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: privateMessages.length,
      itemBuilder: (context, index) {
        return Card(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
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
                          style: theme.textTheme.titleSmall
                              ?.copyWith(color: Colors.greenAccent),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Icon(Icons.arrow_forward_rounded, size: 14),
                        ),
                        Text(
                          privateMessages[index].recipient.name,
                          style: theme.textTheme.titleSmall
                              ?.copyWith(color: Colors.greenAccent),
                        ),
                      ],
                    ),
                    Text(formatTimeToString(
                        dateTime: privateMessages[index]
                            .privateMessage
                            .published
                            .toIso8601String()))
                  ],
                ),
                const SizedBox(height: 10),
                CommonMarkdownBody(
                    body: privateMessages[index].privateMessage.content),
              ],
            ),
          ),
        );
      },
    );
  }
}
