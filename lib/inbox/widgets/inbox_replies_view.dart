import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';

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
import 'package:thunder/utils/swipe.dart';

class InboxRepliesView extends StatefulWidget {
  final List<CommentView> replies;

  const InboxRepliesView({super.key, this.replies = const []});

  @override
  State<InboxRepliesView> createState() => _InboxRepliesViewState();
}

class _InboxRepliesViewState extends State<InboxRepliesView> {
  int? inboxReplyMarkedAsRead;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (widget.replies.isEmpty) {
      return Align(alignment: Alignment.topCenter, heightFactor: (MediaQuery.of(context).size.height / 27), child: const Text('No replies'));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.replies.length,
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
                SwipeablePageRoute(
                  canOnlySwipeFromEdge: disableFullPageSwipe(isUserLoggedIn: authBloc.state.isLoggedIn, state: thunderBloc.state, isPostPage: true),
                  builder: (context) => MultiBlocProvider(
                    providers: [
                      BlocProvider.value(value: accountBloc),
                      BlocProvider.value(value: authBloc),
                      BlocProvider.value(value: thunderBloc),
                      BlocProvider(create: (context) => PostBloc()),
                    ],
                    child: PostPage(
                      selectedCommentId: widget.replies[index].comment.id,
                      selectedCommentPath: widget.replies[index].comment.path,
                      postId: widget.replies[index].post.id,
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
                        widget.replies[index].creator.name,
                        style: theme.textTheme.titleSmall?.copyWith(color: Colors.greenAccent),
                      ),
                      Text(formatTimeToString(dateTime: widget.replies[index].comment.published.toIso8601String()))
                    ],
                  ),
                  GestureDetector(
                    child: Text(
                      '${widget.replies[index].community.name}${' · ${fetchInstanceNameFromUrl(widget.replies[index].community.actorId)}'}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(0.75),
                      ),
                    ),
                    onTap: () => onTapCommunityName(context, widget.replies[index].community.id),
                  ),
                  const SizedBox(height: 10),
                  CommonMarkdownBody(body: widget.replies[index].comment.content),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (widget.replies[index].commentReply?.read == false)
                        // Check to see which reply is curremntly marked as read
                        inboxReplyMarkedAsRead != widget.replies[index].commentReply?.id
                            ? IconButton(
                                onPressed: () {
                                  setState(() => inboxReplyMarkedAsRead = widget.replies[index].commentReply?.id);
                                  context.read<InboxBloc>().add(MarkReplyAsReadEvent(commentReplyId: widget.replies[index].commentReply!.id, read: true));
                                },
                                icon: const Icon(
                                  Icons.check,
                                  semanticLabel: 'Mark as read',
                                ),
                                visualDensity: VisualDensity.compact,
                              )
                            : const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8.0),
                                child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator()),
                              ),
                      IconButton(
                        onPressed: () {
                          InboxBloc inboxBloc = context.read<InboxBloc>();
                          PostBloc postBloc = context.read<PostBloc>();
                          ThunderBloc thunderBloc = context.read<ThunderBloc>();

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
                                      BlocProvider<ThunderBloc>.value(value: thunderBloc),
                                    ],
                                    child: CreateCommentModal(comment: widget.replies[index].comment, parentCommentAuthor: widget.replies[index].creator.name),
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
      SwipeablePageRoute(
        canOnlySwipeFromEdge: disableFullPageSwipe(isUserLoggedIn: authBloc.state.isLoggedIn, state: thunderBloc.state, isFeedPage: true),
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
