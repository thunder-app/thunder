import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';

import 'package:lemmy_api_client/v3.dart';

import 'package:thunder/shared/icon_text.dart';
import 'package:thunder/utils/instance.dart';
import 'package:thunder/utils/numbers.dart';

class UserHeader extends StatelessWidget {
  final PersonViewSafe? userInfo;

  const UserHeader({
    super.key,
    this.userInfo,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      children: [
        if (userInfo?.person.banner == null)
          Positioned.fill(
            child: Container( color: theme.colorScheme.background),
          ),
        if (userInfo?.person.banner != null)
          Positioned.fill(
            child: Row(
              children: [
                Expanded(flex: 1, child: Container()),
                Expanded(
                  flex: 3,
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: CachedNetworkImageProvider(userInfo!.person.banner!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        if (userInfo?.person.banner != null)
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
        Padding(
          padding: const EdgeInsets.only(top: 16.0, left: 24.0, right: 24.0, bottom: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: userInfo?.person.avatar != null ? Colors.transparent : theme.colorScheme.onBackground,
                    foregroundImage: userInfo?.person.avatar != null ? CachedNetworkImageProvider(userInfo!.person.avatar!) : null,
                    maxRadius: 45,
                  ),
                  const SizedBox(width: 20.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          userInfo?.person.displayName != null ? userInfo?.person.displayName ?? '-' : userInfo?.person.name ?? '-',
                          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
                          softWrap: false,
                          maxLines: 1,
                          overflow: TextOverflow.fade,
                        ),
                        Text(
                          '${userInfo?.person.name ?? '-'}@${fetchInstanceNameFromUrl(userInfo?.person.actorId) ?? '-'}',
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8.0),
                        Row(
                          children: [
                            IconText(
                              icon: const Icon(
                                Icons.wysiwyg_rounded,
                                size: 18.0,
                              ),
                              text: formatNumberToK(userInfo?.counts.postCount ?? 0),
                            ),
                            const SizedBox(width: 8.0),
                            IconText(
                              icon: const Icon(
                                Icons.chat_rounded,
                                size: 18.0,
                              ),
                              text: formatNumberToK(userInfo?.counts.commentCount ?? 0),
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
    );
  }
}
