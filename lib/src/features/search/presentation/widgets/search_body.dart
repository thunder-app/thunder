import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/l10n/generated/app_localizations.dart';
import 'package:thunder/src/foundation/config/global_context.dart';
import 'package:thunder/src/app/shell/navigation/navigation_utils.dart';
import 'package:thunder/src/foundation/primitives/primitives.dart';
import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/features/community/community.dart';
import 'package:thunder/src/features/search/search.dart';
import 'package:thunder/src/features/search/presentation/widgets/search_comments_results.dart';
import 'package:thunder/src/features/search/presentation/widgets/search_communities_results.dart';
import 'package:thunder/src/features/search/presentation/widgets/search_instances_results.dart';
import 'package:thunder/src/features/search/presentation/widgets/search_posts_results.dart';
import 'package:thunder/src/features/search/presentation/widgets/search_users_results.dart';
import 'package:thunder/src/shared/error_message.dart';
import 'package:thunder/packages/ui/ui.dart' show ThunderActionChip;

/// The main body content of the search page showing results based on search state.
class SearchBody extends StatelessWidget {
  final Account account;
  final List<ThunderCommunity> favorites;

  /// The scroll controller for infinite scrolling.
  final ScrollController scrollController;

  /// The community to search within (if any).
  final ThunderCommunity? communityToSearch;

  /// The account instance host for display.
  final String accountInstance;

  /// Whether the search query is empty.
  final bool isQueryEmpty;

  /// Called to trigger a search.
  final VoidCallback onSearch;

  /// Called to force a search (view all).
  final VoidCallback onViewAll;

  /// Called to change the search type.
  final ValueChanged<MetaSearchType> onSetSearchType;

  const SearchBody({
    super.key,
    required this.account,
    required this.favorites,
    required this.scrollController,
    required this.communityToSearch,
    required this.accountInstance,
    required this.isQueryEmpty,
    required this.onSearch,
    required this.onViewAll,
    required this.onSetSearchType,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 60),
      child: BlocBuilder<SearchBloc, SearchState>(
        buildWhen: (previous, current) => previous.status != current.status || previous.searchType != current.searchType || previous.trendingCommunities != current.trendingCommunities,
        builder: (context, state) => _buildBody(context, state),
      ),
    );
  }

  Widget _buildBody(BuildContext context, SearchState state) {
    final l10n = AppLocalizations.of(context)!;

    switch (state.status) {
      case SearchStatus.initial:
      case SearchStatus.trending:
        return _SearchInitialView(
          favorites: favorites,
          communityToSearch: communityToSearch,
          accountInstance: accountInstance,
          isQueryEmpty: isQueryEmpty,
          onViewAll: onViewAll,
          trendingCommunities: state.trendingCommunities,
          searchType: state.searchType,
        );
      case SearchStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case SearchStatus.refreshing:
      case SearchStatus.success:
      case SearchStatus.done:
      case SearchStatus.performingCommentAction:
        return _SearchResultsView(
          account: account,
          scrollController: scrollController,
          communityToSearch: communityToSearch,
          onSetSearchType: onSetSearchType,
          state: state,
        );
      case SearchStatus.empty:
        return Center(child: Text(l10n.empty));
      case SearchStatus.failure:
        return _SearchErrorView(
          errorMessage: state.message,
          onRetry: onSearch,
        );
    }
  }
}

/// Widget that displays the initial view when no search has been performed.
class _SearchInitialView extends StatelessWidget {
  final List<ThunderCommunity> favorites;
  final ThunderCommunity? communityToSearch;
  final String accountInstance;
  final bool isQueryEmpty;
  final VoidCallback onViewAll;
  final List<ThunderCommunity>? trendingCommunities;
  final MetaSearchType searchType;

  const _SearchInitialView({
    required this.favorites,
    required this.communityToSearch,
    required this.accountInstance,
    required this.isQueryEmpty,
    required this.onViewAll,
    required this.trendingCommunities,
    required this.searchType,
  });

  @override
  Widget build(BuildContext context) {
    final showTrending = trendingCommunities?.isNotEmpty == true && searchType == MetaSearchType.communities;

    return AnimatedCrossFade(
      duration: const Duration(milliseconds: 250),
      crossFadeState: showTrending ? CrossFadeState.showSecond : CrossFadeState.showFirst,
      firstChild: _SearchEmptyPrompt(
        communityToSearch: communityToSearch,
        accountInstance: accountInstance,
        isQueryEmpty: isQueryEmpty,
        onViewAll: onViewAll,
        searchType: searchType,
      ),
      secondChild: showTrending
          ? _SearchTrendingView(
              favorites: favorites,
              trendingCommunities: trendingCommunities!,
              accountInstance: accountInstance,
              onViewAll: onViewAll,
            )
          : const SizedBox.shrink(),
    );
  }
}

/// Widget that displays the empty search prompt.
class _SearchEmptyPrompt extends StatelessWidget {
  final ThunderCommunity? communityToSearch;
  final String accountInstance;
  final bool isQueryEmpty;
  final VoidCallback onViewAll;
  final MetaSearchType searchType;

  const _SearchEmptyPrompt({
    required this.communityToSearch,
    required this.accountInstance,
    required this.isQueryEmpty,
    required this.onViewAll,
    required this.searchType,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = GlobalContext.l10n;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(Icons.search_rounded, size: 80, color: theme.dividerColor),
        if (communityToSearch == null) ...[
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              switch (searchType) {
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
        if (isQueryEmpty) ...[
          const SizedBox(height: 30),
          ThunderActionChip(
            label: l10n.viewAll,
            onPressed: onViewAll,
          ),
        ],
      ],
    );
  }
}

/// Widget that displays the trending communities view.
class _SearchTrendingView extends StatelessWidget {
  final List<ThunderCommunity> favorites;
  final List<ThunderCommunity> trendingCommunities;
  final String accountInstance;
  final VoidCallback onViewAll;

  const _SearchTrendingView({
    required this.favorites,
    required this.trendingCommunities,
    required this.accountInstance,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = GlobalContext.l10n;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (favorites.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              child: Text(l10n.favorites, style: theme.textTheme.titleLarge),
            ),
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: favorites.length,
              itemBuilder: (context, index) => CommunityListEntry(community: favorites[index], indicateFavorites: false),
            ),
            const SizedBox(height: 20),
          ],
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            child: Text(l10n.trendingCommunities, style: theme.textTheme.titleLarge),
          ),
          ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: trendingCommunities.length,
            itemBuilder: (context, index) => CommunityListEntry(community: trendingCommunities[index]),
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ThunderActionChip(label: l10n.viewAll, onPressed: onViewAll),
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
    );
  }
}

/// Widget that displays search results based on the current search type.
class _SearchResultsView extends StatelessWidget {
  final Account account;
  final ScrollController scrollController;
  final ThunderCommunity? communityToSearch;
  final ValueChanged<MetaSearchType> onSetSearchType;
  final SearchState state;

  const _SearchResultsView({
    required this.account,
    required this.scrollController,
    required this.communityToSearch,
    required this.onSetSearchType,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    if (searchIsEmpty(state.searchType, searchState: state)) {
      return _SearchNoResultsView(
        searchType: state.searchType,
        communityToSearch: communityToSearch,
        onSetSearchType: onSetSearchType,
      );
    }

    return switch (state.searchType) {
      MetaSearchType.communities => SearchCommunitiesResults(scrollController: scrollController),
      MetaSearchType.users => SearchUsersResults(scrollController: scrollController),
      MetaSearchType.comments => SearchCommentsResults(scrollController: scrollController),
      MetaSearchType.posts => SearchPostsResults(scrollController: scrollController, account: account),
      MetaSearchType.instances => SearchInstancesResults(scrollController: scrollController),
      _ => const SizedBox.shrink(),
    };
  }
}

/// Widget that displays when no search results are found.
class _SearchNoResultsView extends StatelessWidget {
  final MetaSearchType searchType;
  final ThunderCommunity? communityToSearch;
  final ValueChanged<MetaSearchType> onSetSearchType;

  const _SearchNoResultsView({
    required this.searchType,
    required this.communityToSearch,
    required this.onSetSearchType,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = GlobalContext.l10n;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${switch (searchType) {
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
              if (searchType != MetaSearchType.communities && communityToSearch == null) ...[
                ThunderActionChip(label: l10n.communities, onPressed: () => onSetSearchType(MetaSearchType.communities)),
                const SizedBox(width: 5),
              ],
              if (searchType != MetaSearchType.users && communityToSearch == null) ThunderActionChip(label: l10n.users, onPressed: () => onSetSearchType(MetaSearchType.users)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (searchType != MetaSearchType.posts) ...[
                ThunderActionChip(label: l10n.posts, onPressed: () => onSetSearchType(MetaSearchType.posts)),
                const SizedBox(width: 5),
              ],
              if (searchType != MetaSearchType.comments) ThunderActionChip(label: l10n.comments, onPressed: () => onSetSearchType(MetaSearchType.comments)),
            ],
          ),
        ],
      ),
    );
  }
}

/// Widget that displays an error message with retry option.
class _SearchErrorView extends StatelessWidget {
  final String? errorMessage;
  final VoidCallback onRetry;

  const _SearchErrorView({
    required this.errorMessage,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = GlobalContext.l10n;

    return ErrorMessage(
      message: errorMessage,
      actions: [
        (text: l10n.retry, action: onRetry, loading: false),
      ],
    );
  }
}
