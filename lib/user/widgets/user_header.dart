import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';

import 'package:lemmy_api_client/v3.dart';

import 'package:thunder/shared/icon_text.dart';
import 'package:thunder/utils/instance.dart';
import 'package:thunder/utils/numbers.dart';

class UserHeader extends StatelessWidget {
  final PersonViewSafe? userInfo;

  const UserHeader({super.key, this.userInfo});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: userInfo?.person.banner != null ? BoxDecoration(
        image: DecorationImage(
            image: CachedNetworkImageProvider(userInfo!.person.banner!),
            fit: BoxFit.cover
        ),
      ) : null,
      child: Container(
        decoration: userInfo?.person.banner != null ? BoxDecoration(
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
        ) : null,
        child: Padding(
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
                        Row(
                          children: [
                            Text(userInfo?.person.name ?? '-'),
                            Text('@'),
                            Text(
                              fetchInstanceNameFromUrl(userInfo?.person.actorId) ?? '-',
                              style: theme.textTheme.titleSmall,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8.0),
                        Row(
                          children: [
                            // IconText(
                            //   icon: const Icon(Icons.people_rounded),
                            //   text: formatNumberToK(userInfo?.communityView.counts.subscribers ?? 0),
                            // ),
                            // const SizedBox(width: 8.0),
                            // IconText(
                            //   icon: const Icon(Icons.sensors_rounded),
                            //   text: (userInfo?.online != null) ? '${userInfo?.online}' : '-',
                            // ),
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
      ),
    );
  }
}
