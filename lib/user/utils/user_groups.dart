import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:lemmy_api_client/v3.dart';

import 'package:thunder/core/enums/user_type.dart';
import 'package:thunder/core/theme/bloc/theme_bloc.dart';
import 'package:thunder/utils/global_context.dart';

/// Fetches the user group color based on the given [userGroups].
///
/// If the user is in multiple groups, the color is based on order of precedence.
/// The order is: OP > Self > Admin > Moderator > Bot
Color? fetchUserGroupColor(BuildContext context, List<UserType> userGroups) {
  final theme = Theme.of(context);
  final bool darkTheme = context.read<ThemeBloc>().state.useDarkTheme;

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
    color = Color.alphaBlend(theme.colorScheme.primaryContainer.withOpacity(0.35), color);

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
String fetchUserGroupDescriptor(List<UserType> userGroups, Person? person) {
  List<String> descriptors = [];
  String descriptor = '';

  final l10n = AppLocalizations.of(GlobalContext.context)!;

  if (userGroups.contains(UserType.op)) descriptors.add(l10n.originalPoster);
  if (userGroups.contains(UserType.self)) descriptors.add(l10n.me);
  if (userGroups.contains(UserType.admin)) descriptors.add(l10n.admin);
  if (userGroups.contains(UserType.moderator)) descriptors.add(l10n.moderator);
  if (userGroups.contains(UserType.bot)) descriptors.add(l10n.bot);
  if (descriptors.isNotEmpty) descriptor = ' (${descriptors.join(', ')})';

  if (userGroups.contains(UserType.birthday) && person != null) {
    int yearsOld = DateTime.now().year - person.published.year;
    descriptor += '\n${l10n.accountBirthday(
      yearsOld == 0 ? '(${l10n.createdToday})' : '(${l10n.xYearsOld(yearsOld, yearsOld)})',
    )}';
  }

  return descriptor;
}
