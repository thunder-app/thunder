import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/features/comment/comment.dart';
import 'package:thunder/l10n/generated/app_localizations.dart';
import 'package:thunder/src/features/inbox/inbox.dart';
import 'package:thunder/src/features/post/post.dart';
import 'package:thunder/src/shared/utils/constants.dart';

/// A page for displaying the result of reply notifications
class NotificationsReplyPage extends StatelessWidget {
  final List<ThunderComment> replies;

  const NotificationsReplyPage({super.key, required this.replies});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final account = context.select<ProfileBloc, Account>((bloc) => bloc.state.account);

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: InboxBloc.initWith(replies: replies, showUnreadOnly: true, account: account)),
        BlocProvider.value(value: PostBloc(account: account)),
      ],
      child: BlocConsumer<InboxBloc, InboxState>(
        listener: (BuildContext context, InboxState state) {
          if (state.replies.isEmpty && (ModalRoute.of(context)?.isCurrent ?? false)) {
            Navigator.of(context).pop();
          }
        },
        builder: (context, state) => Material(
          child: NestedScrollView(
            headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
              return [
                SliverOverlapAbsorber(
                  handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                  sliver: SliverAppBar(
                    pinned: true,
                    centerTitle: false,
                    toolbarHeight: APP_BAR_HEIGHT,
                    forceElevated: innerBoxIsScrolled,
                    title: ListTile(
                      title: Text(l10n.inbox, style: theme.textTheme.titleLarge),
                      subtitle: Text(l10n.reply(replies.length)),
                    ),
                  ),
                ),
              ];
            },
            body: InboxRepliesView(replies: state.replies),
          ),
        ),
      ),
    );
  }
}
