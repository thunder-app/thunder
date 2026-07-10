import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/src/features/feed/feed.dart';
import 'package:thunder/src/core/domain/domain.dart';

/// Compact feed title and sort summary used by feed chrome.
class FeedHeader extends StatelessWidget {
  const FeedHeader({super.key});

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

        return Column(
          spacing: 4.0,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              getAppBarTitle(state),
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Row(
              spacing: 4.0,
              children: [
                Icon(getSortIcon(state), size: 17.0),
                Text(getSortName(state), style: theme.textTheme.titleMedium),
              ],
            ),
          ],
        );
      },
    );
  }
}
