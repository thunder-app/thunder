import 'dart:async';

import 'package:flutter/material.dart';

import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/src/foundation/primitives/primitives.dart';
import 'package:thunder/src/foundation/persistence/persistence.dart';
import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/features/feed/feed.dart';
import 'package:thunder/src/features/search/search.dart';
import 'package:thunder/src/features/search/presentation/widgets/search_body.dart';
import 'package:thunder/src/features/search/presentation/widgets/search_filters_row.dart';
import 'package:thunder/src/features/search/presentation/widgets/search_page_app_bar.dart';
import 'package:thunder/src/shared/sort_picker.dart';
import 'package:thunder/src/foundation/config/config.dart';
import 'package:thunder/src/foundation/utils/utils.dart';
import 'package:thunder/src/foundation/config/global_context.dart';
import 'package:thunder/packages/ui/ui.dart' show ListPickerItem;

/// The main search page that handles search functionality.
class SearchPage extends StatefulWidget {
  /// Limits the search to a specific community.
  final ThunderCommunity? community;

  const SearchPage({super.key, this.community});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with AutomaticKeepAliveClientMixin<SearchPage> {
  @override
  bool get wantKeepAlive => true;

  /// Controller for the search text field.
  final controller = TextEditingController();

  /// Controller for the scroll view.
  final scrollController = ScrollController();

  /// Focus node for the search text field.
  final searchTextFieldFocus = FocusNode();

  /// Previous focus search ID. This is used to trigger the search text field focus.
  int previousFocusSearchId = 0;

  @override
  void initState() {
    super.initState();

    initializePreferences();
    scrollController.addListener(onScroll);

    // Initialize search type based on whether we're searching within a community
    if (widget.community != null) {
      context.read<SearchBloc>().add(const SearchFiltersUpdated(searchType: MetaSearchType.posts));
      WidgetsBinding.instance.addPostFrameCallback((_) => searchTextFieldFocus.requestFocus());
    }

    context.read<SearchBloc>().add(const TrendingCommunitiesRequested());

    BackButtonInterceptor.add(onBackButtonPress);
  }

  @override
  void dispose() {
    controller.dispose();
    scrollController.dispose();
    searchTextFieldFocus.dispose();

    BackButtonInterceptor.remove(onBackButtonPress);
    super.dispose();
  }

  void initializePreferences() {
    final prefs = UserPreferences.instance.preferences;

    final sortType = SearchSortType.values.byName(prefs.getString("search_default_sort_type") ?? DEFAULT_SEARCH_SORT_TYPE.name);
    final sortTypeItem = allSearchSortTypeItems.firstWhere((item) => item.payload == sortType);

    context.read<SearchBloc>().add(SearchFiltersUpdated(sortType: sortType, sortTypeIcon: sortTypeItem.icon, sortTypeLabel: sortTypeItem.label));
  }

  FutureOr<bool> onBackButtonPress(bool stopDefaultButtonEvent, RouteInfo info) async {
    if (searchTextFieldFocus.hasFocus) searchTextFieldFocus.unfocus();
    return false;
  }

  void onScroll() {
    if (scrollController.position.pixels >= scrollController.position.maxScrollExtent * 0.8) {
      final bloc = context.read<SearchBloc>();
      final favorites = context.read<ProfileBloc>().state.favorites;
      final query = controller.text;

      if (query.isEmpty && !bloc.state.viewingAll) return;

      if (bloc.state.status != SearchStatus.done) {
        bloc.add(SearchContinued(query: query, favoriteCommunities: favorites));
      }
    }
  }

  void onSearchFieldChanged(String value) {
    final bloc = context.read<SearchBloc>();

    if (value.isEmpty) {
      bloc.add(const SearchReset());
      return;
    }

    // Auto-detect URL mode for post searches
    if (bloc.state.searchType == MetaSearchType.posts && Uri.tryParse(value)?.isAbsolute == true) {
      bloc.add(const SearchFiltersUpdated(searchByUrl: true));
    }

    search();
  }

  void onClearSearch() {
    searchTextFieldFocus.requestFocus();
    controller.clear();

    context.read<SearchBloc>().add(const SearchReset());
  }

  void search({bool force = false}) {
    final bloc = context.read<SearchBloc>();

    // Update community filter from widget if searching within a community
    if (widget.community != null && bloc.state.communityFilter != widget.community?.id) {
      final community = widget.community!;
      bloc.add(SearchFiltersUpdated(communityFilter: community.id, communityFilterName: community.name));
    }

    if (controller.text.isNotEmpty || force || bloc.state.viewingAll) {
      final favorites = context.read<ProfileBloc>().state.favorites;
      final triggerSearch = force || bloc.state.viewingAll;

      bloc.add(SearchStarted(query: controller.text, force: triggerSearch, favoriteCommunities: favorites));
    } else {
      bloc.add(const SearchReset());
    }
  }

  void showSortPicker() {
    final l10n = GlobalContext.l10n;
    final feedBloc = context.read<FeedBloc>();
    final searchBloc = context.read<SearchBloc>();

    final prefs = UserPreferences.instance.preferences;

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (builderContext) => SortPicker<SearchSortType>(
        account: feedBloc.account,
        title: l10n.sortOptions,
        onSelect: (selected) async {
          searchBloc.add(SearchFiltersUpdated(sortType: selected.payload, sortTypeIcon: selected.icon, sortTypeLabel: selected.label));
          prefs.setString("search_default_sort_type", selected.payload.name);
          search();
        },
        previouslySelected: searchBloc.state.searchSortType ?? DEFAULT_SEARCH_SORT_TYPE,
      ),
    );
  }

  void setSearchType(MetaSearchType searchType) {
    final bloc = context.read<SearchBloc>();

    // Auto-detect URL mode for post searches
    if (searchType == MetaSearchType.posts && Uri.tryParse(controller.text)?.isAbsolute == true) {
      bloc.add(const SearchFiltersUpdated(searchByUrl: true));
    }

    bloc.add(SearchFiltersUpdated(searchType: searchType));
    search();
  }

  List<ListPickerItem<MetaSearchType>> getSearchOptions(Account account) {
    final l10n = GlobalContext.l10n;

    List<ListPickerItem<MetaSearchType>> options = [
      ListPickerItem(label: l10n.communities, payload: MetaSearchType.communities, icon: Icons.people_rounded),
      ListPickerItem(label: l10n.users, payload: MetaSearchType.users, icon: Icons.person_rounded),
      ListPickerItem(label: l10n.posts, payload: MetaSearchType.posts, icon: Icons.wysiwyg_rounded),
      ListPickerItem(label: l10n.comments, payload: MetaSearchType.comments, icon: Icons.chat_rounded),
      ListPickerItem(label: l10n.instance(2), payload: MetaSearchType.instances, icon: Icons.language),
    ];

    // Only keep post/comment for community search
    if (widget.community != null) {
      options = options.where((o) => o.payload == MetaSearchType.posts || o.payload == MetaSearchType.comments).toList();
    }

    return options;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final l10n = GlobalContext.l10n;
    final account = context.select<ProfileBloc, Account>((bloc) => bloc.state.account);

    return BlocListener<SearchBloc, SearchState>(
      listenWhen: (previous, current) => previous.focusSearchId != current.focusSearchId,
      listener: (context, state) {
        if (state.focusSearchId > previousFocusSearchId) {
          searchTextFieldFocus.requestFocus();
          previousFocusSearchId = state.focusSearchId;
        }
      },
      child: Scaffold(
        appBar: SearchPageAppBar(
          controller: controller,
          focusNode: searchTextFieldFocus,
          hintText: l10n.searchInstance(widget.community?.name ?? account.instance),
          onChanged: (value) => debounce(const Duration(milliseconds: 300), onSearchFieldChanged, [value]),
          onClear: onClearSearch,
        ),
        body: Stack(
          children: [
            SearchFiltersRow(
              searchOptions: getSearchOptions(account),
              community: widget.community,
              account: account,
              onSearch: search,
              onShowSortPicker: showSortPicker,
            ),
            SearchBody(
              scrollController: scrollController,
              communityToSearch: widget.community,
              accountInstance: account.instance,
              isQueryEmpty: controller.text.isEmpty,
              onSearch: search,
              onViewAll: () => search(force: true),
              onSetSearchType: setSearchType,
            ),
          ],
        ),
      ),
    );
  }
}
