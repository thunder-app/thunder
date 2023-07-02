import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lemmy_api_client/v3.dart';

import 'package:thunder/account/bloc/account_bloc.dart';
import 'package:thunder/community/pages/community_page.dart';
import 'package:thunder/core/auth/bloc/auth_bloc.dart';

import 'package:thunder/inbox/bloc/inbox_bloc.dart';
import 'package:thunder/post/bloc/post_bloc.dart';
import 'package:thunder/post/pages/post_page.dart';
import 'package:thunder/post/widgets/create_comment_modal.dart';
import 'package:thunder/shared/common_markdown_body.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/utils/date_time.dart';
import 'package:thunder/utils/instance.dart';

class InboxRepliesView extends StatelessWidget {
  const InboxRepliesView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    List<CommentView> replies = context.read<InboxBloc>().state.replies;

    if (replies.isEmpty) {
      return const Center(child: Text('No replies'));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: replies.length,
      itemBuilder: (context, index) {
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
                    child: PostPage(
                      postId: replies[index].post.id,
                      onPostUpdated: () => {},
                    ),
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
                        replies[index].creator.name,
                        style: theme.textTheme.titleSmall?.copyWith(color: Colors.greenAccent),
                      ),
                      Text(formatTimeToString(dateTime: replies[index].comment.published.toIso8601String()))
                    ],
                  ),
                  GestureDetector(
                    child: Text(
                      '${replies[index].community.name}${' · ${fetchInstanceNameFromUrl(replies[index].community.actorId)}'}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(0.75),
                      ),
                    ),
                    onTap: () => onTapCommunityName(context, replies[index].community.id),
                  ),
                  const SizedBox(height: 10),
                  CommonMarkdownBody(body: replies[index].comment.content),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (replies[index].commentReply?.read == false)
                        IconButton(
                          onPressed: () {
                            context.read<InboxBloc>().add(MarkReplyAsReadEvent(commentReplyId: replies[index].commentReply!.id, read: true));
                          },
                          icon: const Icon(
                            Icons.check,
                            semanticLabel: 'Mark as read',
                          ),
                          visualDensity: VisualDensity.compact,
                        ),
                      IconButton(
                        onPressed: () {
                          InboxBloc inboxBloc = context.read<InboxBloc>();
                          PostBloc postBloc = context.read<PostBloc>();

                          showModalBottomSheet(
                            isScrollControlled: true,
                            context: context,
                            showDragHandle: true,
                            builder: (context) {
                              return Padding(
                                padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 40),
                                child: FractionallySizedBox(
                                  heightFactor: 0.8,
                                  child: MultiBlocProvider(
                                    providers: [
                                      BlocProvider<InboxBloc>.value(value: inboxBloc),
                                      BlocProvider<PostBloc>.value(value: postBloc),
                                    ],
                                    child: CreateCommentModal(comment: replies[index].comment, parentCommentAuthor: replies[index].creator.name),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        icon: const Icon(
                          Icons.reply_rounded,
                          semanticLabel: 'Reply',
                        ),
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void onTapCommunityName(BuildContext context, int communityId) {
    AccountBloc accountBloc = context.read<AccountBloc>();
    AuthBloc authBloc = context.read<AuthBloc>();
    ThunderBloc thunderBloc = context.read<ThunderBloc>();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: accountBloc),
            BlocProvider.value(value: authBloc),
            BlocProvider.value(value: thunderBloc),
          ],
          child: CommunityPage(communityId: communityId),
        ),
      ),
    );
  }
}
