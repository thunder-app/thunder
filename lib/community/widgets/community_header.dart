import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:thunder/feed/bloc/feed_bloc.dart';
import 'package:thunder/feed/utils/utils.dart';

import 'package:thunder/shared/avatars/community_avatar.dart';
import 'package:thunder/shared/full_name_widgets.dart';
import 'package:thunder/shared/icon_text.dart';
import 'package:thunder/utils/instance.dart';
import 'package:thunder/utils/numbers.dart';

class CommunityHeader extends StatefulWidget {
  final bool showCommunitySidebar;
  final GetCommunityResponse getCommunityResponse;
  final Function(bool toggled) onToggle;

  const CommunityHeader({
    super.key,
    required this.showCommunitySidebar,
    required this.getCommunityResponse,
    required this.onToggle,
  });

  @override
  State<CommunityHeader> createState() => _CommunityHeaderState();
}

class _CommunityHeaderState extends State<CommunityHeader> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final FeedBloc feedBloc = context.watch<FeedBloc>();

    return Material(
      elevation: widget.showCommunitySidebar ? 5.0 : 0,
      child: GestureDetector(
        onTap: () => widget.onToggle(!widget.showCommunitySidebar),
        onHorizontalDragEnd: (DragEndDetails dragEndDetails) {
          if (dragEndDetails.velocity.pixelsPerSecond.dx >= 0) {
            widget.onToggle(false);
          } else if (dragEndDetails.velocity.pixelsPerSecond.dx < 0) {
            widget.onToggle(true);
          }
        },
        child: Stack(
          children: [
            if (widget.getCommunityResponse.communityView.community.banner == null) Positioned.fill(child: Container(color: theme.colorScheme.surface)),
            if (widget.getCommunityResponse.communityView.community.banner != null)
              Positioned.fill(
                child: Row(
                  children: [
                    Expanded(flex: 1, child: Container()),
                    Expanded(
                      flex: 3,
                      child: Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: CachedNetworkImageProvider(widget.getCommunityResponse.communityView.community.banner!),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            if (widget.getCommunityResponse.communityView.community.banner != null)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        theme.colorScheme.surface,
                        theme.colorScheme.surface,
                        theme.colorScheme.surface.withValues(alpha: 0.9),
                        theme.colorScheme.surface.withValues(alpha: 0.6),
                        theme.colorScheme.surface.withValues(alpha: 0.3),
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
                          CommunityAvatar(
                            community: widget.getCommunityResponse.communityView.community,
                            radius: 45.0,
                            showCommunityStatus: true,
                          ),
                          const SizedBox(width: 20.0),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  widget.getCommunityResponse.communityView.community.title,
                                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
                                ),
                                CommunityFullNameWidget(
                                  context,
                                  widget.getCommunityResponse.communityView.community.name,
                                  widget.getCommunityResponse.communityView.community.title,
                                  fetchInstanceNameFromUrl(widget.getCommunityResponse.communityView.community.actorId) ?? 'N/A',
                                  // Override because we're showing right above
                                  useDisplayName: false,
                                ),
                                const SizedBox(height: 8.0),
                                Wrap(
                                  children: [
                                    IconText(
                                      icon: const Icon(Icons.people_rounded),
                                      text: formatNumberToK(widget.getCommunityResponse.communityView.counts.subscribers),
                                    ),
                                    const SizedBox(width: 8.0),
                                    IconText(
                                      icon: const Icon(Icons.calendar_month_rounded),
                                      text: formatNumberToK(widget.getCommunityResponse.communityView.counts.usersActiveMonth),
                                    ),
                                    const SizedBox(width: 8.0),
                                    IconText(
                                      icon: Icon(getSortIcon(feedBloc.state)),
                                      text: getSortName(feedBloc.state),
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
                              shadows: <Shadow>[Shadow(color: theme.colorScheme.surface, blurRadius: 10.0), Shadow(color: theme.colorScheme.surface, blurRadius: 20.0)],
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
        ),
      ),
    );
  }
}
