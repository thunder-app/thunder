import 'package:flutter/material.dart';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thunder/inbox/bloc/inbox_bloc.dart';

import 'package:thunder/inbox/widgets/inbox_mentions_view.dart';
import 'package:thunder/inbox/widgets/inbox_private_messages_view.dart';
import 'package:thunder/inbox/widgets/inbox_replies_view.dart';
import 'package:thunder/shared/error_message.dart';

enum InboxType { replies, mentions, messages }

class InboxCategory {
  final InboxType type;
  final String title;
  final IconData icon;

  InboxCategory({required this.type, required this.title, required this.icon});
}

List<InboxCategory> inboxCategories = [
  InboxCategory(
    type: InboxType.replies,
    title: 'Replies',
    icon: Icons.comment_bank_rounded,
  ),
  InboxCategory(
    type: InboxType.mentions,
    title: 'Mentions',
    icon: Icons.comment_bank_rounded,
  ),
  InboxCategory(
    type: InboxType.messages,
    title: 'Messages',
    icon: Icons.message_rounded,
  ),
];

class InboxPage extends StatefulWidget {
  const InboxPage({super.key});

  @override
  State<InboxPage> createState() => _InboxPageState();
}

class _InboxPageState extends State<InboxPage> {
  InboxType? _inboxType = inboxCategories[0].type;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70.0,
        centerTitle: false,
        title: AutoSizeText('Inbox', style: theme.textTheme.titleLarge),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              context.read<InboxBloc>().add(const GetInboxEvent());
            },
          )
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(45.0),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Center(
              child: Wrap(
                spacing: 5.0,
                children: inboxCategories.map((InboxCategory inboxCategory) {
                  return ChoiceChip(
                    label: Text(inboxCategory.title),
                    selected: _inboxType == inboxCategory.type,
                    onSelected: (bool selected) {
                      setState(() {
                        _inboxType = selected ? inboxCategory.type : null;
                      });
                    },
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            BlocBuilder<InboxBloc, InboxState>(builder: (context, InboxState state) {
              switch (state.status) {
                case InboxStatus.initial:
                case InboxStatus.loading:
                case InboxStatus.refreshing:
                  return const CircularProgressIndicator();
                case InboxStatus.success:
                  if (_inboxType == InboxType.mentions) return const InboxMentionsView();
                  if (_inboxType == InboxType.messages) return const InboxPrivateMessagesView();
                  if (_inboxType == InboxType.replies) return const InboxRepliesView();
                  return Container();
                case InboxStatus.empty:
                  return const Center(child: Text('Empty Inbox'));
                case InboxStatus.failure:
                  return ErrorMessage(
                    message: state.errorMessage,
                    actionText: 'Refresh Content',
                    action: () => context.read<InboxBloc>().add(const GetInboxEvent()),
                  );
              }
            })
          ],
        ),
      ),
    );
  }
}
