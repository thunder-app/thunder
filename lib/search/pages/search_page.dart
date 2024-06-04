import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:thunder/account/bloc/account_bloc.dart';
import 'package:thunder/account/models/account.dart';
import 'package:thunder/comment/widgets/comment_list_entry.dart';
import 'package:thunder/community/bloc/anonymous_subscriptions_bloc.dart';
import 'package:thunder/community/widgets/community_list_entry.dart';
import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/core/auth/helpers/fetch_account.dart';
import 'package:thunder/core/enums/full_name.dart';
import 'package:thunder/core/enums/meta_search_type.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/core/singletons/preferences.dart';
import 'package:thunder/feed/bloc/feed_bloc.dart';
import 'package:thunder/feed/view/feed_widget.dart';
import 'package:thunder/instance/utils/navigate_instance.dart';
import 'package:thunder/instance/widgets/instance_list_entry.dart';
import 'package:thunder/search/bloc/search_bloc.dart';
import 'package:thunder/search/widgets/search_action_chip.dart';
import 'package:thunder/search/utils/search_utils.dart';
import 'package:thunder/shared/error_message.dart';
import 'package:thunder/shared/input_dialogs.dart';
import 'package:thunder/shared/sort_picker.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/user/widgets/user_list_entry.dart';
import 'package:thunder/utils/bottom_sheet_list_picker.dart';
import 'package:thunder/utils/constants.dart';
import 'package:thunder/utils/debounce.dart';
import 'package:thunder/utils/global_context.dart';
import 'package:thunder/utils/instance.dart';

class SearchPage extends StatefulWidget {
  /// Allows the search page to limited to searching a specific community
  final CommunityView? communityToSearch;

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
  SharedPreferences? prefs;
  SortType sortType = SortType.active;
  IconData? sortTypeIcon;
  String? sortTypeLabel;
  final Set<Community> newAnonymousSubscriptions = {};
  final Set<int> removedSubs = {};
  int _previousFocusSearchId = 0;
  final searchTextFieldFocus = FocusNode();
  int? _previousUserId;
  int? _previousFavoritesCount;

  late MetaSearchType _currentSearchType;
  ListingType _currentFeedType = ListingType.all;
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
    fetchActiveProfileAccount().then((activeProfile) => _previousUserId = activeProfile?.userId);
    context.read<SearchBloc>().add(GetTrendingCommunitiesEvent());

    if (widget.isInitiallyFocused) {
      WidgetsBinding.instance.addPostFrameCallback((_) => searchTextFieldFocus.requestFocus());
    }

    super.initState();
  }

  Future<void> initPrefs() async {
    prefs = (await UserPreferences.instance).sharedPreferences;
    setState(() {
      sortType = SortType.values.byName(prefs!.getString("search_default_sort_type") ?? DEFAULT_SEARCH_SORT_TYPE.name);
      final sortTypeItem = allSortTypeItems.firstWhere((sortTypeItem) => sortTypeItem.payload == sortType);
      sortTypeIcon = sortTypeItem.icon;
      sortTypeLabel = sortTypeItem.label;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();

    super.dispose();
  }

  @override
  void deactivate() {
    _saveToDB();
    super.deactivate();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.8) {
      if (context.read<SearchBloc>().state.status != SearchStatus.done) {
        context.read<SearchBloc>().add(ContinueSearchEvent(
              query: _controller.text,
              sortType: sortType,
              listingType: _currentFeedType,
              searchType: _getSearchTypeToUse(),
              communityId: widget.communityToSearch?.community.id ?? _currentCommunityFilter,
              creatorId: _currentCreatorFilter,
              favoriteCommunities: context.read<AccountBloc>().state.favorites,
            ));
      }
    }
  }

  void resetTextField() {
    searchTextFieldFocus.requestFocus();
    _controller.clear(); // Clear the search field
  }

  _onChange(BuildContext context, String value) {
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
    final ThemeData theme = Theme.of(context);
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    super.build(context);

    context.read<AnonymousSubscriptionsBloc>().add(GetSubscribedCommunitiesEvent());

    final bool isUserLoggedIn = context.read<AuthBloc>().state.isLoggedIn;
    final String? accountInstance = context.read<AuthBloc>().state.account?.instance;
    final String currentAnonymousInstance = context.read<ThunderBloc>().state.currentAnonymousInstance;

    return BlocProvider(
      create: (context) => FeedBloc(lemmyClient: LemmyClient.instance),
      child: MultiBlocListener(
        listeners: [
          BlocListener<FeedBloc, FeedState>(listener: (context, state) => setState(() {})),
          BlocListener<AnonymousSubscriptionsBloc, AnonymousSubscriptionsState>(listener: (context, state) {}),
          BlocListener<SearchBloc, SearchState>(listener: (context, state) {
            context.read<FeedBloc>().add(PopulatePostsEvent(state.posts ?? []));
          }),
          BlocListener<AccountBloc, AccountState>(listener: (context, state) async {
            final Account? activeProfile = await fetchActiveProfileAccount();

            // When account changes, that means our instance most likely changed, so reset search.
            if (state.status == AccountStatus.success &&
                    ((activeProfile?.userId == null && _previousUserId != null) || state.personView?.person.id == activeProfile?.userId && _previousUserId != state.personView?.person.id) ||
                (state.favorites.length != _previousFavoritesCount && _controller.text.isEmpty)) {
              _controller.clear();
              if (context.mounted) context.read<SearchBloc>().add(ResetSearch());
              setState(() {});
              _previousUserId = activeProfile?.userId;
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
        child: BlocBuilder<SearchBloc, SearchState>(
          builder: (context, state) {
            if (state.focusSearchId > _previousFocusSearchId) {
              searchTextFieldFocus.requestFocus();
              _previousFocusSearchId = state.focusSearchId;
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
                          keyboardType: Platform.isIOS ? TextInputType.text : TextInputType.url,
                          focusNode: searchTextFieldFocus,
                          onChanged: (value) => debounce(const Duration(milliseconds: 300), _onChange, [context, value]),
                          controller: _controller,
                          onTap: () {
                            HapticFeedback.selectionClick();
                          },
                          decoration: InputDecoration(
                            fillColor: Theme.of(context).searchViewTheme.backgroundColor,
                            hintText: l10n.searchInstance(widget.communityToSearch?.community.name ?? (isUserLoggedIn ? accountInstance : currentAnonymousInstance) ?? ''),
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
                            if (state.viewingAll) ...[
                              SearchActionChip(
                                backgroundColor: theme.colorScheme.primaryContainer.withOpacity(0.25),
                                children: [
                                  Text(l10n.viewingAll),
                                  const SizedBox(width: 5),
                                  const Icon(Icons.close_rounded, size: 15),
                                ],
                                onPressed: () => context.read<SearchBloc>().add(ResetSearch()),
                              ),
                              const SizedBox(width: 10),
                            ],
                            SearchActionChip(
                              children: [
                                Text(_currentSearchType.name.capitalize),
                                const Icon(Icons.arrow_drop_down_rounded, size: 20),
                              ],
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  showDragHandle: true,
                                  builder: (ctx) => BottomSheetListPicker(
                                    title: l10n.selectSearchType,
                                    items: [
                                      if (widget.communityToSearch == null) ...[
                                        ListPickerItem(label: l10n.communities, payload: MetaSearchType.communities, icon: Icons.people_rounded),
                                        ListPickerItem(label: l10n.users, payload: MetaSearchType.users, icon: Icons.person_rounded),
                                      ],
                                      ListPickerItem(label: l10n.posts, payload: MetaSearchType.posts, icon: Icons.wysiwyg_rounded),
                                      ListPickerItem(label: l10n.comments, payload: MetaSearchType.comments, icon: Icons.chat_rounded),
                                      if (widget.communityToSearch == null) ListPickerItem(label: l10n.instance(2), payload: MetaSearchType.instances, icon: Icons.language),
                                    ],
                                    onSelect: (value) async => _setCurrentSearchType(value.payload),
                                    previouslySelected: _currentSearchType,
                                  ),
                                );
                              },
                            ),
                            const SizedBox(width: 10),
                            if (_currentSearchType == MetaSearchType.posts) ...[
                              SearchActionChip(
                                children: [
                                  const Icon(Icons.link_rounded, size: 15),
                                  const SizedBox(width: 5),
                                  Text(_searchUrlLabel),
                                  const Icon(Icons.arrow_drop_down_rounded, size: 20),
                                ],
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
                              SearchActionChip(
                                children: [
                                  Icon(sortTypeIcon, size: 15),
                                  const SizedBox(width: 5),
                                  Text(sortTypeLabel ?? l10n.sortBy),
                                  const Icon(Icons.arrow_drop_down_rounded, size: 20),
                                ],
                                onPressed: () => showSortBottomSheet(context),
                              ),
                              if (widget.communityToSearch == null) ...[
                                const SizedBox(width: 10),
                                SearchActionChip(
                                  children: [
                                    Icon(_feedTypeIcon, size: 15),
                                    const SizedBox(width: 5),
                                    Text(_feedTypeLabel ?? l10n.feed),
                                    const Icon(Icons.arrow_drop_down_rounded, size: 20),
                                  ],
                                  onPressed: () {
                                    showModalBottomSheet(
                                      context: context,
                                      showDragHandle: true,
                                      builder: (ctx) => BottomSheetListPicker(
                                        title: l10n.selectFeedType,
                                        items: [
                                          ListPickerItem(label: l10n.subscribed, payload: ListingType.subscribed, icon: Icons.view_list_rounded),
                                          ListPickerItem(label: l10n.local, payload: ListingType.local, icon: Icons.home_rounded),
                                          ListPickerItem(label: l10n.all, payload: ListingType.all, icon: Icons.grid_view_rounded)
                                        ],
                                        onSelect: (value) async {
                                          setState(() {
                                            if (value.payload == ListingType.subscribed) {
                                              _feedTypeLabel = l10n.subscribed;
                                              _feedTypeIcon = Icons.view_list_rounded;
                                            } else if (value.payload == ListingType.local) {
                                              _feedTypeLabel = l10n.local;
                                              _feedTypeIcon = Icons.home_rounded;
                                            } else if (value.payload == ListingType.all) {
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
                                SearchActionChip(
                                  backgroundColor: _currentCommunityFilter == null ? null : theme.colorScheme.primaryContainer.withOpacity(0.25),
                                  children: [
                                    const Icon(Icons.people_rounded, size: 15),
                                    const SizedBox(width: 5),
                                    Text(_currentCommunityFilter == null ? l10n.community : l10n.filteringBy(_currentCommunityFilterName ?? '')),
                                    if (_currentCommunityFilter != null) const SizedBox(width: 5),
                                    Icon(_currentCommunityFilter == null ? Icons.arrow_drop_down_rounded : Icons.close_rounded, size: _currentCommunityFilter == null ? 20 : 15),
                                  ],
                                  onPressed: () {
                                    if (_currentCommunityFilter != null) {
                                      setState(() {
                                        _currentCommunityFilter = null;
                                        _currentCommunityFilterName = null;
                                      });
                                      _doSearch();
                                    } else {
                                      showCommunityInputDialog(context, title: l10n.community, onCommunitySelected: (communityView) {
                                        setState(() {
                                          _currentCommunityFilter = communityView.community.id;
                                          _currentCommunityFilterName = generateCommunityFullName(context, communityView.community.name, fetchInstanceNameFromUrl(communityView.community.actorId));
                                        });
                                        _doSearch();
                                      });
                                    }
                                  },
                                ),
                              ],
                              const SizedBox(width: 10),
                              SearchActionChip(
                                backgroundColor: _currentCreatorFilter == null ? null : theme.colorScheme.primaryContainer.withOpacity(0.25),
                                children: [
                                  const Icon(Icons.person_rounded, size: 15),
                                  const SizedBox(width: 5),
                                  Text(_currentCreatorFilter == null ? l10n.creator : l10n.filteringBy(_currentCreatorFilterName ?? '')),
                                  if (_currentCreatorFilter != null) const SizedBox(width: 5),
                                  Icon(_currentCreatorFilter == null ? Icons.arrow_drop_down_rounded : Icons.close_rounded, size: _currentCreatorFilter == null ? 20 : 15),
                                ],
                                onPressed: () {
                                  if (_currentCreatorFilter != null) {
                                    setState(() {
                                      _currentCreatorFilter = null;
                                      _currentCreatorFilterName = null;
                                    });
                                    _doSearch();
                                  } else {
                                    showUserInputDialog(context, title: l10n.creator, onUserSelected: (personView) {
                                      setState(() {
                                        _currentCreatorFilter = personView.person.id;
                                        _currentCreatorFilterName = generateUserFullName(context, personView.person.name, fetchInstanceNameFromUrl(personView.person.actorId));
                                      });
                                      _doSearch();
                                    });
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
                    child: _getSearchBody(context, state, isUserLoggedIn, accountInstance, currentAnonymousInstance),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _getSearchBody(BuildContext context, SearchState state, bool isUserLoggedIn, String? accountInstance, String currentAnonymousInstance) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final ThunderBloc thunderBloc = context.watch<ThunderBloc>();
    final bool tabletMode = thunderBloc.state.tabletMode;

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
                      MetaSearchType.communities => l10n.searchCommunitiesFederatedWith((isUserLoggedIn ? accountInstance : currentAnonymousInstance) ?? ''),
                      MetaSearchType.users => l10n.searchUsersFederatedWith((isUserLoggedIn ? accountInstance : currentAnonymousInstance) ?? ''),
                      MetaSearchType.comments => l10n.searchCommentsFederatedWith((isUserLoggedIn ? accountInstance : currentAnonymousInstance) ?? ''),
                      MetaSearchType.posts => l10n.searchPostsFederatedWith((isUserLoggedIn ? accountInstance : currentAnonymousInstance) ?? ''),
                      MetaSearchType.instances => l10n.searchInstancesFederatedWith((isUserLoggedIn ? accountInstance : currentAnonymousInstance) ?? ''),
                      _ => '',
                    },
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(color: theme.dividerColor),
                  ),
                ),
              ],
              if (_controller.text.isEmpty) ...[
                const SizedBox(height: 30),
                SearchActionChip(
                  children: [Text(l10n.viewAll)],
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
                      if (context.read<AccountBloc>().state.favorites.isNotEmpty) ...[
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
                          itemCount: context.read<AccountBloc>().state.favorites.length,
                          itemBuilder: (BuildContext context, int index) {
                            CommunityView communityView = context.read<AccountBloc>().state.favorites[index];
                            final Set<int> currentSubscriptions = context.read<AnonymousSubscriptionsBloc>().state.ids;
                            return CommunityListEntry(
                              communityView: communityView,
                              isUserLoggedIn: isUserLoggedIn,
                              currentSubscriptions: currentSubscriptions,
                              indicateFavorites: false,
                              getFavoriteStatus: _getFavoriteStatus,
                              getCurrentSubscriptionStatus: _getCurrentSubscriptionStatus,
                              onSubscribeIconPressed: _onSubscribeIconPressed,
                            );
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
                          CommunityView communityView = state.trendingCommunities![index];
                          final Set<int> currentSubscriptions = context.read<AnonymousSubscriptionsBloc>().state.ids;
                          return CommunityListEntry(
                            communityView: communityView,
                            isUserLoggedIn: isUserLoggedIn,
                            currentSubscriptions: currentSubscriptions,
                            getFavoriteStatus: _getFavoriteStatus,
                            getCurrentSubscriptionStatus: _getCurrentSubscriptionStatus,
                            onSubscribeIconPressed: _onSubscribeIconPressed,
                          );
                        },
                      ),
                      const SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SearchActionChip(
                            children: [Text(l10n.viewAll)],
                            onPressed: () => _doSearch(force: true),
                          ),
                          const SizedBox(width: 10),
                          SearchActionChip(
                            children: [Text(l10n.exploreInstance), const Icon(Icons.chevron_right_rounded, size: 21)],
                            onPressed: () => navigateToInstancePage(context, instanceHost: (isUserLoggedIn ? accountInstance : currentAnonymousInstance) ?? '', instanceId: null),
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
                      SearchActionChip(
                        children: [Text(l10n.communities)],
                        onPressed: () => _setCurrentSearchType(MetaSearchType.communities),
                      ),
                      const SizedBox(width: 5),
                    ],
                    if (_currentSearchType != MetaSearchType.users && widget.communityToSearch == null)
                      SearchActionChip(
                        children: [Text(l10n.users)],
                        onPressed: () => _setCurrentSearchType(MetaSearchType.users),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_currentSearchType != MetaSearchType.posts) ...[
                      SearchActionChip(
                        children: [Text(l10n.posts)],
                        onPressed: () => _setCurrentSearchType(MetaSearchType.posts),
                      ),
                      const SizedBox(width: 5),
                    ],
                    if (_currentSearchType != MetaSearchType.comments)
                      SearchActionChip(
                        children: [Text(l10n.comments)],
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
                  CommunityView communityView = state.communities![index];
                  final Set<int> currentSubscriptions = context.read<AnonymousSubscriptionsBloc>().state.ids;
                  return CommunityListEntry(
                    communityView: communityView,
                    isUserLoggedIn: isUserLoggedIn,
                    currentSubscriptions: currentSubscriptions,
                    getFavoriteStatus: _getFavoriteStatus,
                    getCurrentSubscriptionStatus: _getCurrentSubscriptionStatus,
                    onSubscribeIconPressed: _onSubscribeIconPressed,
                  );
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
                  PersonView personView = state.users![index];
                  return UserListEntry(personView: personView);
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
                  CommentView commentView = state.comments![index];
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
                      CommentListEntry(
                        commentView: commentView,
                        onVoteAction: (int commentId, int voteType) => context.read<SearchBloc>().add(VoteCommentEvent(commentId: commentId, score: voteType)),
                        onSaveAction: (int commentId, bool save) => context.read<SearchBloc>().add(SaveCommentEvent(commentId: commentId, save: save)),
                      ),
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
                FeedPostList(postViewMedias: state.posts ?? [], tabletMode: tabletMode, markPostReadOnScroll: false),
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
                final GetInstanceInfoResponse instance = state.instances![index];
                return AnimatedCrossFade(
                  duration: const Duration(milliseconds: 250),
                  firstChild: InstanceListEntry(instance: GetInstanceInfoResponse(success: instance.success, domain: instance.domain, id: instance.id)),
                  secondChild: InstanceListEntry(instance: instance),
                  // If the instance metadata is not fully populated, show one widget, otherwise show the other.
                  // This should allow the metadata to essentially "fade in".
                  crossFadeState: instance.isMetadataPopulated() ? CrossFadeState.showSecond : CrossFadeState.showFirst,
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

  bool _getFavoriteStatus(BuildContext context, Community community) {
    final AccountState accountState = context.read<AccountBloc>().state;
    return accountState.favorites.any((communityView) => communityView.community.id == community.id);
  }

  void showSortBottomSheet(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (builderContext) => SortPicker(
        title: l10n.sortOptions,
        onSelect: (selected) async {
          setState(() {
            sortType = selected.payload;
            sortTypeIcon = selected.icon;
            sortTypeLabel = selected.label;
          });

          prefs!.setString("search_default_sort_type", selected.payload.name);

          _doSearch();
        },
        previouslySelected: sortType,
        minimumVersion: LemmyClient.instance.version,
      ),
    );
  }

  SubscribedType _getCurrentSubscriptionStatus(bool isUserLoggedIn, CommunityView communityView, Set<int>? currentSubscriptions) {
    if (isUserLoggedIn) {
      return communityView.subscribed;
    }
    bool isSubscribed =
        newAnonymousSubscriptions.contains(communityView.community) || (currentSubscriptions?.contains(communityView.community.id) == true && !removedSubs.contains(communityView.community.id));
    return isSubscribed ? SubscribedType.subscribed : SubscribedType.notSubscribed;
  }

  void _onSubscribeIconPressed(bool isUserLoggedIn, BuildContext context, CommunityView communityView) {
    if (isUserLoggedIn) {
      context.read<SearchBloc>().add(ChangeCommunitySubsciptionStatusEvent(
            communityId: communityView.community.id,
            follow: communityView.subscribed == SubscribedType.notSubscribed ? true : false,
            query: _controller.text,
          ));
      return;
    }

    Set<int> currentSubscriptions = context.read<AnonymousSubscriptionsBloc>().state.ids;
    setState(() {
      if (currentSubscriptions.contains(communityView.community.id) && !removedSubs.contains(communityView.community.id)) {
        removedSubs.add(communityView.community.id);
      } else if (newAnonymousSubscriptions.contains(communityView.community)) {
        newAnonymousSubscriptions.remove(communityView.community);
      } else if (removedSubs.contains(communityView.community.id)) {
        removedSubs.remove(communityView.community.id);
      } else {
        newAnonymousSubscriptions.add(communityView.community);
      }
    });
    return;
  }

  void _saveToDB() {
    if (newAnonymousSubscriptions.isNotEmpty) {
      context.read<AnonymousSubscriptionsBloc>().add(AddSubscriptionsEvent(communities: newAnonymousSubscriptions));
    }
    if (removedSubs.isNotEmpty) {
      context.read<AnonymousSubscriptionsBloc>().add(DeleteSubscriptionsEvent(ids: removedSubs));
    }
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
        sortType: sortType,
        listingType: _currentFeedType,
        searchType: _getSearchTypeToUse(),
        communityId: widget.communityToSearch?.community.id ?? _currentCommunityFilter,
        creatorId: _currentCreatorFilter,
        favoriteCommunities: context.read<AccountBloc>().state.favorites,
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
