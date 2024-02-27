import 'package:flutter/material.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:thunder/core/enums/full_name_separator.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/shared/avatars/user_avatar.dart';
import 'package:thunder/user/utils/navigate_user.dart';
import 'package:thunder/utils/instance.dart';

/// Creates a widget that can display a single user entry for use within a list (e.g., search page, instance explorer)
Widget buildUserEntry(BuildContext context, PersonView personView, {String? resolutionInstance}) {
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
          child: Text(
            generateUserFullName(context, personView.person.name, fetchInstanceNameFromUrl(personView.person.actorId)),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ]),
      onTap: () async {
        int? personId = personView.person.id;
        if (resolutionInstance != null) {
          final LemmyApiV3 lemmy = (LemmyClient()..changeBaseUrl(resolutionInstance)).lemmyApiV3;
          try {
            final ResolveObjectResponse resolveObjectResponse = await lemmy.run(ResolveObject(q: personView.person.actorId));
            personId = resolveObjectResponse.person?.person.id;
          } catch (e) {
            // If we can't find it, then we'll get a standard error message about personId being un-navigable
          }
        }

        if (context.mounted) {
          navigateToUserPage(context, userId: personId);
        }
      },
    ),
  );
}
