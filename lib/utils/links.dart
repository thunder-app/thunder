import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:url_launcher/url_launcher.dart' hide launch;
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';

import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/account/models/account.dart';
import 'package:thunder/core/auth/helpers/fetch_account.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/feed/utils/utils.dart';
import 'package:thunder/feed/view/feed_page.dart';
import 'package:thunder/post/utils/post.dart';
import 'package:thunder/utils/instance.dart';
import 'package:thunder/utils/navigate_comment.dart';
import 'package:thunder/utils/navigate_post.dart';
import 'package:thunder/utils/navigate_user.dart';

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

  if (state.openInExternalBrowser || (!Platform.isAndroid && !Platform.isIOS)) {
    launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  } else {
    launch(
      url,
      customTabsOption: CustomTabsOption(
        toolbarColor: Theme.of(context).canvasColor,
        enableUrlBarHiding: true,
        showPageTitle: true,
        enableDefaultShare: true,
        enableInstantApps: true,
      ),
      safariVCOption: SafariViewControllerOption(
        preferredBarTintColor: Theme.of(context).canvasColor,
        preferredControlTintColor: Theme.of(context).textTheme.titleLarge?.color ?? Theme.of(context).primaryColor,
        barCollapsingEnabled: true,
        entersReaderIfAvailable: state.openInReaderMode,
      ),
    );
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
        await navigateToUserPage(context, username: username);
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

  // Fallback: open link in browser
  if (context.mounted) {
    _openLink(context, url: url);
  }
}
