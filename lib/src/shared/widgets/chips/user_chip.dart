import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/src/foundation/primitives/primitives.dart';
import 'package:thunder/src/features/feed/api.dart';
import 'package:thunder/src/shared/identity/widgets/avatars/user_avatar.dart';
import 'package:thunder/src/shared/identity/widgets/full_name_widgets.dart';
import 'package:thunder/src/features/comment/api.dart';
import 'package:thunder/src/features/settings/api.dart';
import 'package:thunder/src/features/user/api.dart';
import 'package:thunder/src/features/instance/domain/utils/instance_link_utils.dart';
import 'package:thunder/src/app/shell/navigation/navigation_utils.dart';
import 'package:thunder/src/shared/full_name_copy_utils.dart';
import 'package:thunder/packages/ui/ui.dart' show Thunder;

/// A chip which displays the given user and instance information. Additionally, it renders special chips for special users.
///
/// When tapped, navigates to the user's profile page.
class UserChip extends StatelessWidget {
  const UserChip({
    super.key,
    required this.user,
    required this.personAvatar,
    this.includeInstance = false,
    this.userGroups = const [],
    this.opacity = 1.0,
    this.ignorePointerEvents = false,
    this.constraints,
  });

  /// The user to display information for
  final ThunderUser user;

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

  /// The constraints for the user chip
  final BoxConstraints? constraints;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final showUserAvatar = context.select<CommentPreferencesCubit, bool>((cubit) => cubit.state.commentShowUserAvatar);
    final metadataFontSizeScale = context.select<ThemePreferencesCubit, FontScale>((cubit) => cubit.state.metadataFontSizeScale);

    return IgnorePointer(
      ignoring: ignorePointerEvents,
      child: Tooltip(
        excludeFromSemantics: true,
        triggerMode: TooltipTriggerMode.longPress,
        onTriggered: () => copyActivityPubFullName(
          type: ActivityPubFullNameType.user,
          name: user.name,
          displayName: user.displayName,
          instance: fetchInstanceNameFromUrl(user.actorId),
        ),
        message: '${generateUserFullName(
          context,
          user.name,
          user.displayName,
          fetchInstanceNameFromUrl(user.actorId),
          useDisplayName: false,
        )}${fetchUserGroupDescriptor(userGroups, user.published)}',
        preferBelow: false,
        child: Material(
          color: userGroups.isNotEmpty ? fetchUserGroupColor(context, userGroups) ?? theme.colorScheme.onSurface : Colors.transparent,
          borderRadius: userGroups.isNotEmpty ? const BorderRadius.all(Radius.elliptical(5, 5)) : null,
          child: InkWell(
            borderRadius: BorderRadius.circular(5),
            onTap: () {
              navigateToFeedPage(context, feedType: FeedType.user, userId: user.id);
            },
            child: Padding(
              padding: userGroups.isNotEmpty ? const EdgeInsets.symmetric(horizontal: 5.0) : EdgeInsets.zero,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (showUserAvatar && personAvatar != null && user.avatar != null) Padding(padding: const EdgeInsets.only(top: 3, bottom: 3, right: 3), child: personAvatar!),
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: (constraints?.maxWidth ?? MediaQuery.sizeOf(context).width) * 0.55),
                    child: UserFullNameWidget(
                        name: user.name,
                        displayName: user.displayName,
                        instance: fetchInstanceNameFromUrl(user.actorId),
                        includeInstance: includeInstance,
                        fontScale: metadataFontSizeScale,
                        transformColor: (c) => userGroups.isNotEmpty ? theme.textTheme.bodyMedium?.color : c?.withValues(alpha: opacity)),
                  ),
                  if (userGroups.isNotEmpty) const SizedBox(width: 2.0),
                  if (userGroups.contains(UserType.op))
                    Padding(
                      padding: const EdgeInsets.only(left: 1),
                      child: Icon(
                        Thunder.microphone_variant,
                        size: 15.0 * metadataFontSizeScale.textScaleFactor,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  if (userGroups.contains(UserType.self))
                    Padding(
                      padding: const EdgeInsets.only(left: 1),
                      child: Icon(
                        Icons.person,
                        size: 15.0 * metadataFontSizeScale.textScaleFactor,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  if (userGroups.contains(UserType.admin))
                    Padding(
                      padding: const EdgeInsets.only(left: 1),
                      child: Icon(
                        Thunder.shield_crown,
                        size: 14.0 * metadataFontSizeScale.textScaleFactor,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  if (userGroups.contains(UserType.moderator))
                    Padding(
                      padding: const EdgeInsets.only(left: 1),
                      child: Icon(
                        Thunder.shield,
                        size: 14.0 * metadataFontSizeScale.textScaleFactor,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  if (userGroups.contains(UserType.bot))
                    Padding(
                      padding: const EdgeInsets.only(left: 1, right: 2),
                      child: Icon(
                        Thunder.robot,
                        size: 13.0 * metadataFontSizeScale.textScaleFactor,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  if (userGroups.contains(UserType.birthday))
                    Padding(
                      padding: const EdgeInsets.only(left: 1, right: 2),
                      child: Icon(
                        Icons.cake_rounded,
                        size: 13.0 * metadataFontSizeScale.textScaleFactor,
                        color: theme.colorScheme.onSurface,
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
