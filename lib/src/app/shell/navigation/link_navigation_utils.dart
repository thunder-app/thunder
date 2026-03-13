import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:intl/message_format.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';

import 'package:thunder/src/features/community/api.dart';
import 'package:thunder/src/features/comment/api.dart';
import 'package:thunder/src/features/post/api.dart';
import 'package:thunder/src/foundation/primitives/primitives.dart';
import 'package:thunder/src/app/shell/navigation/navigation_utils.dart';
import 'package:thunder/src/app/shell/navigation/loading_page.dart';
import 'package:thunder/src/shared/content/utils/media/media_utils.dart';
import 'package:thunder/src/app/state/thunder/thunder_bloc.dart';
import 'package:thunder/src/features/settings/api.dart';
import 'package:thunder/src/features/feed/api.dart';
import 'package:thunder/src/features/instance/data/constants/known_instances.dart';
import 'package:thunder/src/features/instance/domain/utils/instance_link_utils.dart';
import 'package:thunder/src/features/session/api.dart';
import 'package:thunder/src/shared/media/widgets/video_player.dart';
import 'package:thunder/src/features/user/api.dart';

void _openLink(BuildContext context, {required String url, bool isVideo = false}) async {
  final thunderPreferences = context.read<ThunderCubit>().state;
  final browserMode = thunderPreferences.browserMode;
  final openInReaderMode = thunderPreferences.openInReaderMode;

  final videoPlayerMode = context.read<VideoPreferencesCubit>().state.videoPlayerMode;

  bool launchInExternalApp = false;
  bool launchInCustomTab = false;

  if (isVideo && videoPlayerMode == VideoPlayerMode.externalPlayer) {
    launchInExternalApp = true;
  } else if (!isVideo && browserMode == BrowserMode.external) {
    launchInExternalApp = true;
  }

  if (isVideo && videoPlayerMode == VideoPlayerMode.customTabs) {
    launchInCustomTab = true;
  } else if (!isVideo && browserMode == BrowserMode.customTabs) {
    launchInCustomTab = true;
  }

  if (launchInExternalApp || (!kIsWeb && !Platform.isAndroid && !Platform.isIOS)) {
    hideLoadingPage(context, delay: true);
    url_launcher.launchUrl(Uri.parse(url), mode: url_launcher.LaunchMode.externalApplication);
  } else if (launchInCustomTab) {
    // Launches the link within a custom tab
    hideLoadingPage(context, delay: true);

    launchUrl(
      Uri.parse(url),
      customTabsOptions: CustomTabsOptions(
        browser: const CustomTabsBrowserConfiguration(
          prefersDefaultBrowser: true,
        ),
        colorSchemes: CustomTabsColorSchemes(
          defaultPrams: CustomTabsColorSchemeParams(
            toolbarColor: Theme.of(context).canvasColor,
          ),
        ),
        shareState: CustomTabsShareState.browserDefault,
        urlBarHidingEnabled: true,
        showTitle: true,
        instantAppsEnabled: true,
      ),
      safariVCOptions: SafariViewControllerOptions(
        preferredBarTintColor: Theme.of(context).canvasColor,
        preferredControlTintColor: Theme.of(context).textTheme.titleLarge?.color ?? Theme.of(context).primaryColor,
        barCollapsingEnabled: true,
        entersReaderIfAvailable: openInReaderMode,
      ),
    );
  } else if (browserMode == BrowserMode.inApp) {
    // Launches the link within the in-app browser if possible
    // Check if the scheme is not https, in which case the in-app browser can't handle it
    Uri? uri = Uri.tryParse(url);

    if (uri != null && uri.scheme != 'https') {
      // Although a non-https scheme is an indication that this link is intended for another app,
      // we actually have to change it back to https in order for the intent to be properly passed to another app.
      hideLoadingPage(context, delay: true);
      url_launcher.launchUrl(uri, mode: url_launcher.LaunchMode.externalApplication);
    } else {
      navigateToWebView(context, url);
    }
  }
}

void _showVideoPlayer(BuildContext context, {required String url, int? postId}) {
  final videoId = YoutubePlayer.convertUrlToId(url);
  final videoPlayerMode = context.read<VideoPreferencesCubit>().state.videoPlayerMode;

  switch (videoPlayerMode) {
    case VideoPlayerMode.inApp:
      Navigator.of(context).push(
        PageRouteBuilder(
          opaque: false,
          transitionDuration: const Duration(milliseconds: 100),
          reverseTransitionDuration: const Duration(milliseconds: 50),
          pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
            return (videoId != null) ? ThunderYoutubePlayer(videoUrl: url, postId: postId) : ThunderVideoPlayer(videoUrl: url, postId: postId);
          },
          transitionsBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
            return Align(
              child: FadeTransition(opacity: animation, child: child),
            );
          },
        ),
      );
      break;
    case VideoPlayerMode.externalPlayer:
      _openLink(context, url: url, isVideo: true);
      break;
    case VideoPlayerMode.customTabs:
      _openLink(context, url: url, isVideo: true);
      break;
  }
}

/// A universal way of handling links in Thunder.
/// Attempts to perform in-app navigtion to communities, users, posts, and comments
/// Before falling back to opening in the browser (either Custom Tabs or system browser, as specified by the user).
void handleLink(BuildContext context, {required String url, bool forceOpenInBrowser = false}) async {
  final account = resolveEffectiveAccount(context);

  // Try navigating to community
  String? communityName = await getLemmyCommunity(url);
  if (communityName != null && (!context.mounted || await _testValidCommunity(context, url, communityName, communityName.split('@')[1]))) {
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
  if (username != null && (!context.mounted || await _testValidUser(context, url, username, username.split('@')[1]))) {
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
  int? postId = await getLemmyPostId(context, url);
  if (postId != null) {
    try {
      // Show the loading page while we fetch the post
      if (context.mounted) showLoadingPage(context);
      final post = await PostRepositoryImpl(account: account).getPost(postId);

      if (context.mounted) {
        navigateToPost(context, post: post?['post']);
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
      final comment = await CommentRepositoryImpl(account: account).getComment(commentId);

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
      _showVideoPlayer(context, url: url, postId: postId);
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
    _openLink(context, url: url);
  }
}

/// A universal way of handling video links by opening them in the browser/external player
void handleVideoLink(BuildContext context, {required String url}) async {
  _openLink(context, url: url, isVideo: isVideoUrl(url));
}

/// This is a helper method which helps [handleLink] determine whether a link refers to a valid Lemmy community.
/// If the passed in link is not a valid URI, then there's no point in doing any fallback, so assume it passes.
/// If the passed in [instance] is a known Lemmy instance, then it passes.
/// If we can retrieve the passed in object, then it passes.
/// Otherwise it fails.
Future<bool> _testValidCommunity(BuildContext context, String link, String communityName, String instance) async {
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
    await CommunityRepositoryImpl(account: account).getCommunity(name: communityName);
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
Future<bool> _testValidUser(BuildContext context, String link, String userName, String instance) async {
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
    await UserRepositoryImpl(account: account).getUser(username: userName);
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

List<({String sourceName, String link})> generateAlternateSources(String link) {
  return _alternateSources.map((alternateSource) {
    return (sourceName: alternateSource.sourceName, link: alternateSource.template.format({'link': link}));
  }).toList();
}

List<({String sourceName, MessageFormat template})> _alternateSources = [
  (sourceName: 'Internet Archive', template: MessageFormat('https://web.archive.org/save/{link}')),
  (sourceName: 'Ground News', template: MessageFormat('https://ground.news/find?url={link}')),
];

/// Determines if a given URL is valid. The URL must have the 'http' or 'https' scheme.
bool isValidUrl(String url) {
  final uri = Uri.tryParse(url);
  return uri != null && uri.hasAbsolutePath && uri.scheme.startsWith('http');
}
