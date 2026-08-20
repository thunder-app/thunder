import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/src/features/search/search.dart';
import 'package:thunder/src/features/user/user.dart';

/// Displays search results for users.
class SearchUsersResults extends StatelessWidget {
  /// The scroll controller for infinite scrolling.
  final ScrollController scrollController;

  const SearchUsersResults({super.key, required this.scrollController});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<SearchBloc, SearchState, (List<ThunderUser>?, SearchStatus)>(
      selector: (state) => (state.users, state.status),
      builder: (context, data) {
        final (users, status) = data;
        if (users == null) return const SizedBox.shrink();

        return ListView.builder(
          controller: scrollController,
          itemCount: users.length + 1,
          itemBuilder: (context, index) {
            if (index == users.length) {
              return status == SearchStatus.refreshing
                  ? const Center(
                      child: Padding(padding: EdgeInsets.only(bottom: 10.0), child: CircularProgressIndicator()),
                    )
                  : const SizedBox.shrink();
            }

            return UserListEntry(user: users[index]);
          },
        );
      },
    );
  }
}
