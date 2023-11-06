import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';

import 'package:lemmy_api_client/v3.dart';

import 'package:thunder/shared/icon_text.dart';
import 'package:thunder/shared/user_avatar.dart';
import 'package:thunder/utils/instance.dart';
import 'package:thunder/utils/numbers.dart';

class UserHeader extends StatefulWidget {
  final bool showUserSidebar;
  final PersonView? personView;
  final Function(bool toggled) onToggle;

  const UserHeader({
    super.key,
    required this.showUserSidebar,
    this.personView,
    required this.onToggle,
  });

  @override
  State<UserHeader> createState() => _UserHeaderState();
}

class _UserHeaderState extends State<UserHeader> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    PersonView? personView = widget.personView;

    return Material(
      elevation: widget.showUserSidebar ? 5.0 : 0,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 20.0),
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
              if (personView?.person.banner == null || personView?.person.banner == '') Positioned.fill(child: Container(color: theme.colorScheme.background)),
              if (personView?.person.banner != null && personView?.person.banner != '') ...[
                Positioned.fill(
                  child: Row(
                    children: [
                      Expanded(flex: 1, child: Container()),
                      Expanded(
                        flex: 3,
                        child: Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: CachedNetworkImageProvider(widget.personView!.person.banner!),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
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
              ],
              Padding(
                padding: const EdgeInsets.only(top: 16.0, left: 24.0, right: 24.0, bottom: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        UserAvatar(
                          person: widget.personView?.person,
                          radius: 45.0,
                        ),
                        const SizedBox(width: 20.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.personView?.person.displayName != null ? widget.personView?.person.displayName ?? '-' : widget.personView?.person.name ?? '-',
                                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
                                softWrap: false,
                                maxLines: 1,
                                overflow: TextOverflow.fade,
                              ),
                              Text(
                                '${widget.personView?.person.name ?? '-'}@${fetchInstanceNameFromUrl(widget.personView?.person.actorId) ?? '-'}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8.0),
                              Row(
                                children: [
                                  IconText(
                                    icon: const Icon(Icons.wysiwyg_rounded, size: 18.0),
                                    text: formatNumberToK(widget.personView?.counts.postCount ?? 0),
                                  ),
                                  const SizedBox(width: 8.0),
                                  IconText(
                                    icon: const Icon(Icons.chat_rounded, size: 18.0),
                                    text: formatNumberToK(widget.personView?.counts.commentCount ?? 0),
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
        ),
      ),
    );
  }
}
