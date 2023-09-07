import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:thunder/community/widgets/post_card_list.dart';
import 'package:thunder/shared/comment_reference.dart';
import 'package:thunder/user/widgets/user_header.dart';
import 'package:thunder/core/models/comment_view_tree.dart';
import 'package:thunder/core/models/post_view_media.dart';
import 'package:thunder/user/bloc/user_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:thunder/utils/global_context.dart';

import '../../post/pages/create_comment_page.dart';
import '../../thunder/bloc/thunder_bloc.dart';
import '../widgets/user_sidebar.dart';

List<Widget> userOptionTypes = <Widget>[
  Padding(padding: const EdgeInsets.all(8.0), child: Text(AppLocalizations.of(GlobalContext.context)!.posts)),
  Padding(padding: const EdgeInsets.all(8.0), child: Text(AppLocalizations.of(GlobalContext.context)!.comment)),
];

class UserPageSuccess extends StatefulWidget {
  final int? userId;
  final PersonViewSafe? personView;
  final bool isAccountUser;

  final List<CommentViewTree>? commentViewTrees;
  final List<PostViewMedia>? postViews;
  final List<PostViewMedia>? savedPostViews;
  final List<CommentViewTree>? savedComments;
  final List<CommunityModeratorView>? moderates;
  final BlockedPerson? blockedPerson;

  final bool hasReachedPostEnd;
  final bool hasReachedSavedPostEnd;

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
  });

  @override
  State<UserPageSuccess> createState() => _UserPageSuccessState();
}

class _UserPageSuccessState extends State<UserPageSuccess> with TickerProviderStateMixin {
  bool _displaySidebar = false;
  final _scrollController = ScrollController(initialScrollOffset: 0);
  bool hasScrolledToBottom = true;

  int selectedUserOption = 0;
  List<bool> _selectedUserOption = <bool>[true, false];
  bool savedToggle = false;

  late final AnimationController _controller = AnimationController(
    duration: const Duration(seconds: 1),
    vsync: this,
  );

  late final Animation<Offset> _offsetAnimation = Tween<Offset>(
    begin: Offset.zero,
    end: const Offset(1.5, 0.0),
  ).animate(CurvedAnimation(
    parent: _controller,
    curve: Curves.elasticIn,
  ));

  @override
  void initState() {
    _scrollController.addListener(_onScroll);
    setState(() {
      _selectedUserOption = <bool>[true, false];
    });
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.7) {
      context.read<UserBloc>().add(const GetUserEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final DateTime now = DateTime.now().toUtc();

    return Center(
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
                child: widget.personView != null ? UserHeader(userInfo: widget.personView) : const SizedBox(),
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                color: theme.colorScheme.background,
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
                      child: !savedToggle
                          ? ToggleButtons(
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              direction: Axis.horizontal,
                              onPressed: (int index) {
                                setState(() {
                                  // The button that is tapped is set to true, and the others to false.
                                  for (int i = 0; i < _selectedUserOption.length; i++) {
                                    _selectedUserOption[i] = i == index;
                                  }
                                  selectedUserOption = index;
                                });
                              },
                              borderRadius: const BorderRadius.all(Radius.circular(8)),
                              constraints: BoxConstraints.expand(width: (MediaQuery.of(context).size.width / (userOptionTypes.length + (widget.isAccountUser ? 0.8 : 0))) - 12.0),
                              isSelected: _selectedUserOption,
                              children: userOptionTypes,
                            )
                          : null,
                    ),
                    if (widget.isAccountUser)
                      Expanded(
                        child: Padding(
                          padding: savedToggle ? const EdgeInsets.only(right: 8.0) : const EdgeInsets.only(left: 8.0),
                          child: TextButton(
                            onPressed: () {
                              setState(() {
                                savedToggle = !savedToggle;
                              });
                              if (savedToggle) {
                                context.read<UserBloc>().add(GetUserSavedEvent(userId: widget.userId, reset: false));
                              }
                            },
                            style: TextButton.styleFrom(
                              fixedSize: const Size.fromHeight(35),
                              padding: EdgeInsets.zero,
                            ),
                            child: !savedToggle
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
                                        AppLocalizations.of(context)!.history,
                                        semanticsLabel: '${AppLocalizations.of(context)!.history}, ${AppLocalizations.of(context)!.back}',
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
                      child: savedToggle
                          ? ToggleButtons(
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              direction: Axis.horizontal,
                              onPressed: (int index) {
                                setState(() {
                                  // The button that is tapped is set to true, and the others to false.
                                  for (int i = 0; i < _selectedUserOption.length; i++) {
                                    _selectedUserOption[i] = i == index;
                                  }

                                  selectedUserOption = index;
                                });
                                if (index == 2) {
                                  context.read<UserBloc>().add(GetUserSavedEvent(userId: widget.userId, reset: false));
                                }
                              },
                              borderRadius: const BorderRadius.all(Radius.circular(8)),
                              constraints: BoxConstraints.expand(width: (MediaQuery.of(context).size.width / (userOptionTypes.length + (widget.isAccountUser ? 0.8 : 0))) - 12.0),
                              isSelected: _selectedUserOption,
                              children: userOptionTypes,
                            )
                          : null,
                    ),
                  ],
                ),
              ),
              if (!savedToggle && selectedUserOption == 0)
                Expanded(
                  child: PostCardList(
                    postViews: widget.postViews,
                    personId: widget.userId,
                    hasReachedEnd: widget.hasReachedPostEnd,
                    onScrollEndReached: () => context.read<UserBloc>().add(const GetUserEvent()),
                    onSaveAction: (int postId, bool save) => context.read<UserBloc>().add(SavePostEvent(postId: postId, save: save)),
                    onVoteAction: (int postId, VoteType voteType) => context.read<UserBloc>().add(VotePostEvent(postId: postId, score: voteType)),
                    onToggleReadAction: (int postId, bool read) => context.read<UserBloc>().add(MarkUserPostAsReadEvent(postId: postId, read: read)),
                    indicateRead: !widget.isAccountUser,
                  ),
                ),
              if (!savedToggle && selectedUserOption == 1)
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
                          now: now,
                          onVoteAction: (int commentId, VoteType voteType) => context.read<UserBloc>().add(VoteCommentEvent(commentId: commentId, score: voteType)),
                          onSaveAction: (int commentId, bool save) => context.read<UserBloc>().add(SaveCommentEvent(commentId: commentId, save: save)),
                          onDeleteAction: (int commentId, bool deleted) => context.read<UserBloc>().add(DeleteCommentEvent(deleted: deleted, commentId: commentId)),
                          onReplyEditAction: (CommentView commentView, bool isEdit) {
                            UserBloc postBloc = context.read<UserBloc>();
                            ThunderBloc thunderBloc = context.read<ThunderBloc>();

                            showModalBottomSheet(
                              isScrollControlled: true,
                              context: context,
                              showDragHandle: true,
                              builder: (context) {
                                return Padding(
                                  padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 40),
                                  child: FractionallySizedBox(
                                    heightFactor: 0.8,
                                    child: MultiBlocProvider(
                                      providers: [
                                        BlocProvider<UserBloc>.value(value: postBloc),
                                        BlocProvider<ThunderBloc>.value(value: thunderBloc),
                                      ],
                                      child: CreateCommentPage(commentView: commentView, isEdit: isEdit),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          isOwnComment: widget.isAccountUser,
                        ),
                      ],
                    ),
                  ),
                ),
              if (savedToggle && selectedUserOption == 0)
                Expanded(
                  child: PostCardList(
                    postViews: widget.savedPostViews,
                    personId: widget.userId,
                    hasReachedEnd: widget.hasReachedSavedPostEnd,
                    onScrollEndReached: () => context.read<UserBloc>().add(const GetUserSavedEvent()),
                    onSaveAction: (int postId, bool save) => context.read<UserBloc>().add(SavePostEvent(postId: postId, save: save)),
                    onVoteAction: (int postId, VoteType voteType) => context.read<UserBloc>().add(VotePostEvent(postId: postId, score: voteType)),
                    onToggleReadAction: (int postId, bool read) => context.read<UserBloc>().add(MarkUserPostAsReadEvent(postId: postId, read: read)),
                    indicateRead: !widget.isAccountUser,
                  ),
                ),
              if (savedToggle && selectedUserOption == 1)
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
                          now: now,
                          onVoteAction: (int commentId, VoteType voteType) => context.read<UserBloc>().add(VoteCommentEvent(commentId: commentId, score: voteType)),
                          onSaveAction: (int commentId, bool save) => context.read<UserBloc>().add(SaveCommentEvent(commentId: commentId, save: save)),
                          onDeleteAction: (int commentId, bool deleted) => context.read<UserBloc>().add(DeleteCommentEvent(deleted: deleted, commentId: commentId)),
                          onReplyEditAction: (CommentView commentView, bool isEdit) {
                            UserBloc postBloc = context.read<UserBloc>();
                            ThunderBloc thunderBloc = context.read<ThunderBloc>();

                            showModalBottomSheet(
                              isScrollControlled: true,
                              context: context,
                              showDragHandle: true,
                              builder: (context) {
                                return Padding(
                                  padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 40),
                                  child: FractionallySizedBox(
                                    heightFactor: 0.8,
                                    child: MultiBlocProvider(
                                      providers: [
                                        BlocProvider<UserBloc>.value(value: postBloc),
                                        BlocProvider<ThunderBloc>.value(value: thunderBloc),
                                      ],
                                      child: CreateCommentPage(commentView: commentView, isEdit: isEdit),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          isOwnComment: widget.isAccountUser,
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
                            userInfo: widget.personView,
                          ),
                        )
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
                                userInfo: widget.personView,
                                moderates: widget.moderates,
                                isAccountUser: widget.isAccountUser,
                                blockedPerson: widget.blockedPerson,
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
    );
  }
}
