import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lemmy/lemmy.dart';
import 'package:thunder/account/models/account.dart';
import 'package:thunder/community/pages/community_page.dart';
import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/search/bloc/search_bloc.dart';
import 'package:thunder/utils/debounce.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
    return BlocProvider(
      create: (context) => SearchBloc(),
      child: BlocBuilder<SearchBloc, SearchState>(
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
                      icon: const Icon(Icons.close),
                    )
                ],
                hintText: 'Search for communities',
                onChanged: (value) => debounce(const Duration(milliseconds: 300), _onChange, [context, value]),
              ),
            ),
            body: _getSearchBody(context, state),
          );
        },
      ),
    );
  }

  Widget _getSearchBody(BuildContext context, SearchState state) {
    final theme = Theme.of(context);
    final bool isUserLoggedIn = context.read<AuthBloc>().state.isLoggedIn;

    switch (state.status) {
      case SearchStatus.initial:
        LemmyClient lemmyClient = LemmyClient.instance;
        Lemmy lemmy = lemmyClient.lemmy;

        // Obtains the base URL for the instance
        Uri uri = Uri.parse(lemmy.baseUrl);
        String host = uri.host;
        String baseUrl = host.startsWith('www.') ? host.substring(4) : host;

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(Icons.search_rounded, size: 80, color: theme.dividerColor),
            const SizedBox(height: 30),
            Text(
              'Search for communities on $baseUrl',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(color: theme.dividerColor),
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
          itemCount: state.results?.communities.length,
          itemBuilder: (BuildContext context, int index) {
            CommunityView communityView = state.results!.communities[index];

            return ListTile(
              title: Text(communityView.community.title),
              subtitle: Text('${communityView.community.name} · ${communityView.counts.subscribers} subscribers'),
              trailing: isUserLoggedIn
                  ? IconButton(
                      onPressed: communityView.subscribed == SubscribedType.Pending
                          ? null
                          : () {
                              context.read<SearchBloc>().add(
                                    ChangeCommunitySubsciptionStatusEvent(
                                      communityId: communityView.community.id,
                                      follow: communityView.subscribed == SubscribedType.NotSubscribed ? true : false,
                                    ),
                                  );
                              SnackBar snackBar = SnackBar(
                                content: Text('${communityView.subscribed == SubscribedType.NotSubscribed ? 'Added' : 'Removed'} community to subscriptions'),
                                behavior: SnackBarBehavior.floating,
                              );
                              WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                                ScaffoldMessenger.of(context).clearSnackBars();
                                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                              });
                            },
                      icon: Icon(
                        switch (communityView.subscribed) {
                          SubscribedType.NotSubscribed => Icons.add,
                          SubscribedType.Pending => Icons.pending_rounded,
                          SubscribedType.Subscribed => Icons.remove,
                        },
                      ),
                      visualDensity: VisualDensity.compact,
                    )
                  : null,
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => BlocProvider(
                  create: (context) => AuthBloc(),
                  child: CommunityPage(communityId: communityView.community.id),
                ),
              )),
            );
          },
        );
      case SearchStatus.empty:
        return const Center(child: Text('Empty'));
      case SearchStatus.networkFailure:
      case SearchStatus.failure:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.warning_rounded,
                  size: 100,
                  color: Colors.red.shade300,
                ),
                const SizedBox(height: 32.0),
                Text('Oops, something went wrong!', style: theme.textTheme.titleLarge),
                const SizedBox(height: 8.0),
                Text(
                  state.errorMessage ?? 'No error message available',
                  style: theme.textTheme.labelLarge?.copyWith(color: theme.dividerColor),
                ),
                const SizedBox(height: 32.0),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                  onPressed: () => {context.read<SearchBloc>().add(StartSearchEvent(query: _controller.value.text))},
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        );
    }
  }
}

// import 'package:auto_size_text/auto_size_text.dart';
// import 'package:flutter/material.dart';

// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:lemmy/lemmy.dart';
// import 'package:thunder/core/singletons/lemmy_client.dart';

// import 'package:thunder/search/bloc/search_bloc.dart';
// import 'package:thunder/utils/debounce.dart';

// class SearchPage extends StatefulWidget {
//   const SearchPage({super.key});

//   @override
//   State<SearchPage> createState() => _SearchPageState();
// }

// class _SearchPageState extends State<SearchPage> {
//   late TextEditingController _controller;
//   final ScrollController _scrollController = ScrollController();

//   IconData searchTypeIcon = Icons.dashboard_rounded;

//   @override
//   void initState() {
//     _controller = TextEditingController();
//     super.initState();
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     _scrollController.dispose();
//     super.dispose();
//   }

//   void resetTextField() {
//     FocusScope.of(context).unfocus(); // Unfocus the search field
//     _controller.clear(); // Clear the search field
//   }

//   void _onChange(BuildContext context, String value) {
//     context.read<SearchBloc>().add(StartSearchEvent(query: value));
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     return BlocProvider(
//       create: (context) => SearchBloc(),
//       child: BlocBuilder<SearchBloc, SearchState>(
//         builder: (context, state) {
//           return Scaffold(
//             appBar: AppBar(
//               toolbarHeight: 90.0,
//               scrolledUnderElevation: 0.0,
//               title: SearchBar(
//                   controller: _controller,
//                   leading: const Padding(
//                     padding: EdgeInsets.only(left: 8.0),
//                     child: Icon(Icons.search_rounded),
//                   ),
//                   trailing: [
//                     if (_controller.text.isNotEmpty)
//                       IconButton(
//                         onPressed: () {
//                           resetTextField();
//                         },
//                         icon: const Icon(Icons.close),
//                       )
//                   ],
//                   hintText: 'Search for communities',
//                   onChanged: (value) => _onChange(context, value)

//                   // onChanged: (value) => debounce(const Duration(milliseconds: 300), _onChange, [context, value]),
//                   ),
//             ),
//             body: LayoutBuilder(
//               builder: (context, constraints) {
//                 switch (state.status) {
//                   case SearchStatus.initial:
//                     return Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       crossAxisAlignment: CrossAxisAlignment.stretch,
//                       children: [
//                         Icon(Icons.search_rounded, size: 80, color: theme.dividerColor),
//                         const SizedBox(height: 10),
//                         Text(
//                           'Search for communities',
//                           textAlign: TextAlign.center,
//                           style: theme.textTheme.titleMedium?.copyWith(color: theme.dividerColor),
//                         )
//                       ],
//                     );
//                   case SearchStatus.loading:
//                   case SearchStatus.refreshing:
//                   case SearchStatus.success:
//                     return Scrollbar(
//                       thumbVisibility: true,
//                       controller: _scrollController,
//                       child: SingleChildScrollView(
//                         controller: _scrollController,
//                         child: ListView.builder(
//                           shrinkWrap: true,
//                           physics: const NeverScrollableScrollPhysics(),
//                           itemBuilder: (context, index) {
//                             return InkWell(
//                               onTap: () => {},
//                               child: Container(
//                                 decoration: BoxDecoration(
//                                   border: Border(bottom: BorderSide(width: 1.0, color: theme.dividerColor.withOpacity(0.2))),
//                                 ),
//                                 padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   mainAxisAlignment: MainAxisAlignment.start,
//                                   children: [
//                                     Row(
//                                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                       children: [
//                                         Text(
//                                           state.results?.communities[index].community.name ?? '',
//                                           style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
//                                         ),
//                                         if (state.results?.communities[index].community.nsfw == true) const Badge(label: Text('NSFW'))
//                                       ],
//                                     ),
//                                     const SizedBox(height: 8.0),
//                                     AutoSizeText(
//                                       state.results?.communities[index].community.description ?? 'No description available',
//                                       maxLines: 1,
//                                       minFontSize: theme.textTheme.bodySmall!.fontSize!,
//                                       maxFontSize: theme.textTheme.bodySmall!.fontSize!,
//                                       style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w300),
//                                       overflow: TextOverflow.ellipsis,
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             );
//                           },
//                           itemCount: state.results?.communities.length,
//                         ),
//                       ),
//                     );
//                   case SearchStatus.empty:
//                     return Text('Empty');
//                   case SearchStatus.failure:
//                     return Text('Failed');
//                   case SearchStatus.networkFailure:
//                     // TODO: Handle this case.
//                     return Text('Failed');
//                 }
//               },
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
