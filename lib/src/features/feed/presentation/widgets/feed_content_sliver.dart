import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/src/app/state/thunder/thunder_bloc.dart';
import 'package:thunder/src/features/feed/feed.dart';

/// Sliver that displays either feed posts or user-profile comments.
class FeedContentSliver extends StatelessWidget {
  const FeedContentSliver({
    super.key,
    required this.state,
    required this.selectedSubview,
    required this.queuedForRemoval,
  });

  /// Current feed state containing the visible posts or comments.
  final FeedState state;

  /// Selected feed subview for user profiles.
  final FeedTypeSubview selectedSubview;

  /// Post ids currently animating out of the post list.
  final Set<int> queuedForRemoval;

  @override
  Widget build(BuildContext context) {
    final tabletMode = context.select<ThunderCubit, bool>((bloc) => bloc.state.tabletMode);
    final markPostReadOnScroll = context.select<FeedPreferencesCubit, bool>((cubit) => cubit.state.markPostReadOnScroll);

    if (selectedSubview == FeedTypeSubview.comment) {
      return FeedCommentCardList(
        comments: state.comments,
        tabletMode: tabletMode,
      );
    }

    return FeedPostCardList(
      posts: state.posts,
      tabletMode: tabletMode,
      markPostReadOnScroll: markPostReadOnScroll,
      queuedForRemoval: queuedForRemoval,
      dimReadPosts: state.feedType == FeedType.account ? false : null,
    );
  }
}
