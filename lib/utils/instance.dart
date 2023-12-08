import 'dart:collection';

import 'package:lemmy_api_client/v3.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/instances.dart';

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

final RegExp _post = RegExp(r'^(https?:\/\/)(.*)\/post\/([0-9]*).*$');
Future<int?> getLemmyPostId(String text) async {
  LemmyApiV3 lemmy = LemmyClient.instance.lemmyApiV3;

  final RegExpMatch? postMatch = _post.firstMatch(text);
  if (postMatch != null) {
    final String? instance = postMatch.group(2);
    final int? postId = int.tryParse(postMatch.group(3)!);
    if (postId != null) {
      if (instance == lemmy.host) {
        return postId;
      } else {
        // This is a post on another instance. Try to resolve it
        try {
          final ResolveObjectResponse resolveObjectResponse = await lemmy.run(ResolveObject(q: text));
          return resolveObjectResponse.post?.post.id;
        } catch (e) {
          return null;
        }
      }
    }
  }

  return null;
}

final RegExp _comment = RegExp(r'^(https?:\/\/)(.*)\/comment\/([0-9]*).*$');
Future<int?> getLemmyCommentId(String text) async {
  LemmyApiV3 lemmy = LemmyClient.instance.lemmyApiV3;

  final RegExpMatch? commentMatch = _comment.firstMatch(text);
  if (commentMatch != null) {
    final String? instance = commentMatch.group(2);
    final int? commentId = int.tryParse(commentMatch.group(3)!);
    if (commentId != null) {
      if (instance == lemmy.host) {
        return commentId;
      } else {
        // This is a comment on another instance. Try to resolve it
        try {
          final ResolveObjectResponse resolveObjectResponse = await lemmy.run(ResolveObject(q: text));
          return resolveObjectResponse.comment?.comment.id;
        } catch (e) {
          return null;
        }
      }
    }
  }

  return null;
}

class GetInstanceInfoResponse {
  final bool success;
  final String? icon;
  final String? version;

  const GetInstanceInfoResponse({required this.success, this.icon, this.version});
}

Future<GetInstanceInfoResponse> getInstanceInfo(String? url) async {
  if (url?.isEmpty ?? true) {
    return const GetInstanceInfoResponse(success: false);
  }

  try {
    final site = await LemmyApiV3(url!).run(const GetSite()).timeout(const Duration(seconds: 5));
    return GetInstanceInfoResponse(
      success: true,
      icon: site.siteView.site.icon,
      version: site.version,
    );
  } catch (e) {
    // Bad instances will throw an exception, so no icon
    return const GetInstanceInfoResponse(success: false);
  }
}

final validInstances = HashSet<String>();

Future<bool> isLemmyInstance(String? url) async {
  if (url?.isEmpty ?? true) {
    return false;
  }

  if (instances.contains(url)) {
    return true;
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
