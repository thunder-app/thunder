import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import 'package:thunder/account/bloc/account_bloc.dart';
import 'package:thunder/core/enums/local_settings.dart';

import 'package:thunder/core/models/post_view_media.dart';
import 'package:thunder/core/models/comment_view_tree.dart';
import 'package:thunder/core/singletons/preferences.dart';
import 'package:thunder/post/bloc/post_bloc.dart';
import 'package:thunder/post/utils/comment_action_helpers.dart';
import 'package:thunder/post/widgets/comment_view.dart';
import 'package:thunder/shared/snackbar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../thunder/bloc/thunder_bloc.dart';
import 'create_comment_page.dart';

class PostPageSuccess extends StatefulWidget {
  final PostViewMedia postView;
  final List<CommentViewTree> comments;
  final int? selectedCommentId;
  final String? selectedCommentPath;
  final int? newlyCreatedCommentId;
  final int? moddingCommentId;

  final ItemScrollController itemScrollController;
  final ItemPositionsListener itemPositionsListener;
  final bool hasReachedCommentEnd;

  final bool viewFullCommentsRefreshing;

  final List<CommunityModeratorView>? moderators;
  final List<PostView>? crossPosts;

  const PostPageSuccess({
    super.key,
    required this.postView,
    this.comments = const [],
    required this.itemScrollController,
    required this.itemPositionsListener,
    this.hasReachedCommentEnd = false,
    this.selectedCommentId,
    this.selectedCommentPath,
    this.newlyCreatedCommentId,
    this.moddingCommentId,
    this.viewFullCommentsRefreshing = false,
    required this.moderators,
    required this.crossPosts,
  });

  @override
  State<PostPageSuccess> createState() => _PostPageSuccessState();
}

class _PostPageSuccessState extends State<PostPageSuccess> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => widget.itemScrollController.primaryScrollController?.addListener(_onScroll));
  }

  void _onScroll() {
    // We don't want to trigger comment fetch when looking at a comment context.
    // This also fixes a weird behavior that can happen when if the fetch triggers
    // right before you click view all comments. The fetch for all comments won't happen.
    if (widget.selectedCommentId != null || widget.hasReachedCommentEnd) {
      return;
    }
    if ((widget.itemScrollController.primaryScrollController?.position.pixels ?? 0) >= (widget.itemScrollController.primaryScrollController?.position.maxScrollExtent ?? 0) * 0.6) {
      context.read<PostBloc>().add(const GetPostCommentsEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: CommentSubview(
            viewFullCommentsRefreshing: widget.viewFullCommentsRefreshing,
            moddingCommentId: widget.moddingCommentId,
            selectedCommentId: widget.selectedCommentId,
            selectedCommentPath: widget.selectedCommentPath,
            newlyCreatedCommentId: widget.newlyCreatedCommentId,
            now: DateTime.now().toUtc(),
            itemScrollController: widget.itemScrollController,
            itemPositionsListener: widget.itemPositionsListener,
            postViewMedia: widget.postView,
            comments: widget.comments,
            hasReachedCommentEnd: widget.hasReachedCommentEnd,
            onVoteAction: (int commentId, int voteType) => context.read<PostBloc>().add(VoteCommentEvent(commentId: commentId, score: voteType)),
            onSaveAction: (int commentId, bool save) => context.read<PostBloc>().add(SaveCommentEvent(commentId: commentId, save: save)),
            onDeleteAction: (int commentId, bool deleted) => context.read<PostBloc>().add(DeleteCommentEvent(deleted: deleted, commentId: commentId)),
            onReportAction: (int commentId) {
              showReportCommentActionBottomSheet(
                context,
                commentId: commentId,
              );
            },
            onReplyEditAction: (CommentView commentView, bool isEdit) async {
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
                  showSnackbar(AppLocalizations.of(context)!.commentSavedAsDraft);
                  prefs.setString(draftId, jsonEncode(newDraftComment!.toJson()));
                } else {
                  prefs.remove(draftId);
                }
              });
            },
            moderators: widget.moderators,
            crossPosts: widget.crossPosts,
          ),
        ),
      ],
    );
  }
}
