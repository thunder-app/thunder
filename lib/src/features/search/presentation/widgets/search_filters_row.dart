import 'package:flutter/material.dart';

import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/src/foundation/config/global_context.dart';
import 'package:thunder/src/foundation/primitives/primitives.dart';
import 'package:thunder/src/features/settings/api.dart';
import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/features/search/search.dart';
import 'package:thunder/src/shared/input_dialogs.dart';
import 'package:thunder/src/features/instance/domain/utils/instance_link_utils.dart';
import 'package:thunder/packages/ui/ui.dart';

/// The horizontal filter chips row for search options.
class SearchFiltersRow extends StatefulWidget {
  /// Available search type options.
  final List<ThunderListPickerItem<MetaSearchType>> searchOptions;

  /// Limits the search to a specific community.
  final ThunderCommunity? community;

  /// The current account.
  final Account account;

  /// Called to trigger a search after filter changes.
  final VoidCallback onSearch;

  /// Called to show the sort picker.
  final VoidCallback onShowSortPicker;

  const SearchFiltersRow({
    super.key,
    required this.searchOptions,
    required this.community,
    required this.account,
    required this.onSearch,
    required this.onShowSortPicker,
  });

  @override
  State<SearchFiltersRow> createState() => _SearchFiltersRowState();
}

class _SearchFiltersRowState extends State<SearchFiltersRow> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = GlobalContext.l10n;

    return BlocBuilder<SearchBloc, SearchState>(
      buildWhen: (previous, current) => previous.searchType != current.searchType || previous.searchByUrl != current.searchByUrl || previous.viewingAll != current.viewingAll,
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.only(left: 15.0, top: 10.0, right: 15.0),
          child: FadingEdgeScrollView.fromSingleChildScrollView(
            gradientFractionOnStart: 0.1,
            gradientFractionOnEnd: 0.1,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              controller: _scrollController,
              child: Row(
                children: [
                  // "Viewing All" indicator chip
                  if (state.viewingAll) ...[
                    ThunderActionChip(
                      backgroundColor: theme.colorScheme.primaryContainer.withValues(alpha: 0.25),
                      trailingIcon: Icons.close_rounded,
                      label: l10n.viewingAll,
                      onPressed: () => context.read<SearchBloc>().add(const SearchReset()),
                    ),
                    const SizedBox(width: 10),
                  ],

                  // Search type chip
                  _SearchTypeChip(
                    searchOptions: widget.searchOptions,
                    onSearch: widget.onSearch,
                  ),
                  const SizedBox(width: 10),

                  // URL/Text toggle for posts
                  if (state.searchType == MetaSearchType.posts) ...[
                    _UrlTextChip(onSearch: widget.onSearch),
                    const SizedBox(width: 10),
                  ],

                  // Sort, feed type, and filter chips (except for instances)
                  if (state.searchType != MetaSearchType.instances) ...[
                    _SortChip(onShowSortPicker: widget.onShowSortPicker),
                    if (widget.community == null) ...[
                      const SizedBox(width: 10),
                      _FeedTypeChip(onSearch: widget.onSearch),
                      if (!(state.searchType == MetaSearchType.users || state.searchType == MetaSearchType.communities)) ...[
                        const SizedBox(width: 10),
                        _CommunityFilterChip(
                          account: widget.account,
                          onSearch: widget.onSearch,
                        ),
                      ]
                    ],
                    if (!(state.searchType == MetaSearchType.users || state.searchType == MetaSearchType.communities || widget.account.platform == ThreadiversePlatform.piefed)) ...[
                      const SizedBox(width: 10),
                      _CreatorFilterChip(
                        account: widget.account,
                        onSearch: widget.onSearch,
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Chip widget for selecting search type.
class _SearchTypeChip extends StatelessWidget {
  final List<ThunderListPickerItem<MetaSearchType>> searchOptions;
  final VoidCallback onSearch;

  const _SearchTypeChip({
    required this.searchOptions,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = GlobalContext.l10n;

    return BlocSelector<SearchBloc, SearchState, MetaSearchType>(
      selector: (state) => state.searchType,
      builder: (context, searchType) {
        return ThunderActionChip(
          trailingIcon: Icons.arrow_drop_down_rounded,
          label: searchType.name.capitalize,
          onPressed: () {
            showModalBottomSheet(
              context: context,
              showDragHandle: true,
              builder: (ctx) => ThunderBottomSheetListPicker(
                title: l10n.selectSearchType,
                items: searchOptions,
                onSelect: (value) async {
                  context.read<SearchBloc>().add(SearchFiltersUpdated(searchType: value.payload));
                  onSearch();
                },
                previouslySelected: searchType,
              ),
            );
          },
        );
      },
    );
  }
}

/// Chip widget for toggling between URL and text search for posts.
class _UrlTextChip extends StatelessWidget {
  final VoidCallback onSearch;

  const _UrlTextChip({required this.onSearch});

  @override
  Widget build(BuildContext context) {
    final l10n = GlobalContext.l10n;

    return BlocSelector<SearchBloc, SearchState, bool>(
      selector: (state) => state.searchByUrl,
      builder: (context, searchByUrl) {
        return ThunderActionChip(
          icon: Icons.link_rounded,
          trailingIcon: Icons.arrow_drop_down_rounded,
          label: searchByUrl ? l10n.url : l10n.text,
          onPressed: () {
            showModalBottomSheet(
              context: context,
              showDragHandle: true,
              builder: (ctx) => ThunderBottomSheetListPicker(
                title: l10n.searchPostSearchType,
                items: [
                  ThunderListPickerItem(label: l10n.searchByText, payload: 'text', icon: Icons.wysiwyg_rounded),
                  ThunderListPickerItem(label: l10n.searchByUrl, payload: 'url', icon: Icons.link_rounded),
                ],
                onSelect: (value) async {
                  context.read<SearchBloc>().add(SearchFiltersUpdated(searchByUrl: value.payload == 'url'));
                  onSearch();
                },
                previouslySelected: searchByUrl ? 'url' : 'text',
              ),
            );
          },
        );
      },
    );
  }
}

/// Chip widget for selecting sort type.
class _SortChip extends StatelessWidget {
  final VoidCallback onShowSortPicker;

  const _SortChip({required this.onShowSortPicker});

  @override
  Widget build(BuildContext context) {
    final l10n = GlobalContext.l10n;

    return BlocSelector<SearchBloc, SearchState, (IconData?, String?)>(
      selector: (state) => (state.sortTypeIcon, state.sortTypeLabel),
      builder: (context, data) {
        final (sortTypeIcon, sortTypeLabel) = data;

        return ThunderActionChip(
          icon: sortTypeIcon,
          trailingIcon: Icons.arrow_drop_down_rounded,
          label: sortTypeLabel ?? l10n.sortBy,
          onPressed: onShowSortPicker,
        );
      },
    );
  }
}

/// Chip widget for selecting feed type (All, Local, Subscribed).
class _FeedTypeChip extends StatelessWidget {
  final VoidCallback onSearch;

  const _FeedTypeChip({required this.onSearch});

  @override
  Widget build(BuildContext context) {
    final l10n = GlobalContext.l10n;

    return BlocSelector<SearchBloc, SearchState, FeedListType>(
      selector: (state) => state.feedListType,
      builder: (context, feedListType) {
        return ThunderActionChip(
          icon: _getFeedTypeIcon(feedListType),
          trailingIcon: Icons.arrow_drop_down_rounded,
          label: _getFeedTypeLabel(feedListType, l10n),
          onPressed: () {
            showModalBottomSheet(
              context: context,
              showDragHandle: true,
              builder: (ctx) => ThunderBottomSheetListPicker(
                title: l10n.selectFeedType,
                items: [
                  ThunderListPickerItem(label: l10n.subscribed, payload: FeedListType.subscribed, icon: Icons.view_list_rounded),
                  ThunderListPickerItem(label: l10n.local, payload: FeedListType.local, icon: Icons.home_rounded),
                  ThunderListPickerItem(label: l10n.all, payload: FeedListType.all, icon: Icons.grid_view_rounded),
                ],
                onSelect: (value) async {
                  context.read<SearchBloc>().add(SearchFiltersUpdated(feedListType: value.payload));
                  onSearch();
                },
                previouslySelected: feedListType,
              ),
            );
          },
        );
      },
    );
  }

  IconData _getFeedTypeIcon(FeedListType feedListType) {
    return switch (feedListType) {
      FeedListType.subscribed => Icons.view_list_rounded,
      FeedListType.local => Icons.home_rounded,
      FeedListType.all => Icons.grid_view_rounded,
      _ => Icons.grid_view_rounded,
    };
  }

  String _getFeedTypeLabel(FeedListType feedListType, dynamic l10n) {
    return switch (feedListType) {
      FeedListType.subscribed => l10n.subscribed,
      FeedListType.local => l10n.local,
      FeedListType.all => l10n.all,
      _ => l10n.feed,
    };
  }
}

/// Chip widget for filtering by community.
class _CommunityFilterChip extends StatelessWidget {
  final Account account;
  final VoidCallback onSearch;

  const _CommunityFilterChip({
    required this.account,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = GlobalContext.l10n;
    final theme = Theme.of(context);

    return BlocSelector<SearchBloc, SearchState, (int?, String?)>(
      selector: (state) => (state.communityFilter, state.communityFilterName),
      builder: (context, data) {
        final (communityFilter, communityFilterName) = data;

        return ThunderActionChip(
          backgroundColor: communityFilter == null ? null : theme.colorScheme.primaryContainer.withValues(alpha: 0.25),
          icon: Icons.people_rounded,
          trailingIcon: communityFilter != null ? Icons.close_rounded : Icons.arrow_drop_down_rounded,
          label: communityFilter == null ? l10n.community : l10n.filteringBy(communityFilterName ?? ''),
          onPressed: () {
            if (communityFilter != null) {
              context.read<SearchBloc>().add(const SearchFiltersUpdated(clearCommunityFilter: true));
              onSearch();
            } else {
              showCommunityInputDialog(
                context,
                title: l10n.community,
                account: account,
                onCommunitySelected: (ThunderCommunity community) {
                  context.read<SearchBloc>().add(
                        SearchFiltersUpdated(
                          communityFilter: community.id,
                          communityFilterName: generateCommunityFullName(
                            context,
                            community.name,
                            community.title,
                            fetchInstanceNameFromUrl(community.actorId),
                          ),
                        ),
                      );
                  onSearch();
                },
              );
            }
          },
        );
      },
    );
  }
}

/// Chip widget for filtering by creator.
class _CreatorFilterChip extends StatelessWidget {
  final Account account;
  final VoidCallback onSearch;

  const _CreatorFilterChip({
    required this.account,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = GlobalContext.l10n;
    final theme = Theme.of(context);

    return BlocSelector<SearchBloc, SearchState, (int?, String?)>(
      selector: (state) => (state.creatorFilter, state.creatorFilterName),
      builder: (context, data) {
        final (creatorFilter, creatorFilterName) = data;

        return ThunderActionChip(
          backgroundColor: creatorFilter == null ? null : theme.colorScheme.primaryContainer.withValues(alpha: 0.25),
          icon: Icons.person_rounded,
          trailingIcon: creatorFilter != null ? Icons.close_rounded : Icons.arrow_drop_down_rounded,
          label: creatorFilter == null ? l10n.creator : l10n.filteringBy(creatorFilterName ?? ''),
          onPressed: () {
            if (creatorFilter != null) {
              context.read<SearchBloc>().add(const SearchFiltersUpdated(clearCreatorFilter: true));
              onSearch();
            } else {
              showUserInputDialog(
                context,
                title: l10n.creator,
                account: account,
                onUserSelected: (user) {
                  context.read<SearchBloc>().add(
                        SearchFiltersUpdated(
                          creatorFilter: user.id,
                          creatorFilterName: generateUserFullName(
                            context,
                            user.name,
                            user.displayName,
                            fetchInstanceNameFromUrl(user.actorId),
                          ),
                        ),
                      );
                  onSearch();
                },
              );
            }
          },
        );
      },
    );
  }
}
