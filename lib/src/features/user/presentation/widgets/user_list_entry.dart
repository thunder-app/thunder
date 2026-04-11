import 'package:flutter/material.dart';

import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/foundation/primitives/primitives.dart';
import 'package:thunder/src/features/settings/api.dart';
import 'package:thunder/src/features/feed/feed.dart';
import 'package:thunder/src/features/search/search.dart';
import 'package:thunder/src/shared/avatars/user_avatar.dart';
import 'package:thunder/src/shared/name/full_name_widgets.dart';
import 'package:thunder/src/features/user/user.dart';
import 'package:thunder/src/features/instance/domain/utils/instance_link_utils.dart';
import 'package:thunder/src/app/shell/navigation/navigation_utils.dart';

/// A widget that can display a single user entry for use within a list (e.g., search page, instance explorer)
class UserListEntry extends StatelessWidget {
  /// The user to display.
  final ThunderUser user;

  /// The account to use for resolving the user, if different from the current instance.
  final Account? resolutionAccount;

  const UserListEntry({super.key, required this.user, this.resolutionAccount});

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
                name: user.name,
                displayName: user.displayName,
                instance: fetchInstanceNameFromUrl(user.actorId),
                // Override because we're showing display name above
                useDisplayName: false,
              ),
            ),
          ],
        ),
        onTap: () async {
          int? userId = user.id;

          if (resolutionAccount != null) {
            try {
              final response = await SearchRepositoryImpl(account: resolutionAccount!).resolve(query: user.actorId);

              userId = response.user?.id;
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
