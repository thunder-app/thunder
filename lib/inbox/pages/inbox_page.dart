import 'package:flutter/material.dart';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/inbox/bloc/inbox_bloc.dart';

import 'package:thunder/inbox/widgets/inbox_mentions_view.dart';
import 'package:thunder/inbox/widgets/inbox_private_messages_view.dart';
import 'package:thunder/inbox/widgets/inbox_replies_view.dart';
import 'package:thunder/post/bloc/post_bloc.dart';
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

  bool showAll = false;

  final _scrollController = ScrollController(initialScrollOffset: 0);

  @override
  void initState() {
    _scrollController.addListener(_onScroll);
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.7) {
      context.read<InboxBloc>().add(const GetInboxEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80.0,
        centerTitle: false,
        title: AutoSizeText('Inbox', style: theme.textTheme.titleLarge),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.refresh_rounded,
              semanticLabel: 'Refresh',
            ),
            onPressed: () {
              context
                  .read<InboxBloc>()
                  .add(GetInboxEvent(reset: true, showAll: showAll));
            },
          ),
          FilterChip(
            shape: const StadiumBorder(),
            visualDensity: VisualDensity.compact,
            label: const Text('Show All'),
            selected: showAll,
            onSelected: (bool selected) {
              setState(() => showAll = !showAll);
              context
                  .read<InboxBloc>()
                  .add(GetInboxEvent(reset: true, showAll: selected));
            },
          ),
          const SizedBox(width: 16.0),
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
                      _scrollController.animateTo(0,
                          duration: const Duration(milliseconds: 150),
                          curve: Curves.easeInOut);
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
      body: BlocProvider(
        create: (context) => PostBloc(),
        child: RefreshIndicator(
          onRefresh: () async {
            context
                .read<InboxBloc>()
                .add(GetInboxEvent(reset: true, showAll: showAll));
          },
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                BlocBuilder<InboxBloc, InboxState>(
                  builder: (context, InboxState state) {
                    if (context.read<AuthBloc>().state.isLoggedIn == false) {
                      return Align(
                          alignment: Alignment.topCenter,
                          child: Text('Log in to see your inbox',
                              style: theme.textTheme.titleMedium));
                    }

                    switch (state.status) {
                      case InboxStatus.initial:
                        context
                            .read<InboxBloc>()
                            .add(const GetInboxEvent(reset: true));
                      case InboxStatus.loading:
                        return const Padding(
                          padding: EdgeInsets.all(24.0),
                          child: Align(
                            alignment: Alignment.center,
                            child: SizedBox(
                              width: 40,
                              height: 40,
                              child: CircularProgressIndicator(),
                            ),
                          ),
                        );
                      case InboxStatus.refreshing:
                      case InboxStatus.success:
                        if (_inboxType == InboxType.mentions)
                          return InboxMentionsView(mentions: state.mentions);
                        if (_inboxType == InboxType.messages)
                          return InboxPrivateMessagesView(
                              privateMessages: state.privateMessages);
                        if (_inboxType == InboxType.replies)
                          return InboxRepliesView(replies: state.replies);
                      case InboxStatus.empty:
                        return const Center(child: Text('Empty Inbox'));
                      case InboxStatus.failure:
                        return ErrorMessage(
                          message: state.errorMessage,
                          actionText: 'Refresh Content',
                          action: () => context
                              .read<InboxBloc>()
                              .add(const GetInboxEvent()),
                        );
                    }

                    return Container();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
