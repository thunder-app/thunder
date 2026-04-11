import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:super_sliver_list/super_sliver_list.dart';

import 'package:thunder/src/app/shell/state/shell_chrome_cubit.dart';
import 'package:thunder/src/app/state/thunder/thunder_bloc.dart';
import 'package:thunder/src/foundation/config/global_context.dart';
import 'package:thunder/src/app/shell/navigation/navigation_utils.dart';
import 'package:thunder/src/features/feed/api.dart';
import 'package:thunder/src/foundation/primitives/primitives.dart';
import 'package:thunder/src/features/comment/comment.dart';
import 'package:thunder/src/features/post/post.dart';
import 'package:thunder/src/features/session/api.dart';
import 'package:thunder/src/shared/sort_picker.dart';
import 'package:thunder/src/shared/fabs/gesture_fab.dart';

import 'package:thunder/src/shared/fabs/comment_navigator_fab.dart';
import 'package:thunder/packages/ui/ui.dart' show showSnackbar, showThunderTypeaheadDialog;

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

    final account = resolveEffectiveAccount(context);
    final commentSortType = context.read<PostBloc>().state.commentSortType;

    HapticFeedback.mediumImpact();

    showModalBottomSheet<void>(
      showDragHandle: true,
      context: context,
      builder: (builderContext) => SortPicker<CommentSortType>(
        account: account,
        title: l10n.sortOptions,
        onSelect: (selected) async {
          await widget.scrollController.animateTo(0, duration: const Duration(milliseconds: 250), curve: Curves.easeInOutCubicEmphasized);
          if (context.mounted) {
            context.read<PostBloc>().add(GetPostCommentsEvent(commentSortType: selected.payload, reset: true));
          }
        },
        previouslySelected: commentSortType,
      ),
    );
  }

  void replyToPost(BuildContext context, ThunderPost? post, {bool postLocked = false}) async {
    final l10n = GlobalContext.l10n;
    final isLoggedIn = !resolveEffectiveAccount(context).anonymous;

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
        final navigationCubit = context.read<PostNavigationCubit>();
        final isSearchInProgress = navigationCubit.state.commentSearchResults != null;

        if (isSearchInProgress) {
          navigationCubit.endCommentSearch();
          return;
        }

        showThunderTypeaheadDialog<String>(
          context: context,
          title: l10n.searchComments,
          inputLabel: l10n.searchTerm,
          primaryButtonText: l10n.ok,
          secondaryButtonText: l10n.cancel,
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
              context.read<PostNavigationCubit>().startCommentSearch(commentSearchResults);
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

    final combineNavAndFab = context.select<FabPreferencesCubit, bool>((cubit) => cubit.state.combineNavAndFab);
    final isFabSummoned = context.select<ShellChromeCubit, bool>((cubit) => cubit.state.isPostFabSummoned);
    final singlePressAction = context.select<FabPreferencesCubit, PostFabAction>((cubit) => cubit.state.postFabSinglePressAction);
    final longPressAction = context.select<FabPreferencesCubit, PostFabAction>((cubit) => cubit.state.postFabLongPressAction);
    final hideTopBarOnScroll = context.select<ThunderCubit, bool>((bloc) => bloc.state.hideTopBarOnScroll);
    final enableCommentNavigation = context.select<FabPreferencesCubit, bool>((cubit) => cubit.state.enableCommentNavigation);
    final enablePostsFab = context.select<FabPreferencesCubit, bool>((cubit) => cubit.state.enablePostsFab);
    final postFabEnableRefresh = context.select<FabPreferencesCubit, bool>((cubit) => cubit.state.postFabEnableRefresh);
    final postFabEnableReplyToPost = context.select<FabPreferencesCubit, bool>((cubit) => cubit.state.postFabEnableReplyToPost);
    final postFabEnableChangeSort = context.select<FabPreferencesCubit, bool>((cubit) => cubit.state.postFabEnableChangeSort);
    final postFabEnableBackToTop = context.select<FabPreferencesCubit, bool>((cubit) => cubit.state.postFabEnableBackToTop);
    final postFabEnableSearch = context.select<FabPreferencesCubit, bool>((cubit) => cubit.state.postFabEnableSearch);

    final double statusBarHeight = MediaQuery.of(context).padding.top;

    final highlightedCommentId = context.select<PostNavigationCubit, int?>((cubit) => cubit.state.highlightedCommentId);
    final selectedCommentPath = context.select<PostBloc, String?>((bloc) => bloc.state.selectedCommentPath);
    final isSearchInProgress = context.select<PostNavigationCubit, bool>((cubit) => cubit.state.commentSearchResults != null);

    return Stack(
      alignment: Alignment.center,
      children: [
        if (enableCommentNavigation)
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
                  statusBarHeight: hideTopBarOnScroll ? statusBarHeight : 0,
                ),
              ),
            ),
          ),
        if (enablePostsFab)
          Padding(
            padding: EdgeInsets.only(right: combineNavAndFab ? 0 : 16, bottom: combineNavAndFab ? 5 : 0),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: isFabSummoned
                  ? GestureFab(
                      centered: combineNavAndFab,
                      distance: combineNavAndFab ? 45 : 60,
                      icon: Icon(
                        isSearchInProgress ? Icons.youtube_searched_for_rounded : singlePressAction.getIcon(postLocked: widget.post.locked),
                        semanticLabel: isSearchInProgress ? l10n.search : singlePressAction.getTitle(context, postLocked: widget.post.locked),
                        size: 35,
                      ),
                      onPressed: isSearchInProgress
                          ? () {
                              context.read<PostNavigationCubit>().continueCommentSearch();
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
                      fabType: FabType.post,
                      children: [
                        if (postFabEnableRefresh)
                          ActionButton(
                            fabType: FabType.post,
                            centered: combineNavAndFab,
                            onPressed: () {
                              HapticFeedback.mediumImpact();

                              final navigationState = context.read<PostNavigationCubit>().state;
                              if (navigationState.highlightedCommentId != null) {
                                // If we're viewing a specific comment thread, refresh with that context unless "View All Comments" is pressed
                                PostFabAction.refresh.execute(
                                  context: context,
                                  postId: widget.post.id,
                                  selectedCommentPath: selectedCommentPath,
                                );
                              } else {
                                PostFabAction.refresh.execute(
                                  context: context,
                                  postId: widget.post.id,
                                );
                              }
                            },
                            title: PostFabAction.refresh.getTitle(context),
                            icon: Icon(PostFabAction.refresh.getIcon()),
                          ),
                        if (postFabEnableReplyToPost)
                          ActionButton(
                            fabType: FabType.post,
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
                        if (postFabEnableChangeSort)
                          ActionButton(
                            fabType: FabType.post,
                            centered: combineNavAndFab,
                            onPressed: () {
                              HapticFeedback.mediumImpact();
                              PostFabAction.changeSort.execute(override: () => showSortBottomSheet(context));
                            },
                            title: PostFabAction.changeSort.getTitle(context),
                            icon: Icon(PostFabAction.changeSort.getIcon()),
                          ),
                        if (postFabEnableBackToTop)
                          ActionButton(
                            fabType: FabType.post,
                            centered: combineNavAndFab,
                            onPressed: () {
                              PostFabAction.backToTop
                                  .execute(override: () => {widget.scrollController.animateTo(0, duration: const Duration(milliseconds: 250), curve: Curves.easeInOutCubicEmphasized)});
                            },
                            title: PostFabAction.backToTop.getTitle(context),
                            icon: Icon(PostFabAction.backToTop.getIcon()),
                          ),
                        if (postFabEnableSearch)
                          ActionButton(
                            fabType: FabType.post,
                            centered: combineNavAndFab,
                            onPressed: () => startCommentSearch(context),
                            title: isSearchInProgress ? l10n.endSearch : PostFabAction.search.getTitle(context),
                            icon: Icon(isSearchInProgress ? Icons.search_off_rounded : PostFabAction.search.getIcon()),
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
