import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:super_sliver_list/super_sliver_list.dart';

import 'package:thunder/src/app/thunder.dart';
import 'package:thunder/src/app/utils/global_context.dart';
import 'package:thunder/src/app/utils/navigation.dart';
import 'package:thunder/src/core/enums/fab_action.dart';
import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/features/comment/comment.dart';
import 'package:thunder/src/features/post/post.dart';
import 'package:thunder/src/shared/comment_sort_picker.dart';
import 'package:thunder/src/shared/gesture_fab.dart';
import 'package:thunder/src/shared/input_dialogs.dart';
import 'package:thunder/src/shared/snackbar.dart';
import 'package:thunder/src/shared/widgets/comment_navigator_fab.dart';

/// The FAB for the post page.
class PostPageFAB extends StatefulWidget {
  /// The post information - used for various actions.
  final ThunderPost post;

  /// The list of comments - used for the comment navigator FAB.
  final List<CommentNode> comments;

  /// The list controller - used for the comment navigator FAB.
  final ListController listController;

  /// The scroll controller - used for the comment navigator FAB.
  final ScrollController scrollController;

  const PostPageFAB({super.key, required this.post, required this.comments, required this.scrollController, required this.listController});

  @override
  State<PostPageFAB> createState() => _PostPageFABState();
}

class _PostPageFABState extends State<PostPageFAB> {
  @override
  void initState() {
    super.initState();
  }

  void showSortBottomSheet(BuildContext context) {
    final l10n = GlobalContext.l10n;

    final account = context.read<ProfileBloc>().state.account;
    final commentSortType = context.read<PostBloc>().state.commentSortType;

    HapticFeedback.mediumImpact();

    showModalBottomSheet<void>(
      showDragHandle: true,
      context: context,
      builder: (builderContext) => CommentSortPicker(
        account: account,
        title: l10n.sortOptions,
        onSelect: (selected) async {
          await widget.scrollController.animateTo(0, duration: const Duration(milliseconds: 250), curve: Curves.easeInOutCubicEmphasized);
          if (context.mounted) context.read<PostBloc>().add(GetPostCommentsEvent(commentSortType: selected.payload, reset: true));
        },
        previouslySelected: commentSortType,
      ),
    );
  }

  void replyToPost(BuildContext context, ThunderPost? post, {bool postLocked = false}) async {
    final l10n = GlobalContext.l10n;
    final isLoggedIn = context.read<ProfileBloc>().state.isLoggedIn;

    if (postLocked) return showSnackbar(l10n.postLocked);
    if (!isLoggedIn) return showSnackbar(l10n.mustBeLoggedInComment);

    navigateToCreateCommentPage(
      context,
      post: post,
      onCommentSuccess: (comment, userChanged) {
        if (!userChanged) {
          context.read<PostBloc>().add(CommentItemInsertedEvent(comment: comment));
        }
      },
    );
  }

  void startCommentSearch(BuildContext context) {
    PostFabAction.search.execute(
      override: () {
        final l10n = GlobalContext.l10n;
        final status = context.read<PostBloc>().state.status;

        if (status == PostStatus.searchInProgress) {
          context.read<PostBloc>().add(const EndCommentSearchEvent());
          return;
        }

        showInputDialog<String>(
          context: context,
          title: l10n.searchComments,
          inputLabel: l10n.searchTerm,
          onSubmitted: ({payload, value}) {
            Navigator.of(context).pop();
            Map<int, int> commentSearchResults = {};

            final commentNodes = context.read<PostBloc>().state.commentNodes;

            if (commentNodes != null) {
              final comments = commentNodes.flatten();

              for (int index = 0; index < comments.length; index++) {
                final comment = comments[index];
                if (comment.comment?.content.contains(RegExp(value!, caseSensitive: false)) == true) {
                  commentSearchResults[index] = comment.comment!.id;
                }
              }
            }

            if (commentSearchResults.isEmpty) {
              showSnackbar(l10n.noResultsFound);
            } else {
              context.read<PostBloc>().add(StartCommentSearchEvent(commentSearchResults: commentSearchResults));
            }

            return Future.value(null);
          },
          getSuggestions: (_) => [],
          suggestionBuilder: (payload) => Container(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = GlobalContext.l10n;

    final thunderState = context.read<ThunderBloc>().state;
    final combineNavAndFab = thunderState.combineNavAndFab;
    final isFabSummoned = thunderState.isFabSummoned;
    final singlePressAction = thunderState.postFabSinglePressAction;
    final longPressAction = thunderState.postFabLongPressAction;

    final double statusBarHeight = MediaQuery.of(context).padding.top;

    final status = context.select<PostBloc, PostStatus>((bloc) => bloc.state.status);
    final highlightedCommentId = context.select<PostBloc, int?>((bloc) => bloc.state.highlightedCommentId);
    final selectedCommentPath = context.select<PostBloc, String?>((bloc) => bloc.state.selectedCommentPath);

    return Stack(
      alignment: Alignment.center,
      children: [
        if (thunderState.enableCommentNavigation)
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: CommentNavigatorFab(
                  initialIndex: 0,
                  maxIndex: widget.listController.isAttached ? widget.listController.numberOfItems - 1 : 0,
                  scrollController: widget.scrollController,
                  listController: widget.listController,
                  comments: widget.comments,
                  statusBarHeight: thunderState.hideTopBarOnScroll ? statusBarHeight : 0,
                ),
              ),
            ),
          ),
        if (thunderState.enablePostsFab)
          Padding(
            padding: EdgeInsets.only(right: combineNavAndFab ? 0 : 16, bottom: combineNavAndFab ? 5 : 0),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: isFabSummoned
                  ? GestureFab(
                      centered: combineNavAndFab,
                      distance: combineNavAndFab ? 45 : 60,
                      icon: Icon(
                        status == PostStatus.searchInProgress ? Icons.youtube_searched_for_rounded : singlePressAction.getIcon(postLocked: widget.post.locked),
                        semanticLabel: status == PostStatus.searchInProgress ? l10n.search : singlePressAction.getTitle(context, postLocked: widget.post.locked),
                        size: 35,
                      ),
                      onPressed: status == PostStatus.searchInProgress
                          ? () {
                              context.read<PostBloc>().add(const ContinueCommentSearchEvent());
                            }
                          : () => singlePressAction.execute(
                              context: context,
                              post: widget.post,
                              postId: widget.post.id,
                              highlightedCommentId: highlightedCommentId,
                              selectedCommentPath: selectedCommentPath,
                              override: singlePressAction == PostFabAction.backToTop
                                  ? () => {
                                        widget.listController.animateToItem(
                                          index: 0,
                                          scrollController: widget.scrollController,
                                          alignment: 0,
                                          duration: (estimatedDistance) => const Duration(milliseconds: 250),
                                          curve: (estimatedDistance) => Curves.easeInOutCubicEmphasized,
                                        ),
                                      }
                                  : singlePressAction == PostFabAction.changeSort
                                      ? () => showSortBottomSheet(context)
                                      : singlePressAction == PostFabAction.replyToPost
                                          ? () => replyToPost(context, widget.post, postLocked: widget.post.locked)
                                          : singlePressAction == PostFabAction.search
                                              ? () => startCommentSearch(context)
                                              : null),
                      onLongPress: () => longPressAction.execute(
                          context: context,
                          post: widget.post,
                          postId: widget.post.id,
                          highlightedCommentId: highlightedCommentId,
                          selectedCommentPath: selectedCommentPath,
                          override: longPressAction == PostFabAction.backToTop
                              ? () => {
                                    widget.listController.animateToItem(
                                      index: 0,
                                      scrollController: widget.scrollController,
                                      alignment: 0,
                                      duration: (estimatedDistance) => const Duration(milliseconds: 250),
                                      curve: (estimatedDistance) => Curves.easeInOutCubicEmphasized,
                                    ),
                                  }
                              : longPressAction == PostFabAction.changeSort
                                  ? () => showSortBottomSheet(context)
                                  : longPressAction == PostFabAction.replyToPost
                                      ? () => replyToPost(context, widget.post, postLocked: widget.post.locked)
                                      : null),
                      children: [
                        if (thunderState.postFabEnableRefresh)
                          ActionButton(
                            centered: combineNavAndFab,
                            onPressed: () {
                              HapticFeedback.mediumImpact();

                              if (highlightedCommentId != null) {
                                // If we're viewing a specific comment thread, refresh with that context unless "View All Comments" is pressed
                                PostFabAction.refresh.execute(
                                  context: context,
                                  post: widget.post,
                                  postId: widget.post.id,
                                  highlightedCommentId: highlightedCommentId,
                                  selectedCommentPath: selectedCommentPath,
                                );
                              } else {
                                PostFabAction.refresh.execute(
                                  context: context,
                                  post: widget.post,
                                  postId: widget.post.id,
                                );
                              }
                            },
                            title: PostFabAction.refresh.getTitle(context),
                            icon: Icon(PostFabAction.refresh.getIcon()),
                          ),
                        if (thunderState.postFabEnableReplyToPost)
                          ActionButton(
                            centered: combineNavAndFab,
                            onPressed: () {
                              HapticFeedback.mediumImpact();
                              PostFabAction.replyToPost.execute(
                                override: () => replyToPost(context, widget.post, postLocked: widget.post.locked),
                              );
                            },
                            title: PostFabAction.replyToPost.getTitle(context),
                            icon: Icon(widget.post.locked ? Icons.lock : PostFabAction.replyToPost.getIcon()),
                          ),
                        if (thunderState.enableChangeSort)
                          ActionButton(
                            centered: combineNavAndFab,
                            onPressed: () {
                              HapticFeedback.mediumImpact();
                              PostFabAction.changeSort.execute(override: () => showSortBottomSheet(context));
                            },
                            title: PostFabAction.changeSort.getTitle(context),
                            icon: Icon(PostFabAction.changeSort.getIcon()),
                          ),
                        if (thunderState.enableBackToTop)
                          ActionButton(
                            centered: combineNavAndFab,
                            onPressed: () {
                              PostFabAction.backToTop
                                  .execute(override: () => {widget.scrollController.animateTo(0, duration: const Duration(milliseconds: 250), curve: Curves.easeInOutCubicEmphasized)});
                            },
                            title: PostFabAction.backToTop.getTitle(context),
                            icon: Icon(PostFabAction.backToTop.getIcon()),
                          ),
                        if (thunderState.postFabEnableSearch)
                          ActionButton(
                            centered: combineNavAndFab,
                            onPressed: () => startCommentSearch(context),
                            title: status == PostStatus.searchInProgress ? l10n.endSearch : PostFabAction.search.getTitle(context),
                            icon: Icon(status == PostStatus.searchInProgress ? Icons.search_off_rounded : PostFabAction.search.getIcon()),
                          ),
                      ],
                    )
                  : null,
            ),
          ),
      ],
    );
  }
}
