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
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class InboxPrivateMessagesView extends StatelessWidget {
  final Map<int, List<PrivateMessageView>>? privateMessages;

  const InboxPrivateMessagesView({super.key, this.privateMessages = const {}});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    if (privateMessages?.isEmpty == true) {
      return Align(
          alignment: Alignment.topCenter,
          heightFactor: (MediaQuery.of(context).size.height / 27),
          child: Text(
            l10n.noMessages,
          ));
    }
    final Account? account = context.read<AuthBloc>().state.account;
    return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: privateMessages?.length,
        itemBuilder: (context, groupedIndex) {
          int? currentIndex = privateMessages?.keys.elementAt(groupedIndex);
          List<PrivateMessageView>? groupedPrivateMessages = privateMessages![currentIndex];

          // Display only the first item in each group
          PrivateMessageView firstMessage = groupedPrivateMessages![0];

          return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: GestureDetector(
                            onTap: () => navigateToUserPage(
                              context,
                              userId: (account?.userId == firstMessage.recipient.id) ? firstMessage.creator.id : firstMessage.recipient.id,
                            ),
                            child: UserAvatar(
                              person: (account?.userId == firstMessage.recipient.id) ? firstMessage.creator : firstMessage.recipient,
                              radius: 24.0,
                            ),
                          ),
                        ),
                        if (firstMessage.privateMessage.read == false)
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
                            (account?.userId == firstMessage.recipient.id)
                                ? '${firstMessage.creator.displayName ?? firstMessage.creator.name}@${fetchInstanceNameFromUrl(firstMessage.creator.actorId) ?? ""}'
                                : '${firstMessage.recipient.displayName ?? firstMessage.recipient.name}@${fetchInstanceNameFromUrl(firstMessage.recipient.actorId) ?? ""}',
                            style: theme.textTheme.titleSmall?.copyWith(color: Colors.greenAccent, fontWeight: FontWeight.bold),
                          ),
                          CommonMarkdownBody(body: firstMessage.privateMessage.content),
                        ],
                      ),
                    ),
                    Text(formatTimeToString(dateTime: firstMessage.privateMessage.published.toIso8601String())),
                  ],
                ),
              ));
        });
  }
}
