import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/src/core/state/thunder_bloc.dart';
import 'package:thunder/src/core/domain/domain.dart';
import 'package:thunder/src/features/feed/feed.dart';

/// Sliver that displays either feed posts or user-profile comments.
class FeedContentSliver extends StatelessWidget {
  const FeedContentSliver({super.key, required this.posts, required this.comments, required this.feedType, required this.selectedSubview, required this.queuedForRemoval});

  final List<ThunderPost> posts;
  final List<ThunderComment> comments;
  final FeedType? feedType;

  /// Selected feed subview for user profiles.
  final FeedTypeSubview selectedSubview;

  /// Post ids currently animating out of the post list.
  final Set<int> queuedForRemoval;

  @override
  Widget build(BuildContext context) {
    final tabletMode = context.select<ThunderCubit, bool>((bloc) => bloc.state.tabletMode);
    final markPostReadOnScroll = context.select<FeedPreferencesCubit, bool>((cubit) => cubit.state.markPostReadOnScroll);

    if (selectedSubview == FeedTypeSubview.comment) {
      return FeedCommentCardList(comments: comments, tabletMode: tabletMode);
    }

    return FeedPostCardList(
      posts: posts,
      tabletMode: tabletMode,
      markPostReadOnScroll: markPostReadOnScroll,
      queuedForRemoval: queuedForRemoval,
      dimReadPosts: feedType == FeedType.account ? false : null,
    );
  }
}
