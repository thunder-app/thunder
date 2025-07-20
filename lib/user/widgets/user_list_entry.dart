import 'package:flutter/material.dart';
import 'package:thunder/account/models/account.dart';

import 'package:thunder/core/enums/full_name.dart';
import 'package:thunder/feed/view/feed_page.dart';
import 'package:thunder/search/repository/search_repository.dart';
import 'package:thunder/shared/avatars/user_avatar.dart';
import 'package:thunder/shared/full_name_widgets.dart';
import 'package:thunder/user/models/thunder_user.dart';
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
      message: '${user.displayNameOrName}\n${generateUserFullName(
        context,
        user.name,
        user.displayName,
        fetchInstanceNameFromUrl(user.actorId),
      )}',
      preferBelow: false,
      child: ListTile(
        leading: UserAvatar(user: user, radius: 25),
        title: Text(user.displayNameOrName, overflow: TextOverflow.ellipsis),
        subtitle: Row(
          children: [
            Flexible(
              child: UserFullNameWidget(
                context,
                user.name,
                user.displayName,
                fetchInstanceNameFromUrl(user.actorId),
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
              // Create a temporary Account for the request
              final account = Account(instance: resolutionInstance!, id: '', index: -1);
              final response = await LemmySearchRepository(account: account).resolve(query: user.actorId);

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
