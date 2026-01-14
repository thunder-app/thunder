import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/src/app/utils/global_context.dart';
import 'package:thunder/src/core/enums/meta_search_type.dart';
import 'package:thunder/src/core/enums/search_sort_type.dart';
import 'package:thunder/src/core/models/models.dart';
import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/features/feed/feed.dart';
import 'package:thunder/src/features/instance/instance.dart';
import 'package:thunder/src/features/instance/presentation/bloc/instance_page_bloc.dart';
import 'package:thunder/src/features/instance/presentation/bloc/instance_page_event.dart';
import 'package:thunder/src/features/instance/presentation/widgets/instance_page_app_bar.dart';
import 'package:thunder/src/features/instance/presentation/widgets/instance_tabs.dart';

/// A widget that displays the instance page.
///
/// The page contains information about a given instance, with the ability to explore its content.
class InstancePage extends StatefulWidget {
  /// The instance to display.
  final ThunderInstanceInfo instance;

  const InstancePage({
    super.key,
    required this.instance,
  });

  @override
  State<InstancePage> createState() => _InstancePageState();
}

class _InstancePageState extends State<InstancePage> with SingleTickerProviderStateMixin {
  /// The tab controller
  late final TabController _tabController;

  /// The post sort type to use
  SearchSortType searchSortType = SearchSortType.topAll;

  /// Context for [_onScroll] to use to find the proper cubit
  BuildContext? buildContext;

  /// The query to use for search
  String? query;

  @override
  void initState() {
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) _handleTabChange();
    });

    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onRefresh() {
    final context = buildContext;
    if (context == null || !context.mounted) return;

    // Refresh specific tab and reset others
    final bloc = context.read<InstancePageBloc>();

    switch (_tabController.index) {
      case 1:
        bloc.add(ResetInstanceTabs(excludeType: MetaSearchType.communities));
        bloc.add(GetInstanceCommunities(page: 1, sortType: searchSortType, query: query));
        break;
      case 2:
        bloc.add(ResetInstanceTabs(excludeType: MetaSearchType.users));
        bloc.add(GetInstanceUsers(page: 1, sortType: searchSortType, query: query));
        break;
      case 3:
        bloc.add(ResetInstanceTabs(excludeType: MetaSearchType.posts));
        bloc.add(GetInstancePosts(page: 1, sortType: searchSortType, query: query));
        break;
      case 4:
        bloc.add(ResetInstanceTabs(excludeType: MetaSearchType.comments));
        bloc.add(GetInstanceComments(page: 1, sortType: searchSortType, query: query));
        break;
      default:
        bloc.add(const ResetInstanceTabs(excludeType: null));
        break;
    }
  }

  void _handleTabChange() {
    final context = buildContext;
    if (context == null || !context.mounted) return;

    final bloc = context.read<InstancePageBloc>();

    switch (_tabController.index) {
      case 1:
        if (bloc.state.communities.items.isEmpty) bloc.add(GetInstanceCommunities(sortType: searchSortType, query: query));
        break;
      case 2:
        if (bloc.state.users.items.isEmpty) bloc.add(GetInstanceUsers(sortType: searchSortType, query: query));
        break;
      case 3:
        if (bloc.state.posts.items.isEmpty) bloc.add(GetInstancePosts(sortType: searchSortType, query: query));
        break;
      case 4:
        if (bloc.state.comments.items.isEmpty) bloc.add(GetInstanceComments(sortType: searchSortType, query: query));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = GlobalContext.l10n;

    final account = context.read<ProfileBloc>().state.account;

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => InstancePageBloc(account: account, instanceInfo: widget.instance)),
        BlocProvider(create: (context) => FeedBloc(account: account)),
      ],
      child: BlocConsumer<InstancePageBloc, InstancePageState>(
        listener: (context, state) {
          context.read<FeedBloc>().add(PopulatePostsEvent(state.posts.items));
        },
        builder: (context, state) {
          buildContext = context;

          return Scaffold(
            body: SafeArea(
              top: false,
              child: NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    SliverOverlapAbsorber(
                      handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                      sliver: InstancePageAppBar(
                        instance: widget.instance,
                        searchSortType: searchSortType,
                        account: account,
                        onSortSelected: (sortType) {
                          setState(() => searchSortType = sortType);
                          _onRefresh();
                        },
                        onQueryChanged: (query) {
                          setState(() => this.query = query);
                          _onRefresh();
                        },
                        bottom: TabBar(
                          controller: _tabController,
                          isScrollable: true,
                          tabAlignment: TabAlignment.start,
                          tabs: [
                            Tab(
                              child: Row(
                                spacing: 6.0,
                                children: [const Icon(Icons.info_outline_rounded, size: 20.0), Text(l10n.about)],
                              ),
                            ),
                            Tab(
                              child: Row(
                                spacing: 6.0,
                                children: [const Icon(Icons.groups_outlined, size: 20.0), Text(l10n.communities)],
                              ),
                            ),
                            Tab(
                              child: Row(
                                spacing: 6.0,
                                children: [const Icon(Icons.people_outlined, size: 20.0), Text(l10n.users)],
                              ),
                            ),
                            Tab(
                              child: Row(
                                spacing: 6.0,
                                children: [const Icon(Icons.splitscreen_rounded, size: 20.0), Text(l10n.posts)],
                              ),
                            ),
                            Tab(
                              child: Row(
                                spacing: 6.0,
                                children: [const Icon(Icons.comment_outlined, size: 20.0), Text(l10n.comments)],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ];
                },
                body: TabBarView(
                  controller: _tabController,
                  children: [
                    // About Tab
                    Builder(builder: (context) {
                      return CustomScrollView(
                        key: const PageStorageKey('about'),
                        slivers: [
                          SliverOverlapInjector(handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context)),
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Material(
                                child: InstanceInformation(instance: widget.instance),
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                    InstanceCommunityTab(
                      account: account,
                      query: query,
                      searchSortType: searchSortType,
                      onRetry: () => context.read<InstancePageBloc>().add(GetInstanceCommunities(sortType: searchSortType, query: query)),
                    ),
                    InstanceUserTab(
                      account: account,
                      query: query,
                      searchSortType: searchSortType,
                      onRetry: () => context.read<InstancePageBloc>().add(GetInstanceUsers(sortType: searchSortType, query: query)),
                    ),
                    InstancePostTab(
                      account: account,
                      query: query,
                      searchSortType: searchSortType,
                      onRetry: () => context.read<InstancePageBloc>().add(GetInstancePosts(sortType: searchSortType, query: query)),
                    ),
                    InstanceCommentTab(
                      account: account,
                      query: query,
                      searchSortType: searchSortType,
                      onRetry: () => context.read<InstancePageBloc>().add(GetInstanceComments(sortType: searchSortType, query: query)),
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
}
