import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/src/foundation/primitives/primitives.dart';
import 'package:thunder/src/features/feed/api.dart';
import 'package:thunder/src/features/identity/presentation/widgets/avatars/community_avatar.dart';
import 'package:thunder/src/features/identity/presentation/widgets/full_name_widgets.dart';
import 'package:thunder/src/features/settings/api.dart';
import 'package:thunder/src/features/instance/domain/utils/instance_link_utils.dart';
import 'package:thunder/src/app/shell/navigation/navigation_utils.dart';

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
    this.includeInstance,
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

  /// Whether or not to include the instance name
  final bool? includeInstance;

  @override
  Widget build(BuildContext context) {
    final showCommunityAvatar = context.select<FeedPreferencesCubit, bool>((cubit) => cubit.state.postBodyShowCommunityAvatar);
    final postBodyShowCommunityInstance = context.select<FeedPreferencesCubit, bool>((cubit) => cubit.state.postBodyShowCommunityInstance);
    final metadataFontSizeScale = context.select<ThemePreferencesCubit, FontScale>((cubit) => cubit.state.metadataFontSizeScale);

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
              includeInstance: includeInstance ?? postBodyShowCommunityInstance,
              fontScale: metadataFontSizeScale,
              transformColor: (color) => color?.withValues(alpha: 0.75),
            ),
          ],
        ),
      ),
    );
  }
}
