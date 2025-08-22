import 'package:flutter/material.dart';

import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/core/enums/full_name.dart';
import 'package:thunder/src/features/feed/feed.dart';
import 'package:thunder/src/features/search/search.dart';
import 'package:thunder/src/shared/widgets/avatars/user_avatar.dart';
import 'package:thunder/src/shared/full_name_widgets.dart';
import 'package:thunder/src/features/user/user.dart';
import 'package:thunder/src/shared/utils/instance.dart';
import 'package:thunder/src/app/utils/navigation.dart';

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
              final response = await SearchRepositoryImpl(account: account).resolve(query: user.actorId);

              userId = response['user']?.id;
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
