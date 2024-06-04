// Dart imports
import 'dart:async';

// Flutter imports
import 'package:flutter/material.dart';

// Package imports
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:lemmy_api_client/v3.dart';

// Project imports
import 'package:thunder/comment/utils/navigate_comment.dart';
import 'package:thunder/community/widgets/post_card_list.dart';
import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/core/models/comment_view_tree.dart';
import 'package:thunder/core/models/post_view_media.dart';
import 'package:thunder/feed/view/feed_page.dart';
import 'package:thunder/post/bloc/post_bloc.dart' as post_bloc;
import 'package:thunder/post/utils/comment_action_helpers.dart';
import 'package:thunder/shared/comment_reference.dart';
import 'package:thunder/shared/primitive_wrapper.dart';
import 'package:thunder/shared/snackbar.dart';
import 'package:thunder/user/bloc/user_bloc_old.dart';
import 'package:thunder/user/widgets/user_header.dart';
import 'package:thunder/user/widgets/user_sidebar.dart';
import 'package:thunder/utils/global_context.dart';

List<Widget> userOptionTypes = <Widget>[
  Padding(padding: const EdgeInsets.all(8.0), child: Text(AppLocalizations.of(GlobalContext.context)!.posts)),
  Padding(padding: const EdgeInsets.all(8.0), child: Text(AppLocalizations.of(GlobalContext.context)!.comments)),
];

class UserPageSuccess extends StatefulWidget {
  final int? userId;
  final PersonView? personView;
  final bool isAccountUser;

  final List<CommentViewTree>? commentViewTrees;
  final List<PostViewMedia>? postViews;
  final List<PostViewMedia>? savedPostViews;
  final List<CommentViewTree>? savedComments;
  final List<CommunityModeratorView>? moderates;
  final BlockPersonResponse? blockedPerson;

  final bool hasReachedPostEnd;
  final bool hasReachedSavedPostEnd;

  final List<bool>? selectedUserOption;
  final PrimitiveWrapper<bool>? savedToggle;

  final GetPersonDetailsResponse? fullPersonView;

  const UserPageSuccess({
    super.key,
    required this.userId,
    this.isAccountUser = false,
    required this.personView,
    this.commentViewTrees,
    this.postViews,
    this.savedPostViews,
    this.savedComments,
    this.moderates,
    required this.hasReachedPostEnd,
    required this.hasReachedSavedPostEnd,
    this.blockedPerson,
    this.selectedUserOption,
    this.savedToggle,
    this.fullPersonView,
  });

  @override
  State<UserPageSuccess> createState() => _UserPageSuccessState();
}

class _UserPageSuccessState extends State<UserPageSuccess> with TickerProviderStateMixin {
  bool _displaySidebar = false;
  final _scrollController = ScrollController(initialScrollOffset: 0);
  bool hasScrolledToBottom = true;

  int? selectedUserOption;
  // Do not change the object reference of either of these.
  // Only change members.
  List<bool>? _selectedUserOption;
  PrimitiveWrapper<bool>? savedToggle;

  @override
  void initState() {
    _scrollController.addListener(_onScroll);
    BackButtonInterceptor.add(_handleBack);
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    BackButtonInterceptor.remove(_handleBack);
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.7) {
      context.read<UserBloc>().add(const GetUserEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    selectedUserOption ??= widget.selectedUserOption?.indexOf(true) ?? 0;
    _selectedUserOption ??= widget.selectedUserOption ?? [true, false];
    savedToggle ??= widget.savedToggle ?? PrimitiveWrapper<bool>(false);

    final int? currentUserId = context.read<AuthBloc>().state.account?.userId;

    return BlocProvider<post_bloc.PostBloc>(
      create: (context) => post_bloc.PostBloc(),
      child: Center(
        child: Stack(
          children: [
            Column(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _displaySidebar = !_displaySidebar;
                    });
                  },
                  onHorizontalDragUpdate: (details) {
                    if (details.delta.dx < -3) {
                      setState(() {
                        _displaySidebar = true;
                      });
                    }
                  },
                  child: widget.fullPersonView != null
                      ? UserHeader(showUserSidebar: _displaySidebar, getPersonDetailsResponse: widget.fullPersonView!, onToggle: (value) => setState(() => _displaySidebar = value))
                      : const SizedBox(),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      AnimatedSwitcher(
                        switchOutCurve: Curves.easeInOut,
                        switchInCurve: Curves.easeInOut,
                        duration: const Duration(milliseconds: 250),
                        transitionBuilder: (Widget child, Animation<double> animation) {
                          return SizeTransition(
                            axis: Axis.horizontal,
                            sizeFactor: animation,
                            child: FadeTransition(opacity: animation, child: child),
                          );
                        },
                        child: !savedToggle!.value
                            ? ToggleButtons(
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                direction: Axis.horizontal,
                                onPressed: (int index) {
                                  setState(() {
                                    // The button that is tapped is set to true, and the others to false.
                                    for (int i = 0; i < _selectedUserOption!.length; i++) {
                                      _selectedUserOption![i] = i == index;
                                    }
                                    selectedUserOption = index;
                                  });
                                },
                                borderRadius: const BorderRadius.all(Radius.circular(8)),
                                constraints: BoxConstraints.expand(width: (MediaQuery.of(context).size.width / (userOptionTypes.length + (widget.isAccountUser ? 0.8 : 0.1))) - 12.0),
                                isSelected: _selectedUserOption!,
                                children: userOptionTypes,
                              )
                            : null,
                      ),
                      if (widget.isAccountUser)
                        Expanded(
                          child: Padding(
                            padding: savedToggle!.value ? const EdgeInsets.only(right: 8.0) : const EdgeInsets.only(left: 8.0),
                            child: TextButton(
                              onPressed: () {
                                setState(() {
                                  selectedUserOption = 0;
                                  _selectedUserOption![0] = true;
                                  _selectedUserOption![1] = false;
                                  savedToggle!.value = !savedToggle!.value;
                                });
                                if (savedToggle!.value) {
                                  context.read<UserBloc>().add(GetUserSavedEvent(userId: widget.userId, reset: false));
                                }
                              },
                              style: TextButton.styleFrom(
                                fixedSize: const Size.fromHeight(35),
                                padding: EdgeInsets.zero,
                              ),
                              child: !savedToggle!.value
                                  ? Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const SizedBox(width: 8.0),
                                        Text(AppLocalizations.of(context)!.saved),
                                        const Icon(Icons.chevron_right),
                                      ],
                                    )
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.chevron_left),
                                        Text(
                                          AppLocalizations.of(context)!.overview,
                                          semanticsLabel: '${AppLocalizations.of(context)!.overview}, ${AppLocalizations.of(context)!.back}',
                                        ),
                                        const SizedBox(width: 8.0),
                                      ],
                                    ),
                            ),
                          ),
                        ),
                      AnimatedSwitcher(
                        switchOutCurve: Curves.easeInOut,
                        switchInCurve: Curves.easeInOut,
                        duration: const Duration(milliseconds: 250),
                        transitionBuilder: (Widget child, Animation<double> animation) {
                          return SizeTransition(
                            axis: Axis.horizontal,
                            sizeFactor: animation,
                            child: FadeTransition(opacity: animation, child: child),
                          );
                        },
                        child: savedToggle!.value
                            ? ToggleButtons(
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                direction: Axis.horizontal,
                                onPressed: (int index) {
                                  setState(() {
                                    // The button that is tapped is set to true, and the others to false.
                                    for (int i = 0; i < _selectedUserOption!.length; i++) {
                                      _selectedUserOption![i] = i == index;
                                    }

                                    selectedUserOption = index;
                                  });
                                  if (index == 2) {
                                    context.read<UserBloc>().add(GetUserSavedEvent(userId: widget.userId, reset: false));
                                  }
                                },
                                borderRadius: const BorderRadius.all(Radius.circular(8)),
                                constraints: BoxConstraints.expand(width: (MediaQuery.of(context).size.width / (userOptionTypes.length + (widget.isAccountUser ? 0.8 : 0))) - 12.0),
                                isSelected: _selectedUserOption!,
                                children: userOptionTypes,
                              )
                            : null,
                      ),
                    ],
                  ),
                ),
                if (!savedToggle!.value && selectedUserOption == 0)
                  Expanded(
                    child: PostCardList(
                      postViews: widget.postViews,
                      personId: widget.userId,
                      hasReachedEnd: widget.hasReachedPostEnd,
                      onScrollEndReached: () => context.read<UserBloc>().add(const GetUserEvent()),
                      onSaveAction: (int postId, bool save) => context.read<UserBloc>().add(SavePostEvent(postId: postId, save: save)),
                      onVoteAction: (int postId, int voteType) => context.read<UserBloc>().add(VotePostEvent(postId: postId, score: voteType)),
                      onToggleReadAction: (int postId, bool read) => context.read<UserBloc>().add(MarkUserPostAsReadEvent(postId: postId, read: read)),
                      indicateRead: !widget.isAccountUser,
                      feedType: FeedType.user,
                    ),
                  ),
                if (!savedToggle!.value && selectedUserOption == 1)
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: widget.commentViewTrees?.length,
                      itemBuilder: (context, index) => Column(
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
                            comment: widget.commentViewTrees![index].commentView!,
                            onVoteAction: (int commentId, int voteType) => context.read<UserBloc>().add(VoteCommentEvent(commentId: commentId, score: voteType)),
                            onSaveAction: (int commentId, bool save) => context.read<UserBloc>().add(SaveCommentEvent(commentId: commentId, save: save)),
                            onDeleteAction: (int commentId, bool deleted) => context.read<UserBloc>().add(DeleteCommentEvent(deleted: deleted, commentId: commentId)),
                            onReportAction: (int commentId) {
                              if (widget.isAccountUser) {
                                showSnackbar(AppLocalizations.of(context)!.cannotReportOwnComment);
                              } else {
                                showReportCommentActionBottomSheet(
                                  context,
                                  commentId: commentId,
                                );
                              }
                            },
                            onReplyEditAction: (CommentView commentView, bool isEdit) async => navigateToCreateCommentPage(
                              context,
                              commentView: isEdit ? commentView : null,
                              parentCommentView: isEdit ? null : commentView,
                              onCommentSuccess: (commentView, userChanged) {
                                if (!userChanged) {
                                  // TODO: handle success for account page changes.
                                  // context.read<UserBloc>().add(UpdateCommentEvent(commentView: commentView, isEdit: isEdit)),
                                }
                              },
                            ),
                            isOwnComment: widget.isAccountUser,
                          ),
                        ],
                      ),
                    ),
                  ),
                if (savedToggle!.value && selectedUserOption == 0)
                  Expanded(
                    child: PostCardList(
                      postViews: widget.savedPostViews,
                      personId: widget.userId,
                      hasReachedEnd: widget.hasReachedSavedPostEnd,
                      onScrollEndReached: () => context.read<UserBloc>().add(const GetUserSavedEvent()),
                      onSaveAction: (int postId, bool save) => context.read<UserBloc>().add(SavePostEvent(postId: postId, save: save)),
                      onVoteAction: (int postId, int voteType) => context.read<UserBloc>().add(VotePostEvent(postId: postId, score: voteType)),
                      onToggleReadAction: (int postId, bool read) => context.read<UserBloc>().add(MarkUserPostAsReadEvent(postId: postId, read: read)),
                      indicateRead: !widget.isAccountUser,
                      feedType: FeedType.user,
                    ),
                  ),
                if (savedToggle!.value && selectedUserOption == 1)
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: widget.savedComments?.length,
                      itemBuilder: (context, index) => Column(
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
                            comment: widget.savedComments![index].commentView!,
                            onVoteAction: (int commentId, int voteType) => context.read<UserBloc>().add(VoteCommentEvent(commentId: commentId, score: voteType)),
                            onSaveAction: (int commentId, bool save) => context.read<UserBloc>().add(SaveCommentEvent(commentId: commentId, save: save)),
                            onDeleteAction: (int commentId, bool deleted) => context.read<UserBloc>().add(DeleteCommentEvent(deleted: deleted, commentId: commentId)),
                            onReportAction: (int commentId) {
                              if (widget.isAccountUser) {
                                showSnackbar(AppLocalizations.of(context)!.cannotReportOwnComment);
                              } else {
                                showReportCommentActionBottomSheet(
                                  context,
                                  commentId: commentId,
                                );
                              }
                            },
                            onReplyEditAction: (CommentView commentView, bool isEdit) async => navigateToCreateCommentPage(
                              context,
                              commentView: isEdit ? commentView : null,
                              parentCommentView: isEdit ? null : commentView,
                              onCommentSuccess: (commentView, userChanged) {
                                if (!userChanged) {
                                  // TODO: handle success for account page changes.
                                  // context.read<UserBloc>().add(UpdateCommentEvent(commentView: commentView, isEdit: isEdit)),
                                }
                              },
                            ),
                            isOwnComment: widget.isAccountUser && widget.savedComments![index].commentView!.creator.id == currentUserId,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            GestureDetector(
              onHorizontalDragUpdate: (details) {
                if (details.delta.dx > 3) {
                  setState(() {
                    _displaySidebar = false;
                  });
                }
              },
              child: Column(
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _displaySidebar
                        ? GestureDetector(
                            onTap: () {
                              setState(() {
                                _displaySidebar = false;
                              });
                            },
                            child: UserHeader(
                              getPersonDetailsResponse: widget.fullPersonView!,
                              onToggle: (value) => setState(() => _displaySidebar = value),
                              showUserSidebar: _displaySidebar,
                            ))
                        : null,
                  ),
                  Expanded(
                    child: Stack(
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: _displaySidebar
                              ? GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _displaySidebar = false;
                                    });
                                  },
                                  child: Container(
                                    color: Colors.black.withOpacity(0.75),
                                  ),
                                )
                              : null,
                        ),
                        AnimatedSwitcher(
                          switchInCurve: Curves.decelerate,
                          switchOutCurve: Curves.easeOut,
                          transitionBuilder: (child, animation) {
                            return SlideTransition(
                              position: Tween<Offset>(begin: const Offset(1.2, 0), end: const Offset(0, 0)).animate(animation),
                              child: child,
                            );
                          },
                          duration: const Duration(milliseconds: 300),
                          child: _displaySidebar
                              ? UserSidebar(
                                  getPersonDetailsResponse: widget.fullPersonView,
                                  onDismiss: () => setState(() => _displaySidebar = false),
                                )
                              : null,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  FutureOr<bool> _handleBack(bool stopDefaultButtonEvent, RouteInfo info) async {
    final bool topOfNavigationStack = ModalRoute.of(context)?.isCurrent ?? false;

    if (topOfNavigationStack) {
      if (_displaySidebar) {
        setState(() {
          _displaySidebar = false;
        });
        return true;
      } else if (savedToggle!.value) {
        setState(() {
          selectedUserOption = 0;
          _selectedUserOption![0] = true;
          _selectedUserOption![1] = false;
          savedToggle!.value = false;
        });
        return true;
      }
    }

    return false;
  }
}
