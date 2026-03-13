import 'package:flutter/material.dart';

import 'package:thunder/src/foundation/primitives/primitives.dart';
import 'package:thunder/src/features/search/search.dart';
import 'package:thunder/src/features/session/api.dart';
import 'package:thunder/src/app/shell/navigation/loading_page.dart';
import 'package:thunder/src/foundation/utils/utils.dart';
import 'package:thunder/src/features/instance/data/services/instance_discovery_service.dart' as instance_discovery;

String? fetchInstanceNameFromUrl(String? url) {
  if (url == null) {
    return null;
  }

  final uri = Uri.parse(url);
  return uri.host;
}

/// Checks if the given text references a community on a valid Lemmy/PieFed server.
/// If so, returns the community name in the format community@instance.tld.
/// Otherwise, returns null.
Future<String?> getLemmyCommunity(String text) async {
  final result = parseCommunity(text);
  return result?.qualified;
}

/// Checks if the given text references a user on a valid Lemmy/PieFed server.
/// If so, returns the username in the format username@instance.tld.
/// Otherwise, returns null.
Future<String?> getLemmyUser(String text) async {
  final result = parseUser(text);
  return result?.qualified;
}

/// Gets the post ID from a Lemmy/PieFed URL.
/// If the URL is from a different instance, it will attempt to resolve it.
Future<int?> getLemmyPostId(BuildContext context, String text) async {
  final parsed = parsePostId(text);
  if (parsed == null) {
    return null;
  }

  final account = resolveEffectiveAccount(context);
  final postId = int.tryParse(parsed.value);

  if (postId == null) {
    return null;
  }

  if (parsed.instance == account.instance) {
    return postId;
  } else {
    // This is a post on another instance. Try to resolve it
    try {
      showLoadingPage(context);
      final response = await SearchRepositoryImpl(account: account).resolve(query: text);
      return response.post?.id;
    } catch (e) {
      return null;
    }
  }
}

/// Gets the comment ID from a Lemmy/PieFed URL.
/// If the URL is from a different instance, it will attempt to resolve it.
Future<int?> getLemmyCommentId(BuildContext context, String text) async {
  final parsed = parseCommentId(text);
  if (parsed == null) {
    return null;
  }

  final account = resolveEffectiveAccount(context);
  final commentId = int.tryParse(parsed.value);

  if (commentId == null) {
    return null;
  }

  if (parsed.instance == account.instance) {
    return commentId;
  } else {
    // This is a comment on another instance. Try to resolve it
    try {
      showLoadingPage(context);
      final response = await SearchRepositoryImpl(account: account).resolve(query: text);
      return response.comment?.id;
    } catch (e) {
      return null;
    }
  }
}

/// Fetches the instance info for a given URL.
///
/// This includes the instance name, version, icon, and user count.
/// If the URL is invalid or the instance is unreachable, it returns a default [ThunderInstanceInfo] with success set to false.
Future<ThunderInstanceInfo> getInstanceInfo(String? url, {int? id, Duration? timeout}) async {
  return instance_discovery.getInstanceInfo(url, id: id, timeout: timeout);
}

/// Determines the proper ThreadiversePlatform by fetching software information from nodeinfo.
///
/// Given a URL, fetches the .well-known/nodeinfo endpoint and parses the JSON response
/// to determine the underlying software platform (lemmy, piefed, etc.).
///
/// Returns the detected ThreadiversePlatform or null if detection fails.
Future<Map<String, dynamic>?> detectPlatformFromNodeInfo(String url, {Duration? timeout}) async {
  return instance_discovery.detectPlatformFromNodeInfo(url, timeout: timeout);
}
