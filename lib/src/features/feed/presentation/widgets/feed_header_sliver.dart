import 'package:flutter/material.dart';

import 'package:thunder/src/features/community/community.dart';
import 'package:thunder/src/core/domain/domain.dart';
import 'package:thunder/src/features/feed/feed.dart';
import 'package:thunder/src/features/user/user.dart';

/// Sliver that displays the optional tagline, community header, or user header for a feed.
class FeedHeaderSliver extends StatelessWidget {
  const FeedHeaderSliver({
    super.key,
    required this.feedType,
    required this.community,
    required this.communityInstance,
    required this.communityModerators,
    required this.user,
    required this.userModerates,
    required this.selectedSubview,
    required this.onChangeFeedType,
  });

  final FeedType? feedType;
  final ThunderCommunity? community;
  final ThunderSite? communityInstance;
  final List<ThunderUser> communityModerators;
  final ThunderUser? user;
  final List<ThunderCommunity> userModerates;

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
          if (feedType == FeedType.general) TagLine(),
          if (community != null && feedType == FeedType.community)
            CommunityHeader(
              community: community!,
              instance: communityInstance,
              moderators: communityModerators,
              condensed: false,
            ),
          if (user != null && (feedType == FeedType.user || feedType == FeedType.account))
            UserHeader(
              user: user!,
              moderates: userModerates,
              feedType: selectedSubview,
              onChangeFeedType: onChangeFeedType,
              condensed: false,
            ),
        ],
      ),
    );
  }
}
