import 'dart:io';
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';

import 'package:thunder/account/bloc/account_bloc.dart';
import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/core/enums/local_settings.dart';
import 'package:thunder/core/models/post_view_media.dart';
import 'package:thunder/core/singletons/preferences.dart';
import 'package:thunder/feed/utils/utils.dart';
import 'package:thunder/feed/view/feed_page.dart';
import 'package:thunder/inbox/bloc/inbox_bloc.dart';
import 'package:thunder/post/bloc/post_bloc.dart';
import 'package:thunder/post/pages/post_page.dart';
import 'package:thunder/post/pages/create_comment_page.dart';
import 'package:thunder/shared/common_markdown_body.dart';
import 'package:thunder/shared/snackbar.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/utils/date_time.dart';
import 'package:thunder/utils/instance.dart';
import 'package:thunder/utils/swipe.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class InboxMentionsView extends StatelessWidget {
  final List<PersonMentionView> mentions;

  const InboxMentionsView({super.key, this.mentions = const []});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (mentions.isEmpty) {
      return Align(alignment: Alignment.topCenter, heightFactor: (MediaQuery.of(context).size.height / 27), child: const Text('No mentions'));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: mentions.length,
      itemBuilder: (context, index) {
        return Card(
          clipBehavior: Clip.hardEdge,
          child: InkWell(
            onTap: () async {
              AccountBloc accountBloc = context.read<AccountBloc>();
              AuthBloc authBloc = context.read<AuthBloc>();
              ThunderBloc thunderBloc = context.read<ThunderBloc>();

              final ThunderState state = context.read<ThunderBloc>().state;
              final bool reduceAnimations = state.reduceAnimations;

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
                    child: PostPage(
                        selectedCommentPath: mentions[index].comment.path,
                        selectedCommentId: mentions[index].comment.id,
                        postId: mentions[index].post.id,
                        onPostUpdated: (PostViewMedia postViewMedia) => {}),
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
                        onPressed: () async {
                          InboxBloc inboxBloc = context.read<InboxBloc>();
                          PostBloc postBloc = context.read<PostBloc>();
                          ThunderBloc thunderBloc = context.read<ThunderBloc>();
                          AccountBloc accountBloc = context.read<AccountBloc>();

                          final ThunderState state = context.read<ThunderBloc>().state;
                          final bool reduceAnimations = state.reduceAnimations;

                          SharedPreferences prefs = (await UserPreferences.instance).sharedPreferences;
                          DraftComment? newDraftComment;
                          DraftComment? previousDraftComment;
                          String draftId = '${LocalSettings.draftsCache.name}-${mentions[index].comment.id}';
                          String? draftCommentJson = prefs.getString(draftId);
                          if (draftCommentJson != null) {
                            previousDraftComment = DraftComment.fromJson(jsonDecode(draftCommentJson));
                          }
                          Timer timer = Timer.periodic(const Duration(seconds: 10), (Timer t) {
                            if (newDraftComment?.isNotEmpty == true) {
                              prefs.setString(draftId, jsonEncode(newDraftComment!.toJson()));
                            }
                          });

                          Navigator.of(context)
                              .push(
                            SwipeablePageRoute(
                              transitionDuration: reduceAnimations ? const Duration(milliseconds: 100) : null,
                              canOnlySwipeFromEdge: true,
                              backGestureDetectionWidth: 45,
                              builder: (context) {
                                return MultiBlocProvider(
                                    providers: [
                                      BlocProvider<InboxBloc>.value(value: inboxBloc),
                                      BlocProvider<PostBloc>.value(value: postBloc),
                                      BlocProvider<ThunderBloc>.value(value: thunderBloc),
                                      BlocProvider<AccountBloc>.value(value: accountBloc),
                                    ],
                                    child: CreateCommentPage(
                                      comment: mentions[index].comment,
                                      parentCommentAuthor: mentions[index].creator.name,
                                      previousDraftComment: previousDraftComment,
                                      onUpdateDraft: (c) => newDraftComment = c,
                                    ));
                              },
                            ),
                          )
                              .whenComplete(() async {
                            timer.cancel();

                            if (newDraftComment?.saveAsDraft == true && newDraftComment?.isNotEmpty == true) {
                              await Future.delayed(const Duration(milliseconds: 300));
                              showSnackbar(context, AppLocalizations.of(context)!.commentSavedAsDraft);
                              prefs.setString(draftId, jsonEncode(newDraftComment!.toJson()));
                            } else {
                              prefs.remove(draftId);
                            }
                          });
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
    navigateToFeedPage(context, feedType: FeedType.community, communityId: communityId);
  }
}
