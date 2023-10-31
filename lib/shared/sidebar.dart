import 'package:flutter/material.dart';
import 'package:lemmy_api_client/v3.dart';

import 'package:thunder/feed/utils/utils.dart';
import 'package:thunder/feed/view/feed_page.dart';
import 'package:thunder/shared/user_avatar.dart';
import 'package:thunder/utils/instance.dart';

/// A general sidebar widget which contains common logic to handle creation and dismissal of sidebar.
/// The [onDismiss] callback is called when the sidebar is dismissed.
///
/// This is used in [CommunitySidebar] and [UserSidebar].
class Sidebar extends StatefulWidget {
  final List<Widget> children;
  final Function onDismiss;

  const Sidebar({super.key, required this.children, required this.onDismiss});

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      alignment: Alignment.topRight,
      child: Dismissible(
        key: Key(widget.key.toString()),
        onUpdate: (DismissUpdateDetails details) => details.reached ? widget.onDismiss() : null,
        direction: DismissDirection.startToEnd,
        child: FractionallySizedBox(
          widthFactor: 0.8,
          alignment: FractionalOffset.centerRight,
          child: Container(
            color: theme.colorScheme.background,
            alignment: Alignment.topRight,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: widget.children,
            ),
          ),
        ),
      ),
    );
  }
}

class CommunityModeratorList extends StatelessWidget {
  const CommunityModeratorList({super.key, required this.communityModeratorViewList});

  final List<CommunityModeratorView> communityModeratorViewList;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        for (CommunityModeratorView mods in communityModeratorViewList)
          GestureDetector(
            onTap: () {
              navigateToFeedPage(context, feedType: FeedType.user, userId: mods.moderator.id);
            },
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  UserAvatar(
                    person: mods.moderator,
                    radius: 20.0,
                  ),
                  const SizedBox(width: 16.0),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mods.moderator.displayName ?? mods.moderator.name,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '${mods.moderator.name} · ${fetchInstanceNameFromUrl(mods.moderator.actorId)}',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: theme.colorScheme.onBackground.withOpacity(0.6),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class SidebarSectionHeader extends StatelessWidget {
  const SidebarSectionHeader({
    super.key,
    required this.value,
  });

  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0, bottom: 4),
      child: Row(
        children: [
          Text(value),
          const Expanded(child: Divider(height: 5, thickness: 2, indent: 15)),
        ],
      ),
    );
  }
}

class SidebarStat extends StatelessWidget {
  const SidebarStat({
    super.key,
    required this.icon,
    required this.value,
  });

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 8, top: 2, bottom: 2),
          child: Icon(
            icon,
            size: 18,
            color: theme.colorScheme.onBackground.withOpacity(0.65),
          ),
        ),
        Text(
          value,
          style: TextStyle(color: theme.textTheme.titleSmall?.color?.withOpacity(0.65)),
        ),
      ],
    );
  }
}
