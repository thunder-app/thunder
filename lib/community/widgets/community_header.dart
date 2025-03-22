import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/core/models/models.dart';
import 'package:thunder/feed/bloc/feed_bloc.dart';
import 'package:thunder/feed/utils/utils.dart';
import 'package:thunder/shared/avatars/community_avatar.dart';
import 'package:thunder/shared/full_name_widgets.dart';
import 'package:thunder/shared/icon_text.dart';
import 'package:thunder/utils/instance.dart';
import 'package:thunder/utils/numbers.dart';

class CommunityHeader extends StatefulWidget {
  /// Community to display in the header
  final ThunderCommunity community;

  /// Whether the community sidebar is currently shown
  final bool showCommunitySidebar;

  /// Callback function when the community sidebar is toggled
  final Function(bool toggled) onToggle;

  const CommunityHeader({
    super.key,
    required this.community,
    required this.showCommunitySidebar,
    required this.onToggle,
  });

  @override
  State<CommunityHeader> createState() => _CommunityHeaderState();
}

class _CommunityHeaderState extends State<CommunityHeader> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = context.watch<FeedBloc>().state;

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
            if (widget.community.banner == null) Positioned.fill(child: Container(color: theme.colorScheme.surface)),
            if (widget.community.banner != null)
              Positioned.fill(
                child: Row(
                  children: [
                    Expanded(flex: 1, child: Container()),
                    Expanded(
                      flex: 3,
                      child: Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: CachedNetworkImageProvider(widget.community.banner!),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            if (widget.community.banner != null)
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
                          CommunityAvatar(community: widget.community, radius: 45.0, showCommunityStatus: true),
                          const SizedBox(width: 20.0),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  widget.community.title,
                                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
                                ),
                                CommunityFullNameWidget(
                                  context,
                                  widget.community.communityName,
                                  widget.community.title,
                                  fetchInstanceNameFromUrl(widget.community.url),
                                  // Override because we're showing right above
                                  useDisplayName: false,
                                ),
                                const SizedBox(height: 8.0),
                                Wrap(
                                  spacing: 8.0,
                                  children: [
                                    if (widget.community.subscribers != null)
                                      IconText(
                                        icon: const Icon(Icons.people_rounded),
                                        text: formatNumberToK(widget.community.subscribers!),
                                      ),
                                    if (widget.community.usersActiveMonth != null)
                                      IconText(
                                        icon: const Icon(Icons.calendar_month_rounded),
                                        text: formatNumberToK(widget.community.usersActiveMonth!),
                                      ),
                                    IconText(
                                      icon: Icon(getSortIcon(state)),
                                      text: getSortName(state),
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
                              shadows: <Shadow>[
                                Shadow(color: theme.colorScheme.surface, blurRadius: 10.0),
                                Shadow(color: theme.colorScheme.surface, blurRadius: 20.0),
                              ],
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
