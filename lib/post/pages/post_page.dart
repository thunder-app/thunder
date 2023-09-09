import 'dart:async';
import 'dart:convert';

import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import 'package:thunder/account/bloc/account_bloc.dart';
import 'package:thunder/community/bloc/community_bloc.dart';
import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/core/enums/fab_action.dart';
import 'package:thunder/core/enums/local_settings.dart';
import 'package:thunder/core/models/post_view_media.dart';
import 'package:thunder/core/singletons/preferences.dart';
import 'package:thunder/post/bloc/post_bloc.dart';
import 'package:thunder/post/pages/post_page_success.dart';
import 'package:thunder/post/pages/create_comment_page.dart';
import 'package:thunder/shared/comment_navigator_fab.dart';
import 'package:thunder/shared/comment_sort_picker.dart';
import 'package:thunder/shared/error_message.dart';
import 'package:thunder/shared/snackbar.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../shared/gesture_fab.dart';

class PostPage extends StatefulWidget {
  final PostViewMedia? postView;
  final int? postId;
  final String? selectedCommentPath;
  final int? selectedCommentId;

  final VoidCallback onPostUpdated;

  const PostPage({
    super.key,
    this.postView,
    this.postId,
    this.selectedCommentPath,
    this.selectedCommentId,
    required this.onPostUpdated,
  });

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener = ItemPositionsListener.create();
  bool hasScrolledToBottom = false;
  bool resetFailureMessage = true;
  bool _previousIsFabOpen = false;
  bool isFabOpen = false;
  bool _previousIsFabSummoned = true;
  bool isFabSummoned = true;
  bool enableFab = false;
  bool enableCommentNavigation = true;
  bool combineNavAndFab = true;

  CommentSortType? sortType;
  IconData? sortTypeIcon;
  String? sortTypeLabel;

  @override
  void initState() {
    super.initState();
    BackButtonInterceptor.add(_handleBack);
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(_handleBack);
    super.dispose();
  }

  FutureOr<bool> _handleBack(bool stopDefaultButtonEvent, RouteInfo info) async {
    if (context.read<ThunderBloc>().state.isFabOpen) {
      context.read<ThunderBloc>().add(const OnFabToggle(false));
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ThunderState thunderState = context.watch<ThunderBloc>().state;
    enableFab = thunderState.enablePostsFab;

    bool enableBackToTop = thunderState.postFabEnableBackToTop;
    bool enableChangeSort = thunderState.postFabEnableChangeSort;
    bool enableReplyToPost = thunderState.postFabEnableReplyToPost;
    bool enableRefresh = thunderState.postFabEnableRefresh;

    bool postLocked = widget.postView?.postView.post.locked == true;

    PostFabAction singlePressAction = thunderState.postFabSinglePressAction;
    PostFabAction longPressAction = thunderState.postFabLongPressAction;

    enableCommentNavigation = thunderState.enableCommentNavigation;
    combineNavAndFab = enableCommentNavigation && thunderState.combineNavAndFab;

    if (thunderState.isFabOpen != _previousIsFabOpen) {
      isFabOpen = thunderState.isFabOpen;
      _previousIsFabOpen = isFabOpen;
    }

    if (thunderState.isFabSummoned != _previousIsFabSummoned) {
      isFabSummoned = thunderState.isFabSummoned;
      _previousIsFabSummoned = isFabSummoned;
    }

    return BlocProvider<PostBloc>(
      create: (context) => PostBloc(),
      child: BlocConsumer<PostBloc, PostState>(
        listenWhen: (previousState, currentState) {
          if (previousState.sortType != currentState.sortType) {
            setState(() {
              sortType = currentState.sortType;
              final sortTypeItem = commentSortTypeItems.firstWhere((sortTypeItem) => sortTypeItem.payload == currentState.sortType);
              sortTypeIcon = sortTypeItem.icon;
              sortTypeLabel = sortTypeItem.label;
            });
          }
          return true;
        },
        listener: (context, state) {},
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: ListTile(
                title: Text(
                  sortTypeLabel?.isNotEmpty == true ? AppLocalizations.of(context)!.comments : '',
                  style: theme.textTheme.titleLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(sortTypeLabel ?? ''),
                contentPadding: const EdgeInsets.symmetric(horizontal: 0),
              ),
              flexibleSpace: GestureDetector(
                onTap: () {
                  if (context.read<ThunderBloc>().state.isFabOpen) {
                    context.read<ThunderBloc>().add(const OnFabToggle(false));
                  }
                },
              ),
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_rounded,
                  semanticLabel: AppLocalizations.of(context)!.back,
                ),
                onPressed: () {
                  if (context.read<ThunderBloc>().state.isFabOpen) {
                    context.read<ThunderBloc>().add(const OnFabToggle(false));
                  }
                  Navigator.pop(context);
                },
              ),
              actions: [
                IconButton(
                    icon: Icon(Icons.refresh_rounded, semanticLabel: AppLocalizations.of(context)!.refresh),
                    onPressed: () {
                      if (context.read<ThunderBloc>().state.isFabOpen) {
                        context.read<ThunderBloc>().add(const OnFabToggle(false));
                      }
                      HapticFeedback.mediumImpact();
                      return context
                          .read<PostBloc>()
                          .add(GetPostEvent(postView: widget.postView, postId: widget.postId, selectedCommentId: state.selectedCommentId, selectedCommentPath: state.selectedCommentPath));
                    }),
                IconButton(
                  icon: Icon(
                    Icons.sort,
                    semanticLabel: AppLocalizations.of(context)!.sortBy,
                  ),
                  tooltip: AppLocalizations.of(context)!.sortBy,
                  onPressed: () {
                    if (context.read<ThunderBloc>().state.isFabOpen) {
                      context.read<ThunderBloc>().add(const OnFabToggle(false));
                    }
                    showSortBottomSheet(context, state);
                  },
                ),
              ],
              centerTitle: false,
              toolbarHeight: 70.0,
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
            floatingActionButton: Stack(
              alignment: Alignment.center,
              children: [
                if (enableCommentNavigation)
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: CommentNavigatorFab(
                          itemPositionsListener: _itemPositionsListener,
                        ),
                      ),
                    ),
                  ),
                if (enableFab)
                  Padding(
                    padding: EdgeInsets.only(
                      right: combineNavAndFab ? 0 : 16,
                      bottom: combineNavAndFab ? 5 : 0,
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: isFabSummoned
                          ? GestureFab(
                              centered: combineNavAndFab,
                              distance: combineNavAndFab ? 45 : 60,
                              icon: Icon(
                                singlePressAction.getIcon(postLocked: postLocked),
                                semanticLabel: singlePressAction.getTitle(context, postLocked: postLocked),
                                size: 35,
                              ),
                              onPressed: () => singlePressAction.execute(
                                  context: context,
                                  postView: state.postView,
                                  postId: state.postId,
                                  selectedCommentId: state.selectedCommentId,
                                  selectedCommentPath: state.selectedCommentPath,
                                  override: singlePressAction == PostFabAction.backToTop
                                      ? () => {
                                            _itemScrollController.scrollTo(
                                              index: 0,
                                              duration: const Duration(milliseconds: 500),
                                              curve: Curves.easeInOut,
                                            )
                                          }
                                      : singlePressAction == PostFabAction.changeSort
                                          ? () => showSortBottomSheet(context, state)
                                          : singlePressAction == PostFabAction.replyToPost
                                              ? () => replyToPost(context, postLocked: postLocked)
                                              : null),
                              onLongPress: () => longPressAction.execute(
                                  context: context,
                                  postView: state.postView,
                                  postId: state.postId,
                                  selectedCommentId: state.selectedCommentId,
                                  selectedCommentPath: state.selectedCommentPath,
                                  override: longPressAction == PostFabAction.backToTop
                                      ? () => {
                                            _itemScrollController.scrollTo(
                                              index: 0,
                                              duration: const Duration(milliseconds: 500),
                                              curve: Curves.easeInOut,
                                            )
                                          }
                                      : longPressAction == PostFabAction.changeSort
                                          ? () => showSortBottomSheet(context, state)
                                          : longPressAction == PostFabAction.replyToPost
                                              ? () => replyToPost(context, postLocked: postLocked)
                                              : null),
                              children: [
                                if (enableRefresh)
                                  ActionButton(
                                    centered: combineNavAndFab,
                                    onPressed: () {
                                      HapticFeedback.mediumImpact();
                                      PostFabAction.refresh.execute(
                                        context: context,
                                        postView: state.postView,
                                        postId: state.postId,
                                        selectedCommentId: state.selectedCommentId,
                                        selectedCommentPath: state.selectedCommentPath,
                                      );
                                    },
                                    title: PostFabAction.refresh.getTitle(context),
                                    icon: Icon(
                                      PostFabAction.refresh.getIcon(),
                                    ),
                                  ),
                                if (enableReplyToPost)
                                  ActionButton(
                                    centered: combineNavAndFab,
                                    onPressed: () {
                                      HapticFeedback.mediumImpact();
                                      PostFabAction.replyToPost.execute(
                                        override: () => replyToPost(context, postLocked: postLocked),
                                      );
                                    },
                                    title: PostFabAction.replyToPost.getTitle(context),
                                    icon: Icon(
                                      postLocked ? Icons.lock : PostFabAction.replyToPost.getIcon(),
                                    ),
                                  ),
                                if (enableChangeSort)
                                  ActionButton(
                                    centered: combineNavAndFab,
                                    onPressed: () {
                                      HapticFeedback.mediumImpact();
                                      PostFabAction.changeSort.execute(
                                        override: () => showSortBottomSheet(context, state),
                                      );
                                    },
                                    title: PostFabAction.changeSort.getTitle(context),
                                    icon: Icon(
                                      PostFabAction.changeSort.getIcon(),
                                    ),
                                  ),
                                if (enableBackToTop)
                                  ActionButton(
                                    centered: combineNavAndFab,
                                    onPressed: () {
                                      PostFabAction.backToTop.execute(
                                          override: () => {
                                                _itemScrollController.scrollTo(
                                                  index: 0,
                                                  duration: const Duration(milliseconds: 500),
                                                  curve: Curves.easeInOut,
                                                )
                                              });
                                    },
                                    title: PostFabAction.backToTop.getTitle(context),
                                    icon: Icon(
                                      PostFabAction.backToTop.getIcon(),
                                    ),
                                  ),
                              ],
                            )
                          : null,
                    ),
                  ),
              ],
            ),
            body: Stack(
              alignment: Alignment.bottomRight,
              children: [
                SafeArea(
                  child: BlocConsumer<PostBloc, PostState>(
                    listenWhen: (previous, current) {
                      if ((previous.status != PostStatus.failure && current.status == PostStatus.failure) || (previous.errorMessage != current.errorMessage)) {
                        setState(() => resetFailureMessage = true);
                      }
                      return true;
                    },
                    listener: (context, state) {
                      if (state.status == PostStatus.success && widget.postView != null) {
                        // Update the community's post
                        context.read<CommunityBloc>().add(UpdatePostEvent(postViewMedia: state.postView!));
                      }
                    },
                    builder: (context, state) {
                      if (state.status == PostStatus.failure && resetFailureMessage == true) {
                        showSnackbar(
                          context,
                          state.errorMessage ?? AppLocalizations.of(context)!.missingErrorMessage,
                          backgroundColor: Theme.of(context).colorScheme.onErrorContainer,
                          leadingIcon: Icons.warning_rounded,
                          leadingIconColor: Theme.of(context).colorScheme.errorContainer,
                        );
                        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                          setState(() => resetFailureMessage = false);
                        });
                      }
                      switch (state.status) {
                        case PostStatus.initial:
                          context
                              .read<PostBloc>()
                              .add(GetPostEvent(postView: widget.postView, postId: widget.postId, selectedCommentPath: widget.selectedCommentPath, selectedCommentId: widget.selectedCommentId));
                          return const Center(child: CircularProgressIndicator());
                        case PostStatus.loading:
                          return const Center(child: CircularProgressIndicator());
                        case PostStatus.refreshing:
                        case PostStatus.success:
                        case PostStatus.failure:
                          if (state.postView != null) {
                            return RefreshIndicator(
                              onRefresh: () async {
                                HapticFeedback.mediumImpact();
                                return context
                                    .read<PostBloc>()
                                    .add(GetPostEvent(postView: widget.postView, postId: widget.postId, selectedCommentId: state.selectedCommentId, selectedCommentPath: state.selectedCommentPath));
                              },
                              child: PostPageSuccess(
                                postView: state.postView!,
                                comments: state.comments,
                                selectedCommentId: state.selectedCommentId,
                                selectedCommentPath: state.selectedCommentPath,
                                moddingCommentId: state.moddingCommentId,
                                viewFullCommentsRefreshing: state.viewAllCommentsRefresh,
                                itemScrollController: _itemScrollController,
                                itemPositionsListener: _itemPositionsListener,
                                hasReachedCommentEnd: state.hasReachedCommentEnd,
                                moderators: state.moderators,
                              ),
                            );
                          }
                          return ErrorMessage(
                            message: state.errorMessage,
                            action: () {
                              context.read<PostBloc>().add(GetPostEvent(postView: widget.postView, postId: widget.postId, selectedCommentId: null));
                            },
                            actionText: AppLocalizations.of(context)!.refreshContent,
                          );
                        case PostStatus.empty:
                          return ErrorMessage(
                            message: state.errorMessage,
                            action: () {
                              context.read<PostBloc>().add(GetPostEvent(postView: widget.postView, postId: widget.postId));
                            },
                            actionText: AppLocalizations.of(context)!.refreshContent,
                          );
                      }
                    },
                  ),
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: isFabOpen
                      ? Listener(
                          onPointerUp: (details) {
                            context.read<ThunderBloc>().add(const OnFabToggle(false));
                          },
                          child: Container(
                            color: theme.colorScheme.background.withOpacity(0.95),
                          ),
                        )
                      : null,
                ),
                if (enableFab)
                  SizedBox(
                    height: 70,
                    width: 70,
                    child: GestureDetector(
                      onVerticalDragUpdate: (details) {
                        if (details.delta.dy < -5) {
                          context.read<ThunderBloc>().add(const OnFabSummonToggle(true));
                        }
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

//TODO: More or less duplicate from community_page.dart
  void showSortBottomSheet(BuildContext context, PostState state) {
    showModalBottomSheet<void>(
      showDragHandle: true,
      context: context,
      builder: (builderContext) => CommentSortPicker(
        title: AppLocalizations.of(context)!.sortOptions,
        onSelect: (selected) {
          setState(() {
            sortType = selected.payload;
            sortTypeIcon = selected.icon;
          });
          context.read<PostBloc>().add(
                  //shouldn't this be GetPostCommentsEvent?
                  GetPostEvent(
                postView: widget.postView,
                postId: widget.postId,
                sortType: sortType,
              ));
          //Navigator.of(context).pop();
        },
        previouslySelected: sortType,
      ),
    );
  }

  void replyToPost(BuildContext context, {bool postLocked = false}) async {
    if (postLocked) {
      showSnackbar(context, AppLocalizations.of(context)!.postLocked);
      return;
    }
    PostBloc postBloc = context.read<PostBloc>();
    ThunderBloc thunderBloc = context.read<ThunderBloc>();
    AuthBloc authBloc = context.read<AuthBloc>();
    AccountBloc accountBloc = context.read<AccountBloc>();

    if (!authBloc.state.isLoggedIn) {
      showSnackbar(context, AppLocalizations.of(context)!.mustBeLoggedInComment);
    } else {
      SharedPreferences prefs = (await UserPreferences.instance).sharedPreferences;
      DraftComment? newDraftComment;
      DraftComment? previousDraftComment;
      String draftId = '${LocalSettings.draftsCache.name}-${(widget.postView ?? postBloc.state.postView)!.postView.post.id}';
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
                  postView: widget.postView ?? postBloc.state.postView,
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
    }
  }
}
