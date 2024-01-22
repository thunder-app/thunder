import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:thunder/inbox/bloc/inbox_bloc.dart';
import 'package:thunder/inbox/widgets/inbox_replies_view.dart';
import 'package:thunder/post/bloc/post_bloc.dart';

/// A page for displaying the result of reply notifications
class NotificationsReplyPage extends StatelessWidget {
  final List<CommentReplyView> replies;

  const NotificationsReplyPage({super.key, required this.replies});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: InboxBloc()),
        BlocProvider.value(value: PostBloc()),
      ],
      child: Container(
        color: theme.colorScheme.background,
        child: SafeArea(
          top: false,
          child: CustomScrollView(
            slivers: <Widget>[
              SliverAppBar(
                flexibleSpace: const FlexibleSpaceBar(titlePadding: EdgeInsets.zero),
                pinned: true,
                title: ListTile(
                  title: Text(l10n.inbox, style: theme.textTheme.titleLarge),
                  subtitle: Text(l10n.reply(replies.length)),
                ),
              ),
              SliverToBoxAdapter(
                child: Material(
                  child: InboxRepliesView(
                    replies: replies,
                    showAll: true,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
