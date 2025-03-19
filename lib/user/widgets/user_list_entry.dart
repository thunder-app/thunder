import 'package:flutter/material.dart';

import 'package:lemmy_api_client/v3.dart';

import 'package:thunder/core/enums/full_name.dart';
import 'package:thunder/core/models/models.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/feed/view/feed_page.dart';
import 'package:thunder/shared/avatars/user_avatar.dart';
import 'package:thunder/shared/full_name_widgets.dart';
import 'package:thunder/utils/instance.dart';
import 'package:thunder/utils/navigation.dart';

/// A widget that can display a single user entry for use within a list (e.g., search page, instance explorer)
class UserListEntry extends StatelessWidget {
  /// The user to display.
  final ThunderUser user;

  /// The instance to resolve the user on, if different from the current instance.
  final String? resolutionInstance;

  const UserListEntry({super.key, required this.user, this.resolutionInstance});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      excludeFromSemantics: true,
      message: '${user.name}\n${generateUserFullName(
        context,
        user.username,
        user.displayName,
        fetchInstanceNameFromUrl(user.url),
      )}',
      preferBelow: false,
      child: ListTile(
        leading: UserAvatar(user: user, radius: 25),
        title: Text(user.name, overflow: TextOverflow.ellipsis),
        subtitle: Row(
          children: [
            Flexible(
              child: UserFullNameWidget(
                context,
                user.username,
                user.displayName,
                fetchInstanceNameFromUrl(user.url),
                // Override because we're showing display name above
                useDisplayName: false,
              ),
            ),
          ],
        ),
        onTap: () async {
          int? userId = user.id;

          if (resolutionInstance != null) {
            try {
              final lemmy = (LemmyClient()..changeBaseUrl(resolutionInstance!)).lemmyApiV3;
              final response = await lemmy.run(ResolveObject(q: user.url));

              userId = response.person?.person.id;
            } catch (e) {
              // If we can't find it, then we'll get a standard error message about personId being un-navigable
            }
          }

          if (context.mounted) {
            navigateToFeedPage(context, feedType: FeedType.user, userId: userId);
          }
        },
      ),
    );
  }
}
