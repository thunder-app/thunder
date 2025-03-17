import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_size_text/auto_size_text.dart';

import 'package:thunder/core/models/models.dart';
import 'package:thunder/feed/feed.dart';
import 'package:thunder/shared/avatars/user_avatar.dart';
import 'package:thunder/shared/full_name_widgets.dart';
import 'package:thunder/shared/icon_text.dart';
import 'package:thunder/utils/instance.dart';
import 'package:thunder/utils/numbers.dart';

class UserHeader extends StatefulWidget {
  /// User to display in the header
  final ThunderUser user;

  /// Whether the user sidebar is currently shown
  final bool showUserSidebar;

  /// Callback function when the user sidebar is toggled
  final Function(bool toggled) onToggle;

  const UserHeader({
    super.key,
    required this.user,
    required this.showUserSidebar,
    required this.onToggle,
  });

  @override
  State<UserHeader> createState() => _UserHeaderState();
}

class _UserHeaderState extends State<UserHeader> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final FeedBloc feedBloc = context.watch<FeedBloc>();

    return Material(
      elevation: widget.showUserSidebar ? 5.0 : 0,
      child: GestureDetector(
        onTap: () => widget.onToggle(!widget.showUserSidebar),
        onHorizontalDragEnd: (DragEndDetails dragEndDetails) {
          if (dragEndDetails.velocity.pixelsPerSecond.dx >= 0) {
            widget.onToggle(false);
          } else if (dragEndDetails.velocity.pixelsPerSecond.dx < 0) {
            widget.onToggle(true);
          }
        },
        child: Stack(
          children: [
            if (widget.user.banner == null) Positioned.fill(child: Container(color: theme.colorScheme.surface)),
            if (widget.user.banner != null)
              Positioned.fill(
                child: Row(
                  children: [
                    Expanded(flex: 1, child: Container()),
                    Expanded(
                      flex: 3,
                      child: Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: CachedNetworkImageProvider(widget.user.banner!),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            if (widget.user.banner != null)
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
                          UserAvatar(user: widget.user, radius: 45.0),
                          const SizedBox(width: 20.0),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                AutoSizeText(
                                  widget.user.name,
                                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
                                  maxLines: 1,
                                ),
                                UserFullNameWidget(
                                  context,
                                  widget.user.username,
                                  widget.user.displayName,
                                  fetchInstanceNameFromUrl(widget.user.url),
                                  autoSize: true,
                                  // Override because we're showing display name above
                                  useDisplayName: false,
                                ),
                                const SizedBox(height: 8.0),
                                Wrap(
                                  spacing: 8.0,
                                  children: [
                                    if (widget.user.totalPosts != null)
                                      IconText(
                                        icon: const Icon(Icons.wysiwyg_rounded),
                                        text: formatNumberToK(widget.user.totalPosts!),
                                      ),
                                    if (widget.user.totalComments != null)
                                      IconText(
                                        icon: const Icon(Icons.chat_rounded),
                                        text: formatNumberToK(widget.user.totalComments!),
                                      ),
                                    if (feedBloc.state.feedType == FeedType.user)
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
