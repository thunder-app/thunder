import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import 'package:lemmy_api_client/v3.dart';

import 'package:thunder/shared/icon_text.dart';
import 'package:thunder/utils/instance.dart';
import 'package:thunder/utils/numbers.dart';

class CommunityHeader extends StatelessWidget {
  final FullCommunityView? communityInfo;
  final bool? isSidebarOpen;

  const CommunityHeader({
    super.key,
    this.communityInfo,
    this.isSidebarOpen,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Container(
          color: theme.colorScheme.background,
          child: Container(
            decoration: communityInfo?.communityView.community.banner != null
                ? BoxDecoration(
                    image: DecorationImage(image: CachedNetworkImageProvider(communityInfo!.communityView.community.banner!), fit: BoxFit.cover),
                  )
                : null,
            child: Container(
              decoration: communityInfo?.communityView.community.banner != null
                  ? BoxDecoration(
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
                    )
                  : null,
              child: Padding(
                padding: const EdgeInsets.only(top: 16.0, left: 24.0, right: 24.0, bottom: 16.0),
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
                        Icon(
                          isSidebarOpen != null && isSidebarOpen! ? Icons.chevron_right_rounded : Icons.chevron_left_rounded,
                          size: 50,
                          shadows: const <Shadow>[Shadow(color: Colors.black, blurRadius: 5.0)],
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
