import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:thunder/account/bloc/account_bloc.dart';
import 'package:thunder/community/pages/community_page.dart';
import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/core/singletons/preferences.dart';
import 'package:thunder/search/bloc/search_bloc.dart';
import 'package:thunder/shared/error_message.dart';
import 'package:thunder/shared/sort_picker.dart';
import 'package:thunder/shared/community_icon.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/utils/constants.dart';
import 'package:thunder/utils/debounce.dart';
import 'package:thunder/utils/instance.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();
  final _scrollController = ScrollController(initialScrollOffset: 0);
  SharedPreferences? prefs;
  SortType sortType = SortType.active;
  IconData? sortTypeIcon;
  String? sortTypeLabel;

  @override
  void initState() {
    _scrollController.addListener(_onScroll);
    initPrefs();
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

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.8) {
      if (context.read<SearchBloc>().state.status != SearchStatus.done) {
        context.read<SearchBloc>().add(ContinueSearchEvent(query: _controller.text, sortType: sortType));
      }
    }
  }

  void resetTextField() {
    FocusScope.of(context).unfocus(); // Unfocus the search field
    _controller.clear(); // Clear the search field
  }

  _onChange(BuildContext context, String value) {
    context.read<SearchBloc>().add(StartSearchEvent(query: value, sortType: sortType));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchBloc, SearchState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
              toolbarHeight: 90.0,
              scrolledUnderElevation: 0.0,
              title: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(50),
                elevation: 8,
                child: Stack(
                  children: [
                    TextField(
                      onChanged: (value) => debounce(const Duration(milliseconds: 300), _onChange, [context, value]),
                      controller: _controller,
                      onTap: () {
                        HapticFeedback.selectionClick();
                      },
                      decoration: InputDecoration(
                        fillColor: Theme.of(context).searchViewTheme.backgroundColor,
                        hintText: 'Search for communities',
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
                                width: 90,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.close,
                                        semanticLabel: 'Clear Search',
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
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 7, right: 5),
                          child: IconButton(
                            icon: Icon(sortTypeIcon, semanticLabel: 'Sort By'),
                            tooltip: sortTypeLabel,
                            onPressed: () {
                              HapticFeedback.mediumImpact();
                              showSortBottomSheet(context, state);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )),
          body: _getSearchBody(context, state),
        );
      },
    );
  }

  Widget _getSearchBody(BuildContext context, SearchState state) {
    final theme = Theme.of(context);
    final bool isUserLoggedIn = context.read<AuthBloc>().state.isLoggedIn;

    switch (state.status) {
      case SearchStatus.initial:
        LemmyClient lemmyClient = LemmyClient.instance;

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(Icons.search_rounded, size: 80, color: theme.dividerColor),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                'Search for communities federated with ${lemmyClient.lemmyApiV3.host}',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(color: theme.dividerColor),
              ),
            )
          ],
        );
      case SearchStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case SearchStatus.refreshing:
      case SearchStatus.success:
      case SearchStatus.done:
        if (state.communities?.isEmpty ?? true) {
          return Center(
            child: Text(
              'No communities found',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(color: theme.dividerColor),
            ),
          );
        }
        return ListView.builder(
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
              return Tooltip(
                  excludeFromSemantics: true,
                  message: '${communityView.community.title}\n${communityView.community.name} · ${fetchInstanceNameFromUrl(communityView.community.actorId)}',
                  preferBelow: false,
                  child: ListTile(
                      leading: CommunityIcon(community: communityView.community, radius: 25),
                      title: Text(
                        communityView.community.title,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Row(children: [
                        Flexible(
                          child: Text(
                            '${communityView.community.name} · ${fetchInstanceNameFromUrl(communityView.community.actorId)}',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          ' · ${communityView.counts.subscribers}',
                          semanticsLabel: '${communityView.counts.subscribers} subscribers',
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.people_rounded, size: 16.0),
                      ]),
                      trailing: isUserLoggedIn
                          ? IconButton(
                              onPressed: () {
                                context.read<SearchBloc>().add(
                                      ChangeCommunitySubsciptionStatusEvent(
                                        communityId: communityView.community.id,
                                        follow: communityView.subscribed == SubscribedType.notSubscribed ? true : false,
                                      ),
                                    );
                                SnackBar snackBar = SnackBar(
                                  content: Text(
                                      '${communityView.subscribed == SubscribedType.notSubscribed ? 'Added' : 'Removed'} community ${communityView.subscribed == SubscribedType.notSubscribed ? 'to' : 'from'} subscriptions'),
                                  behavior: SnackBarBehavior.floating,
                                );
                                WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                                  ScaffoldMessenger.of(context).clearSnackBars();
                                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                });
                                context.read<AccountBloc>().add(GetAccountInformation());
                              },
                              icon: Icon(
                                switch (communityView.subscribed) {
                                  SubscribedType.notSubscribed => Icons.add_circle_outline_rounded,
                                  SubscribedType.pending => Icons.pending_outlined,
                                  SubscribedType.subscribed => Icons.remove_circle_outline_rounded,
                                },
                              ),
                              tooltip: switch (communityView.subscribed) {
                                SubscribedType.notSubscribed => 'Subscribe',
                                SubscribedType.pending => 'Unsubscribe (subscription pending)',
                                SubscribedType.subscribed => 'Unsubscribe',
                              },
                              visualDensity: VisualDensity.compact,
                            )
                          : null,
                      onTap: () {
                        AccountBloc accountBloc = context.read<AccountBloc>();
                        AuthBloc authBloc = context.read<AuthBloc>();
                        ThunderBloc thunderBloc = context.read<ThunderBloc>();

                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => MultiBlocProvider(
                              providers: [
                                BlocProvider.value(value: accountBloc),
                                BlocProvider.value(value: authBloc),
                                BlocProvider.value(value: thunderBloc),
                              ],
                              child: CommunityPage(communityId: communityView.community.id),
                            ),
                          ),
                        );
                      }));
            }
          },
        );
      case SearchStatus.empty:
        return const Center(child: Text('Empty'));
      case SearchStatus.failure:
        return ErrorMessage(
          message: state.errorMessage,
          action: () => {context.read<SearchBloc>().add(StartSearchEvent(query: _controller.value.text, sortType: sortType))},
          actionText: 'Retry',
        );
    }
  }

  void showSortBottomSheet(BuildContext context, SearchState state) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (builderContext) => SortPicker(
        title: 'Sort Options',
        onSelect: (selected) {
          sortType = selected.payload;
          sortTypeIcon = selected.icon;
          sortTypeLabel = selected.label;

          prefs!.setString("search_default_sort_type", selected.payload.name);

          context.read<SearchBloc>().add(
                StartSearchEvent(query: _controller.text, sortType: sortType),
              );
        },
      ),
    );
  }
}
