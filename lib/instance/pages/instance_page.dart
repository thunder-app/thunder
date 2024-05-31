import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:thunder/comment/widgets/comment_list_entry.dart';
import 'package:thunder/community/widgets/community_list_entry.dart';
import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/feed/bloc/feed_bloc.dart';
import 'package:thunder/feed/view/feed_widget.dart';
import 'package:thunder/instance/bloc/instance_bloc.dart';
import 'package:thunder/instance/cubit/instance_page_cubit.dart';
import 'package:thunder/instance/enums/instance_action.dart';
import 'package:thunder/instance/widgets/instance_view.dart';
import 'package:thunder/modlog/utils/navigate_modlog.dart';
import 'package:thunder/search/widgets/search_action_chip.dart';
import 'package:thunder/shared/error_message.dart';
import 'package:thunder/shared/persistent_header.dart';
import 'package:thunder/shared/snackbar.dart';
import 'package:thunder/shared/sort_picker.dart';
import 'package:thunder/shared/thunder_popup_menu_item.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/user/widgets/user_list_entry.dart';
import 'package:thunder/utils/instance.dart';
import 'package:thunder/utils/links.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:thunder/utils/numbers.dart';

class InstancePage extends StatefulWidget {
  final GetSiteResponse getSiteResponse;
  final bool? isBlocked;

  // This is needed (in addition to Site) specifically for blocking.
  // Since site is requested directly from the target instance, its ID is only right on its own server
  // But it's wrong on the server we're connected to.
  final int? instanceId;

  const InstancePage({
    super.key,
    required this.getSiteResponse,
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
  SortType sortType = SortType.topAll;

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

    final bool isUserLoggedIn = context.read<AuthBloc>().state.isLoggedIn;
    final String? accountInstance = context.read<AuthBloc>().state.account?.instance;
    final String currentAnonymousInstance = context.read<ThunderBloc>().state.currentAnonymousInstance;

    return BlocListener<InstanceBloc, InstanceState>(
      listener: (context, state) {
        if (state.message != null) {
          showSnackbar(state.message!);
        }

        if (state.status == InstanceStatus.success && currentlyTogglingBlock) {
          currentlyTogglingBlock = false;
          setState(() {
            isBlocked = !isBlocked!;
          });
        }
      },
      child: MultiBlocProvider(
        providers: [
          BlocProvider.value(
            value: InstancePageCubit(
              instance: fetchInstanceNameFromUrl(widget.getSiteResponse.siteView.site.actorId)!,
              resolutionInstance: (isUserLoggedIn ? accountInstance : currentAnonymousInstance)!,
            ),
          ),
          BlocProvider.value(
            value: FeedBloc(lemmyClient: LemmyClient()..changeBaseUrl(fetchInstanceNameFromUrl(widget.getSiteResponse.siteView.site.actorId)!)),
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
                color: theme.colorScheme.background,
                child: SafeArea(
                  top: false,
                  child: CustomScrollView(
                    controller: _scrollController,
                    slivers: [
                      SliverAppBar(
                        pinned: true,
                        toolbarHeight: 70.0,
                        title: ListTile(
                          title: Text(
                            fetchInstanceNameFromUrl(widget.getSiteResponse.siteView.site.actorId) ?? '',
                            overflow: TextOverflow.fade,
                            maxLines: 1,
                            softWrap: false,
                            style: theme.textTheme.titleLarge,
                          ),
                          subtitle: Text("v${widget.getSiteResponse.version} · ${l10n.countUsers(formatLongNumber(widget.getSiteResponse.siteView.counts.users))}"),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                        ),
                        actions: [
                          if (LemmyClient.instance.supportsFeature(LemmyFeature.blockInstance) && widget.instanceId != null)
                            IconButton(
                              tooltip: isBlocked! ? l10n.unblockInstance : l10n.blockInstance,
                              onPressed: () {
                                currentlyTogglingBlock = true;
                                context.read<InstanceBloc>().add(InstanceActionEvent(
                                      instanceAction: InstanceAction.block,
                                      instanceId: widget.instanceId!,
                                      domain: fetchInstanceNameFromUrl(widget.getSiteResponse.siteView.site.actorId),
                                      value: !isBlocked!,
                                    ));
                              },
                              icon: Icon(
                                isBlocked! ? Icons.undo_rounded : Icons.block,
                                semanticLabel: isBlocked! ? l10n.unblockInstance : l10n.blockInstance,
                              ),
                            ),
                          if (viewType == SearchType.all)
                            IconButton(
                              tooltip: l10n.openInBrowser,
                              onPressed: () => handleLink(context, url: widget.getSiteResponse.siteView.site.actorId),
                              icon: Icon(
                                Icons.open_in_browser_rounded,
                                semanticLabel: l10n.openInBrowser,
                              ),
                            ),
                          if (viewType != SearchType.all)
                            IconButton(
                              icon: Icon(Icons.sort, semanticLabel: l10n.sortBy),
                              onPressed: () {
                                HapticFeedback.mediumImpact();

                                showModalBottomSheet<void>(
                                  showDragHandle: true,
                                  context: context,
                                  isScrollControlled: true,
                                  builder: (builderContext) => SortPicker(
                                    title: l10n.sortOptions,
                                    onSelect: (selected) async {
                                      sortType = selected.payload;
                                      _doLoad(context);
                                    },
                                    previouslySelected: sortType,
                                    minimumVersion: LemmyClient.instance.version,
                                  ),
                                );
                              },
                            ),
                          PopupMenuButton(
                            itemBuilder: (context) => [
                              ThunderPopupMenuItem(
                                onTap: () async {
                                  HapticFeedback.mediumImpact();
                                  FeedBloc feedBloc = context.read<FeedBloc>();
                                  navigateToModlogPage(
                                    context,
                                    feedBloc: feedBloc,
                                    lemmyClient: feedBloc.lemmyClient,
                                  );
                                },
                                icon: Icons.shield_rounded,
                                title: l10n.modlog,
                              ),
                              if (viewType != SearchType.all)
                                ThunderPopupMenuItem(
                                  onTap: () => handleLink(context, url: widget.getSiteResponse.siteView.site.actorId),
                                  icon: Icons.open_in_browser_rounded,
                                  title: l10n.openInBrowser,
                                ),
                            ],
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
                                children: [
                                  SearchActionChip(
                                    backgroundColor: viewType == SearchType.all ? theme.colorScheme.primaryContainer.withOpacity(0.25) : null,
                                    children: [
                                      Text(l10n.about),
                                    ],
                                    onPressed: () => setState(() => viewType = SearchType.all),
                                  ),
                                  const SizedBox(width: 10),
                                  SearchActionChip(
                                    backgroundColor: viewType == SearchType.communities ? theme.colorScheme.primaryContainer.withOpacity(0.25) : null,
                                    children: [
                                      Text(l10n.communities),
                                    ],
                                    onPressed: () async {
                                      viewType = SearchType.communities;
                                      await context.read<InstancePageCubit>().loadCommunities(page: 1, sortType: sortType);
                                      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollController.jumpTo(0));
                                    },
                                  ),
                                  // This condition can be removed if/when the Search endpoint respects the Local filter for users
                                  // ignore: dead_code
                                  if (false) ...[
                                    const SizedBox(width: 10),
                                    SearchActionChip(
                                      backgroundColor: viewType == SearchType.users ? theme.colorScheme.primaryContainer.withOpacity(0.25) : null,
                                      children: [
                                        Text(l10n.users),
                                      ],
                                      onPressed: () async {
                                        viewType = SearchType.users;
                                        await context.read<InstancePageCubit>().loadUsers(page: 1, sortType: sortType);
                                        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollController.jumpTo(0));
                                      },
                                    ),
                                  ],
                                  const SizedBox(width: 10),
                                  SearchActionChip(
                                    backgroundColor: viewType == SearchType.posts ? theme.colorScheme.primaryContainer.withOpacity(0.25) : null,
                                    children: [
                                      Text(l10n.posts),
                                    ],
                                    onPressed: () async {
                                      viewType = SearchType.posts;
                                      await context.read<InstancePageCubit>().loadPosts(page: 1, sortType: sortType);
                                      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollController.jumpTo(0));
                                    },
                                  ),
                                  const SizedBox(width: 10),
                                  SearchActionChip(
                                    backgroundColor: viewType == SearchType.comments ? theme.colorScheme.primaryContainer.withOpacity(0.25) : null,
                                    children: [
                                      Text(l10n.comments),
                                    ],
                                    onPressed: () async {
                                      viewType = SearchType.comments;
                                      await context.read<InstancePageCubit>().loadComments(page: 1, sortType: sortType);
                                      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollController.jumpTo(0));
                                    },
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
                                child: InstanceView(site: widget.getSiteResponse.siteView.site),
                              ),
                            ),
                          ),
                        if (viewType == SearchType.communities)
                          SliverList(
                            delegate: SliverChildBuilderDelegate(
                              childCount: state.communities?.length,
                              (context, index) {
                                CommunityView? communityView = state.communities?[index];
                                return Material(
                                  child: communityView != null
                                      ? CommunityListEntry(
                                          communityView: communityView,
                                          isUserLoggedIn: false,
                                          resolutionInstance: state.resolutionInstance,
                                        )
                                      : Container(),
                                );
                              },
                            ),
                          ),
                        if (viewType == SearchType.users)
                          SliverList(
                            delegate: SliverChildBuilderDelegate(
                              childCount: state.users?.length,
                              (context, index) {
                                PersonView? user = state.users?[index];
                                return Material(
                                  child: user != null
                                      ? UserListEntry(
                                          personView: user,
                                          resolutionInstance: state.resolutionInstance,
                                        )
                                      : Container(),
                                );
                              },
                            ),
                          ),
                        if (viewType == SearchType.posts)
                          FeedPostList(
                            markPostReadOnScroll: false,
                            postViewMedias: state.posts ?? [],
                            tabletMode: tabletMode,
                          ),
                        if (viewType == SearchType.comments)
                          SliverList(
                            delegate: SliverChildBuilderDelegate(
                              childCount: state.comments?.length,
                              (context, index) {
                                var commentView = state.comments?[index];
                                return Material(
                                  child: commentView != null ? CommentListEntry(commentView: commentView) : Container(),
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
      ),
    );
  }

  Future<void> _doLoad(BuildContext context, {int? page}) async {
    final InstancePageCubit instancePageCubit = context.read<InstancePageCubit>();

    switch (viewType) {
      case SearchType.communities:
        await instancePageCubit.loadCommunities(page: page ?? 1, sortType: sortType);
        break;
      case SearchType.users:
        await instancePageCubit.loadUsers(page: page ?? 1, sortType: sortType);
        break;
      case SearchType.posts:
        await instancePageCubit.loadPosts(page: page ?? 1, sortType: sortType);
        break;
      case SearchType.comments:
        await instancePageCubit.loadComments(page: page ?? 1, sortType: sortType);
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
