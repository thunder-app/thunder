import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lemmy_api_client/v3.dart';

import 'package:thunder/account/bloc/account_bloc.dart';
import 'package:thunder/community/pages/community_page.dart';
import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/core/enums/font_scale.dart';
import 'package:thunder/inbox/bloc/inbox_bloc.dart';
import 'package:thunder/post/bloc/post_bloc.dart';
import 'package:thunder/post/pages/post_page.dart';
import 'package:thunder/post/widgets/create_comment_modal.dart';
import 'package:thunder/shared/common_markdown_body.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/utils/date_time.dart';
import 'package:thunder/utils/instance.dart';

import '../../utils/numbers.dart';

class InboxMentionsView extends StatelessWidget {
  final List<PersonMentionView> mentions;

  const InboxMentionsView({super.key, this.mentions = const []});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ThunderState state = context.read<ThunderBloc>().state;

    if (mentions.isEmpty) {
      return Align(alignment: Alignment.topCenter, heightFactor: (MediaQuery.of(context).size.height / 27), child: const Text('No mentions'));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: mentions.length,
      itemBuilder: (context, index) {
        int upvotes = mentions[index].counts.upvotes ?? 0;
        int downvotes = mentions[index].counts.downvotes ?? 0;
        return Container(
          margin: const EdgeInsets.only(top: 4),
          /*clipBehavior: Clip.hardEdge,*/
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
                    child: PostPage(postId: mentions[index].post.id, selectedCommentPath: mentions[index].comment.path, selectedCommentId: mentions[index].comment.id, onPostUpdated: () => {}),
                  ),
                ),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Divider(
                  height: 1.0,
                  thickness: 4.0,
                  color: ElevationOverlay.applySurfaceTint(
                    Theme.of(context).colorScheme.surface,
                    Theme.of(context).colorScheme.surfaceTint,
                    10,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              mentions[index].post.name,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            'in ',
                            textScaleFactor: state.contentFontSizeScale.textScaleFactor,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.4),
                            ),
                          ),
                          Text(
                            '${mentions[index].community.name}${' · ${fetchInstanceNameFromUrl(mentions[index].community.actorId)}'}',
                            textScaleFactor: state.contentFontSizeScale.textScaleFactor,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.75),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.only(left: 18.0, right: 8, top: 8, bottom: 16,),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            mentions[index].creator.name,
                            style: theme.textTheme.titleSmall,
                          ),
                          const SizedBox(width: 8.0),
                          Icon(
                            Icons.north_rounded,
                            size: 12.0 * state.contentFontSizeScale.textScaleFactor,
                            color: mentions[index].myVote == VoteType.up ? Colors.orange : theme.colorScheme.onBackground,
                          ),
                          const SizedBox(width: 2.0),
                          Text(
                            formatNumberToK(upvotes),
                            semanticsLabel: '${formatNumberToK(upvotes)} upvotes',
                            textScaleFactor: state.contentFontSizeScale.textScaleFactor,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: mentions[index].myVote == VoteType.up ? Colors.orange : theme.colorScheme.onBackground,
                            ),
                          ),
                          const SizedBox(width: 10.0),
                          Icon(
                            Icons.south_rounded,
                            size: 12.0 * state.contentFontSizeScale.textScaleFactor,
                            color: downvotes != 0 ? theme.colorScheme.onBackground : Colors.transparent,
                          ),
                          const SizedBox(width: 2.0),
                          if (downvotes != 0)
                            Text(
                              formatNumberToK(downvotes),
                              semanticsLabel: '${formatNumberToK(upvotes)} downvotes',
                              textScaleFactor: state.contentFontSizeScale.textScaleFactor,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: downvotes != 0 ? theme.colorScheme.onBackground : Colors.transparent,
                              ),
                            ),
                          const Spacer(),
                          Text(formatTimeToString(dateTime: mentions[index].comment.published.toIso8601String())),
                        ],
                      ),
                      const SizedBox(height: 10),
                      CommonMarkdownBody(body: mentions[index].comment.content),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
        /*return Card(
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
                    child: PostPage(selectedCommentPath: mentions[index].comment.path, selectedCommentId: mentions[index].comment.id, postId: mentions[index].post.id, onPostUpdated: () => {}),
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
                        mentions[index].creator.name,
                        style: theme.textTheme.titleSmall?.copyWith(color: Colors.greenAccent),
                      ),
                      Text(formatTimeToString(dateTime: mentions[index].comment.published.toIso8601String()))
                    ],
                  ),
                  GestureDetector(
                    child: Text(
                      '${mentions[index].community.name}${' · ${fetchInstanceNameFromUrl(mentions[index].community.actorId)}'}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(0.75),
                      ),
                    ),
                    onTap: () => onTapCommunityName(context, mentions[index].community.id),
                  ),
                  const SizedBox(height: 10),
                  CommonMarkdownBody(body: mentions[index].comment.content),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (mentions[index].personMention.read == false)
                        IconButton(
                          onPressed: () {
                            context.read<InboxBloc>().add(MarkMentionAsReadEvent(personMentionId: mentions[index].personMention.id, read: true));
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
                                      BlocProvider<ThunderBloc>.value(value: thunderBloc),
                                    ],
                                    child: CreateCommentModal(comment: mentions[index].comment, parentCommentAuthor: mentions[index].creator.name),
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
        );*/
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
