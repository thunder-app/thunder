// Flutter imports

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

// Package imports
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:share_plus/share_plus.dart';
import 'package:thunder/account/utils/profiles.dart';

// Project imports
import 'package:thunder/comment/utils/navigate_comment.dart';
import 'package:thunder/community/widgets/post_card_list.dart';
import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/core/models/comment_view_tree.dart';
import 'package:thunder/core/models/post_view_media.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/feed/bloc/feed_bloc.dart';
import 'package:thunder/feed/utils/utils.dart';
import 'package:thunder/feed/view/feed_page.dart';
import 'package:thunder/post/utils/comment_action_helpers.dart';
import 'package:thunder/shared/avatars/user_avatar.dart';
import 'package:thunder/shared/comment_reference.dart';
import 'package:thunder/shared/full_name_widgets.dart';
import 'package:thunder/shared/icon_text.dart';
import 'package:thunder/shared/persistent_header.dart';
import 'package:thunder/shared/primitive_wrapper.dart';
import 'package:thunder/shared/snackbar.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/user/bloc/user_bloc_old.dart';
import 'package:thunder/user/widgets/user_sidebar.dart';
import 'package:thunder/utils/global_context.dart';
import 'package:thunder/utils/instance.dart';
import 'package:thunder/utils/numbers.dart';

class UserPageNew extends StatefulWidget {
  const UserPageNew(
      {super.key,
      this.userId,
      this.personView,
      required this.isAccountUser,
      this.commentViewTrees,
      this.postViews,
      this.savedPostViews,
      this.savedComments,
      this.moderates,
      this.blockedPerson,
      required this.hasReachedPostEnd,
      required this.hasReachedSavedPostEnd,
      this.selectedUserOption,
      this.savedToggle,
      this.fullPersonView});

  final BlockPersonResponse? blockedPerson;
  final List<CommentViewTree>? commentViewTrees;
  final GetPersonDetailsResponse? fullPersonView;
  final bool hasReachedPostEnd;
  final bool hasReachedSavedPostEnd;
  final bool isAccountUser;
  final List<CommunityModeratorView>? moderates;
  final PersonView? personView;
  final List<PostViewMedia>? postViews;
  final List<CommentViewTree>? savedComments;
  final List<PostViewMedia>? savedPostViews;
  final PrimitiveWrapper<bool>? savedToggle;
  final List<bool>? selectedUserOption;
  final int? userId;

  @override
  State<UserPageNew> createState() => _UserPageNewState();
}

class _UserPageNewState extends State<UserPageNew> with SingleTickerProviderStateMixin {
  late TabController tabController;
  String? userActorId;
  UserBloc? userBloc;

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    tabController = TabController(vsync: this, length: 3);
  }

  @override
  Widget build(BuildContext context) {
    final ThunderState state = context.read<ThunderBloc>().state;
    final bool reduceAnimations = state.reduceAnimations;
    final theme = Theme.of(context);
    final FeedBloc feedBloc = context.watch<FeedBloc>();

    return BlocProvider<UserBloc>(
      create: (context) => UserBloc(lemmyClient: LemmyClient.instance),
      child: BlocListener<UserBloc, UserState>(
        listener: (context, state) {
          if (userActorId == null && state.personView?.person.actorId != null) {
            setState(() => userActorId = state.personView!.person.actorId);
          }
        },
        child: Scaffold(
            endDrawer: Drawer(
              child: SafeArea(
                child: Column(
                  children: [
                    // saved
                    //drafts
                    // upvotes and downvotes
                    // create community
                    // manage accounts
                    // logout

                    const ListTile(
                      leading: Icon(Icons.bookmarks_sharp),
                      title: Text('Manage Subscriptions'),
                    ),
                    ListTile(
                      onTap: () => context.go('saved'),
                      leading: const Icon(Icons.bookmark),
                      title: const Text('Saved'),
                    ),
                    const ListTile(
                      leading: Icon(Icons.drafts_outlined),
                      title: Text('Drafts'),
                    ),
                    const ListTile(
                      leading: Icon(Icons.thumbs_up_down_outlined),
                      title: Text('Upvotes & Downvotes'),
                    ),

                    const ListTile(
                      leading: Icon(Icons.group_add),
                      title: Text('Create a Community'),
                    ),
                    const ListTile(
                      leading: Icon(Icons.manage_accounts_rounded),
                      title: Text('Manage Accounts'),
                    ),
                    const Divider(),
                    const ListTile(
                      leading: Icon(Icons.logout),
                      title: Text('Sign Out'),
                    ),
                  ],
                ),
              ),
            ),
            extendBodyBehindAppBar: true,
            body: DefaultTabController(
                length: 3,
                child: NestedScrollView(
                  headerSliverBuilder: (context, value) {
                    return [
                      SliverAppBar(
                        flexibleSpace: Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.only(bottomRight: Radius.circular(16), bottomLeft: Radius.circular(16)),
                                image: DecorationImage(
                                  image: CachedNetworkImageProvider(widget.personView!.person.banner!),
                                  fit: BoxFit.cover,
                                  opacity: .5,
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.center,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 16.0, left: 24.0, right: 24.0, bottom: 16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      children: [
                                        InkWell(
                                          onTap: () => showProfileModalSheet(context),
                                          child: UserAvatar(
                                            person: widget.personView?.person,
                                            radius: 45.0,
                                          ),
                                        ),
                                        const SizedBox(width: 20.0),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              AutoSizeText(
                                                widget.personView?.person.displayName ?? widget.personView!.person.name,
                                                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
                                                maxLines: 1,
                                              ),
                                              UserFullNameWidget(
                                                context,
                                                widget.personView?.person.name,
                                                widget.personView?.person.displayName,
                                                fetchInstanceNameFromUrl(widget.personView?.person.actorId),
                                                autoSize: true,
                                                // Override because we're showing display name above
                                                useDisplayName: false,
                                              ),
                                              const SizedBox(height: 8.0),
                                              Wrap(
                                                children: [
                                                  IconText(
                                                    icon: const Icon(Icons.wysiwyg_rounded),
                                                    text: formatNumberToK(widget.personView!.counts.postCount),
                                                  ),
                                                  const SizedBox(width: 8.0),
                                                  IconText(
                                                    icon: const Icon(Icons.chat_rounded),
                                                    text: formatNumberToK(widget.personView!.counts.commentCount),
                                                  ),
                                                  if (feedBloc.state.feedType == FeedType.user) ...[
                                                    const SizedBox(width: 8.0),
                                                    IconText(
                                                      icon: Icon(getSortIcon(feedBloc.state)),
                                                      text: getSortName(feedBloc.state),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                        expandedHeight: 200,
                        scrolledUnderElevation: 0,
                        // leading: widget.isAccountUser
                        //     ? Padding(
                        //         padding: const EdgeInsets.fromLTRB(0.0, 4.0, 4.0, 4.0),
                        //         child: IconButton(
                        //           onPressed: () => showProfileModalSheet(context),
                        //           icon: Icon(
                        //             Icons.people_alt_rounded,
                        //             semanticLabel: AppLocalizations.of(context)!.profiles,
                        //           ),
                        //           tooltip: AppLocalizations.of(context)!.profiles,
                        //         ),
                        //       )
                        //     : null,
                        actions: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0.0, 4.0, 0.0, 4.0),
                            child: IconButton(
                              onPressed: () => userBloc?.add(ResetUserEvent()),
                              icon: Icon(
                                Icons.refresh_rounded,
                                semanticLabel: AppLocalizations.of(context)!.refresh,
                              ),
                              tooltip: AppLocalizations.of(context)!.refresh,
                            ),
                          ),
                          if (!widget.isAccountUser && userActorId != null)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0.0, 4.0, 0.0, 4.0),
                              child: IconButton(
                                onPressed: () => Share.share(userActorId!),
                                icon: Icon(
                                  Icons.share_rounded,
                                  semanticLabel: AppLocalizations.of(context)!.share,
                                ),
                                tooltip: AppLocalizations.of(context)!.share,
                              ),
                            ),
                          if (widget.userId != null && widget.isAccountUser)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0.0, 4.0, 0, 4.0),
                              child: IconButton(
                                onPressed: () {
                                  Scaffold.of(context).openEndDrawer();
                                  // final AccountBloc accountBloc = context.read<AccountBloc>();
                                  // final ThunderBloc thunderBloc = context.read<ThunderBloc>();
                                  // final UserSettingsBloc userSettingsBloc = UserSettingsBloc();

                                  // Navigator.of(context).push(
                                  //   SwipeablePageRoute(
                                  //     transitionDuration: reduceAnimations ? const Duration(milliseconds: 100) : null,
                                  //     canSwipe: Platform.isIOS || state.enableFullScreenSwipeNavigationGesture,
                                  //     canOnlySwipeFromEdge: !state.enableFullScreenSwipeNavigationGesture,
                                  //     builder: (context) => MultiBlocProvider(
                                  //       providers: [
                                  //         BlocProvider.value(value: accountBloc),
                                  //         BlocProvider.value(value: thunderBloc),
                                  //         BlocProvider.value(value: userSettingsBloc),
                                  //       ],
                                  //       child: const UserSettingsPage(),
                                  //     ),
                                  //   ),
                                  // );
                                },
                                icon: Icon(
                                  Icons.menu,
                                  semanticLabel: AppLocalizations.of(context)!.accountSettings,
                                ),
                                tooltip: AppLocalizations.of(context)!.accountSettings,
                              ),
                            ),
                        ],
                      ),
                      // SliverToBoxAdapter(
                      //   child: Stack(
                      //     children: [

                      //     ],
                      //   ),
                      // ),
                      SliverPersistentHeader(
                          pinned: true,
                          delegate: PersistentHeader(
                            child: SafeArea(
                              child: TabBar(
                                // tabAlignment: TabAlignment.start,
                                // isScrollable: true,
                                controller: tabController,
                                tabs: [
                                  Tab(
                                    child: Text(AppLocalizations.of(GlobalContext.context)!.posts),
                                  ),
                                  Tab(
                                    child: Text(AppLocalizations.of(GlobalContext.context)!.comments),
                                  ),
                                  Tab(
                                    child: Text(AppLocalizations.of(GlobalContext.context)!.about),
                                  ),
                                ],
                              ),
                            ),
                          )),
                    ];
                  },
                  body: TabBarView(
                    physics: const NeverScrollableScrollPhysics(),
                    controller: tabController,
                    children: [
                      PostCardTab(
                        postViews: widget.postViews,
                        userId: widget.userId,
                        hasReachedSavedPostEnd: widget.hasReachedSavedPostEnd,
                        isAccountUser: widget.isAccountUser,
                        hasReachedPostEnd: widget.hasReachedPostEnd,
                      ),
                      CommentsCardTab(
                        isAccountUser: widget.isAccountUser,
                        commentViewTrees: widget.commentViewTrees!,
                        userId: widget.userId,
                        hasReachedCommentsEnd: widget.hasReachedPostEnd,
                      ),
                      UserSidebar(
                        getPersonDetailsResponse: widget.fullPersonView,
                        onDismiss: () {},
                      ),
                    ],
                  ),
                ))),
      ),
    );
  }
}

class PostCardTab extends StatelessWidget {
  const PostCardTab({super.key, this.postViews, this.userId, this.personView, required this.isAccountUser, required this.hasReachedPostEnd, required this.hasReachedSavedPostEnd});

  final bool hasReachedPostEnd;
  final bool hasReachedSavedPostEnd;
  final bool isAccountUser;
  final PersonView? personView;
  final List<PostViewMedia>? postViews;
  final int? userId;

  @override
  Widget build(BuildContext context) {
    return PostCardList(
      postViews: postViews,
      personId: userId,
      hasReachedEnd: hasReachedPostEnd,
      onScrollEndReached: () => context.read<UserBloc>().add(const GetUserEvent()),
      onSaveAction: (int postId, bool save) => context.read<UserBloc>().add(SavePostEvent(postId: postId, save: save)),
      onVoteAction: (int postId, int voteType) => context.read<UserBloc>().add(VotePostEvent(postId: postId, score: voteType)),
      onToggleReadAction: (int postId, bool read) => context.read<UserBloc>().add(MarkUserPostAsReadEvent(postId: postId, read: read)),
      onHideAction: (int postId, bool hide) => context.read<UserBloc>().add(MarkUserPostAsHiddenEvent(postId: postId, hide: hide)),
      indicateRead: !isAccountUser,
      feedType: FeedType.user,
    );
  }
}

class CommentsCardTab extends StatelessWidget {
  const CommentsCardTab({
    super.key,
    required this.isAccountUser,
    this.commentViewTrees,
    required this.userId,
    this.hasReachedCommentsEnd,
  });

  final List<CommentViewTree>? commentViewTrees;
  final bool isAccountUser;
  final int? userId;
  final bool? hasReachedCommentsEnd;

  @override
  Widget build(BuildContext context) {
    final int? currentUserId = context.read<AuthBloc>().state.account?.userId;

    return Scaffold(
        body: ListView.builder(
            //controller: _scrollController,
            itemCount: commentViewTrees?.length,
            itemBuilder: (context, index) {
              return CommentReference(
                  comment: commentViewTrees![index].commentView!,
                  isOwnComment: isAccountUser && commentViewTrees![index].commentView!.creator.id == currentUserId,
                  disableActions: true,
                  onVoteAction: (int commentId, int voteType) => context.read<UserBloc>().add(VoteCommentEvent(commentId: commentId, score: voteType)),
                  onSaveAction: (int commentId, bool save) => context.read<UserBloc>().add(SaveCommentEvent(commentId: commentId, save: save)),
                  onDeleteAction: (int commentId, bool deleted) => context.read<UserBloc>().add(DeleteCommentEvent(deleted: deleted, commentId: commentId)),
                  onReportAction: (int commentId) {
                    if (isAccountUser) {
                      showSnackbar(AppLocalizations.of(context)!.cannotReportOwnComment);
                    } else {
                      showReportCommentActionBottomSheet(
                        context,
                        commentId: commentId,
                      );
                    }
                  },
                  onReplyEditAction: (CommentView commentView, bool isEdit) async =>
                      navigateToCreateCommentPage(context, commentView: isEdit ? commentView : null, parentCommentView: isEdit ? null : commentView, onCommentSuccess: (commentView, userChanged) {
                        if (!userChanged) {
                          // TODO: handle success for account page changes.
                          // context.read<UserBloc>().add(UpdateCommentEvent(commentView: commentView, isEdit: isEdit)),
                        }
                      })

                  // CommentsCardList(
                  //   commentViewTrees: widget.commentViewTrees!,
                  //   hasReachedEnd: widget.hasReachedCommentsEnd,
                  //   personId: widget.userId,
                  //   onScrollEndReached: () {},
                  //   onVoteAction: (int commentId, int voteType) => context.read<UserBloc>().add(VoteCommentEvent(commentId: commentId, score: voteType)),
                  //   onSaveAction: (int commentId, bool save) => context.read<UserBloc>().add(SaveCommentEvent(commentId: commentId, save: save)),
                  //   onDeleteAction: (int commentId, bool deleted) => context.read<UserBloc>().add(DeleteCommentEvent(deleted: deleted, commentId: commentId)),
                  //   onReportAction: (int commentId) {
                  //     if (widget.isAccountUser) {
                  //       showSnackbar(AppLocalizations.of(context)!.cannotReportOwnComment);
                  //     } else {
                  //       showReportCommentActionBottomSheet(
                  //         context,
                  //         commentId: commentId,
                  //       );
                  //     }
                  //   },
                  //   onReplyEditAction: (CommentView commentView, bool isEdit) async => navigateToCreateCommentPage(
                  //     context,
                  //     commentView: isEdit ? commentView : null,
                  //     parentCommentView: isEdit ? null : commentView,
                  //     onCommentSuccess: (commentView, userChanged) {
                  //       if (!userChanged) {
                  //         // TODO: handle success for account page changes.
                  //         // context.read<UserBloc>().add(UpdateCommentEvent(commentView: commentView, isEdit: isEdit)),
                  //       }
                  //     },
                  //   ),
                  //   isOwnComment: widget.isAccountUser,
                  //   disableActions: true,
                  // ),
                  );
            }));
  }
}
