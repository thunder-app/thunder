import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';

import 'package:lemmy_api_client/v3.dart';

import 'package:thunder/shared/icon_text.dart';
import 'package:thunder/utils/instance.dart';
import 'package:thunder/utils/numbers.dart';

class CommunityHeader extends StatelessWidget {
  final FullCommunityView? communityInfo;

  const CommunityHeader({super.key, this.communityInfo});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(top: 8.0, left: 24.0, right: 24.0, bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: communityInfo?.communityView.community.icon != null ? Colors.transparent : theme.colorScheme.onBackground,
                foregroundImage: communityInfo?.communityView.community.icon != null ? CachedNetworkImageProvider(communityInfo!.communityView.community.icon!) : null,
                maxRadius: 45,
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
                    Text(
                      fetchInstanceNameFromUrl(communityInfo?.communityView.community.actorId) ?? 'N/A',
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8.0),
                    Row(
                      children: [
                        IconText(
                          icon: const Icon(Icons.people_rounded),
                          text: formatNumberToK(communityInfo?.communityView.counts.subscribers ?? 0),
                        ),
                        const SizedBox(width: 8.0),
                        IconText(
                          icon: const Icon(Icons.sensors_rounded),
                          text: (communityInfo?.online != null) ? '${communityInfo?.online}' : '-',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
