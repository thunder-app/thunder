import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:thunder/account/models/account.dart';
import 'package:thunder/core/auth/bloc/auth_bloc.dart';

import 'package:thunder/shared/common_markdown_body.dart';
import 'package:thunder/shared/user_avatar.dart';
import 'package:thunder/utils/date_time.dart';
import 'package:thunder/utils/instance.dart';
import 'package:thunder/utils/navigate_user.dart';

class InboxPrivateMessagesView extends StatelessWidget {
  final List<PrivateMessageView> privateMessages;

  const InboxPrivateMessagesView({super.key, this.privateMessages = const []});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (privateMessages.isEmpty) {
      return Align(alignment: Alignment.topCenter, heightFactor: (MediaQuery.of(context).size.height / 27), child: const Text('No messages'));
    }
    final Account? account = context.read<AuthBloc>().state.account;

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: privateMessages.length,
      itemBuilder: (context, index) {
        return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: GestureDetector(
              onTap: () {
                navigateToUserPage(
                  context,
                  userId: (account?.userId == privateMessages[index].recipient.id) ? privateMessages[index].creator.id : privateMessages[index].recipient.id,
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: UserAvatar(
                            person: (account?.userId == privateMessages[index].recipient.id) ? privateMessages[index].creator : privateMessages[index].recipient,
                            radius: 24.0,
                          ),
                        ),
                        if (privateMessages[index].privateMessage.read == false)
                          //const  Badge()
                          Positioned(
                            bottom: 0,
                            left: -4,
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Icon(
                                Icons.fiber_manual_record,
                                color: Theme.of(context).primaryColor.withOpacity(.7),
                              ),
                            ),
                          )
                      ],
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            (account?.userId == privateMessages[index].recipient.id)
                                ? '${privateMessages[index].creator.displayName ?? privateMessages[index].creator.name}@${fetchInstanceNameFromUrl(privateMessages[index].creator.actorId) ?? ""}'
                                : '${privateMessages[index].recipient.displayName ?? privateMessages[index].recipient.name}@${fetchInstanceNameFromUrl(privateMessages[index].recipient.actorId) ?? ""}',
                            style: theme.textTheme.titleSmall?.copyWith(color: Colors.greenAccent, fontWeight: FontWeight.bold),
                          ),
                          CommonMarkdownBody(body: privateMessages[index].privateMessage.content),
                        ],
                      ),
                    ),
                    Text(formatTimeToString(dateTime: privateMessages[index].privateMessage.published.toIso8601String())),
                  ],
                ),
              ),
            ));
      },
    );
  }
}
