import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:markdown/markdown.dart' as md;
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
import 'package:thunder/utils/navigate_comment.dart';
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

    // Custom extension set
    md.ExtensionSet customExtensionSet = md.ExtensionSet.gitHubFlavored;
    customExtensionSet = md.ExtensionSet(List.from(customExtensionSet.blockSyntaxes)..add(SpoilerBlockSyntax()), List.from(customExtensionSet.inlineSyntaxes));

    return MarkdownBody(
      extensionSet: customExtensionSet,
      builders: {
        'spoiler': SpoilerElementBuilder(),
      },
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
        int? commentId = await getLemmyCommentId(parsedUrl);
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

/// A Markdown Extension to handle spoiler tags on Lemmy. This extends the [md.BlockSyntax]
/// to allow for multi-line parsing of text for a given spoiler tag.
///
/// It parses the following syntax for a spoiler:
///
/// ```
/// ::: spoiler spoiler_title
/// spoiler_body
/// :::
/// ```
class SpoilerBlockSyntax extends md.BlockSyntax {
  /// The pattern to match the end of a spoiler
  static final RegExp _spoilerBlockEnd = RegExp(r'^(?:::)$');

  /// The pattern to match the beginning of a spoiler
  @override
  RegExp get pattern => RegExp(r'^:::\s+spoiler\s+(.+)\s*$');

  @override
  bool canParse(md.BlockParser parser) {
    return pattern.hasMatch(parser.current.content);
  }

  /// Parses the block of text for the given spoiler. This will fetch the title and the body of the spoiler.
  @override
  md.Node parse(md.BlockParser parser) {
    final Match? match = pattern.firstMatch(parser.current.content);
    final String? title = match?.group(1)?.trim();

    parser.advance(); // Move to the next line

    final List<String> body = [];

    // Accumulate lines of the body until the closing :::
    while (!parser.isDone) {
      if (_spoilerBlockEnd.hasMatch(parser.current.content)) {
        parser.advance();
        break;
      }
      body.add(parser.current.content);
      parser.advance();
    }

    // Create a custom Node which will be used to render the spoiler in [SpoilerElementBuilder]
    final md.Node spoiler = md.Element('p', [
      /// This is a workaround to allow us to parse the spoiler title and body within the [SpoilerElementBuilder]
      ///
      /// If the title and body are passed as separate elements into the [spoiler] tag, it causes
      /// the resulting [SpoilerWidget] to always show the second element. To work around this, the title and
      /// body are placed together into a single node, separated by a ::: to distinguish the sections.
      md.Element('spoiler', [
        md.UnparsedContent('${title ?? 'spoiler'}:::${body.join('\n')}'),
      ]),
    ]);

    return spoiler;
  }
}

/// Creates a [MarkdownElementBuilder] that renders the custom spoiler tag defined in [SpoilerSyntax].
///
/// This breaks down the combined title/body and creates the resulting [SpoilerWidget]
class SpoilerElementBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    String rawText = element.textContent;
    List<String> parts = rawText.split(':::');

    if (parts.length != 2) {
      // An invalid spoiler format
      return Container();
    }

    String? title = parts[0].trim();
    String? body = parts[1].trim();
    return SpoilerWidget(title: title, body: body);
  }
}

/// Creates a widget that toggles the visibility of the given [body].
/// It displays the [title] of the spoiler by default unless tapped.
///
/// If no [title] is given, it will display "spoiler" as the default text.
class SpoilerWidget extends StatefulWidget {
  final String? title;
  final String? body;

  const SpoilerWidget({super.key, this.title, this.body});

  @override
  State<SpoilerWidget> createState() => _SpoilerWidgetState();
}

class _SpoilerWidgetState extends State<SpoilerWidget> {
  bool isShown = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isShown) {
      return GestureDetector(
        child: CommonMarkdownBody(body: widget.body ?? ''),
        onTap: () => setState(() => isShown = false),
      );
    }

    return RichText(
      text: TextSpan(
        text: widget.title ?? 'spoiler',
        recognizer: TapGestureRecognizer()..onTap = () => setState(() => isShown = true),
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.secondary,
        ),
      ),
    );
  }
}
