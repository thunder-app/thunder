import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
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
import 'package:thunder/utils/swipe.dart';

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
    final bool reduceAnimations = state.reduceAnimations;

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
              transitionDuration: reduceAnimations ? const Duration(milliseconds: 100) : null,
              backGestureDetectionStartOffset: Platform.isAndroid ? 45 : 0,
              backGestureDetectionWidth: 45,
              canOnlySwipeFromEdge: disableFullPageSwipe(isUserLoggedIn: authBloc.state.isLoggedIn, state: thunderBloc.state, isPostPage: true),
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
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    comment.creator.name,
                    style: theme.textTheme.titleSmall?.copyWith(color: Colors.greenAccent),
                  ),
                  const SizedBox(width: 2.0),
                  Icon(
                    Icons.north_rounded,
                    size: 12.0 * state.contentFontSizeScale.textScaleFactor,
                    color: theme.colorScheme.onBackground,
                  ),
                  const SizedBox(width: 2.0),
                  Text(
                    formatNumberToK(upvotes),
                    semanticsLabel: '${formatNumberToK(upvotes)} upvotes',
                    textScaleFactor: MediaQuery.of(context).textScaleFactor * state.metadataFontSizeScale.textScaleFactor,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onBackground,
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
                      semanticsLabel: '${formatNumberToK(downvotes)} downvotes',
                      textScaleFactor: MediaQuery.of(context).textScaleFactor * state.metadataFontSizeScale.textScaleFactor,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: downvotes != 0 ? theme.colorScheme.onBackground : Colors.transparent,
                      ),
                    ),
                  Expanded(child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [Text(formatTimeToString(dateTime: comment.comment.published.toIso8601String()))]))
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
                children: [],
              )
            ],
          ),
        ),
      ),
    );
  }
}
