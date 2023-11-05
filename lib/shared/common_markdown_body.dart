import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:link_preview_generator/link_preview_generator.dart';

import 'package:markdown/markdown.dart' as md;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:thunder/account/models/account.dart';
import 'package:thunder/core/auth/helpers/fetch_account.dart';
import 'package:thunder/core/enums/font_scale.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/feed/utils/utils.dart';
import 'package:thunder/feed/view/feed_page.dart';
import 'package:thunder/post/utils/post.dart';
import 'package:thunder/shared/image_preview.dart';
import 'package:thunder/utils/bottom_sheet_list_picker.dart';
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

    // Custom extension set
    md.ExtensionSet customExtensionSet = md.ExtensionSet.gitHubFlavored;
    customExtensionSet = md.ExtensionSet(List.from(customExtensionSet.blockSyntaxes)..add(SpoilerBlockSyntax()), List.from(customExtensionSet.inlineSyntaxes));

    return MarkdownBody(
      extensionSet: customExtensionSet,
      builders: {
        'spoiler': SpoilerElementBuilder(),
        'a': LinkElementBuilder(context: context, state: state, isComment: isComment),
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
      // Since we're now rending links ourselves, we do not want a separate onTapLink handler.
      // In fact, when this is here, it triggers on text that doesn't even represent a link.
      //onTapLink: (text, url, title) => _handleLinkTap(context, state, text, url),
      styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
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

    if (parts.length < 2) {
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

Future<void> _handleLinkTap(BuildContext context, ThunderState state, String text, String? url) async {
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
      if (context.mounted) {
        await navigateToFeedPage(context, feedType: FeedType.community, communityName: communityName);
        return;
      }
    } catch (e) {
      // Ignore exception, if it's not a valid community we'll perform the next fallback
    }
  }

  // Try navigating to user
  String? username = await getLemmyUser(parsedUrl);
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
  if (url != null && context.mounted) {
    openLink(context, url: parsedUrl, openInExternalBrowser: state.openInExternalBrowser);
  }
}

/// Creates a [MarkdownElementBuilder] that renders links.
class LinkElementBuilder extends MarkdownElementBuilder {
  final BuildContext context;
  final ThunderState state;
  final bool? isComment;

  LinkElementBuilder({required this.context, required this.state, required this.isComment});

  @override
  Widget? visitElementAfterWithContext(BuildContext context, md.Element element, TextStyle? preferredStyle, TextStyle? parentStyle) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    String? href = element.attributes['href'];
    if (href == null) {
      // Not a link
      return super.visitElementAfterWithContext(context, element, preferredStyle, parentStyle);
    } else if (href.startsWith('mailto:')) {
      href = href.replaceFirst('mailto:', '');
    }

    return RichText(
      text: TextSpan(
        children: [
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: InkWell(
              borderRadius: BorderRadius.circular(5),
              onTap: () => _handleLinkTap(context, state, element.textContent, href),
              onLongPress: () {
                showModalBottomSheet(
                  context: context,
                  showDragHandle: true,
                  isScrollControlled: true,
                  builder: (ctx) => BottomSheetListPicker(
                    title: l10n.linkActions,
                    heading: Column(
                      children: [
                        if (!element.attributes['href']!.startsWith('mailto:')) ...[
                          LinkPreviewGenerator(
                            link: href!,
                            placeholderWidget: const CircularProgressIndicator(),
                            linkPreviewStyle: LinkPreviewStyle.large,
                            cacheDuration: Duration.zero,
                            onTap: () {},
                            bodyTextOverflow: TextOverflow.fade,
                            graphicFit: BoxFit.scaleDown,
                            removeElevation: true,
                            backgroundColor: theme.dividerColor.withOpacity(0.25),
                            borderRadius: 10,
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
                                child: Text(href!),
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
                          _handleLinkTap(context, state, element.textContent, href);
                          break;
                        case 'copy':
                          Clipboard.setData(ClipboardData(text: href!));
                          break;
                        case 'share':
                          Share.share(href!);
                          break;
                      }
                    },
                  ),
                );
              },
              child: Text(
                element.textContent,
                // Note that we don't need to specify a textScaleFactor here because it's already applied by the styleSheet of the parent
                style: theme.textTheme.bodyMedium?.copyWith(
                  // TODO: In the future, we could consider using a theme color (or a blend) here.
                  color: Colors.blue,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
