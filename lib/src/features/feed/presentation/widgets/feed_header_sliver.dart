import 'package:flutter/material.dart';

import 'package:thunder/src/features/community/community.dart';
import 'package:thunder/src/features/feed/feed.dart';
import 'package:thunder/src/features/user/user.dart';

/// Sliver that displays the optional tagline, community header, or user header for a feed.
class FeedHeaderSliver extends StatelessWidget {
  const FeedHeaderSliver({
    super.key,
    required this.state,
    required this.selectedSubview,
    required this.onChangeFeedType,
  });

  /// Current feed state used to choose and populate the visible header.
  final FeedState state;

  /// Selected user-profile subview when the header belongs to a user feed.
  final FeedTypeSubview selectedSubview;

  /// Called when the user switches between posts and comments in a user header.
  final ValueChanged<FeedTypeSubview> onChangeFeedType;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (state.feedType == FeedType.general) TagLine(),
          if (state.community != null && state.feedType == FeedType.community)
            CommunityHeader(
              community: state.community!,
              instance: state.communityInstance,
              moderators: state.communityModerators,
              condensed: false,
            ),
          if (state.user != null && (state.feedType == FeedType.user || state.feedType == FeedType.account))
            UserHeader(
              user: state.user!,
              moderates: state.userModerates,
              feedType: selectedSubview,
              onChangeFeedType: onChangeFeedType,
              condensed: false,
            ),
        ],
      ),
    );
  }
}
