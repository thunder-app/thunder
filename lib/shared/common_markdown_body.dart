import 'package:flutter/material.dart';

import 'package:jovial_svg/jovial_svg.dart';
import 'package:expandable/expandable.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:thunder/shared/text/scalable_text.dart';
import 'package:thunder/utils/colors.dart';

import 'package:thunder/utils/media/image.dart';
import 'package:thunder/utils/links.dart';
import 'package:thunder/shared/image_preview.dart';
import 'package:thunder/core/enums/font_scale.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/utils/markdown/extended_markdown.dart';

enum CustomMarkdownType { superscript, subscript }

class CommonMarkdownBody extends StatelessWidget {
  /// The markdown content body
  final String body;

  /// Whether to hide the markdown content. This is mainly used for spoiler markdown
  final bool hideContent;

  /// Indicates if the given markdown is a comment. Depending on the markdown content, different text scaling may be applied
  /// TODO: This should be converted to an enum of possible markdown content (e.g., post, comment, general, metadata, etc.) to allow for more fined-tuned scaling of text
  final bool? isComment;

  final double? imageMaxWidth;

  const CommonMarkdownBody({
    super.key,
    required this.body,
    this.hideContent = false,
    this.isComment,
    this.imageMaxWidth,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ThunderState state = context.watch<ThunderBloc>().state;

    /// This is the stylesheet used for any markdown with [hideContent] set to true
    /// It tries to remove all content from the markdown while retaining the general size dimensions
    MarkdownStyleSheet spoilerMarkdownStyleSheet = MarkdownStyleSheet(
      a: const TextStyle(color: Colors.transparent),
      p: theme.textTheme.bodyMedium!.copyWith(color: Colors.transparent),
      pPadding: EdgeInsets.zero,
      code: theme.textTheme.bodyMedium!.copyWith(
        backgroundColor: Colors.transparent,
        fontFamily: 'monospace',
        fontSize: theme.textTheme.bodyMedium!.fontSize! * 0.85,
        color: Colors.transparent,
      ),
      h1: theme.textTheme.headlineSmall!.copyWith(color: Colors.transparent),
      h1Padding: EdgeInsets.zero,
      h2: theme.textTheme.titleLarge!.copyWith(color: Colors.transparent),
      h2Padding: EdgeInsets.zero,
      h3: theme.textTheme.titleMedium!.copyWith(color: Colors.transparent),
      h3Padding: EdgeInsets.zero,
      h4: theme.textTheme.bodyLarge!.copyWith(color: Colors.transparent),
      h4Padding: EdgeInsets.zero,
      h5: theme.textTheme.bodyLarge!.copyWith(color: Colors.transparent),
      h5Padding: EdgeInsets.zero,
      h6: theme.textTheme.bodyLarge!.copyWith(color: Colors.transparent),
      h6Padding: EdgeInsets.zero,
      em: const TextStyle(fontStyle: FontStyle.italic, color: Colors.transparent),
      strong: const TextStyle(fontWeight: FontWeight.bold, color: Colors.transparent),
      del: const TextStyle(decoration: TextDecoration.none, color: Colors.transparent),
      blockquote: theme.textTheme.bodyMedium!.copyWith(color: Colors.transparent),
      img: theme.textTheme.bodyMedium!.copyWith(color: Colors.transparent),
      checkbox: theme.textTheme.bodyMedium!.copyWith(color: Colors.transparent),
      blockSpacing: 8.0,
      listIndent: 24.0,
      listBullet: theme.textTheme.bodyMedium!.copyWith(color: Colors.transparent),
      listBulletPadding: const EdgeInsets.only(right: 4),
      tableHead: const TextStyle(fontWeight: FontWeight.w600, color: Colors.transparent),
      tableBody: theme.textTheme.bodyMedium?.copyWith(color: Colors.transparent),
      tableHeadAlign: TextAlign.center,
      tableBorder: TableBorder.all(color: Colors.transparent),
      tableColumnWidth: const FlexColumnWidth(),
      tableCellsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      tableCellsDecoration: const BoxDecoration(color: Colors.transparent),
      blockquotePadding: const EdgeInsets.all(8.0),
      blockquoteDecoration: const BoxDecoration(
        color: Colors.transparent,
        border: Border(left: BorderSide(color: Colors.transparent, width: 4)),
      ),
      codeblockPadding: const EdgeInsets.all(8.0),
      codeblockDecoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(2.0),
      ),
      horizontalRuleDecoration: BoxDecoration(
        border: Border(top: BorderSide(width: theme.textTheme.bodyMedium!.fontSize!, color: Colors.transparent)),
      ),
      textScaleFactor: MediaQuery.of(context).textScaleFactor * (isComment == true ? state.commentFontSizeScale.textScaleFactor : state.contentFontSizeScale.textScaleFactor),
    );

    // Custom extension set
    md.ExtensionSet customExtensionSet = md.ExtensionSet.gitHubFlavored;
    customExtensionSet = md.ExtensionSet(
      List.from(customExtensionSet.blockSyntaxes)..add(SpoilerBlockSyntax()),
      List.from(customExtensionSet.inlineSyntaxes)..addAll([SuperscriptInlineSyntax(), SubscriptInlineSyntax()]),
    );

    return ExtendedMarkdownBody(
      data: body,
      extensionSet: customExtensionSet,
      inlineSyntaxes: [LemmyLinkSyntax(), SubscriptInlineSyntax(), SuperscriptInlineSyntax()],
      builders: {
        'spoiler': SpoilerElementBuilder(),
        'sub': SubscriptElementBuilder(),
        'sup': SuperscriptElementBuilder(),
      },
      imageBuilder: (uri, title, alt) {
        if (hideContent) return Container();

        return FutureBuilder(
          future: isImageUriSvg(uri),
          builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  snapshot.data != true
                      ? ImagePreview(
                          url: uri.toString(),
                          isExpandable: true,
                          isComment: isComment,
                          showFullHeightImages: true,
                          maxWidth: imageMaxWidth,
                          altText: alt,
                        )
                      : Container(
                          constraints: isComment == true
                              ? BoxConstraints(
                                  maxHeight: MediaQuery.of(context).size.width * 0.55,
                                  maxWidth: MediaQuery.of(context).size.width * 0.60,
                                )
                              : BoxConstraints(
                                  maxWidth: imageMaxWidth ?? MediaQuery.of(context).size.width - 24,
                                ),
                          child: ScalableImageWidget.fromSISource(
                            fit: BoxFit.contain,
                            si: ScalableImageSource.fromSvgHttpUrl(uri),
                          ),
                        ),
                ],
              ),
            );
          },
        );
      },
      onTapLink: (text, url, title) => handleLinkTap(context, state, text, url),
      onLongPressLink: (text, url, title) => handleLinkLongPress(context, state, text, url),
      styleSheet: hideContent
          ? spoilerMarkdownStyleSheet
          : MarkdownStyleSheet.fromTheme(theme).copyWith(
              textScaleFactor: MediaQuery.of(context).textScaleFactor * (isComment == true ? state.commentFontSizeScale.textScaleFactor : state.contentFontSizeScale.textScaleFactor),
              blockquoteDecoration: BoxDecoration(
                color: getBackgroundColor(context),
                border: Border(left: BorderSide(color: theme.colorScheme.primary.withOpacity(0.75), width: 4)),
                borderRadius: BorderRadius.circular(5),
              ),
              codeblockDecoration: BoxDecoration(
                color: getBackgroundColor(context),
                borderRadius: BorderRadius.circular(10),
              ),
              code: theme.textTheme.bodyMedium?.copyWith(
                backgroundColor: getBackgroundColor(context),
                fontFamily: 'monospace',
                fontSize: theme.textTheme.bodyMedium!.fontSize! * 0.85,
              ),
              tableBorder: TableBorder.all(
                color: Colors.grey,
                width: 1,
                borderRadius: const BorderRadius.all(Radius.circular(5)),
              ),
              horizontalRuleDecoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(5)),
                border: Border(
                  top: BorderSide(
                    width: 3,
                    color: theme.colorScheme.primary.withOpacity(0.75),
                  ),
                ),
              ),
            ),
    );
  }
}

class LemmyLinkSyntax extends md.InlineSyntax {
  // https://github.com/LemmyNet/lemmy-ui/blob/61255bf01a8d2acdbb77229838002bf8067ada70/src/shared/config.ts#L38
  static const String _pattern = r'(\/[cmu]\/|@|!)([a-zA-Z0-9._%+-]+)@([a-zA-Z0-9.-]+\.[a-zA-Z]{2,})';

  LemmyLinkSyntax() : super(_pattern);

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    final modifier = match[1]!;
    final name = match[2]!;
    final url = match[3]!;
    final anchor = md.Element.text('a', '$modifier$name@$url');

    anchor.attributes['href'] = '$modifier$name@$url';
    parser.addNode(anchor);

    return true;
  }
}

/// A Markdown Extension to handle subscript tags on Lemmy. This extends the [md.InlineSyntax]
/// to allow for inline parsing of text for a given subscript tag.
///
/// It parses the following syntax for a subscript:
///
/// ```
/// ~subscript~ and text~subscript~
/// ```
///
/// It does not capture this syntax properly (parity with Lemmy UI):
/// ```
/// ~subscript with space~ and text~subscript with space~
/// ```
class SubscriptInlineSyntax extends md.InlineSyntax {
  SubscriptInlineSyntax() : super(r'~([^~\s]+)~');

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    parser.addNode(md.Element.text("sub", match[1]!));
    return true;
  }
}

/// A Markdown Extension to handle superscript tags on Lemmy. This extends the [md.InlineSyntax]
/// to allow for inline parsing of text for a given superscript tag.
///
/// It parses the following syntax for a superscript:
/// ```
/// ^superscript^ and text^superscript^
/// ```
///
/// It does not capture this syntax properly (parity with Lemmy UI):
/// ```
/// ^superscript with space^ and text^superscript with space^
/// ```
class SuperscriptInlineSyntax extends md.InlineSyntax {
  SuperscriptInlineSyntax() : super(r'\^([^\s^]+)\^');

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    parser.addNode(md.Element.text("sup", match[1]!));
    return true;
  }
}

/// Note: This is currently disabled as this is not an officially supported Lemmy Markdown syntax
///
/// A Markdown Extension to handle spoiler tags on Lemmy. This extends the [md.InlineSyntax]
/// to allow for inline parsing of text for a given spoiler tag.
///
/// It parses the following syntax for a spoiler:
///
/// ```
/// :::spoiler spoiler_body:::
/// :::spoiler spoiler_body :::
/// ::: spoiler spoiler_body :::
/// ```
///
/// It does not capture this syntax properly:
/// ```
/// ::: spoiler spoiler_body:::
/// ```
class SpoilerInlineSyntax extends md.InlineSyntax {
  static const String _pattern = r'(:::\s?spoiler\s(.*?)\s?:::)';

  SpoilerInlineSyntax() : super(_pattern);

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    final body = match[2]!;

    // Create a custom Node which will be used to render the spoiler in [SpoilerElementBuilder]
    final md.Node spoiler = md.Element('span', [
      /// This is a workaround to allow us to parse the spoiler title and body within the [SpoilerElementBuilder]
      ///
      /// If the title and body are passed as separate elements into the [spoiler] tag, it causes
      /// the resulting [SpoilerWidget] to always show the second element. To work around this, the title and
      /// body are placed together into a single node, separated by a ::: to distinguish the sections.
      md.Element('spoiler', [
        md.UnparsedContent('_inline:::$body'),
      ]),
    ]);

    parser.addNode(spoiler);
    return true;
  }
}

/// A Markdown Extension to handle spoiler tags on Lemmy. This extends the [md.BlockSyntax]
/// to allow for multi-line parsing of text for a given spoiler tag.
class SpoilerBlockSyntax extends md.BlockSyntax {
  /// The pattern to match the end of a spoiler
  /// This pattern checks for the following conditions:
  /// - The line starts with 0-3 whitespace characters
  /// - The line is followed by 3 or more colons
  /// - The line ends without any other characters except optional whitespace
  RegExp endPattern = RegExp(r'^\s{0,3}:{3,}\s*$');

  /// The pattern to match the beginning of a spoiler
  /// This pattern checks for the following conditions:
  /// - The line starts with 0-3 whitespace characters
  /// - The line is followed by 3 or more colons
  /// - The line contains optional whitespace between the colons and "spoiler"
  /// - The line contains some non-whitespace character after the spoiler keyword
  @override
  RegExp get pattern => RegExp(r'^\s{0,3}:{3,}\s*spoiler\s+(\S.*)$');

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

    // Accumulate lines of the body until the closing pattern
    while (!parser.isDone) {
      // Stop parsing if the current line is one of the following:
      if (endPattern.hasMatch(parser.current.content)) {
        parser.advance();
        break;
      } else {
        body.add(parser.current.content);
        parser.advance();
      }
    }

    // Create a custom Node which will be used to render the spoiler in [SpoilerElementBuilder]
    final md.Node spoiler = md.Element('p', [
      /// This is a workaround to allow us to parse the spoiler title and body within the [SpoilerElementBuilder]
      ///
      /// If the title and body are passed as separate elements into the [spoiler] tag, it causes
      /// the resulting [SpoilerWidget] to always show the second element. To work around this, the title and
      /// body are placed together into a single node, separated by a :::/-/::: to distinguish the sections.
      md.Element('spoiler', [
        md.Text('${title ?? '_block'}:::/-/:::${body.join('\n')}'),
      ]),
    ]);

    return spoiler;
  }
}

/// Creates a [MarkdownElementBuilder] that renders the custom spoiler tag defined in [SpoilerSyntax].
///
/// This breaks down the combined title/body and creates the resulting [SpoilerWidget]
class SpoilerElementBuilder extends MarkdownElementBuilder {
  SpoilerElementBuilder();

  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    String rawText = element.textContent;
    List<String> parts = rawText.split(':::/-/:::');

    if (parts.length < 2) {
      // An invalid spoiler format
      return Container();
    }

    String? title = parts[0].trim();
    String? body = parts[1].trim();
    return SpoilerWidget(title: title, body: body);
  }
}

/// Creates a widget that toggles the visibility of the given [body]
class SpoilerWidget extends StatefulWidget {
  final String? title;
  final String? body;

  const SpoilerWidget({super.key, this.title, this.body});

  @override
  State<SpoilerWidget> createState() => _SpoilerWidgetState();
}

class _SpoilerWidgetState extends State<SpoilerWidget> {
  /// Whether the spoiler is expanded
  final ExpandableController expandableController = ExpandableController(initialExpanded: false);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final state = context.read<ThunderBloc>().state;

    return Ink(
      decoration: BoxDecoration(
        color: getBackgroundColor(context),
        borderRadius: const BorderRadius.all(Radius.elliptical(5, 5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            borderRadius: const BorderRadius.all(Radius.elliptical(5, 5)),
            onTap: () {
              expandableController.toggle();
              setState(() {}); // Update the state to trigger the collapse/expand
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    expandableController.expanded ? Icons.expand_more_rounded : Icons.chevron_right_rounded,
                    semanticLabel: expandableController.expanded ? l10n.collapseSpoiler : l10n.expandSpoiler,
                    size: 20,
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: ScalableText(
                      widget.title ?? l10n.spoiler,
                      fontScale: state.contentFontSizeScale,
                      style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expandable(
            controller: expandableController,
            collapsed: Container(),
            expanded: Padding(
              padding: const EdgeInsets.only(left: 4, right: 4, bottom: 4),
              child: CommonMarkdownBody(
                body: widget.body ?? '',
                isComment: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Creates a [MarkdownElementBuilder] that renders the custom subscript tag defined in [SubscriptInlineSyntax].
class SubscriptElementBuilder extends MarkdownElementBuilder {
  @override
  Widget visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final String textContent = element.textContent;

    return SuperscriptSubscriptWidget(text: textContent, type: CustomMarkdownType.subscript);
  }
}

/// Creates a [MarkdownElementBuilder] that renders the custom superscript tag defined in [SuperscriptInlineSyntax]..
class SuperscriptElementBuilder extends MarkdownElementBuilder {
  @override
  Widget visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final String textContent = element.textContent;

    return SuperscriptSubscriptWidget(text: textContent, type: CustomMarkdownType.superscript);
  }
}

/// Creates a widget that displays the given [text] in the given [type] (superscript or subscript).
///
/// Note: There seems to be an issue with rendering both superscript and subscript at the if they are in the same line.
/// For example: `This is a text^subscript^ and this is a text~superscript~`.
/// In this case, the subscript is not rendered correctly.
class SuperscriptSubscriptWidget extends StatelessWidget {
  /// The text for the superscript or subscript
  final String text;

  /// Whether the text is superscript or subscript
  final CustomMarkdownType type;

  const SuperscriptSubscriptWidget({super.key, required this.text, required this.type});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = context.read<ThunderBloc>().state;

    return RichText(
      text: TextSpan(
        children: [
          WidgetSpan(
            child: Transform.translate(
              offset: Offset(0.0, type == CustomMarkdownType.subscript ? 3.0 : -5.0),
              child: ScalableText(
                text,
                fontScale: state.contentFontSizeScale,
                style: theme.textTheme.bodyMedium?.copyWith(fontSize: 11),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
