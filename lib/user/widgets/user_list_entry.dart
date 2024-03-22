import 'package:flutter/material.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:thunder/core/enums/full_name.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/feed/utils/utils.dart';
import 'package:thunder/feed/view/feed_page.dart';
import 'package:thunder/shared/avatars/user_avatar.dart';
import 'package:thunder/utils/instance.dart';

/// A widget that can display a single user entry for use within a list (e.g., search page, instance explorer)
class UserListEntry extends StatelessWidget {
  final PersonView personView;
  final String? resolutionInstance;

  const UserListEntry({super.key, required this.personView, this.resolutionInstance});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      excludeFromSemantics: true,
      message: '${personView.person.displayName ?? personView.person.name}\n${generateUserFullName(context, personView.person.name, fetchInstanceNameFromUrl(personView.person.actorId))}',
      preferBelow: false,
      child: ListTile(
        leading: UserAvatar(person: personView.person, radius: 25),
        title: Text(
          personView.person.displayName ?? personView.person.name,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Row(children: [
          Flexible(
            child: generateUserFullNameWidget(
              context,
              personView.person.name,
              fetchInstanceNameFromUrl(personView.person.actorId),
            ),
          ),
        ]),
        onTap: () async {
          int? personId = personView.person.id;
          if (resolutionInstance != null) {
            final LemmyApiV3 lemmy = (LemmyClient()..changeBaseUrl(resolutionInstance!)).lemmyApiV3;
            try {
              final ResolveObjectResponse resolveObjectResponse = await lemmy.run(ResolveObject(q: personView.person.actorId));
              personId = resolveObjectResponse.person?.person.id;
            } catch (e) {
              // If we can't find it, then we'll get a standard error message about personId being un-navigable
            }
          }

          if (context.mounted) {
            navigateToFeedPage(context, feedType: FeedType.user, userId: personId);
          }
        },
      ),
    );
  }
}
