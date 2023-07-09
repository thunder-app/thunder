import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lemmy_api_client/v3.dart';

import 'package:thunder/account/bloc/account_bloc.dart';
import 'package:thunder/community/pages/community_page.dart';
import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/search/bloc/search_bloc.dart';
import 'package:thunder/shared/error_message.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
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

  @override
  void initState() {
    _scrollController.addListener(_onScroll);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();

    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.8) {
      context.read<SearchBloc>().add(ContinueSearchEvent(query: _controller.text));
    }
  }

  void resetTextField() {
    FocusScope.of(context).unfocus(); // Unfocus the search field
    _controller.clear(); // Clear the search field
  }

  _onChange(BuildContext context, String value) {
    context.read<SearchBloc>().add(StartSearchEvent(query: value));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchBloc, SearchState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            toolbarHeight: 90.0,
            scrolledUnderElevation: 0.0,
            title: SearchBar(
              controller: _controller,
              leading: const Padding(
                padding: EdgeInsets.only(left: 8.0),
                child: Icon(Icons.search_rounded),
              ),
              trailing: [
                if (_controller.text.isNotEmpty)
                  IconButton(
                    onPressed: () {
                      resetTextField();
                      context.read<SearchBloc>().add(ResetSearch());
                    },
                    icon: const Icon(
                      Icons.close,
                      semanticLabel: 'Clear Search',
                    ),
                  )
              ],
              hintText: 'Search for communities',
              onChanged: (value) => debounce(const Duration(milliseconds: 300), _onChange, [context, value]),
            ),
          ),
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

        // Obtains the base URL for the instance
        Uri uri = Uri.parse(lemmyClient.lemmyApiV3.host);
        String host = uri.host;
        String baseUrl = host.startsWith('www.') ? host.substring(4) : host;

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(Icons.search_rounded, size: 80, color: theme.dividerColor),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                'Search for communities federated with $baseUrl',
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
        if (state.results == null || state.results!.communities.isEmpty) {
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
          itemCount: state.results?.communities.length,
          itemBuilder: (BuildContext context, int index) {
            CommunityView communityView = state.results!.communities[index];

            return ListTile(
                leading: CircleAvatar(
                  backgroundColor: communityView.community.icon != null ? Colors.transparent : theme.colorScheme.primaryContainer,
                  foregroundImage: communityView.community.icon != null ? CachedNetworkImageProvider(communityView.community.icon!) : null,
                  maxRadius: 25,
                  child: Text( communityView.community.name[0].toUpperCase(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                    ),
                  ),
                ),
                title: Text(
                  communityView.community.title,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Row(children: [
                  Text('${communityView.community.name} · ${fetchInstanceNameFromUrl(communityView.community.actorId)} · ${communityView.counts.subscribers}'),
                  const SizedBox(width: 4),
                  const Icon(Icons.people_rounded, size: 16.0),
                ]),
                trailing: isUserLoggedIn
                    ? IconButton(
                        onPressed: communityView.subscribed == SubscribedType.pending
                            ? null
                            : () {
                                context.read<SearchBloc>().add(
                                      ChangeCommunitySubsciptionStatusEvent(
                                        communityId: communityView.community.id,
                                        follow: communityView.subscribed == SubscribedType.notSubscribed ? true : false,
                                      ),
                                    );
                                SnackBar snackBar = SnackBar(
                                  content: Text('${communityView.subscribed == SubscribedType.notSubscribed ? 'Added' : 'Removed'} community to subscriptions'),
                                  behavior: SnackBarBehavior.floating,
                                );
                                WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                                  ScaffoldMessenger.of(context).clearSnackBars();
                                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                });
                              },
                        icon: Icon(
                          switch (communityView.subscribed) {
                            SubscribedType.notSubscribed => Icons.add,
                            SubscribedType.pending => Icons.pending_rounded,
                            SubscribedType.subscribed => Icons.remove,
                          },
                        ),
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
                });
          },
        );
      case SearchStatus.empty:
        return const Center(child: Text('Empty'));
      case SearchStatus.networkFailure:
      case SearchStatus.failure:
        return ErrorMessage(
          message: state.errorMessage,
          action: () => {context.read<SearchBloc>().add(StartSearchEvent(query: _controller.value.text))},
          actionText: 'Retry',
        );
    }
  }
}
