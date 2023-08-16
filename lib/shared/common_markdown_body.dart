import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:thunder/utils/navigate_community.dart';
import 'package:thunder/core/enums/font_scale.dart';
import 'package:thunder/shared/image_preview.dart';
import 'package:thunder/utils/links.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/utils/instance.dart';
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

        String? communityName = await getLemmyCommunity(parsedUrl);

        if (communityName != null) {
          try {
            await navigateToCommunityByName(context, communityName);
            return;
          } catch (e) {
            // Ignore exception, if it's not a valid community we'll perform the next fallback
          }
        }

        String? username = await getLemmyUser(parsedUrl);

        if (username != null) {
          try {
            await navigateToUserByName(context, username);
            return;
          } catch (e) {
            // Ignore exception, if it's not a valid user, we'll perform the next fallback
          }
        }

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
