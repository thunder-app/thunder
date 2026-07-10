import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/src/core/domain/domain.dart';
import 'package:thunder/src/features/feed/api.dart';
import 'package:thunder/src/shared/avatars/community_avatar.dart';
import 'package:thunder/src/shared/name/full_name_widgets.dart';
import 'package:thunder/src/features/settings/api.dart';
import 'package:thunder/src/features/instance/domain/utils/instance_link_utils.dart';
import 'package:thunder/src/core/navigation/navigation_utils.dart';
import 'package:thunder/src/shared/name/full_name_copy_utils.dart';

/// A chip which displays the given community and instance information.
///
/// When tapped, navigates to the community's profile page.
class CommunityChip extends StatelessWidget {
  /// The community to display information for.
  final ThunderCommunity community;

  const CommunityChip({super.key, required this.community});

  @override
  Widget build(BuildContext context) {
    final showCommunityAvatar = context.select<FeedPreferencesCubit, bool>((cubit) => cubit.state.postBodyShowCommunityAvatar);
    final showCommunityInstance = context.select<FeedPreferencesCubit, bool>((cubit) => cubit.state.postBodyShowCommunityInstance);
    final metadataFontSizeScale = context.select<ThemePreferencesCubit, FontScale>((cubit) => cubit.state.metadataFontSizeScale);

    final instanceName = fetchInstanceNameFromUrl(community.actorId);

    return InkWell(
      borderRadius: BorderRadius.circular(5.0),
      onTap: () => navigateToFeedPage(context, feedType: FeedType.community, communityId: community.id),
      child: Tooltip(
        preferBelow: false,
        excludeFromSemantics: true,
        triggerMode: TooltipTriggerMode.longPress,
        message: generateCommunityFullName(
          context,
          community.name,
          community.title,
          instanceName ?? '-',
          useDisplayName: false,
        ),
        onTriggered: () => copyActivityPubFullName(
          type: ActivityPubFullNameType.community,
          name: community.name,
          displayName: community.title,
          instance: instanceName,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (showCommunityAvatar)
              Padding(
                padding: const EdgeInsets.only(top: 3.0, bottom: 3.0, right: 3.0),
                child: CommunityAvatar(community: community, radius: 8.0, thumbnailSize: 20, format: 'png'),
              ),
            CommunityFullNameWidget(
              name: community.name,
              displayName: community.title,
              instance: instanceName,
              includeInstance: showCommunityInstance,
              fontScale: metadataFontSizeScale,
              transformColor: (color) => color?.withValues(alpha: 0.75),
            ),
          ],
        ),
      ),
    );
  }
}
