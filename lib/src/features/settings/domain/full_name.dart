import 'package:flutter/widgets.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/src/features/settings/api.dart';
import 'package:thunder/src/shared/identity/models/name_style.dart' show FullNameSeparator;
import 'package:thunder/src/shared/identity/utils/name_formatting.dart' show formatCommunityFullNamePrefix, formatCommunityFullNameSuffix, formatUserFullNamePrefix, formatUserFullNameSuffix;

export 'package:thunder/src/shared/identity/models/name_style.dart' show FullNameSeparator, NameColor, NameThickness;

/// --- USERS ---

String generateUserFullName(BuildContext? context, String? name, String? displayName, String? instance, {FullNameSeparator? userSeparator, bool? useDisplayName}) {
  assert(context != null || (userSeparator != null && useDisplayName != null));

  final preferences = context?.read<ThemePreferencesCubit>().state;
  final resolvedSeparator = userSeparator ?? preferences!.userSeparator;
  final resolvedUseDisplayName = useDisplayName ?? preferences!.useDisplayNamesForUsers;

  final prefix = formatUserFullNamePrefix(name, displayName, separator: resolvedSeparator, useDisplayName: resolvedUseDisplayName);
  final suffix = formatUserFullNameSuffix(instance, separator: resolvedSeparator);

  return '$prefix$suffix';
}

/// --- COMMUNITIES ---

String generateCommunityFullName(BuildContext? context, String? name, String? displayName, String? instance, {FullNameSeparator? communitySeparator, bool? useDisplayName}) {
  assert(context != null || (communitySeparator != null && useDisplayName != null));

  final preferences = context?.read<ThemePreferencesCubit>().state;
  final resolvedSeparator = communitySeparator ?? preferences!.communitySeparator;
  final resolvedUseDisplayName = useDisplayName ?? preferences!.useDisplayNamesForCommunities;

  final prefix = formatCommunityFullNamePrefix(name, displayName, separator: resolvedSeparator, useDisplayName: resolvedUseDisplayName);
  final suffix = formatCommunityFullNameSuffix(instance, separator: resolvedSeparator);

  return '$prefix$suffix';
}
