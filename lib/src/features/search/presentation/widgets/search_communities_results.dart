import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/src/features/community/community.dart';
import 'package:thunder/src/features/search/search.dart';

/// Displays search results for communities.
class SearchCommunitiesResults extends StatelessWidget {
  /// The scroll controller for infinite scrolling.
  final ScrollController scrollController;

  const SearchCommunitiesResults({super.key, required this.scrollController});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<SearchBloc, SearchState, (List<ThunderCommunity>?, SearchStatus)>(
      selector: (state) => (state.communities, state.status),
      builder: (context, data) {
        final (communities, status) = data;
        if (communities == null) return const SizedBox.shrink();

        return ListView.builder(
          controller: scrollController,
          itemCount: communities.length + 1,
          itemBuilder: (context, index) {
            if (index == communities.length) {
              return status == SearchStatus.refreshing
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 10),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : const SizedBox.shrink();
            }
            return CommunityListEntry(community: communities[index]);
          },
        );
      },
    );
  }
}
