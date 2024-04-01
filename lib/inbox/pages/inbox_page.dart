import 'package:flutter/material.dart';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/inbox/bloc/inbox_bloc.dart';

import 'package:thunder/inbox/widgets/inbox_categories_widget.dart';
import 'package:thunder/inbox/widgets/inbox_mentions_view.dart';
import 'package:thunder/inbox/widgets/inbox_private_messages_view.dart';
import 'package:thunder/inbox/widgets/inbox_replies_view.dart';
import 'package:thunder/post/bloc/post_bloc.dart';
import 'package:thunder/shared/dialogs.dart';
import 'package:thunder/shared/error_message.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

enum InboxType { replies, mentions, messages }

class InboxPage extends StatefulWidget {
  const InboxPage({super.key});

  @override
  State<InboxPage> createState() => _InboxPageState();
}

class _InboxPageState extends State<InboxPage> {
  bool showAll = false;
  InboxType? inboxType = InboxType.replies;
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
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.7) {
      context.read<InboxBloc>().add(const GetInboxEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80.0,
        centerTitle: false,
        title: AutoSizeText(l10n.inbox, style: theme.textTheme.titleLarge),
        actions: [
          IconButton(
            icon: Icon(
              Icons.checklist,
              semanticLabel: l10n.readAll,
            ),
            onPressed: () async {
              await showThunderDialog<bool>(
                context: context,
                title: l10n.confirmMarkAllAsReadTitle,
                contentText: l10n.confirmMarkAllAsReadBody,
                onSecondaryButtonPressed: (dialogContext) {
                  Navigator.of(dialogContext).pop();
                },
                secondaryButtonText: l10n.cancel,
                onPrimaryButtonPressed: (dialogContext, _) {
                  Navigator.of(dialogContext).pop();
                  context.read<InboxBloc>().add(MarkAllAsReadEvent());
                },
                primaryButtonText: l10n.markAllAsRead,
              );
            },
          ),
          IconButton(
            icon: Icon(
              Icons.refresh_rounded,
              semanticLabel: l10n.refresh,
            ),
            onPressed: () {
              context.read<InboxBloc>().add(GetInboxEvent(reset: true, showAll: showAll));
            },
          ),
          FilterChip(
            shape: const StadiumBorder(),
            visualDensity: VisualDensity.compact,
            label: Text(l10n.showAll),
            selected: showAll,
            onSelected: (bool selected) {
              setState(() => showAll = !showAll);
              context.read<InboxBloc>().add(GetInboxEvent(reset: true, showAll: selected));
            },
          ),
          const SizedBox(width: 16.0),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(45.0),
          child: BlocBuilder<InboxBloc, InboxState>(
            builder: (context, state) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Center(
                  child: InboxCategoryWidget(
                    inboxType: inboxType,
                    onSelected: (InboxType? selected) {
                      _scrollController.animateTo(0, duration: const Duration(milliseconds: 150), curve: Curves.easeInOut);
                      setState(() {
                        inboxType = selected;
                      });
                    },
                    unreadCounts: {
                      InboxType.replies: context.read<InboxBloc>().state.repliesUnreadCount,
                      InboxType.mentions: context.read<InboxBloc>().state.mentionsUnreadCount,
                      InboxType.messages: context.read<InboxBloc>().state.messagesUnreadCount,
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ),
      body: BlocProvider(
        create: (context) => PostBloc(),
        child: RefreshIndicator(
          onRefresh: () async {
            context.read<InboxBloc>().add(GetInboxEvent(reset: true, showAll: showAll));
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
                      return Align(alignment: Alignment.topCenter, child: Text(l10n.loginToSeeInbox, style: theme.textTheme.titleMedium));
                    }

                    switch (state.status) {
                      case InboxStatus.initial:
                        context.read<InboxBloc>().add(const GetInboxEvent(reset: true));
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
                        if (inboxType == InboxType.mentions) return InboxMentionsView(mentions: state.mentions);
                        if (inboxType == InboxType.messages) return InboxPrivateMessagesView(privateMessages: state.privateMessages);
                        if (inboxType == InboxType.replies) return InboxRepliesView(replies: state.replies, showAll: showAll);
                      case InboxStatus.empty:
                        return Center(child: Text(l10n.emptyInbox));
                      case InboxStatus.failure:
                        return ErrorMessage(
                          message: state.errorMessage,
                          actionText: l10n.refreshContent,
                          action: () => context.read<InboxBloc>().add(const GetInboxEvent()),
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
