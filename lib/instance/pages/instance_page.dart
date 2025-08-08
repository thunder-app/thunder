import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lemmy_api_client/v3.dart';

import 'package:thunder/account/account.dart';
import 'package:thunder/comment/comment.dart';
import 'package:thunder/community/widgets/community_list_entry.dart';
import 'package:thunder/core/enums/post_sort_type.dart';
import 'package:thunder/core/enums/threadiverse_platform.dart';
import 'package:thunder/core/models/models.dart';
import 'package:thunder/feed/bloc/feed_bloc.dart';
import 'package:thunder/feed/widgets/feed_post_card_list.dart';
import 'package:thunder/instance/cubit/instance_page_cubit.dart';
import 'package:thunder/instance/repository/instance_repository.dart';
import 'package:thunder/instance/widgets/instance_view.dart';
import 'package:thunder/utils/constants.dart';
import 'package:thunder/utils/navigation.dart';
import 'package:thunder/shared/chips/thunder_action_chip.dart';
import 'package:thunder/shared/error_message.dart';
import 'package:thunder/shared/persistent_header.dart';
import 'package:thunder/shared/snackbar.dart';
import 'package:thunder/shared/sort_picker.dart';
import 'package:thunder/shared/thunder_popup_menu_item.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/user/widgets/user_list_entry.dart';
import 'package:thunder/utils/instance.dart';
import 'package:thunder/utils/links.dart';
import 'package:thunder/localizations/app_localizations.dart';
import 'package:thunder/utils/numbers.dart';

class InstancePage extends StatefulWidget {
  /// The platform of the instance.
  final ThreadiversePlatform platform;

  /// The site information for the instance.
  final ThunderSiteResponse site;

  /// Whether the instance is blocked.
  final bool? isBlocked;

  // This is needed (in addition to Site) specifically for blocking.
  // Since site is requested directly from the target instance, its ID is only right on its own server
  // But it's wrong on the server we're connected to.
  final int? instanceId;

  const InstancePage({
    super.key,
    required this.platform,
    required this.site,
    required this.isBlocked,
    required this.instanceId,
  });

  @override
  State<InstancePage> createState() => _InstancePageState();
}

class _InstancePageState extends State<InstancePage> {
  final ScrollController _scrollController = ScrollController(initialScrollOffset: 0);
  bool _isLoading = false;

  bool? isBlocked;
  bool currentlyTogglingBlock = false;

  // Use the existing SearchType enum to represent what we're showing in the instance page
  // with SearchType.all representing the about page
  SearchType viewType = SearchType.all;
  PostSortType postSortType = PostSortType.topAll;

  /// Context for [_onScroll] to use
  BuildContext? buildContext;

  @override
  void initState() {
    _scrollController.addListener(_onScroll);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final ThemeData theme = Theme.of(context);

    isBlocked ??= widget.isBlocked ?? false;
    final bool tabletMode = context.read<ThunderBloc>().state.tabletMode;

    final bool isUserLoggedIn = context.read<ProfileBloc>().state.isLoggedIn;
    final String accountInstance = context.read<ProfileBloc>().state.account.instance;
    final String? currentAnonymousInstance = context.read<ThunderBloc>().state.currentAnonymousInstance;

    final chipColor = theme.colorScheme.primaryContainer.withValues(alpha: 0.25);

    final account = context.select<ProfileBloc, Account>((bloc) => bloc.state.account);

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(
          value: InstancePageCubit(
            instance: fetchInstanceNameFromUrl(widget.site.site.actorId)!,
            resolutionInstance: (isUserLoggedIn ? accountInstance : currentAnonymousInstance)!,
            account: account,
          ),
        ),
        BlocProvider.value(
          value: FeedBloc(
            account: Account(
              id: '',
              instance: fetchInstanceNameFromUrl(widget.site.site.actorId)!,
              index: -1,
              platform: widget.platform,
            ),
          ),
        ),
      ],
      child: BlocConsumer<InstancePageCubit, InstancePageState>(
        listener: (context, state) {
          context.read<FeedBloc>().add(PopulatePostsEvent(state.posts ?? []));
        },
        builder: (context, state) {
          buildContext = context;
          return Scaffold(
            body: Container(
              color: theme.colorScheme.surface,
              child: SafeArea(
                top: false,
                child: CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    SliverAppBar(
                      pinned: true,
                      toolbarHeight: APP_BAR_HEIGHT,
                      title: ListTile(
                        title: Text(
                          fetchInstanceNameFromUrl(widget.site.site.actorId) ?? '',
                          overflow: TextOverflow.fade,
                          maxLines: 1,
                          softWrap: false,
                          style: theme.textTheme.titleLarge,
                        ),
                        subtitle: Text("v${widget.site.version} · ${l10n.countUsers(formatLongNumber(widget.site.site.users ?? 0))}"),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                      ),
                      actions: [
                        if (widget.instanceId != null)
                          IconButton(
                            tooltip: isBlocked! ? l10n.unblockInstance : l10n.blockInstance,
                            onPressed: () async {
                              currentlyTogglingBlock = true;

                              final repository = InstanceRepositoryImpl(account: account);
                              final blocked = await repository.block(widget.instanceId!, !isBlocked!);

                              if (blocked) {
                                showSnackbar(l10n.successfullyBlockedCommunity(fetchInstanceNameFromUrl(widget.site.site.actorId) ?? ''));
                              } else {
                                showSnackbar(l10n.successfullyUnblockedCommunity(fetchInstanceNameFromUrl(widget.site.site.actorId) ?? ''));
                              }

                              currentlyTogglingBlock = false;
                              setState(() => isBlocked = !isBlocked!);
                            },
                            icon: Icon(
                              isBlocked! ? Icons.undo_rounded : Icons.block,
                              semanticLabel: isBlocked! ? l10n.unblockInstance : l10n.blockInstance,
                            ),
                          ),
                        if (viewType == SearchType.all)
                          IconButton(
                            tooltip: l10n.openInBrowser,
                            onPressed: () => handleLink(context, url: widget.site.site.actorId),
                            icon: Icon(
                              Icons.open_in_browser_rounded,
                              semanticLabel: l10n.openInBrowser,
                            ),
                          ),
                        if (viewType != SearchType.all)
                          IconButton(
                            icon: Icon(Icons.sort, semanticLabel: l10n.sortBy),
                            onPressed: () {
                              final feedBloc = context.read<FeedBloc>();
                              HapticFeedback.mediumImpact();

                              showModalBottomSheet<void>(
                                showDragHandle: true,
                                context: context,
                                isScrollControlled: true,
                                builder: (builderContext) => SortPicker(
                                  account: feedBloc.account,
                                  title: l10n.sortOptions,
                                  onSelect: (selected) async {
                                    postSortType = selected.payload;
                                    _doLoad(context);
                                  },
                                  previouslySelected: postSortType,
                                ),
                              );
                            },
                          ),
                        Semantics(
                          label: l10n.menu,
                          child: PopupMenuButton(
                            itemBuilder: (context) => [
                              ThunderPopupMenuItem(
                                onTap: () async {
                                  HapticFeedback.mediumImpact();
                                  navigateToModlogPage(
                                    context,
                                    subtitle: fetchInstanceNameFromUrl(widget.site.site.actorId) ?? '',
                                  );
                                },
                                icon: Icons.shield_rounded,
                                title: l10n.modlog,
                              ),
                              if (viewType != SearchType.all)
                                ThunderPopupMenuItem(
                                  onTap: () => handleLink(context, url: widget.site.site.actorId),
                                  icon: Icons.open_in_browser_rounded,
                                  title: l10n.openInBrowser,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: PersistentHeader(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 15, right: 15),
                            child: Row(
                              spacing: 10.0,
                              children: [
                                ThunderActionChip(
                                  backgroundColor: viewType == SearchType.all ? chipColor : null,
                                  icon: Icons.info_rounded,
                                  onPressed: () => setState(() => viewType = SearchType.all),
                                  label: l10n.about,
                                ),
                                ThunderActionChip(
                                  backgroundColor: viewType == SearchType.communities ? chipColor : null,
                                  icon: Icons.people_rounded,
                                  onPressed: () async {
                                    viewType = SearchType.communities;
                                    await context.read<InstancePageCubit>().loadCommunities(page: 1, postSortType: postSortType);
                                    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollController.jumpTo(0));
                                  },
                                  label: l10n.communities,
                                ),
                                ThunderActionChip(
                                  backgroundColor: viewType == SearchType.users ? chipColor : null,
                                  icon: Icons.person_rounded,
                                  onPressed: () async {
                                    viewType = SearchType.users;
                                    await context.read<InstancePageCubit>().loadUsers(page: 1, postSortType: postSortType);
                                    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollController.jumpTo(0));
                                  },
                                  label: l10n.users,
                                ),
                                ThunderActionChip(
                                  backgroundColor: viewType == SearchType.posts ? chipColor : null,
                                  icon: Icons.article_rounded,
                                  onPressed: () async {
                                    viewType = SearchType.posts;
                                    await context.read<InstancePageCubit>().loadPosts(page: 1, postSortType: postSortType);
                                    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollController.jumpTo(0));
                                  },
                                  label: l10n.posts,
                                ),
                                ThunderActionChip(
                                  backgroundColor: viewType == SearchType.comments ? chipColor : null,
                                  icon: Icons.comment_rounded,
                                  onPressed: () async {
                                    viewType = SearchType.comments;
                                    await context.read<InstancePageCubit>().loadComments(page: 1, postSortType: postSortType);
                                    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollController.jumpTo(0));
                                  },
                                  label: l10n.comments,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (state.status == InstancePageStatus.loading)
                      const SliverFillRemaining(
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    if (state.status == InstancePageStatus.failure)
                      SliverFillRemaining(
                        child: ErrorMessage(
                          message: state.errorMessage,
                          actions: [
                            (
                              text: l10n.refreshContent,
                              action: () async => await _doLoad(context),
                              loading: false,
                            ),
                          ],
                        ),
                      ),
                    if (state.status == InstancePageStatus.success || state.status == InstancePageStatus.done) ...[
                      if (viewType == SearchType.all)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Material(
                              child: InstanceView(site: widget.site.site),
                            ),
                          ),
                        ),
                      if (viewType == SearchType.communities)
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            childCount: state.communities?.length,
                            (context, index) {
                              final community = state.communities?[index];

                              return Material(
                                child: community != null ? CommunityListEntry(community: community, resolutionInstance: state.resolutionInstance) : Container(),
                              );
                            },
                          ),
                        ),
                      if (viewType == SearchType.users)
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            childCount: state.users?.length,
                            (context, index) {
                              final user = state.users?[index];
                              return Material(child: user != null ? UserListEntry(user: user, resolutionInstance: state.resolutionInstance) : Container());
                            },
                          ),
                        ),
                      if (viewType == SearchType.posts)
                        FeedPostCardList(
                          markPostReadOnScroll: false,
                          posts: state.posts ?? [],
                          tabletMode: tabletMode,
                        ),
                      if (viewType == SearchType.comments)
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            childCount: state.comments?.length,
                            (context, index) {
                              final comment = state.comments?[index];
                              return Material(
                                child: comment != null ? CommentListEntry(comment: comment) : Container(),
                              );
                            },
                          ),
                        ),
                    ],
                    if (state.status == InstancePageStatus.success && viewType != SearchType.all) ...[
                      const SliverToBoxAdapter(
                        child: SizedBox(height: 10),
                      ),
                      const SliverToBoxAdapter(
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    ],
                    if (viewType != SearchType.all)
                      const SliverToBoxAdapter(
                        child: SizedBox(height: 10),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _doLoad(BuildContext context, {int? page}) async {
    final InstancePageCubit instancePageCubit = context.read<InstancePageCubit>();

    switch (viewType) {
      case SearchType.communities:
        await instancePageCubit.loadCommunities(page: page ?? 1, postSortType: postSortType);
        break;
      case SearchType.users:
        await instancePageCubit.loadUsers(page: page ?? 1, postSortType: postSortType);
        break;
      case SearchType.posts:
        await instancePageCubit.loadPosts(page: page ?? 1, postSortType: postSortType);
        break;
      case SearchType.comments:
        await instancePageCubit.loadComments(page: page ?? 1, postSortType: postSortType);
        break;
      default:
        break;
    }
  }

  Future<void> _onScroll() async {
    if (!_isLoading && _scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.8) {
      _isLoading = true;
      InstancePageState? instancePageState = buildContext?.read<InstancePageCubit>().state;
      if (instancePageState != null && instancePageState.status != InstancePageStatus.done) {
        await _doLoad(buildContext!, page: (instancePageState.page ?? 0) + 1);
      }
      _isLoading = false;
    }
  }
}
