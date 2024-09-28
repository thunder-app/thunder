import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/message_format.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:link_preview_generator/link_preview_generator.dart';
import 'package:share_plus/share_plus.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import 'package:thunder/core/enums/browser_mode.dart';
import 'package:thunder/core/enums/video_player_mode.dart';
import 'package:thunder/feed/bloc/feed_bloc.dart';
import 'package:thunder/instances.dart';
import 'package:thunder/modlog/utils/navigate_modlog.dart';
import 'package:thunder/shared/pages/loading_page.dart';
import 'package:thunder/shared/picker_item.dart';
import 'package:thunder/shared/webview.dart';
import 'package:thunder/utils/media/image.dart';
import 'package:thunder/utils/media/video.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/account/models/account.dart';
import 'package:thunder/core/auth/helpers/fetch_account.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/feed/utils/utils.dart';
import 'package:thunder/feed/view/feed_page.dart';
import 'package:thunder/post/utils/post.dart';
import 'package:thunder/utils/instance.dart';
import 'package:thunder/comment/utils/navigate_comment.dart';
import 'package:thunder/post/utils/navigate_post.dart';

class LinkInfo {
  String? imageURL;
  String? title;

  LinkInfo({this.imageURL, this.title});
}

Future<LinkInfo> getLinkInfo(String url) async {
  try {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final document = parser.parse(response.body);
      final metatags = document.getElementsByTagName('meta');

      String imageURL = '';
      String title = '';

      for (final metatag in metatags) {
        final property = metatag.attributes['property'];
        final content = metatag.attributes['content'];

        if (property == 'og:image') {
          imageURL = content ?? '';
        } else if (property == 'og:title') {
          title = content ?? '';
        }
      }

      return LinkInfo(imageURL: imageURL, title: title);
    } else {
      throw Exception('Unable to fetch link information');
    }
  } catch (e) {
    return LinkInfo();
  }
}

void _openLink(BuildContext context, {required String url, bool isVideo = false}) async {
  ThunderState state = context.read<ThunderBloc>().state;
  if ((isVideo && state.videoPlayerMode == VideoPlayerMode.externalPlayer) || (!kIsWeb && !Platform.isAndroid && !Platform.isIOS)) {
    hideLoadingPage(context, delay: true);
    url_launcher.launchUrl(Uri.parse(url), mode: url_launcher.LaunchMode.externalApplication);
  } else if ((state.browserMode == BrowserMode.external && !isVideo) || (!kIsWeb && !Platform.isAndroid && !Platform.isIOS)) {
    hideLoadingPage(context, delay: true);
    url_launcher.launchUrl(Uri.parse(url), mode: url_launcher.LaunchMode.externalApplication);
  } else if ((isVideo && state.videoPlayerMode == VideoPlayerMode.customTabs) || (state.browserMode == BrowserMode.customTabs)) {
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
        entersReaderIfAvailable: state.openInReaderMode,
      ),
    );
  } else if (state.browserMode == BrowserMode.inApp) {
    // Check if the scheme is not https, in which case the in-app browser can't handle it
    Uri? uri = Uri.tryParse(url);
    if (uri != null && uri.scheme != 'https') {
      // Although a non-https scheme is an indication that this link is intended for another app,
      // we actually have to change it back to https in order for the intent to be properly passed to another app.
      hideLoadingPage(context, delay: true);
      url_launcher.launchUrl(uri, mode: url_launcher.LaunchMode.externalApplication);
    } else {
      final bool reduceAnimations = state.reduceAnimations;

      SwipeablePageRoute route = SwipeablePageRoute(
        transitionDuration: isLoadingPageShown
            ? Duration.zero
            : reduceAnimations
                ? const Duration(milliseconds: 100)
                : null,
        reverseTransitionDuration: reduceAnimations ? const Duration(milliseconds: 100) : const Duration(milliseconds: 500),
        backGestureDetectionWidth: 45,
        canOnlySwipeFromEdge: true,
        builder: (context) => WebView(url: url),
      );

      pushOnTopOfLoadingPage(context, route);
    }
  }
}

/// A universal way of handling links in Thunder.
/// Attempts to perform in-app navigtion to communities, users, posts, and comments
/// Before falling back to opening in the browser (either Custom Tabs or system browser, as specified by the user).
void handleLink(BuildContext context, {required String url, bool forceOpenInBrowser = false}) async {
  LemmyApiV3 lemmy = LemmyClient.instance.lemmyApiV3;
  Account? account = await fetchActiveProfileAccount();

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

      GetPostResponse post = await lemmy.run(GetPost(
        id: postId,
        auth: account?.jwt,
      ));

      if (context.mounted) {
        navigateToPost(context, postViewMedia: (await parsePostViews([post.postView])).first);
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

      CommentResponse fullCommentView = await lemmy.run(GetComment(
        id: commentId,
        auth: account?.jwt,
      ));

      if (context.mounted) {
        navigateToComment(context, fullCommentView.commentView);
        return;
      }
    } catch (e) {
      // Ignore exception, if it's not a valid comment, we'll perform the next fallback
    }
  }

  // Try navigate to modlog
  Uri? uri = Uri.tryParse(url);
  if (context.mounted && uri != null && instances.contains(uri.host) && url.contains('/modlog')) {
    try {
      final LemmyClient lemmyClient = LemmyClient()..changeBaseUrl(uri.host);
      FeedBloc feedBloc = FeedBloc(lemmyClient: lemmyClient);
      await navigateToModlogPage(
        context,
        feedBloc: feedBloc,
        modlogActionType: ModlogActionType.fromJson(uri.queryParameters['actionType'] ?? ModlogActionType.all.value),
        communityId: int.tryParse(uri.queryParameters['communityId'] ?? ''),
        userId: int.tryParse(uri.queryParameters['userId'] ?? ''),
        moderatorId: int.tryParse(uri.queryParameters['modId'] ?? ''),
        lemmyClient: lemmyClient,
      );
      return;
    } catch (e) {}
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
      showVideoPlayer(context, url: url, postId: postId);
      return;
    }
  } catch (e) {
    debugPrint(e.toString());
  }

  // Fallback: open link in browser
  if (context.mounted) {
    _openLink(context, url: url);
  }
}

/// A universal way of handling links by opening them in the browser
/// (either Custom Tabs or system browser, as specified by the user).

void openLinkInBrowser(BuildContext context, {required String url}) async {
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

  if (instances.contains(instance)) {
    return true;
  }

  try {
    // Since this may take a while, show a loading page.
    showLoadingPage(context);

    Account? account = await fetchActiveProfileAccount();
    await LemmyClient.instance.lemmyApiV3.run(GetCommunity(name: communityName, auth: account?.jwt));
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

  if (instances.contains(instance)) {
    return true;
  }

  try {
    // Since this may take a while, show a loading page.
    showLoadingPage(context);

    Account? account = await fetchActiveProfileAccount();
    await LemmyClient.instance.lemmyApiV3.run(GetPersonDetails(username: userName, auth: account?.jwt));
    return true;
  } catch (e) {
    // Ignore and return false below.
  }

  return false;
}

void handleLinkLongPress(BuildContext context, String text, String? url, {LinkBottomSheetPage initialPage = LinkBottomSheetPage.general, void Function(String)? customNavigation}) {
  HapticFeedback.mediumImpact();
  showModalBottomSheet(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (ctx) => LinkBottomSheet(
      text: text,
      url: url,
      initialPage: initialPage,
      customNavigation: customNavigation,
    ),
  );
}

enum LinkBottomSheetPage {
  general,
  alternateLinks,
}

class LinkBottomSheet extends StatefulWidget {
  final String? url;
  final String text;
  final LinkBottomSheetPage initialPage;
  final void Function(String)? customNavigation;

  const LinkBottomSheet({
    super.key,
    required this.text,
    required this.url,
    this.initialPage = LinkBottomSheetPage.general,
    this.customNavigation,
  });

  @override
  State<LinkBottomSheet> createState() => _LinkBottomSheetState();
}

class _LinkBottomSheetState extends State<LinkBottomSheet> {
  LinkBottomSheetPage? page;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final ThunderState thunderState = context.read<ThunderBloc>().state;

    bool isValidUrl = widget.url?.startsWith('http') ?? false;

    return SingleChildScrollView(
      child: AnimatedSize(
        duration: const Duration(milliseconds: 250),
        alignment: Alignment.bottomCenter,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: Material(
                  borderRadius: BorderRadius.circular(50),
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(50),
                    onTap: (page ?? widget.initialPage) == LinkBottomSheetPage.general ? null : () => setState(() => page = LinkBottomSheetPage.general),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: [
                            if ((page ?? widget.initialPage) != LinkBottomSheetPage.general) ...[
                              const Icon(Icons.chevron_left, size: 30),
                              const SizedBox(width: 12),
                            ],
                            Text(
                              switch (page ?? widget.initialPage) {
                                LinkBottomSheetPage.alternateLinks => l10n.alternateSources,
                                _ => l10n.linkActions,
                              },
                              style: theme.textTheme.titleLarge,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              if (isValidUrl && (page ?? widget.initialPage) == LinkBottomSheetPage.general) ...[
                Padding(
                  padding: const EdgeInsets.only(left: 24, right: 24),
                  child: LinkPreviewGenerator(
                    link: widget.url!,
                    placeholderWidget: const CircularProgressIndicator(),
                    linkPreviewStyle: LinkPreviewStyle.large,
                    cacheDuration: Duration.zero,
                    onTap: null,
                    bodyTextOverflow: TextOverflow.fade,
                    graphicFit: BoxFit.scaleDown,
                    removeElevation: true,
                    backgroundColor: theme.dividerColor.withOpacity(0.25),
                    borderRadius: 10,
                    useDefaultOnTap: false,
                  ),
                ),
                const SizedBox(height: 10),
              ],
              Padding(
                padding: const EdgeInsets.only(left: 24, right: 24),
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.dividerColor.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(5),
                    child: Text(widget.url!),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              if ((page ?? widget.initialPage) == LinkBottomSheetPage.general) ...[
                PickerItem(
                  label: l10n.open,
                  icon: Icons.language,
                  onSelected: () => handleLinkTap(context, thunderState, widget.text, widget.url),
                ),
                PickerItem(
                  label: l10n.copy,
                  icon: Icons.copy_rounded,
                  onSelected: () => Clipboard.setData(ClipboardData(text: widget.url ?? widget.text)),
                ),
                PickerItem(
                  label: l10n.share,
                  icon: Icons.share_rounded,
                  onSelected: () => Share.share(widget.url ?? widget.text),
                ),
                PickerItem(
                  label: l10n.alternateSources,
                  icon: Icons.link_rounded,
                  onSelected: () => setState(() => page = LinkBottomSheetPage.alternateLinks),
                  trailingIcon: Icons.chevron_right_rounded,
                ),
              ],
              if ((page ?? widget.initialPage) == LinkBottomSheetPage.alternateLinks)
                ...generateAlternateSources(widget.url ?? widget.text).map((alternateSource) {
                  return PickerItem(
                    label: alternateSource.sourceName,
                    subtitle: alternateSource.link,
                    icon: Icons.archive_rounded,
                    onSelected: () {
                      if (widget.customNavigation != null) {
                        widget.customNavigation!.call(alternateSource.link);
                      } else {
                        handleLink(context, url: alternateSource.link);
                      }

                      Navigator.of(context).pop();
                    },
                    trailingIcon: Icons.chevron_right_rounded,
                  );
                }),
              const SizedBox(height: 40.0),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> handleLinkTap(BuildContext context, ThunderState state, String text, String? url) async {
  Uri? parsedUri = Uri.tryParse(text);

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
  (sourceName: 'Archive Today', template: MessageFormat('https://archive.today/{link}')),
  (sourceName: 'Internet Archive', template: MessageFormat('https://web.archive.org/save/{link}')),
  (sourceName: 'Ground News', template: MessageFormat('https://ground.news/find?url={link}')),
];
