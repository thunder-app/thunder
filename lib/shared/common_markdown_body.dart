import 'package:flutter/material.dart';

import 'package:jovial_svg/jovial_svg.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import 'package:thunder/utils/image.dart';
import 'package:thunder/utils/links.dart';
import 'package:thunder/shared/image_preview.dart';
import 'package:thunder/core/enums/font_scale.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/utils/markdown/extended_markdown.dart';

class CommonMarkdownBody extends StatelessWidget {
  /// The markdown content body
  final String body;

  /// Whether the text is selectable - defaults to false
  final bool isSelectableText;

  /// Indicates if the given markdown is a comment. Depending on the markdown content, different text scaling may be applied
  /// TODO: This should be converted to an enum of possible markdown content (e.g., post, comment, general, metadata, etc.) to allow for more fined-tuned scaling of text
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

    return ExtendedMarkdownBody(
      data: body,
      extensionSet: customExtensionSet,
      inlineSyntaxes: [LemmyLinkSyntax(), SpoilerInlineSyntax()],
      builders: {
        'spoiler': SpoilerElementBuilder(),
      },
      imageBuilder: (uri, title, alt) {
        return FutureBuilder(
          future: isImageUriSvg(uri),
          builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  !snapshot.hasData
                      ? Container()
                      : snapshot.data == true
                          ? ScalableImageWidget.fromSISource(
                              si: ScalableImageSource.fromSvgHttpUrl(uri),
                            )
                          : ImagePreview(
                              url: uri.toString(),
                              isExpandable: true,
                              isComment: isComment,
                              showFullHeightImages: true,
                            ),
                ],
              ),
            );
          },
        );
      },
      selectable: isSelectableText,
      onTapLink: (text, url, title) => handleLinkTap(context, state, text, url),
      onLongPressLink: (text, url, title) => handleLinkLongPress(context, state, text, url),
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
        md.UnparsedContent('${title ?? '_block'}:::${body.join('\n')}'),
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

/// Creates a widget that toggles the visibility of the given [body]
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
        behavior: HitTestBehavior.opaque,
        child: CommonMarkdownBody(body: widget.body ?? ''),
        onTap: () => setState(() => isShown = false),
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() => isShown = true),
      child: Container(
        color: theme.colorScheme.primary,
        child: Text(
          widget.body ?? 'help',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.transparent,
          ),
        ),
      ),
    );
  }
}
