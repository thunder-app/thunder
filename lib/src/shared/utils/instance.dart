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
import 'package:thunder/src/shared/utils/link_utils.dart';

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

  final account = context.read<ProfileBloc>().state.account;
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
      return response['post']?.id;
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

  final account = context.read<ProfileBloc>().state.account;
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
      return response['comment']?.id;
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
  if (url?.isEmpty ?? true) {
    return ThunderInstanceInfo(
      domain: '',
      name: '',
      success: false,
    );
  }

  try {
    final platformInfo = await detectPlatformFromNodeInfo(url!);
    final platform = platformInfo?['platform'];

    // Create a temporary Account for the request
    final account = Account(instance: url, id: '', index: -1, platform: platform);

    final site = await InstanceRepositoryImpl(account: account).info().timeout(timeout ?? const Duration(seconds: 5));
    final instance = site.site;

    return ThunderInstanceInfo(
      id: id,
      domain: fetchInstanceNameFromUrl(instance.actorId)!,
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
    return ThunderInstanceInfo(
      domain: '',
      name: '',
      success: false,
    );
  }
}

/// Determines the proper ThreadiversePlatform by fetching software information from nodeinfo.
///
/// Given a URL, fetches the .well-known/nodeinfo endpoint and parses the JSON response
/// to determine the underlying software platform (lemmy, piefed, etc.).
///
/// Returns the detected ThreadiversePlatform or null if detection fails.
Future<Map<String, dynamic>?> detectPlatformFromNodeInfo(String url, {Duration? timeout}) async {
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
    final String? softwareVersion = nodeInfoData['software']?['version']?.toString();

    if (softwareName == null) return null;

    // Map software names to ThreadiversePlatform
    switch (softwareName) {
      case 'lemmy':
        return {'platform': ThreadiversePlatform.lemmy, 'version': softwareVersion};
      case 'piefed':
        return {'platform': ThreadiversePlatform.piefed, 'version': softwareVersion};
      default:
        return null;
    }
  } catch (e) {
    // Return null if any error occurs during detection
    return null;
  }
}
