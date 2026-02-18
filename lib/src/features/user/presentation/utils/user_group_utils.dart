import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/l10n/generated/app_localizations.dart';
import 'package:thunder/src/foundation/primitives/primitives.dart';
import 'package:thunder/src/features/settings/api.dart';
import 'package:thunder/src/foundation/config/global_context.dart';
import 'package:thunder/src/features/account/account.dart';

/// Fetches the user groups for a givencomment.
List<UserType> getCommentUserGroups(ThunderComment comment, Account account) {
  final groups = <UserType>[];

  if (comment.creator?.botAccount == true) groups.add(UserType.bot);
  if (comment.creatorIsModerator == true) groups.add(UserType.moderator);
  if (comment.creatorIsAdmin == true) groups.add(UserType.admin);
  if (comment.post?.creatorId == comment.creatorId) groups.add(UserType.op);
  if (comment.creatorId == account.userId) groups.add(UserType.self);

  final now = DateTime.now();
  final published = comment.creator?.published;

  final isUserBirthday = published != null && published.month == now.month && published.day == now.day;
  if (isUserBirthday) groups.add(UserType.birthday);

  return groups;
}

/// Fetches the user group color based on the given [userGroups].
///
/// If the user is in multiple groups, the color is based on order of precedence.
/// The order is: OP > Self > Admin > Moderator > Bot
Color? fetchUserGroupColor(BuildContext context, List<UserType> userGroups) {
  final theme = Theme.of(context);
  final bool darkTheme = context.read<ThemePreferencesCubit>().state.useDarkTheme;

  Color? color;

  if (userGroups.contains(UserType.op)) {
    color = UserType.op.color;
  } else if (userGroups.contains(UserType.self)) {
    color = UserType.self.color;
  } else if (userGroups.contains(UserType.admin)) {
    color = UserType.admin.color;
  } else if (userGroups.contains(UserType.moderator)) {
    color = UserType.moderator.color;
  } else if (userGroups.contains(UserType.bot)) {
    color = UserType.bot.color;
  } else if (userGroups.contains(UserType.birthday)) {
    color = UserType.birthday.color;
  }

  if (color != null) {
    // Blend with theme
    color = Color.alphaBlend(theme.colorScheme.primaryContainer.withValues(alpha: 0.35), color);

    // Lighten for light mode
    if (!darkTheme) {
      color = HSLColor.fromColor(color).withLightness(0.85).toColor();
    }
  }

  return color;
}

/// Fetches the user group descriptor based on the given [userGroups].
///
/// If the user is in multiple groups, the descriptor will contain all of them.
String fetchUserGroupDescriptor(List<UserType> userGroups, DateTime? created) {
  List<String> descriptors = [];
  String descriptor = '';

  final l10n = AppLocalizations.of(GlobalContext.context)!;

  if (userGroups.contains(UserType.op)) descriptors.add(l10n.originalPoster);
  if (userGroups.contains(UserType.self)) descriptors.add(l10n.me);
  if (userGroups.contains(UserType.admin)) descriptors.add(l10n.admin);
  if (userGroups.contains(UserType.moderator)) descriptors.add(l10n.moderator(1));
  if (userGroups.contains(UserType.bot)) descriptors.add(l10n.bot);
  if (descriptors.isNotEmpty) descriptor = ' (${descriptors.join(', ')})';

  if (userGroups.contains(UserType.birthday) && created != null) {
    int yearsOld = DateTime.now().year - created.year;
    descriptor += '\n${l10n.accountBirthday(
      yearsOld == 0 ? '(${l10n.createdToday})' : '(${l10n.xYearsOld(yearsOld, yearsOld)})',
    )}';
  }

  return descriptor;
}
