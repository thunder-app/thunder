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
import 'package:thunder/utils/navigate_community.dart';
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

                final ThunderState state = context.read<ThunderBloc>().state;
                final bool reduceAnimations = state.reduceAnimations;

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
                            commentView: commentView,
                            isEdit: isEdit,
                            previousDraftComment: previousDraftComment,
                            onUpdateDraft: (c) => newDraftComment = c,
                          ));
                    },
                  ),
                )
                    .whenComplete(() async {
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
  }

  void onTapCommunityName(BuildContext context, int communityId) {
    navigateToCommunityPage(context, communityId: communityId);
  }
}
