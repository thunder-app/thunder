import 'package:flutter/material.dart';

import 'package:thunder/src/core/domain/domain.dart';
import 'package:thunder/src/core/navigation/external_link_navigation.dart';
import 'package:thunder/src/core/navigation/navigation_utils.dart';
import 'package:thunder/src/core/navigation/loading_page.dart';
import 'package:thunder/src/shared/media/media_utils.dart';
import 'package:thunder/src/features/feed/api.dart';
import 'package:thunder/src/features/instance/data/constants/known_instances.dart';
import 'package:thunder/src/features/instance/domain/utils/instance_link_utils.dart';
import 'package:thunder/src/features/session/api.dart';
import 'package:thunder/src/core/app/repository_factories.dart';

export 'external_link_navigation.dart' show handleVideoLink, navigateToWebView;
export 'threadiverse_link_navigation.dart' show testValidCommunity, testValidUser;

/// A universal way of handling links in Thunder.
/// Attempts to perform in-app navigtion to communities, users, posts, and comments
/// Before falling back to opening in the browser (either Custom Tabs or system browser, as specified by the user).
void handleLink(BuildContext context, {required String url, bool forceOpenInBrowser = false}) async {
  final account = resolveEffectiveAccount(context);

  // Try navigating to community
  String? communityName = await getLemmyCommunity(url);
  if (communityName != null && (!context.mounted || await testValidCommunity(context, url, communityName, communityName.split('@')[1]))) {
    try {
      if (context.mounted) {
        await navigateToFeedPage(context, feedType: FeedType.community, communityName: communityName);
        return;
      }
    } catch (e) {
      // Ignore exception, if it's not a valid community we'll perform the next fallback
    }
  }

  // Try navigating to user
  String? username = await getLemmyUser(url);
  if (username != null && (!context.mounted || await testValidUser(context, url, username, username.split('@')[1]))) {
    try {
      if (context.mounted) {
        await navigateToFeedPage(context, feedType: FeedType.user, username: username);
        return;
      }
    } catch (e) {
      // Ignore exception, if it's not a valid user, we'll perform the next fallback
    }
  }

  // Try navigating to post
  int? postId = await getLemmyPostId(context, checkEmbeddedInstance(url));
  if (postId != null) {
    try {
      // Show the loading page while we fetch the post
      if (context.mounted) showLoadingPage(context);
      final post = await createPostRepository(account).getPost(postId);

      if (context.mounted) {
        navigateToPost(context, post: post?.post);
        return;
      }
    } catch (e) {
      // Ignore exception, if it's not a valid post, we'll perform the next fallback
    }
  }

  // Try navigating to comment
  int? commentId = await getLemmyCommentId(context, url);
  if (commentId != null) {
    try {
      // Show the loading page while we fetch the comment
      if (context.mounted) showLoadingPage(context);
      final comment = await createCommentRepository(account).getComment(commentId);

      if (context.mounted) {
        navigateToComment(context, comment);
        return;
      }
    } catch (e) {
      // Ignore exception, if it's not a valid comment, we'll perform the next fallback
    }
  }

  // Try navigate to modlog
  Uri? uri = Uri.tryParse(url);
  if (context.mounted && uri != null && knownInstances.keys.contains(uri.host) && url.contains('/modlog')) {
    try {
      await navigateToModlogPage(
        context,
        modlogActionType: ModlogActionType.values.firstWhere(
          (type) => type.name.toLowerCase() == uri.queryParameters['actionType']?.toLowerCase(),
          orElse: () => ModlogActionType.all,
        ),
        communityId: int.tryParse(uri.queryParameters['communityId'] ?? ''),
        userId: int.tryParse(uri.queryParameters['userId'] ?? ''),
        moderatorId: int.tryParse(uri.queryParameters['modId'] ?? ''),
        subtitle: uri.host,
      );
      return;
    } catch (e) {
      // Ignore exception, if it's not a valid modlog link, we'll perform the next fallback
    }
  }

  // Try opening it as an image
  try {
    if (isImageUrl(url) && context.mounted) {
      showImageViewer(context, url: url);
      return;
    }
  } catch (e) {
    // Ignore the exception and fall back.
  }

  // try opening as a video
  try {
    if (isVideoUrl(url) && context.mounted && !forceOpenInBrowser) {
      showThunderVideoPlayer(context, url: url, postId: postId);
      return;
    }
  } catch (e) {
    debugPrint(e.toString());
  }

  // Try to see if it's an internal link
  if (url.startsWith('thunder://')) {
    String link = url;
    link = link.replaceFirst('thunder://', '');

    if (link.startsWith('setting-')) {
      String setting = link.replaceFirst('setting-', '');
      navigateToSettingPage(context, LocalSettings.values.firstWhere((localSetting) => localSetting.name == setting));
      return;
    }
  }

  // Fallback: open link in browser
  if (context.mounted) {
    openExternalLink(context, url: url);
  }
}

/// This is a helper method which helps [handleLink] determine whether a link refers to a valid Lemmy community.
/// If the passed in link is not a valid URI, then there's no point in doing any fallback, so assume it passes.
/// If the passed in [instance] is a known Lemmy instance, then it passes.
/// If we can retrieve the passed in object, then it passes.
/// Otherwise it fails.
Future<bool> testValidCommunity(BuildContext context, String link, String communityName, String instance) async {
  Uri? uri = Uri.tryParse(link);
  if (uri == null || !uri.hasScheme) {
    return true;
  }

  if (knownInstances.keys.contains(instance)) {
    return true;
  }

  try {
    // Since this may take a while, show a loading page.
    showLoadingPage(context);

    final account = resolveEffectiveAccount(context);
    await createCommunityRepository(account).getCommunity(name: communityName);
    return true;
  } catch (e) {
    // Ignore and return false below.
  }

  return false;
}

/// This is a helper method which helps [handleLink] determine whether a link refers to a valid Lemmy user.
/// If the passed in link is not a valid URI, then there's no point in doing any fallback, so assume it passes.
/// If the passed in [instance] is a known Lemmy instance, then it passes.
/// If we can retrieve the passed in object, then it passes.
/// Otherwise it fails.
Future<bool> testValidUser(BuildContext context, String link, String userName, String instance) async {
  Uri? uri = Uri.tryParse(link);
  if (uri == null || !uri.hasScheme) {
    return true;
  }

  if (knownInstances.keys.contains(instance)) {
    return true;
  }

  try {
    // Since this may take a while, show a loading page.
    showLoadingPage(context);

    final account = resolveEffectiveAccount(context);
    await createUserRepository(account).getUser(username: userName);
    return true;
  } catch (e) {
    // Ignore and return false below.
  }

  return false;
}

Future<void> handleLinkTap(BuildContext context, String text, String? url) async {
  Uri? parsedUri = Uri.tryParse(url ?? '') ?? Uri.tryParse(text);

  String parsedUrl = text;

  if (parsedUri != null && parsedUri.host.isNotEmpty) {
    parsedUrl = parsedUri.toString();
  } else {
    parsedUrl = url ?? '';
  }

  // The markdown link processor treats URLs with @ as emails and prepends "mailto:".
  // If the URL contains that, but the text doesn't, we can remove it.
  if (parsedUrl.startsWith('mailto:') && !text.startsWith('mailto:')) {
    parsedUrl = parsedUrl.replaceFirst('mailto:', '');
  }

  if (context.mounted) {
    handleLink(context, url: parsedUrl);
  }
}
