import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:thunder/account/models/account.dart';
import 'package:thunder/core/auth/helpers/fetch_account.dart';
import 'package:thunder/core/enums/font_scale.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/feed/utils/utils.dart';
import 'package:thunder/feed/view/feed_page.dart';
import 'package:thunder/post/utils/post.dart';
import 'package:thunder/shared/image_preview.dart';
import 'package:thunder/utils/links.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/utils/instance.dart';
import 'package:thunder/utils/navigate_post.dart';
import 'package:thunder/utils/navigate_user.dart';

class CommonMarkdownBody extends StatelessWidget {
  final String body;
  final bool isSelectableText;
  final bool? isComment;

  const CommonMarkdownBody({
    super.key,
    required this.body,
    this.isSelectableText = false,
    this.isComment,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ThunderState state = context.watch<ThunderBloc>().state;

    bool openInExternalBrowser = state.openInExternalBrowser;

    return MarkdownBody(
      // TODO We need spoiler support here
      data: body,
      imageBuilder: (uri, title, alt) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              ImagePreview(
                url: uri.toString(),
                isExpandable: true,
                isComment: isComment,
                showFullHeightImages: true,
              ),
            ],
          ),
        );
      },
      selectable: isSelectableText,
      onTapLink: (text, url, title) async {
        LemmyApiV3 lemmy = LemmyClient.instance.lemmyApiV3;
        Account? account = await fetchActiveProfileAccount();

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

        // Try navigating to community
        String? communityName = await getLemmyCommunity(parsedUrl);
        if (communityName != null) {
          try {
            await navigateToFeedPage(context, feedType: FeedType.community, communityName: communityName);
            return;
          } catch (e) {
            // Ignore exception, if it's not a valid community we'll perform the next fallback
          }
        }

        // Try navigating to user
        String? username = await getLemmyUser(parsedUrl);
        if (username != null) {
          try {
            await navigateToUserPage(context, username: username);
            return;
          } catch (e) {
            // Ignore exception, if it's not a valid user, we'll perform the next fallback
          }
        }

        // Try navigating to post
        int? postId = await getLemmyPostId(parsedUrl);
        if (postId != null) {
          try {
            FullPostView post = await lemmy.run(GetPost(
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

        // TODO: Try navigating to comment

        // Fallback: open link in browser
        if (url != null) {
          openLink(context, url: parsedUrl, openInExternalBrowser: openInExternalBrowser);
        }
      },
      styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
        // If its a comment, use the commentFontSizeScale, otherwise fallback to the contentFontSizeScale (for posts and other widgets using CommonMarkdownBody)
        textScaleFactor: MediaQuery.of(context).textScaleFactor * (isComment == true ? state.commentFontSizeScale.textScaleFactor : state.contentFontSizeScale.textScaleFactor),
        p: theme.textTheme.bodyMedium,
        blockquoteDecoration: const BoxDecoration(
          color: Colors.transparent,
          border: Border(left: BorderSide(color: Colors.grey, width: 4)),
        ),
      ),
    );
  }
}
