import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/src/features/community/community.dart';
import 'package:thunder/src/core/enums/threadiverse_platform.dart';
import 'package:thunder/l10n/generated/app_localizations.dart';
import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/features/comment/comment.dart';
import 'package:thunder/src/core/enums/enums.dart';
import 'package:thunder/src/core/enums/post_sort_type.dart';
import 'package:thunder/src/core/enums/full_name.dart';
import 'package:thunder/src/core/enums/meta_search_type.dart';
import 'package:thunder/src/core/models/models.dart';
import 'package:thunder/src/core/singletons/preferences.dart';
import 'package:thunder/src/features/feed/feed.dart';
import 'package:thunder/src/app/utils/navigation.dart';
import 'package:thunder/src/features/instance/instance.dart';
import 'package:thunder/src/features/search/search.dart';
import 'package:thunder/src/shared/widgets/chips/thunder_action_chip.dart';
import 'package:thunder/src/shared/error_message.dart';
import 'package:thunder/src/shared/input_dialogs.dart';
import 'package:thunder/src/shared/sort_picker.dart';
import 'package:thunder/src/app/bloc/thunder_bloc.dart';
import 'package:thunder/src/features/user/user.dart';
import 'package:thunder/src/shared/utils/bottom_sheet_list_picker.dart';
import 'package:thunder/src/shared/utils/constants.dart';
import 'package:thunder/src/shared/utils/debounce.dart';
import 'package:thunder/src/app/utils/global_context.dart';
import 'package:thunder/src/shared/utils/instance.dart';

class SearchPage extends StatefulWidget {
  /// Allows the search page to limited to searching a specific community
  final ThunderCommunity? communityToSearch;

  /// Whether the search field is initially focused upon opening this page
  final bool isInitiallyFocused;

  const SearchPage({super.key, this.communityToSearch, this.isInitiallyFocused = false});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with AutomaticKeepAliveClientMixin<SearchPage> {
  @override
  bool get wantKeepAlive => true;

  final TextEditingController _controller = TextEditingController();
  final _scrollController = ScrollController(initialScrollOffset: 0);
  // This exists only because it is required by FadingEdgeScrollView
  final ScrollController _searchFiltersScrollController = ScrollController();
  PostSortType postSortType = PostSortType.active;
  IconData? postSortTypeIcon;
  String? postSortTypeLabel;
  int _previousFocusSearchId = 0;
  final searchTextFieldFocus = FocusNode();
  int? _previousUserId;
  int? _previousFavoritesCount;

  late MetaSearchType _currentSearchType;
  FeedListType _currentFeedType = FeedListType.all;
  IconData? _feedTypeIcon = Icons.grid_view_rounded;
  String? _feedTypeLabel = AppLocalizations.of(GlobalContext.context)!.all;
  bool _searchByUrl = false;
  String _searchUrlLabel = AppLocalizations.of(GlobalContext.context)!.text;
  String? _currentCommunityFilterName;
  int? _currentCommunityFilter;
  String? _currentCreatorFilterName;
  int? _currentCreatorFilter;

  @override
  void initState() {
    _currentSearchType = widget.communityToSearch == null ? MetaSearchType.communities : MetaSearchType.posts;
    _scrollController.addListener(_onScroll);
    initPrefs();
    fetchActiveProfile().then((activeProfile) => _previousUserId = activeProfile.userId);
    context.read<SearchBloc>().add(GetTrendingCommunitiesEvent());

    if (widget.isInitiallyFocused) {
      WidgetsBinding.instance.addPostFrameCallback((_) => searchTextFieldFocus.requestFocus());
    }

    BackButtonInterceptor.add(_handleBackButtonPress);
    super.initState();
  }

  Future<void> initPrefs() async {
    setState(() {
      postSortType = PostSortType.values.byName(UserPreferences.instance.preferences.getString("search_default_sort_type") ?? DEFAULT_SEARCH_POST_SORT_TYPE.name);
      final postSortTypeItem = allPostSortTypeItems.firstWhere((item) => item.payload == postSortType);
      postSortTypeIcon = postSortTypeItem.icon;
      postSortTypeLabel = postSortTypeItem.label;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();

    super.dispose();
  }

  FutureOr<bool> _handleBackButtonPress(bool stopDefaultButtonEvent, RouteInfo info) async {
    if (searchTextFieldFocus.hasFocus) searchTextFieldFocus.unfocus();
    return false;
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.8) {
      if (context.read<SearchBloc>().state.status != SearchStatus.done) {
        context.read<SearchBloc>().add(ContinueSearchEvent(
              query: _controller.text,
              postSortType: postSortType,
              feedListType: _currentFeedType,
              searchType: _getSearchTypeToUse(),
              communityId: widget.communityToSearch?.id ?? _currentCommunityFilter,
              creatorId: _currentCreatorFilter,
              favoriteCommunities: context.read<ProfileBloc>().state.favorites,
            ));
      }
    }
  }

  void resetTextField() {
    searchTextFieldFocus.requestFocus();
    _controller.clear(); // Clear the search field
  }

  void _onChange(BuildContext context, String value) {
    if (_currentSearchType == MetaSearchType.posts && Uri.tryParse(value)?.isAbsolute == true) {
      setState(() {
        _searchByUrl = true;
        _searchUrlLabel = AppLocalizations.of(context)!.url;
      });
    }

    _doSearch();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    super.build(context);

    context.read<AnonymousSubscriptionsBloc>().add(GetSubscribedCommunitiesEvent());

    final account = context.select<ProfileBloc, Account>((bloc) => bloc.state.account);

    List<ListPickerItem> searchOptions = [
      ListPickerItem(label: l10n.communities, payload: MetaSearchType.communities, icon: Icons.people_rounded),
      ListPickerItem(label: l10n.users, payload: MetaSearchType.users, icon: Icons.person_rounded),
      ListPickerItem(label: l10n.posts, payload: MetaSearchType.posts, icon: Icons.wysiwyg_rounded),
      ListPickerItem(label: l10n.comments, payload: MetaSearchType.comments, icon: Icons.chat_rounded),
      ListPickerItem(label: l10n.instance(2), payload: MetaSearchType.instances, icon: Icons.language),
    ];

    // Only keep post/comment for community search
    if (widget.communityToSearch != null) {
      searchOptions = searchOptions.where((option) => option.payload == MetaSearchType.posts || option.payload == MetaSearchType.comments).toList();
    }

    // PieFed only supports communities, posts, users, url
    if (account.platform == ThreadiversePlatform.piefed) {
      searchOptions = searchOptions
          .where((option) => option.payload == MetaSearchType.communities || option.payload == MetaSearchType.posts || option.payload == MetaSearchType.users || option.payload == MetaSearchType.url)
          .toList();
    }

    return BlocProvider(
      create: (context) => FeedBloc(account: account),
      child: MultiBlocListener(
        listeners: [
          BlocListener<FeedBloc, FeedState>(listener: (context, state) => setState(() {})),
          BlocListener<AnonymousSubscriptionsBloc, AnonymousSubscriptionsState>(listener: (context, state) {}),
          BlocListener<SearchBloc, SearchState>(listener: (context, state) => context.read<FeedBloc>().add(PopulatePostsEvent(state.posts ?? []))),
          BlocListener<ProfileBloc, ProfileState>(listener: (context, state) async {
            final activeProfile = await fetchActiveProfile();

            // When account changes, that means our instance most likely changed, so reset search.
            if (state.status == ProfileStatus.success && ((activeProfile.userId == null && _previousUserId != null) || state.user?.id == activeProfile.userId && _previousUserId != state.user?.id) ||
                (state.favorites.length != _previousFavoritesCount && _controller.text.isEmpty)) {
              _controller.clear();
              if (context.mounted) context.read<SearchBloc>().add(ResetSearch());
              setState(() {});
              _previousUserId = activeProfile.userId;
              _previousFavoritesCount = state.favorites.length;
            }
          }),
          BlocListener<ThunderBloc, ThunderState>(
            listener: (context, state) {
              _controller.clear();
              context.read<SearchBloc>().add(ResetSearch());
              setState(() {});
              _previousUserId = null;
            },
          ),
        ],
        child: BlocSelector<SearchBloc, SearchState, int>(
          selector: (state) => state.focusSearchId,
          builder: (context, focusSearchId) {
            if (focusSearchId > _previousFocusSearchId) {
              searchTextFieldFocus.requestFocus();
              _previousFocusSearchId = focusSearchId;
            }

            return Scaffold(
              appBar: AppBar(
                  toolbarHeight: 90.0,
                  scrolledUnderElevation: 0.0,
                  title: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(50),
                    child: Stack(
                      children: [
                        TextField(
                          keyboardType: (!kIsWeb && Platform.isIOS) ? TextInputType.text : TextInputType.url,
                          focusNode: searchTextFieldFocus,
                          onChanged: (value) => debounce(const Duration(milliseconds: 300), _onChange, [context, value]),
                          controller: _controller,
                          onTap: () {
                            HapticFeedback.selectionClick();
                          },
                          decoration: InputDecoration(
                            fillColor: Theme.of(context).searchViewTheme.backgroundColor,
                            hintText: l10n.searchInstance(widget.communityToSearch?.name ?? account.instance),
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(50),
                              borderSide: const BorderSide(
                                width: 0,
                                style: BorderStyle.none,
                              ),
                            ),
                            suffixIcon: _controller.text.isNotEmpty
                                ? SizedBox(
                                    width: 50,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        IconButton(
                                          icon: Icon(
                                            Icons.close,
                                            semanticLabel: l10n.clearSearch,
                                          ),
                                          onPressed: () {
                                            resetTextField();
                                            context.read<SearchBloc>().add(ResetSearch());
                                          },
                                        ),
                                      ],
                                    ),
                                  )
                                : null,
                            prefixIcon: const Icon(Icons.search_rounded),
                            contentPadding: const EdgeInsets.fromLTRB(12, 20, 12, 12),
                          ),
                        ),
                      ],
                    ),
                  )),
              body: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 15, top: 10, right: 15),
                    child: FadingEdgeScrollView.fromSingleChildScrollView(
                      gradientFractionOnStart: 0.1,
                      gradientFractionOnEnd: 0.1,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        controller: _searchFiltersScrollController,
                        child: Row(
                          children: [
                            if (context.read<SearchBloc>().state.viewingAll) ...[
                              ThunderActionChip(
                                backgroundColor: theme.colorScheme.primaryContainer.withValues(alpha: 0.25),
                                trailingIcon: Icons.close_rounded,
                                label: l10n.viewingAll,
                                onPressed: () => context.read<SearchBloc>().add(ResetSearch()),
                              ),
                              const SizedBox(width: 10),
                            ],
                            ThunderActionChip(
                              trailingIcon: Icons.arrow_drop_down_rounded,
                              label: _currentSearchType.name.capitalize,
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  showDragHandle: true,
                                  builder: (ctx) => BottomSheetListPicker(
                                    title: l10n.selectSearchType,
                                    items: searchOptions,
                                    onSelect: (value) async => _setCurrentSearchType(value.payload),
                                    previouslySelected: _currentSearchType,
                                  ),
                                );
                              },
                            ),
                            const SizedBox(width: 10),
                            if (_currentSearchType == MetaSearchType.posts) ...[
                              ThunderActionChip(
                                icon: Icons.link_rounded,
                                trailingIcon: Icons.arrow_drop_down_rounded,
                                label: _searchUrlLabel,
                                onPressed: () {
                                  showModalBottomSheet(
                                    context: context,
                                    showDragHandle: true,
                                    builder: (ctx) => BottomSheetListPicker(
                                      title: l10n.searchPostSearchType,
                                      items: [
                                        ListPickerItem(label: l10n.searchByText, payload: 'text', icon: Icons.wysiwyg_rounded),
                                        ListPickerItem(label: l10n.searchByUrl, payload: 'url', icon: Icons.link_rounded),
                                      ],
                                      onSelect: (value) async {
                                        setState(() {
                                          _searchByUrl = value.payload == 'url';
                                          _searchUrlLabel = value.payload == 'url' ? l10n.url : l10n.text;
                                        });
                                        _doSearch();
                                      },
                                      previouslySelected: _searchByUrl ? 'url' : 'text',
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(width: 10),
                            ],
                            if (_currentSearchType != MetaSearchType.instances) ...[
                              ThunderActionChip(
                                icon: postSortTypeIcon,
                                trailingIcon: Icons.arrow_drop_down_rounded,
                                label: postSortTypeLabel ?? l10n.sortBy,
                                onPressed: () => showSortBottomSheet(context),
                              ),
                              if (widget.communityToSearch == null) ...[
                                const SizedBox(width: 10),
                                ThunderActionChip(
                                  icon: _feedTypeIcon,
                                  trailingIcon: Icons.arrow_drop_down_rounded,
                                  label: _feedTypeLabel ?? l10n.feed,
                                  onPressed: () {
                                    showModalBottomSheet(
                                      context: context,
                                      showDragHandle: true,
                                      builder: (ctx) => BottomSheetListPicker(
                                        title: l10n.selectFeedType,
                                        items: [
                                          ListPickerItem(label: l10n.subscribed, payload: FeedListType.subscribed, icon: Icons.view_list_rounded),
                                          ListPickerItem(label: l10n.local, payload: FeedListType.local, icon: Icons.home_rounded),
                                          ListPickerItem(label: l10n.all, payload: FeedListType.all, icon: Icons.grid_view_rounded)
                                        ],
                                        onSelect: (value) async {
                                          setState(() {
                                            if (value.payload == FeedListType.subscribed) {
                                              _feedTypeLabel = l10n.subscribed;
                                              _feedTypeIcon = Icons.view_list_rounded;
                                            } else if (value.payload == FeedListType.local) {
                                              _feedTypeLabel = l10n.local;
                                              _feedTypeIcon = Icons.home_rounded;
                                            } else if (value.payload == FeedListType.all) {
                                              _feedTypeLabel = l10n.all;
                                              _feedTypeIcon = Icons.grid_view_rounded;
                                            }
                                            _currentFeedType = value.payload;
                                          });
                                          _doSearch();
                                        },
                                        previouslySelected: _currentFeedType,
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(width: 10),
                                ThunderActionChip(
                                  backgroundColor: _currentCommunityFilter == null ? null : theme.colorScheme.primaryContainer.withValues(alpha: 0.25),
                                  icon: Icons.people_rounded,
                                  trailingIcon: _currentCommunityFilter != null ? Icons.close_rounded : Icons.arrow_drop_down_rounded,
                                  label: _currentCommunityFilter == null ? l10n.community : l10n.filteringBy(_currentCommunityFilterName ?? ''),
                                  onPressed: () {
                                    if (_currentCommunityFilter != null) {
                                      setState(() {
                                        _currentCommunityFilter = null;
                                        _currentCommunityFilterName = null;
                                      });
                                      _doSearch();
                                    } else {
                                      showCommunityInputDialog(
                                        context,
                                        title: l10n.community,
                                        account: account,
                                        onCommunitySelected: (ThunderCommunity community) {
                                          setState(() {
                                            _currentCommunityFilter = community.id;
                                            _currentCommunityFilterName = generateCommunityFullName(
                                              context,
                                              community.name,
                                              community.title,
                                              fetchInstanceNameFromUrl(community.actorId),
                                            );
                                          });
                                          _doSearch();
                                        },
                                      );
                                    }
                                  },
                                ),
                              ],
                              const SizedBox(width: 10),
                              ThunderActionChip(
                                backgroundColor: _currentCreatorFilter == null ? null : theme.colorScheme.primaryContainer.withValues(alpha: 0.25),
                                icon: Icons.person_rounded,
                                trailingIcon: _currentCreatorFilter != null ? Icons.close_rounded : Icons.arrow_drop_down_rounded,
                                label: _currentCreatorFilter == null ? l10n.creator : l10n.filteringBy(_currentCreatorFilterName ?? ''),
                                onPressed: () {
                                  if (_currentCreatorFilter != null) {
                                    setState(() {
                                      _currentCreatorFilter = null;
                                      _currentCreatorFilterName = null;
                                    });
                                    _doSearch();
                                  } else {
                                    showUserInputDialog(
                                      context,
                                      title: l10n.creator,
                                      account: account,
                                      onUserSelected: (user) {
                                        setState(() {
                                          _currentCreatorFilter = user.id;
                                          _currentCreatorFilterName = generateUserFullName(
                                            context,
                                            user.name,
                                            user.displayName,
                                            fetchInstanceNameFromUrl(user.actorId),
                                          );
                                        });
                                        _doSearch();
                                      },
                                    );
                                  }
                                },
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 60),
                    child: _getSearchBody(context, context.read<SearchBloc>().state, account.instance),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _getSearchBody(BuildContext context, SearchState state, String accountInstance) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final bool tabletMode = context.select<ThunderBloc, bool>((bloc) => bloc.state.tabletMode);

    switch (state.status) {
      case SearchStatus.initial:
      case SearchStatus.trending:
        return AnimatedCrossFade(
          duration: const Duration(milliseconds: 250),
          crossFadeState: state.trendingCommunities?.isNotEmpty == true && _currentSearchType == MetaSearchType.communities ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          firstChild: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(Icons.search_rounded, size: 80, color: theme.dividerColor),
              if (widget.communityToSearch == null) ...[
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Text(
                    switch (_currentSearchType) {
                      MetaSearchType.communities => l10n.searchCommunitiesFederatedWith(accountInstance),
                      MetaSearchType.users => l10n.searchUsersFederatedWith(accountInstance),
                      MetaSearchType.comments => l10n.searchCommentsFederatedWith(accountInstance),
                      MetaSearchType.posts => l10n.searchPostsFederatedWith(accountInstance),
                      MetaSearchType.instances => l10n.searchInstancesFederatedWith(accountInstance),
                      _ => '',
                    },
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(color: theme.dividerColor),
                  ),
                ),
              ],
              if (_controller.text.isEmpty) ...[
                const SizedBox(height: 30),
                ThunderActionChip(
                  label: l10n.viewAll,
                  onPressed: () => _doSearch(force: true),
                ),
              ],
            ],
          ),
          secondChild: state.trendingCommunities?.isNotEmpty == true
              ? SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (context.read<ProfileBloc>().state.favorites.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                          child: Text(
                            l10n.favorites,
                            style: theme.textTheme.titleLarge,
                          ),
                        ),
                        ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: context.read<ProfileBloc>().state.favorites.length,
                          itemBuilder: (BuildContext context, int index) {
                            final community = context.read<ProfileBloc>().state.favorites[index];
                            return CommunityListEntry(community: community, indicateFavorites: false);
                          },
                        ),
                        const SizedBox(height: 20),
                      ],
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                        child: Text(
                          l10n.trendingCommunities,
                          style: theme.textTheme.titleLarge,
                        ),
                      ),
                      ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: state.trendingCommunities!.length,
                        itemBuilder: (BuildContext context, int index) {
                          final community = state.trendingCommunities![index];
                          return CommunityListEntry(community: community);
                        },
                      ),
                      const SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ThunderActionChip(
                            label: l10n.viewAll,
                            onPressed: () => _doSearch(force: true),
                          ),
                          const SizedBox(width: 10),
                          ThunderActionChip(
                            trailingIcon: Icons.chevron_right_rounded,
                            label: l10n.exploreInstance,
                            onPressed: () => navigateToInstancePage(context, instanceHost: accountInstance, instanceId: null),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                )
              : Container(),
        );
      case SearchStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case SearchStatus.refreshing:
      case SearchStatus.success:
      case SearchStatus.done:
      case SearchStatus.performingCommentAction:
        if (searchIsEmpty(_currentSearchType, searchState: state)) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${switch (_currentSearchType) {
                    MetaSearchType.communities => l10n.noCommunitiesFound,
                    MetaSearchType.users => l10n.noUsersFound,
                    MetaSearchType.comments => l10n.noCommentsFound,
                    MetaSearchType.posts => l10n.noPostsFound,
                    _ => '',
                  }} ${l10n.trySearchingFor}',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(color: theme.dividerColor),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_currentSearchType != MetaSearchType.communities && widget.communityToSearch == null) ...[
                      ThunderActionChip(
                        label: l10n.communities,
                        onPressed: () => _setCurrentSearchType(MetaSearchType.communities),
                      ),
                      const SizedBox(width: 5),
                    ],
                    if (_currentSearchType != MetaSearchType.users && widget.communityToSearch == null)
                      ThunderActionChip(
                        label: l10n.users,
                        onPressed: () => _setCurrentSearchType(MetaSearchType.users),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_currentSearchType != MetaSearchType.posts) ...[
                      ThunderActionChip(
                        label: l10n.posts,
                        onPressed: () => _setCurrentSearchType(MetaSearchType.posts),
                      ),
                      const SizedBox(width: 5),
                    ],
                    if (_currentSearchType != MetaSearchType.comments)
                      ThunderActionChip(
                        label: l10n.comments,
                        onPressed: () => _setCurrentSearchType(MetaSearchType.comments),
                      ),
                  ],
                ),
              ],
            ),
          );
        }
        if (_currentSearchType == MetaSearchType.communities) {
          return FadingEdgeScrollView.fromScrollView(
            gradientFractionOnEnd: 0,
            child: ListView.builder(
              controller: _scrollController,
              itemCount: state.communities!.length + 1,
              itemBuilder: (BuildContext context, int index) {
                if (index == state.communities!.length) {
                  return state.status == SearchStatus.refreshing
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.only(bottom: 10),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : Container();
                } else {
                  final community = state.communities![index];
                  return CommunityListEntry(community: community);
                }
              },
            ),
          );
        } else if (_currentSearchType == MetaSearchType.users) {
          return FadingEdgeScrollView.fromScrollView(
            gradientFractionOnEnd: 0,
            child: ListView.builder(
              controller: _scrollController,
              itemCount: state.users!.length + 1,
              itemBuilder: (BuildContext context, int index) {
                if (index == state.users!.length) {
                  return state.status == SearchStatus.refreshing
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.only(bottom: 10),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : Container();
                } else {
                  final user = state.users![index];
                  return UserListEntry(user: user);
                }
              },
            ),
          );
        } else if (_currentSearchType == MetaSearchType.comments) {
          return FadingEdgeScrollView.fromScrollView(
            gradientFractionOnEnd: 0,
            child: ListView.builder(
              controller: _scrollController,
              itemCount: state.comments!.length + 1,
              itemBuilder: (BuildContext context, int index) {
                if (index == state.comments!.length) {
                  return state.status == SearchStatus.refreshing
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.only(bottom: 10),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : Container();
                } else {
                  ThunderComment comment = state.comments![index];
                  return Column(
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
                      CommentListEntry(comment: comment),
                    ],
                  );
                }
              },
            ),
          );
        } else if (_currentSearchType == MetaSearchType.posts) {
          return FadingEdgeScrollView.fromScrollView(
            gradientFractionOnEnd: 0,
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                FeedPostCardList(posts: state.posts ?? [], tabletMode: tabletMode, markPostReadOnScroll: false),
                if (state.status == SearchStatus.refreshing)
                  const SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 10),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ),
              ],
            ),
          );
        } else if (_currentSearchType == MetaSearchType.instances) {
          return FadingEdgeScrollView.fromScrollView(
            gradientFractionOnEnd: 0,
            child: ListView.builder(
              controller: _scrollController,
              itemCount: state.instances!.length,
              itemBuilder: (BuildContext context, int index) {
                final instanceInfo = state.instances![index];
                return AnimatedCrossFade(
                  duration: const Duration(milliseconds: 250),
                  firstChild: InstanceListEntry(instanceInfo: ThunderInstanceInfo(success: instanceInfo.success, domain: instanceInfo.domain, id: instanceInfo.id)),
                  secondChild: InstanceListEntry(instanceInfo: instanceInfo),
                  // If the instance metadata is not fully populated, show one widget, otherwise show the other.
                  // This should allow the metadata to essentially "fade in".
                  crossFadeState: instanceInfo.isMetadataPopulated() ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                );
              },
            ),
          );
        } else {
          return Container();
        }
      case SearchStatus.empty:
        return Center(child: Text(l10n.empty));
      case SearchStatus.failure:
        return ErrorMessage(
          message: state.errorMessage,
          actions: [
            (
              text: l10n.retry,
              action: _doSearch,
              loading: false,
            ),
          ],
        );
    }
  }

  void showSortBottomSheet(BuildContext context) {
    final l10n = GlobalContext.l10n;
    final feedBloc = context.read<FeedBloc>();

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (builderContext) => SortPicker(
        account: feedBloc.account,
        title: l10n.sortOptions,
        onSelect: (selected) async {
          setState(() {
            postSortType = selected.payload;
            postSortTypeIcon = selected.icon;
            postSortTypeLabel = selected.label;
          });

          UserPreferences.instance.preferences.setString("search_default_sort_type", selected.payload.name);

          _doSearch();
        },
        previouslySelected: postSortType,
      ),
    );
  }

  MetaSearchType _getSearchTypeToUse() {
    if (_currentSearchType == MetaSearchType.posts && _searchByUrl) {
      return MetaSearchType.url;
    }
    return _currentSearchType;
  }

  /// Performs a search with the current parameters.
  /// Does not search when the query field is empty, unless [force] is `true`.
  void _doSearch({bool force = false}) {
    final SearchBloc searchBloc = context.read<SearchBloc>();

    if (_controller.text.isNotEmpty || force || searchBloc.state.viewingAll) {
      searchBloc.add(StartSearchEvent(
        query: _controller.text,
        postSortType: postSortType,
        feedListType: _currentFeedType,
        searchType: _getSearchTypeToUse(),
        communityId: widget.communityToSearch?.id ?? _currentCommunityFilter,
        creatorId: _currentCreatorFilter,
        favoriteCommunities: context.read<ProfileBloc>().state.favorites,
        force: force || searchBloc.state.viewingAll,
      ));
    } else {
      context.read<SearchBloc>().add(ResetSearch());
    }
  }

  void _setCurrentSearchType(MetaSearchType newCurrentSearchType) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    setState(() {
      _currentSearchType = newCurrentSearchType;

      if (_currentSearchType == MetaSearchType.posts && Uri.tryParse(_controller.text)?.isAbsolute == true) {
        _searchByUrl = true;
        _searchUrlLabel = l10n.url;
      }
    });

    _doSearch();
  }
}
