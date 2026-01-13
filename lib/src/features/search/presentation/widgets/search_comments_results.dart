import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/src/features/comment/comment.dart';
import 'package:thunder/src/features/search/search.dart';

/// Displays search results for comments.
class SearchCommentsResults extends StatelessWidget {
  /// The scroll controller for infinite scrolling.
  final ScrollController scrollController;

  const SearchCommentsResults({super.key, required this.scrollController});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocSelector<SearchBloc, SearchState, (List<ThunderComment>?, SearchStatus)>(
      selector: (state) => (state.comments, state.status),
      builder: (context, data) {
        final (comments, status) = data;
        if (comments == null) return const SizedBox.shrink();

        return ListView.builder(
          controller: scrollController,
          itemCount: comments.length + 1,
          itemBuilder: (context, index) {
            if (index == comments.length) {
              return status == SearchStatus.refreshing
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 10),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : const SizedBox.shrink();
            }
            return Column(
              children: [
                Divider(
                  height: 1.0,
                  thickness: 1.0,
                  color: ElevationOverlay.applySurfaceTint(
                    theme.colorScheme.surface,
                    theme.colorScheme.surfaceTint,
                    10,
                  ),
                ),
                CommentListEntry(comment: comments[index]),
              ],
            );
          },
        );
      },
    );
  }
}
