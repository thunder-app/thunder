import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';

import 'package:lemmy_api_client/v3.dart';
import 'package:thunder/shared/community_icon.dart';

import 'package:thunder/shared/icon_text.dart';
import 'package:thunder/utils/instance.dart';
import 'package:thunder/utils/numbers.dart';

class CommunityHeader extends StatelessWidget {
  final FullCommunityView? communityInfo;

  const CommunityHeader({
    super.key,
    this.communityInfo,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      children: [
        if (communityInfo?.communityView.community.banner == null)
          Positioned.fill(
            child: Container(color: theme.colorScheme.background),
          ),
        if (communityInfo?.communityView.community.banner != null)
          Positioned.fill(
            child: Row(
              children: [
                Expanded(flex: 1, child: Container()),
                Expanded(
                  flex: 3,
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: CachedNetworkImageProvider(communityInfo!.communityView.community.banner!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        if (communityInfo?.communityView.community.banner != null)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    theme.colorScheme.background,
                    theme.colorScheme.background,
                    theme.colorScheme.background.withOpacity(0.85),
                    theme.colorScheme.background.withOpacity(0.4),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 16.0, left: 24.0, right: 24.0, bottom: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      CommunityIcon(
                        community: communityInfo?.communityView.community,
                        radius: 45.0,
                      ),
                      const SizedBox(width: 20.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              communityInfo?.communityView.community.title ?? communityInfo?.communityView.community.name ?? 'N/A',
                              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            Text('${communityInfo?.communityView.community.name ?? 'N/A'}@${fetchInstanceNameFromUrl(communityInfo?.communityView.community.actorId) ?? 'N/A'}'),
                            const SizedBox(height: 8.0),
                            Row(
                              children: [
                                IconText(
                                  icon: const Icon(Icons.people_rounded),
                                  text: formatNumberToK(communityInfo?.communityView.counts.subscribers ?? 0),
                                ),
                                const SizedBox(width: 8.0),
                                IconText(
                                  icon: const Icon(Icons.calendar_month_rounded),
                                  text: formatNumberToK(communityInfo?.communityView.counts.usersActiveMonth ?? 0),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(9.0),
                        child: Icon(
                          Icons.info_outline_rounded,
                          size: 25,
                          shadows: <Shadow>[Shadow(color: theme.colorScheme.background, blurRadius: 10.0), Shadow(color: theme.colorScheme.background, blurRadius: 20.0)],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
