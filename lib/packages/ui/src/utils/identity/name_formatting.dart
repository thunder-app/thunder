import 'package:thunder/packages/ui/src/models/identity/name_style.dart';

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

String formatUserFullName(
  String? name,
  String? displayName,
  String? instance, {
  required FullNameSeparator separator,
  required bool useDisplayName,
}) {
  final prefix = formatUserFullNamePrefix(name, displayName, separator: separator, useDisplayName: useDisplayName);
  final suffix = formatUserFullNameSuffix(instance, separator: separator);

  return '$prefix$suffix';
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

String formatCommunityFullName(
  String? name,
  String? displayName,
  String? instance, {
  required FullNameSeparator separator,
  required bool useDisplayName,
}) {
  final prefix = formatCommunityFullNamePrefix(name, displayName, separator: separator, useDisplayName: useDisplayName);
  final suffix = formatCommunityFullNameSuffix(instance, separator: separator);

  return '$prefix$suffix';
}
