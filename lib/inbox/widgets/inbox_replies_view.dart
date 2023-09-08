import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';

import 'package:thunder/account/bloc/account_bloc.dart';
import 'package:thunder/community/pages/community_page.dart';
import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/core/enums/local_settings.dart';
import 'package:thunder/core/singletons/preferences.dart';

import 'package:thunder/inbox/bloc/inbox_bloc.dart';
import 'package:thunder/post/bloc/post_bloc.dart';
import 'package:thunder/shared/comment_reference.dart';
import 'package:thunder/post/pages/create_comment_page.dart';
import 'package:thunder/shared/snackbar.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/utils/swipe.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
    final DateTime now = DateTime.now().toUtc();
    final theme = Theme.of(context);

    if (widget.replies.isEmpty) {
      return Align(alignment: Alignment.topCenter, heightFactor: (MediaQuery.of(context).size.height / 27), child: const Text('No replies'));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.replies.length,
      itemBuilder: (context, index) {
        return Column(
          children: [
            Divider(
              height: 1.0,
              thickness: 1.0,
              color: ElevationOverlay.applySurfaceTint(
                Theme.of(context).colorScheme.surface,
                Theme.of(context).colorScheme.surfaceTint,
                10,
              ),
            ),
            CommentReference(
              comment: widget.replies[index],
              now: now,
              onVoteAction: (int commentId, VoteType voteType) => context.read<PostBloc>().add(VoteCommentEvent(commentId: commentId, score: voteType)),
              onSaveAction: (int commentId, bool save) => context.read<PostBloc>().add(SaveCommentEvent(commentId: commentId, save: save)),
              onDeleteAction: (int commentId, bool deleted) => context.read<PostBloc>().add(DeleteCommentEvent(deleted: deleted, commentId: commentId)),
              onReplyEditAction: (CommentView commentView, bool isEdit) async {
                HapticFeedback.mediumImpact();
                InboxBloc inboxBloc = context.read<InboxBloc>();
                PostBloc postBloc = context.read<PostBloc>();
                ThunderBloc thunderBloc = context.read<ThunderBloc>();
                AccountBloc accountBloc = context.read<AccountBloc>();

                SharedPreferences prefs = (await UserPreferences.instance).sharedPreferences;
                DraftComment? newDraftComment;
                DraftComment? previousDraftComment;
                String draftId = '${LocalSettings.draftsCache.name}-${commentView.comment.id}';
                String? draftCommentJson = prefs.getString(draftId);
                if (draftCommentJson != null) {
                  previousDraftComment = DraftComment.fromJson(jsonDecode(draftCommentJson));
                }
                Timer timer = Timer.periodic(const Duration(seconds: 10), (Timer t) {
                  if (newDraftComment?.isNotEmpty == true) {
                    prefs.setString(draftId, jsonEncode(newDraftComment!.toJson()));
                  }
                });

                Navigator.of(context).push(
                  SwipeablePageRoute(
                    builder: (context) {
                      return MultiBlocProvider(
                          providers: [
                            BlocProvider<InboxBloc>.value(value: inboxBloc),
                            BlocProvider<PostBloc>.value(value: postBloc),
                            BlocProvider<ThunderBloc>.value(value: thunderBloc),
                            BlocProvider<AccountBloc>.value(value: accountBloc),
                          ],
                          child: CreateCommentPage(
                            commentView: commentView,
                            isEdit: isEdit,
                            previousDraftComment: previousDraftComment,
                            onUpdateDraft: (c) => newDraftComment = c,
                          ));
                    },
                  ),
                ).whenComplete(() async {
                  timer.cancel();

                  if (newDraftComment?.saveAsDraft == true && newDraftComment?.isNotEmpty == true && (!isEdit || commentView.comment.content != newDraftComment?.text)) {
                    await Future.delayed(const Duration(milliseconds: 300));
                    showSnackbar(context, AppLocalizations.of(context)!.commentSavedAsDraft);
                    prefs.setString(draftId, jsonEncode(newDraftComment!.toJson()));
                  } else {
                    prefs.remove(draftId);
                  }
                });
              },
              isOwnComment: widget.replies[index].creator.id == context.read<AuthBloc>().state.account?.userId,
              child: widget.replies[index].commentReply?.read == false
                  ? inboxReplyMarkedAsRead != widget.replies[index].commentReply?.id
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
                        )
                  : null,
            ),
          ],
        );
      },
    );

    /*Card(
          clipBehavior: Clip.hardEdge,
          child: InkWell(
            onTap: () async {
              AccountBloc accountBloc = context.read<AccountBloc>();
              AuthBloc authBloc = context.read<AuthBloc>();
              ThunderBloc thunderBloc = context.read<ThunderBloc>();

              // To to specific post for now, in the future, will be best to scroll to the position of the comment
              await Navigator.of(context).push(
                SwipeablePageRoute(
                  backGestureDetectionStartOffset: 45,
                  canOnlySwipeFromEdge: disableFullPageSwipe(
                      isUserLoggedIn: authBloc.state.isLoggedIn,
                      state: thunderBloc.state,
                      isPostPage: true),
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.replies[index].creator.name,
                        style: theme.textTheme.titleSmall
                            ?.copyWith(color: Colors.greenAccent),
                      ),
                      Text(formatTimeToString(
                          dateTime: widget.replies[index].comment.published
                              .toIso8601String()))
                    ],
                  ),
                  GestureDetector(
                    child: Text(
                      '${widget.replies[index].community.name}${' · ${fetchInstanceNameFromUrl(widget.replies[index].community.actorId)}'}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodyMedium?.color
                            ?.withOpacity(0.75),
                      ),
                    ),
                    onTap: () => onTapCommunityName(
                        context, widget.replies[index].community.id),
                  ),
                  const SizedBox(height: 10),
                  CommonMarkdownBody(
                      body: widget.replies[index].comment.content),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Divider(
                        height: 1.0,
                        thickness: 1.0,
                        color: ElevationOverlay.applySurfaceTint(
                          Theme.of(context).colorScheme.surface,
                          Theme.of(context).colorScheme.surfaceTint,
                          10,
                        ),
                      ),
                      CommentReference(
                        comment: widget.replies[index],
                        now: now,
                        onVoteAction: (int commentId, VoteType voteType) =>
                            context.read<PostBloc>().add(VoteCommentEvent(
                                commentId: commentId, score: voteType)),
                        onSaveAction: (int commentId, bool save) => context
                            .read<PostBloc>()
                            .add(SaveCommentEvent(
                                commentId: commentId, save: save)),
                        onDeleteAction: (int commentId, bool deleted) => context
                            .read<PostBloc>()
                            .add(DeleteCommentEvent(
                                deleted: deleted, commentId: commentId)),
                        onReplyEditAction:
                            (CommentView commentView, bool isEdit) {
                          HapticFeedback.mediumImpact();
                          InboxBloc inboxBloc = context.read<InboxBloc>();
                          PostBloc postBloc = context.read<PostBloc>();
                          ThunderBloc thunderBloc = context.read<ThunderBloc>();
                          AccountBloc accountBloc = context.read<AccountBloc>();

                          Navigator.of(context).push(
                            SwipeablePageRoute(
                              builder: (context) {
                                return MultiBlocProvider(
                                    providers: [
                                      BlocProvider<InboxBloc>.value(
                                          value: inboxBloc),
                                      BlocProvider<PostBloc>.value(
                                          value: postBloc),
                                      BlocProvider<ThunderBloc>.value(
                                          value: thunderBloc),
                                      BlocProvider<AccountBloc>.value(
                                          value: accountBloc),
                                    ],
                                    child: CreateCommentPage(
                                        commentView: commentView,
                                        isEdit: isEdit));
                              },
                            ),
                          );
                        },
                        isOwnComment: widget.replies[index].creator.id ==
                            context.read<AuthBloc>().state.account?.userId,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (widget.replies[index].commentReply?.read ==
                                false)
                              inboxReplyMarkedAsRead !=
                                      widget.replies[index].commentReply?.id
                                  ? IconButton(
                                      onPressed: () {
                                        setState(() => inboxReplyMarkedAsRead =
                                            widget.replies[index].commentReply
                                                ?.id);
                                        context.read<InboxBloc>().add(
                                            MarkReplyAsReadEvent(
                                                commentReplyId: widget
                                                    .replies[index]
                                                    .commentReply!
                                                    .id,
                                                read: true));
                                      },
                                      icon: const Icon(
                                        Icons.check,
                                        semanticLabel: 'Mark as read',
                                      ),
                                      visualDensity: VisualDensity.compact,
                                    )
                                  : const Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 8.0),
                                      child: SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator()),
                                    ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );*/
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
