import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import 'package:thunder/src/core/domain/domain.dart';
import 'package:thunder/src/core/navigation/loading_page.dart';
import 'package:thunder/src/core/navigation/swipeable_page_route.dart';
import 'package:thunder/src/core/state/thunder_bloc.dart';
import 'package:thunder/src/features/settings/api.dart';
import 'package:thunder/src/shared/media/media_utils.dart';
import 'package:thunder/src/shared/media/thunder_video_player.dart';
import 'package:thunder/src/shared/media/thunder_youtube_player.dart';
import 'package:thunder/src/shared/webview/webview.dart';

void openExternalLink(BuildContext context, {required String url, bool isVideo = false}) async {
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
        browser: const CustomTabsBrowserConfiguration(prefersDefaultBrowser: true),
        colorSchemes: CustomTabsColorSchemes(defaultPrams: CustomTabsColorSchemeParams(toolbarColor: Theme.of(context).canvasColor)),
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

void showThunderVideoPlayer(BuildContext context, {required String url, int? postId}) {
  final videoId = YoutubePlayerController.convertUrlToId(url);
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
      openExternalLink(context, url: url, isVideo: true);
      break;
    case VideoPlayerMode.customTabs:
      openExternalLink(context, url: url, isVideo: true);
      break;
  }
}

/// A universal way of handling video links by opening them in the browser/external player
void handleVideoLink(BuildContext context, {required String url}) async {
  openExternalLink(context, url: url, isVideo: isVideoUrl(url));
}

/// Navigates to the given [url] in a webview.
void navigateToWebView(BuildContext context, String url) {
  final gestureCubit = context.read<GesturePreferencesCubit>();
  final themeCubit = context.read<ThemePreferencesCubit>();
  final reduceAnimations = themeCubit.state.reduceAnimations;
  final enableFullScreenSwipeNavigationGesture = gestureCubit.state.enableFullScreenSwipeNavigationGesture;

  SwipeablePageRoute route = SwipeablePageRoute(
    transitionDuration: isLoadingPageShown
        ? Duration.zero
        : reduceAnimations
        ? const Duration(milliseconds: 100)
        : null,
    reverseTransitionDuration: reduceAnimations ? const Duration(milliseconds: 100) : const Duration(milliseconds: 500),
    canSwipe: !kIsWeb && Platform.isIOS || enableFullScreenSwipeNavigationGesture,
    canOnlySwipeFromEdge: true,
    builder: (context) => WebView(url: url),
  );

  pushOnTopOfLoadingPage(context, route);
}
