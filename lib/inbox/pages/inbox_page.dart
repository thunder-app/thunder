import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import "package:flutter_gen/gen_l10n/app_localizations.dart";
import 'package:lemmy_api_client/v3.dart';

import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/inbox/bloc/inbox_bloc.dart';
import 'package:thunder/inbox/enums/inbox_type.dart';
import 'package:thunder/inbox/widgets/inbox_mentions_view.dart';
import 'package:thunder/inbox/widgets/inbox_private_messages_view.dart';
import 'package:thunder/inbox/widgets/inbox_replies_view.dart';
import 'package:thunder/shared/comment_sort_picker.dart';
import 'package:thunder/shared/dialogs.dart';
import 'package:thunder/shared/snackbar.dart';

/// A widget that displays the user's inbox replies, mentions, and private messages.
class InboxPage extends StatefulWidget {
  const InboxPage({super.key});

  @override
  State<InboxPage> createState() => _InboxPageState();
}

class _InboxPageState extends State<InboxPage> with SingleTickerProviderStateMixin {
  /// The controller for the tab bar used for switching between inbox types.
  late TabController tabController;

  /// The global key for the nested scroll view.
  final GlobalKey<NestedScrollViewState> nestedScrollViewKey = GlobalKey();

  /// Whether to show all inbox mentions, replies, and private messages or not
  bool showAll = false;

  /// The current inbox sort type. This only applies to replies and mentions, since messages does not have a sort type
  CommentSortType commentSortType = CommentSortType.new_;

  /// The current account id. If this changes, and the current view is active, reload the view
  int? accountId;

  InboxType get inboxType => tabController.index == 0
      ? InboxType.replies
      : tabController.index == 1
          ? InboxType.mentions
          : InboxType.messages;

  @override
  void initState() {
    super.initState();
    tabController = TabController(vsync: this, length: 3);
    accountId = context.read<AuthBloc>().state.account?.userId;

    WidgetsBinding.instance.addPostFrameCallback(
      (_) => nestedScrollViewKey.currentState!.innerController.addListener(() {
        ScrollController controller = nestedScrollViewKey.currentState!.innerController;

        if (controller.position.pixels >= controller.position.maxScrollExtent * 0.7 && context.read<InboxBloc>().state.status == InboxStatus.success) {
          context.read<InboxBloc>().add(GetInboxEvent(inboxType: inboxType));
        }
      }),
    );

    context.read<InboxBloc>().add(GetInboxEvent(inboxType: inboxType, reset: true));
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  /// Displays the sort options bottom sheet for comments, since replies and mentions are technically comments
  void showSortBottomSheet() {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    showModalBottomSheet<void>(
      showDragHandle: true,
      context: context,
      builder: (builderContext) => CommentSortPicker(
        title: l10n.sortOptions,
        onSelect: (selected) async {
          setState(() => commentSortType = selected.payload);
          context.read<InboxBloc>().add(GetInboxEvent(inboxType: inboxType, reset: true, showAll: showAll, commentSortType: selected.payload));
        },
        previouslySelected: commentSortType,
        minimumVersion: LemmyClient.instance.version,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: BlocConsumer<InboxBloc, InboxState>(
        listener: (context, state) {
          if (state.status == InboxStatus.initial || state.status == InboxStatus.loading || state.status == InboxStatus.empty) {
            nestedScrollViewKey.currentState?.innerController.jumpTo(0);

            int? newAccountId = context.read<AuthBloc>().state.account?.userId;

            if (newAccountId != accountId) {
              accountId = newAccountId;
              context.read<InboxBloc>().add(GetInboxEvent(inboxType: inboxType, reset: true, showAll: showAll));
            }
          }

          if (state.errorMessage?.isNotEmpty == true) {
            showSnackbar(
              state.errorMessage!,
              trailingIcon: Icons.refresh_rounded,
              trailingAction: () => context.read<InboxBloc>().add(GetInboxEvent(inboxType: inboxType, reset: true, showAll: showAll)),
            );
          }
        },
        builder: (context, state) {
          return NestedScrollView(
            key: nestedScrollViewKey,
            headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
              return [
                SliverOverlapAbsorber(
                  handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                  sliver: SliverAppBar(
                    pinned: true,
                    centerTitle: false,
                    toolbarHeight: 70.0,
                    forceElevated: innerBoxIsScrolled,
                    title: Text(l10n.inbox),
                    actions: [
                      IconButton(
                        icon: Icon(Icons.checklist, semanticLabel: l10n.readAll),
                        onPressed: () async {
                          await showThunderDialog<bool>(
                            context: context,
                            title: l10n.confirmMarkAllAsReadTitle,
                            contentText: l10n.confirmMarkAllAsReadBody,
                            onSecondaryButtonPressed: (dialogContext) => Navigator.of(dialogContext).pop(),
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
                        icon: Icon(Icons.refresh_rounded, semanticLabel: l10n.refresh),
                        onPressed: () => context.read<InboxBloc>().add(GetInboxEvent(inboxType: inboxType, reset: true, showAll: showAll)),
                      ),
                      IconButton(onPressed: () => showSortBottomSheet(), icon: Icon(Icons.sort, semanticLabel: l10n.sortBy)),
                      FilterChip(
                        shape: const StadiumBorder(),
                        visualDensity: VisualDensity.compact,
                        label: Text(l10n.showAll),
                        selected: showAll,
                        onSelected: (bool selected) {
                          setState(() => showAll = !showAll);
                          context.read<InboxBloc>().add(GetInboxEvent(inboxType: inboxType, reset: true, showAll: selected));
                        },
                      ),
                      const SizedBox(width: 16.0),
                    ],
                    bottom: TabBar(
                      controller: tabController,
                      onTap: (index) {
                        context.read<InboxBloc>().add(GetInboxEvent(inboxType: inboxType, reset: true, showAll: showAll));
                      },
                      tabs: [
                        Tab(
                          child: Wrap(
                            spacing: 4.0,
                            children: [
                              Text(l10n.reply(10)),
                              if (state.repliesUnreadCount > 0) Badge(label: Text(state.repliesUnreadCount > 99 ? '99+' : state.repliesUnreadCount.toString())),
                            ],
                          ),
                        ),
                        Tab(
                          child: Wrap(
                            spacing: 4.0,
                            children: [
                              Text(l10n.mention(10)),
                              if (state.mentionsUnreadCount > 0) Badge(label: Text(state.mentionsUnreadCount > 99 ? '99+' : state.mentionsUnreadCount.toString())),
                            ],
                          ),
                        ),
                        Tab(
                          child: Wrap(
                            spacing: 4.0,
                            children: [
                              Text(l10n.message(10)),
                              if (state.messagesUnreadCount > 0) Badge(label: Text(state.messagesUnreadCount > 99 ? '99+' : state.messagesUnreadCount.toString())),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ];
            },
            body: TabBarView(
              controller: tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                InboxRepliesView(replies: state.replies),
                InboxMentionsView(mentions: state.mentions),
                InboxPrivateMessagesView(privateMessages: state.privateMessages),
              ],
            ),
          );
        },
      ),
    );
  }
}
