import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/core/enums/full_name.dart';
import 'package:thunder/feed/utils/utils.dart';
import 'package:thunder/feed/view/feed_page.dart';
import 'package:thunder/shared/full_name_widgets.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/utils/instance.dart';

/// A chip which displays the given community and instance information.
///
/// When tapped, navigates to the community's profile page.
class CommunityChip extends StatelessWidget {
  const CommunityChip({
    super.key,
    this.communityId,
    this.communityName,
    this.communityUrl,
  });

  /// The ID of the community.
  final int? communityId;

  /// The name of the community.
  final String? communityName;

  /// The URL of the community.
  final String? communityUrl;

  @override
  Widget build(BuildContext context) {
    final state = context.read<ThunderBloc>().state;

    return InkWell(
      borderRadius: BorderRadius.circular(5),
      onTap: () => navigateToFeedPage(context, feedType: FeedType.community, communityId: communityId),
      child: Tooltip(
        excludeFromSemantics: true,
        message: generateCommunityFullName(context, communityName, fetchInstanceNameFromUrl(communityUrl) ?? '-'),
        preferBelow: false,
        child: CommunityFullNameWidget(
          context,
          communityName,
          fetchInstanceNameFromUrl(communityUrl),
          includeInstance: state.postBodyShowCommunityInstance,
          fontScale: state.metadataFontSizeScale,
          transformColor: (color) => color?.withOpacity(0.75),
        ),
      ),
    );
  }
}
