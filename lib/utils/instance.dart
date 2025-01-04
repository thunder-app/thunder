import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/instances.dart';
import 'package:thunder/shared/pages/loading_page.dart';

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
  // Do an initial check for usernames in the format /u/user@instance.tld or @user@instance.tld.
  // These can accidentally trip our community name detection.
  if (text.toLowerCase().startsWith('/u/') || text.toLowerCase().startsWith('@')) {
    return null;
  }

  final RegExpMatch? fullCommunityUrlMatch = fullCommunityUrl.firstMatch(text);
  if (fullCommunityUrlMatch != null && fullCommunityUrlMatch.groupCount >= 4) {
    return '${fullCommunityUrlMatch.group(3)}@${fullCommunityUrlMatch.group(4)}';
  }

  final RegExpMatch? shortCommunityUrlMatch = shortCommunityUrl.firstMatch(text);
  if (shortCommunityUrlMatch != null && shortCommunityUrlMatch.groupCount >= 3) {
    return '${shortCommunityUrlMatch.group(3)}@${shortCommunityUrlMatch.group(2)}';
  }

  final RegExpMatch? instanceNameMatch = instanceName.firstMatch(text);
  if (instanceNameMatch != null && instanceNameMatch.groupCount >= 3) {
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
  // Do an initial check for communities in the format /c/community@instance.tld or !community@instance.tld.
  // These can accidentally trip our user name detection.
  if (text.toLowerCase().startsWith('/c/') || text.toLowerCase().startsWith('!')) {
    return null;
  }

  final RegExpMatch? fullUsernameUrlMatch = fullUsernameUrl.firstMatch(text);
  if (fullUsernameUrlMatch != null && fullUsernameUrlMatch.groupCount >= 4) {
    return '${fullUsernameUrlMatch.group(3)}@${fullUsernameUrlMatch.group(4)}';
  }

  final RegExpMatch? shortUsernameUrlMatch = shortUsernameUrl.firstMatch(text);
  if (shortUsernameUrlMatch != null && shortUsernameUrlMatch.groupCount >= 3) {
    return '${shortUsernameUrlMatch.group(3)}@${shortUsernameUrlMatch.group(2)}';
  }

  final RegExpMatch? usernameMatch = username.firstMatch(text);
  if (usernameMatch != null && usernameMatch.groupCount >= 3) {
    return '${usernameMatch.group(2)}@${usernameMatch.group(3)}';
  }

  return null;
}

final RegExp _post = RegExp(r'^(https?:\/\/)(.*)\/post\/([0-9]*).*$');
Future<int?> getLemmyPostId(BuildContext context, String text) async {
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
          // Show the loading page while we resolve the post
          showLoadingPage(context);

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
final RegExp _commentAlternate = RegExp(r'^(https?:\/\/)(.*)\/post\/([0-9]*)\/([0-9]*).*$');
Future<int?> getLemmyCommentId(BuildContext context, String text) async {
  LemmyApiV3 lemmy = LemmyClient.instance.lemmyApiV3;

  String? instance;
  int? commentId;

  // Try legacy comment link format
  RegExpMatch? commentMatch = _comment.firstMatch(text);
  if (commentMatch != null) {
    // It's a match!
    instance = commentMatch.group(2);
    commentId = int.tryParse(commentMatch.group(3)!);
  } else {
    // Otherwise, try the new format
    commentMatch = _commentAlternate.firstMatch(text);
    if (commentMatch != null) {
      // It's a match!
      instance = commentMatch.group(2);
      commentId = int.tryParse(commentMatch.group(4)!);
    }
  }

  if (commentId != null) {
    if (instance == lemmy.host) {
      return commentId;
    } else {
      // This is a comment on another instance. Try to resolve it
      try {
        // Show the loading page while we resolve the post
        showLoadingPage(context);

        final ResolveObjectResponse resolveObjectResponse = await lemmy.run(ResolveObject(q: text));
        return resolveObjectResponse.comment?.comment.id;
      } catch (e) {
        return null;
      }
    }
  }

  return null;
}

class GetInstanceInfoResponse {
  final bool success;
  final String? icon;
  final String? version;
  final String? name;
  final String? domain;
  final int? users;
  final int? id;
  final List<ProviderView>? oauthProviders;

  const GetInstanceInfoResponse({
    required this.success,
    this.icon,
    this.version,
    this.name,
    this.domain,
    this.users,
    this.id,
    this.oauthProviders,
  });

  bool isMetadataPopulated() => icon != null || version != null || name != null || users != null;
}

Future<GetInstanceInfoResponse> getInstanceInfo(String? url, {int? id, Duration? timeout}) async {
  if (url?.isEmpty ?? true) {
    return const GetInstanceInfoResponse(success: false);
  }

  try {
    final site = await LemmyApiV3(url!).run(const GetSite()).timeout(timeout ?? const Duration(seconds: 5));
    return GetInstanceInfoResponse(
      success: true,
      icon: site.siteView.site.icon,
      version: site.version,
      name: site.siteView.site.name,
      domain: fetchInstanceNameFromUrl(site.siteView.site.actorId),
      users: site.siteView.counts.users,
      id: id,
      oauthProviders: site.oauthProviders,
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
