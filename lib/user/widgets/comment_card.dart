import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:thunder/account/bloc/account_bloc.dart';
import 'package:thunder/community/utils/post_card_action_helpers.dart';
import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/core/enums/font_scale.dart';
import 'package:thunder/post/bloc/post_bloc.dart';
import 'package:thunder/post/pages/post_page.dart';
import 'package:thunder/shared/common_markdown_body.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/utils/date_time.dart';
import 'package:thunder/utils/instance.dart';

import '../../utils/numbers.dart';

class CommentCard extends StatelessWidget {
  final CommentView comment;

  const CommentCard({super.key, required this.comment});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    int upvotes = comment.counts.upvotes ?? 0;
    int downvotes = comment.counts.downvotes ?? 0;

    final ThunderState state = context.read<ThunderBloc>().state;

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
                child: PostPage(postId: comment.post.id, selectedCommentPath: comment.comment.path, selectedCommentId: comment.comment.id, onPostUpdated: () => {}),
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
                          comment.post.name,
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
                        '${comment.community.name}${' · ${fetchInstanceNameFromUrl(comment.community.actorId)}'}',
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
                        comment.creator.name,
                        style: theme.textTheme.titleSmall,
                      ),
                      const SizedBox(width: 8.0),
                      Icon(
                        Icons.north_rounded,
                        size: 12.0 * state.contentFontSizeScale.textScaleFactor,
                        color: comment.myVote == VoteType.up ? Colors.orange : theme.colorScheme.onBackground,
                      ),
                      const SizedBox(width: 2.0),
                      Text(
                        formatNumberToK(upvotes),
                        semanticsLabel: '${formatNumberToK(upvotes)} upvotes',
                        textScaleFactor: state.contentFontSizeScale.textScaleFactor,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: comment.myVote == VoteType.up ? Colors.orange : theme.colorScheme.onBackground,
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
                      Text(formatTimeToString(dateTime: comment.comment.published.toIso8601String())),
                    ],
                  ),
                  const SizedBox(height: 10),
                  CommonMarkdownBody(body: comment.comment.content),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
