import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:thunder/account/bloc/profile_bloc.dart';
import 'package:thunder/account/models/account.dart';
import 'package:thunder/localizations/app_localizations.dart';

import 'package:thunder/inbox/bloc/inbox_bloc.dart';
import 'package:thunder/inbox/widgets/inbox_replies_view.dart';
import 'package:thunder/post/bloc/post_bloc.dart';
import 'package:thunder/utils/constants.dart';

/// A page for displaying the result of reply notifications
class NotificationsReplyPage extends StatelessWidget {
  final List<CommentReplyView> replies;

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
