import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:thunder/account/bloc/account_bloc.dart';
import 'package:thunder/community/utils/post_card_action_helpers.dart';
import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/post/bloc/post_bloc.dart';
import 'package:thunder/post/pages/post_page.dart';
import 'package:thunder/shared/common_markdown_body.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/utils/date_time.dart';
import 'package:thunder/utils/instance.dart';

class CommentCard extends StatelessWidget {
  final CommentView comment;

  const CommentCard({super.key, required this.comment});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: () async {
          AccountBloc accountBloc = context.read<AccountBloc>();
          AuthBloc authBloc = context.read<AuthBloc>();
          ThunderBloc thunderBloc = context.read<ThunderBloc>();

          // To to specific post for now, in the future, will be best to scroll to the position of the comment
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => MultiBlocProvider(
                providers: [
                  BlocProvider.value(value: accountBloc),
                  BlocProvider.value(value: authBloc),
                  BlocProvider.value(value: thunderBloc),
                  BlocProvider(create: (context) => PostBloc()),
                ],
                child: PostPage(postId: comment.post.id, selectedCommentPath: comment.comment.path, selectedCommentId: comment.comment.id, onPostUpdated: () => {}),
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    comment.creator.name,
                    style: theme.textTheme.titleSmall?.copyWith(color: Colors.greenAccent),
                  ),
                  Text(formatTimeToString(dateTime: comment.comment.published.toIso8601String()))
                ],
              ),
              GestureDetector(
                child: Text(
                  '${comment.community.name}${' · ${fetchInstanceNameFromUrl(comment.community.actorId)}'}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.75),
                  ),
                ),
                onTap: () => onTapCommunityName(context, comment.community.id),
              ),
              const SizedBox(height: 10),
              CommonMarkdownBody(body: comment.comment.content),
              const Divider(height: 20),
              const Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // IconButton(
                  //   onPressed: () {
                  //     InboxBloc inboxBloc = context.read<InboxBloc>();

                  //     showModalBottomSheet(
                  //       isScrollControlled: true,
                  //       context: context,
                  //       showDragHandle: true,
                  //       builder: (context) {
                  //         return Padding(
                  //           padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 40),
                  //           child: FractionallySizedBox(
                  //             heightFactor: 0.8,
                  //             child: BlocProvider<InboxBloc>.value(
                  //               value: inboxBloc,
                  //               child: CreateCommentModal(comment: comment.comment, parentCommentAuthor: comment.creator.name),
                  //             ),
                  //           ),
                  //         );
                  //       },
                  //     );
                  //   },
                  //   icon: const Icon(
                  //     Icons.reply_rounded,
                  //     semanticLabel: 'Reply',
                  //   ),
                  //   visualDensity: VisualDensity.compact,
                  // ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
