import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/core/enums/full_name.dart';
import 'package:thunder/feed/utils/utils.dart';
import 'package:thunder/feed/view/feed_page.dart';
import 'package:thunder/shared/avatars/community_avatar.dart';
import 'package:thunder/shared/full_name_widgets.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/utils/instance.dart';

/// A chip which displays the given community and instance information.
///
/// When tapped, navigates to the community's profile page.
class CommunityChip extends StatelessWidget {
  const CommunityChip({
    super.key,
    required this.communityId,
    required this.communityAvatar,
    required this.communityName,
    required this.communityTitle,
    required this.communityUrl,
  });

  /// The ID of the community.
  final int communityId;

  /// The avatar of the community.
  final CommunityAvatar communityAvatar;

  /// The name of the community.
  final String communityName;

  /// The title of the community.
  final String communityTitle;

  /// The URL of the community.
  final String communityUrl;

  @override
  Widget build(BuildContext context) {
    final state = context.read<ThunderBloc>().state;
    final showCommunityAvatar = state.postBodyShowCommunityAvatar;

    return InkWell(
      borderRadius: BorderRadius.circular(5),
      onTap: () => navigateToFeedPage(context, feedType: FeedType.community, communityId: communityId),
      child: Tooltip(
        excludeFromSemantics: true,
        message: generateCommunityFullName(
          context,
          communityName,
          communityTitle,
          fetchInstanceNameFromUrl(communityUrl) ?? '-',
          useDisplayName: false,
        ),
        preferBelow: false,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (showCommunityAvatar) Padding(padding: const EdgeInsets.only(top: 3, bottom: 3, right: 3), child: communityAvatar),
            CommunityFullNameWidget(
              context,
              communityName,
              communityTitle,
              fetchInstanceNameFromUrl(communityUrl),
              includeInstance: state.postBodyShowCommunityInstance,
              fontScale: state.metadataFontSizeScale,
              transformColor: (color) => color?.withValues(alpha: 0.75),
            ),
          ],
        ),
      ),
    );
  }
}
