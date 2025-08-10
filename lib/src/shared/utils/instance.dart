import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/core/enums/threadiverse_platform.dart';
import 'package:thunder/src/core/models/models.dart';
import 'package:thunder/src/features/instance/instance.dart';
import 'package:thunder/src/features/search/search.dart';
import 'package:thunder/src/shared/pages/loading_page.dart';

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
  final account = context.read<ProfileBloc>().state.account;

  final RegExpMatch? postMatch = _post.firstMatch(text);
  if (postMatch != null) {
    final String? instance = postMatch.group(2);
    final int? postId = int.tryParse(postMatch.group(3)!);
    if (postId != null) {
      if (instance == account.instance) {
        return postId;
      } else {
        // This is a post on another instance. Try to resolve it
        try {
          // Show the loading page while we resolve the post
          showLoadingPage(context);

          final response = await SearchRepositoryImpl(account: account).resolve(query: text);
          return response.post?.post.id;
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
  String? instance;
  int? commentId;

  final account = context.read<ProfileBloc>().state.account;

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
    if (instance == account.instance) {
      return commentId;
    } else {
      // This is a comment on another instance. Try to resolve it
      try {
        // Show the loading page while we resolve the post
        showLoadingPage(context);

        final response = await SearchRepositoryImpl(account: account).resolve(query: text);
        return response.comment?.comment.id;
      } catch (e) {
        return null;
      }
    }
  }

  return null;
}

/// Fetches the instance info for a given URL.
///
/// This includes the instance name, version, icon, and user count.
/// If the URL is invalid or the instance is unreachable, it returns a default [ThunderInstanceInfo] with success set to false.
Future<ThunderInstanceInfo> getInstanceInfo(String? url, {int? id, Duration? timeout}) async {
  if (url?.isEmpty ?? true) return const ThunderInstanceInfo(success: false);

  try {
    final platform = await detectPlatformFromNodeInfo(url!);
    if (platform == null) return const ThunderInstanceInfo(success: false);

    // Create a temporary Account for the request
    final account = Account(instance: url, id: '', index: -1, platform: platform);

    final site = await InstanceRepositoryImpl(account: account).getSiteInfo().timeout(timeout ?? const Duration(seconds: 5));
    final instance = site.site;

    return ThunderInstanceInfo(
      id: id,
      domain: fetchInstanceNameFromUrl(instance.actorId),
      version: site.version,
      name: instance.name,
      icon: instance.icon,
      users: instance.users,
      success: true,
      platform: platform,
      contentWarning: site.site.contentWarning,
    );
  } catch (e) {
    debugPrint('Error getting instance info: $e');
    // Bad instances will throw an exception, so no icon
    return const ThunderInstanceInfo(success: false);
  }
}

/// Determines the proper ThreadiversePlatform by fetching software information from nodeinfo.
///
/// Given a URL, fetches the .well-known/nodeinfo endpoint and parses the JSON response
/// to determine the underlying software platform (lemmy, piefed, etc.).
///
/// Returns the detected ThreadiversePlatform or null if detection fails.
Future<ThreadiversePlatform?> detectPlatformFromNodeInfo(String url, {Duration? timeout}) async {
  if (url.isEmpty) return null;

  try {
    // Ensure the URL has proper protocol
    Uri uri;
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      uri = Uri.parse('https://$url');
    } else {
      uri = Uri.parse(url);
    }

    // Construct the nodeinfo URL
    final nodeInfoUri = Uri(
      scheme: uri.scheme,
      host: uri.host,
      port: uri.port,
      path: '/.well-known/nodeinfo',
    );

    // Fetch the nodeinfo response
    final response = await http.get(nodeInfoUri).timeout(timeout ?? const Duration(seconds: 5));

    if (response.statusCode != 200) {
      return null;
    }

    // Parse the JSON response
    final Map<String, dynamic> nodeInfo = json.decode(response.body);

    // Extract the nodeinfo link from the well-known response
    String? nodeInfoUrl;
    if (nodeInfo['links'] != null && nodeInfo['links'].isNotEmpty) {
      // Look for a nodeinfo schema link (prefer 2.0 or 2.1)
      for (final link in nodeInfo['links']) {
        final rel = link['rel']?.toString();
        if (rel != null && rel.contains('nodeinfo.diaspora.software/ns/schema/')) {
          nodeInfoUrl = link['href']?.toString();
          break;
        }
      }
    }

    if (nodeInfoUrl == null) return null;

    // Fetch the actual nodeinfo document
    final nodeInfoResponse = await http.get(Uri.parse(nodeInfoUrl)).timeout(timeout ?? const Duration(seconds: 5));

    if (nodeInfoResponse.statusCode != 200) {
      return null;
    }

    final Map<String, dynamic> nodeInfoData = json.decode(nodeInfoResponse.body);
    final String? softwareName = nodeInfoData['software']?['name']?.toString().toLowerCase();

    if (softwareName == null) return null;

    // Map software names to ThreadiversePlatform
    switch (softwareName) {
      case 'lemmy':
        return ThreadiversePlatform.lemmy;
      case 'piefed':
        return ThreadiversePlatform.piefed;
      default:
        return null;
    }
  } catch (e) {
    // Return null if any error occurs during detection
    return null;
  }
}
