import 'package:thunder/src/shared/identity/models/name_style.dart';

String formatUserFullNamePrefix(
  String? name,
  String? displayName, {
  required FullNameSeparator separator,
  required bool useDisplayName,
}) {
  final resolvedName = (useDisplayName && displayName?.isNotEmpty == true ? displayName : name) ?? '';

  return switch (separator) {
    FullNameSeparator.dot => resolvedName,
    FullNameSeparator.at => resolvedName,
    FullNameSeparator.lemmy => '@$resolvedName',
  };
}

String formatUserFullNameSuffix(
  String? instance, {
  required FullNameSeparator separator,
}) {
  return switch (separator) {
    FullNameSeparator.dot => ' · $instance',
    FullNameSeparator.at => '@$instance',
    FullNameSeparator.lemmy => '@$instance',
  };
}

String formatCommunityFullNamePrefix(
  String? name,
  String? displayName, {
  required FullNameSeparator separator,
  required bool useDisplayName,
}) {
  final resolvedName = (useDisplayName && displayName?.isNotEmpty == true ? displayName : name) ?? '';

  return switch (separator) {
    FullNameSeparator.dot => resolvedName,
    FullNameSeparator.at => resolvedName,
    FullNameSeparator.lemmy => '!$resolvedName',
  };
}

String formatCommunityFullNameSuffix(
  String? instance, {
  required FullNameSeparator separator,
}) {
  return switch (separator) {
    FullNameSeparator.dot => ' · $instance',
    FullNameSeparator.at => '@$instance',
    FullNameSeparator.lemmy => '@$instance',
  };
}
