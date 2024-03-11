import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:link_preview_generator/link_preview_generator.dart';
import 'package:share_plus/share_plus.dart';
import 'package:thunder/core/enums/browser_mode.dart';
import 'package:thunder/shared/webview.dart';
import 'package:thunder/utils/bottom_sheet_list_picker.dart';
import 'package:thunder/utils/image.dart';
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

void _openLink(BuildContext context, {required String url}) async {
  ThunderState state = context.read<ThunderBloc>().state;

  if (state.browserMode == BrowserMode.external || (!kIsWeb && !Platform.isAndroid && !Platform.isIOS)) {
    url_launcher.launchUrl(Uri.parse(url), mode: url_launcher.LaunchMode.externalApplication);
  } else if (state.browserMode == BrowserMode.customTabs) {
    await launchUrl(
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
      url_launcher.launchUrl(uri, mode: url_launcher.LaunchMode.externalApplication);
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => WebView(url: url),
        ),
      );
    }
  }
}

/// A universal way of handling links in Thunder.
/// Attempts to perform in-app navigtion to communities, users, posts, and comments
/// Before falling back to opening in the browser (either Custom Tabs or system browser, as specified by the user).
void handleLink(BuildContext context, {required String url}) async {
  LemmyApiV3 lemmy = LemmyClient.instance.lemmyApiV3;
  Account? account = await fetchActiveProfileAccount();

  // Try navigating to community
  String? communityName = await getLemmyCommunity(url);
  if (communityName != null) {
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
  if (username != null) {
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
  int? postId = await getLemmyPostId(url);
  if (postId != null) {
    try {
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
  int? commentId = await getLemmyCommentId(url);
  if (commentId != null) {
    try {
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

  // Try opening it as an image
  try {
    if (isImageUrl(url) && context.mounted) {
      showImageViewer(context, url: url);
      return;
    }
  } catch (e) {
    // Ignore the exception and fall back.
  }

  // Fallback: open link in browser
  if (context.mounted) {
    _openLink(context, url: url);
  }
}

void handleLinkLongPress(BuildContext context, ThunderState state, String text, String? url) {
  final theme = Theme.of(context);
  final l10n = AppLocalizations.of(context)!;

  HapticFeedback.mediumImpact();
  showModalBottomSheet(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (ctx) {
      bool isValidUrl = url?.startsWith('http') ?? false;

      return BottomSheetListPicker(
        title: l10n.linkActions,
        heading: Column(
          children: [
            if (isValidUrl) ...[
              LinkPreviewGenerator(
                link: url!,
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
              const SizedBox(height: 10),
            ],
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: theme.dividerColor.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(5),
                    child: Text(url!),
                  ),
                ),
              ],
            ),
          ],
        ),
        items: [
          ListPickerItem(label: l10n.open, payload: 'open', icon: Icons.language),
          ListPickerItem(label: l10n.copy, payload: 'copy', icon: Icons.copy_rounded),
          ListPickerItem(label: l10n.share, payload: 'share', icon: Icons.share_rounded),
        ],
        onSelect: (value) {
          switch (value.payload) {
            case 'open':
              handleLinkTap(context, state, text, url);
              break;
            case 'copy':
              Clipboard.setData(ClipboardData(text: url));
              break;
            case 'share':
              Share.share(url);
              break;
          }
        },
      );
    },
  );
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
