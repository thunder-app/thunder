import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/src/features/feed/feed.dart';
import 'package:thunder/src/foundation/primitives/primitives.dart';

/// Title area for the feed app bar, including feed name and active sort.
class FeedAppBarTitle extends StatelessWidget {
  const FeedAppBarTitle({super.key, this.visible = true});

  /// Whether the title should be visible.
  final bool visible;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocSelector<FeedBloc, FeedState, ({FeedListType? feedListType, PostSortType? postSortType, FeedType? feedType, ThunderCommunity? community, ThunderUser? user})>(
      selector: (state) => (
        feedListType: state.feedListType,
        postSortType: state.postSortType,
        feedType: state.feedType,
        community: state.community,
        user: state.user,
      ),
      builder: (context, _) {
        final state = context.read<FeedBloc>().state;

        return AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: visible ? 1.0 : 0.0,
          child: ListTile(
            title: Text(
              getAppBarTitle(state),
              style: theme.textTheme.titleLarge,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Row(
              children: [
                Icon(getSortIcon(state), size: 13.0),
                const SizedBox(width: 4.0),
                Text(getSortName(state)),
              ],
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 0.0),
          ),
        );
      },
    );
  }
}
