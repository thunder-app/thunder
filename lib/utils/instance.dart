import 'dart:collection';

import 'package:lemmy_api_client/v3.dart';

String? fetchInstanceNameFromUrl(String? url) {
  if (url == null) {
    return null;
  }

  final uri = Uri.parse(url);
  return uri.host;
}

/// Matches instance.tld/c/community@otherinstance.tld
/// Puts community in group 3 and otherinstance.tld in group 4
/// https://regex101.com/r/sE8SmL/1
final RegExp fullCommunityUrl = RegExp(r'^!?(https?:\/\/)?(.*)\/c\/(.*)@(.*)$');

/// Matches instance.tld/c/community
/// Puts community in group 3 and instance.tld in group 2
/// https://regex101.com/r/AW2qTr/1
final RegExp shortCommunityUrl = RegExp(r'^!?(https?:\/\/)?(.*)\/c\/([^@\n]*)$');

/// Matches community@instance.tld
/// Puts community in group 2 and instance.tld in group 3
/// https://regex101.com/r/1VrXgX/1
final RegExp instanceName = RegExp(r'^!?(https?:\/\/)?((?:(?!\/c\/c).)*)@(.*)$');

/// Checks if the given text references a community on a valid Lemmy server.
/// If so, returns the community name in the format community@instance.tld.
/// Otherwise, returns null.
Future<String?> getLemmyCommunity(String text) async {
  final RegExpMatch? fullCommunityUrlMatch = fullCommunityUrl.firstMatch(text);
  if (fullCommunityUrlMatch != null && fullCommunityUrlMatch.groupCount >= 4 && await isLemmyInstance(fullCommunityUrlMatch.group(4))) {
    return '${fullCommunityUrlMatch.group(3)}@${fullCommunityUrlMatch.group(4)}';
  }

  final RegExpMatch? shortCommunityUrlMatch = shortCommunityUrl.firstMatch(text);
  if (shortCommunityUrlMatch != null && shortCommunityUrlMatch.groupCount >= 3 && await isLemmyInstance(shortCommunityUrlMatch.group(2))) {
    return '${shortCommunityUrlMatch.group(3)}@${shortCommunityUrlMatch.group(2)}';
  }

  final RegExpMatch? instanceNameMatch = instanceName.firstMatch(text);
  if (instanceNameMatch != null && instanceNameMatch.groupCount >= 3 && await isLemmyInstance(instanceNameMatch.group(3))) {
    return '${instanceNameMatch.group(2)}@${instanceNameMatch.group(3)}';
  }

  return null;
}

/// Matches instance.tld/u/username@otherinstance.tld
/// Puts username in group 3 and otherinstance.tld in group 4
final RegExp fullUsernameUrl = RegExp(r'^@?(https?:\/\/)?(.*)\/u\/(.*)@(.*)$');

/// Matches instance.tld/u/username
/// Puts username in group 3 and instance.tld in group 2
final RegExp shortUsernameUrl = RegExp(r'^@?(https?:\/\/)?(.*)\/u\/([^@\n]*)$');

/// Matches username@instance.tld
/// Puts username in group 2 and instance.tld in group 3
final RegExp username = RegExp(r'^@?(https?:\/\/)?((?:(?!\/u\/u).)*)@(.*)$');

/// Checks if the given text references a user on a valid Lemmy server.
/// If so, returns the username name in the format username@instance.tld.
/// Otherwise, returns null.
Future<String?> getLemmyUser(String text) async {
  final RegExpMatch? fullUsernameUrlMatch = fullUsernameUrl.firstMatch(text);
  if (fullUsernameUrlMatch != null && fullUsernameUrlMatch.groupCount >= 4 && await isLemmyInstance(fullUsernameUrlMatch.group(4))) {
    return '${fullUsernameUrlMatch.group(3)}@${fullUsernameUrlMatch.group(4)}';
  }

  final RegExpMatch? shortUsernameUrlMatch = shortUsernameUrl.firstMatch(text);
  if (shortUsernameUrlMatch != null && shortUsernameUrlMatch.groupCount >= 3 && await isLemmyInstance(shortUsernameUrlMatch.group(2))) {
    return '${shortUsernameUrlMatch.group(3)}@${shortUsernameUrlMatch.group(2)}';
  }

  final RegExpMatch? usernameMatch = username.firstMatch(text);
  if (usernameMatch != null && usernameMatch.groupCount >= 3 && await isLemmyInstance(usernameMatch.group(3))) {
    return '${usernameMatch.group(2)}@${usernameMatch.group(3)}';
  }

  return null;
}

Future<String?> getInstanceIcon(String? url) async {
  if (url?.isEmpty ?? true) {
    return null;
  }

  try {
    final site = await LemmyApiV3(url!).run(const GetSite()).timeout(const Duration(seconds: 5));
    return site.siteView?.site.icon;
  } catch (e) {
    // Bad instances will throw an exception, so no icon
    return null;
  }
}

final validInstances = HashSet<String>();

Future<bool> isLemmyInstance(String? url) async {
  if (url?.isEmpty ?? true) {
    return false;
  }

  if (validInstances.contains(url)) {
    return true;
  }

  try {
    await LemmyApiV3(url!).run(const GetSite());
    // If we get here, it worked
    validInstances.add(url);
    return true;
  } catch (e) {
    return false;
  }
}
