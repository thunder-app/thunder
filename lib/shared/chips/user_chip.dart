import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lemmy_api_client/v3.dart';

import 'package:thunder/core/enums/font_scale.dart';
import 'package:thunder/core/enums/full_name.dart';
import 'package:thunder/core/enums/user_type.dart';
import 'package:thunder/feed/utils/utils.dart';
import 'package:thunder/feed/view/feed_page.dart';
import 'package:thunder/shared/avatars/user_avatar.dart';
import 'package:thunder/shared/full_name_widgets.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/thunder/thunder_icons.dart';
import 'package:thunder/user/utils/user_groups.dart';
import 'package:thunder/utils/instance.dart';

/// A chip which displays the given user and instance information. Additionally, it renders special chips for special users.
///
/// When tapped, navigates to the user's profile page.
class UserChip extends StatelessWidget {
  const UserChip({
    super.key,
    required this.person,
    required this.personAvatar,
    this.includeInstance = false,
    this.userGroups = const [],
    this.opacity = 1.0,
    this.ignorePointerEvents = false,
  });

  /// The person that this chip represents.
  final Person person;

  /// The avatar of the user
  final UserAvatar? personAvatar;

  /// Whether or not to include the instance name
  final bool includeInstance;

  /// The groups that the user belongs to (e.g., self, moderator, admin)
  /// This determines special badge colors and icons
  final List<UserType> userGroups;

  /// An override opacity for the text
  final double opacity;

  /// Whether or not to disable the touch events (e.g., navigating to user page)
  final bool ignorePointerEvents;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = context.read<ThunderBloc>().state;
    final showUserAvatar = state.commentShowUserAvatar;

    return IgnorePointer(
      ignoring: ignorePointerEvents,
      child: Tooltip(
        excludeFromSemantics: true,
        message: '${generateUserFullName(context, person.name, fetchInstanceNameFromUrl(person.actorId) ?? '-')}${fetchUserGroupDescriptor(userGroups, person)}',
        preferBelow: false,
        child: Material(
          color: userGroups.isNotEmpty ? fetchUserGroupColor(context, userGroups) ?? theme.colorScheme.onBackground : Colors.transparent,
          borderRadius: userGroups.isNotEmpty ? const BorderRadius.all(Radius.elliptical(5, 5)) : null,
          child: InkWell(
            borderRadius: BorderRadius.circular(5),
            onTap: () {
              navigateToFeedPage(context, feedType: FeedType.user, userId: person.id);
            },
            child: Padding(
              padding: userGroups.isNotEmpty ? const EdgeInsets.symmetric(horizontal: 5.0) : EdgeInsets.zero,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (showUserAvatar && personAvatar != null) Padding(padding: const EdgeInsets.only(top: 3, bottom: 3, right: 3), child: personAvatar!),
                  UserFullNameWidget(
                    context,
                    person.displayName != null && state.useDisplayNames ? person.displayName! : person.name,
                    fetchInstanceNameFromUrl(person.actorId),
                    includeInstance: includeInstance,
                    fontScale: state.metadataFontSizeScale,
                    transformColor: (c) => userGroups.isNotEmpty ? theme.textTheme.bodyMedium?.color : c?.withOpacity(opacity),
                  ),
                  if (userGroups.isNotEmpty) const SizedBox(width: 2.0),
                  if (userGroups.contains(UserType.op))
                    Padding(
                      padding: const EdgeInsets.only(left: 1),
                      child: Icon(
                        Thunder.microphone_variant,
                        size: 15.0 * state.metadataFontSizeScale.textScaleFactor,
                        color: theme.colorScheme.onBackground,
                      ),
                    ),
                  if (userGroups.contains(UserType.self))
                    Padding(
                      padding: const EdgeInsets.only(left: 1),
                      child: Icon(
                        Icons.person,
                        size: 15.0 * state.metadataFontSizeScale.textScaleFactor,
                        color: theme.colorScheme.onBackground,
                      ),
                    ),
                  if (userGroups.contains(UserType.admin))
                    Padding(
                      padding: const EdgeInsets.only(left: 1),
                      child: Icon(
                        Thunder.shield_crown,
                        size: 14.0 * state.metadataFontSizeScale.textScaleFactor,
                        color: theme.colorScheme.onBackground,
                      ),
                    ),
                  if (userGroups.contains(UserType.moderator))
                    Padding(
                      padding: const EdgeInsets.only(left: 1),
                      child: Icon(
                        Thunder.shield,
                        size: 14.0 * state.metadataFontSizeScale.textScaleFactor,
                        color: theme.colorScheme.onBackground,
                      ),
                    ),
                  if (userGroups.contains(UserType.bot))
                    Padding(
                      padding: const EdgeInsets.only(left: 1, right: 2),
                      child: Icon(
                        Thunder.robot,
                        size: 13.0 * state.metadataFontSizeScale.textScaleFactor,
                        color: theme.colorScheme.onBackground,
                      ),
                    ),
                  if (userGroups.contains(UserType.birthday))
                    Padding(
                      padding: const EdgeInsets.only(left: 1, right: 2),
                      child: Icon(
                        Icons.cake_rounded,
                        size: 13.0 * state.metadataFontSizeScale.textScaleFactor,
                        color: theme.colorScheme.onBackground,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
