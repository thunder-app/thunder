import 'package:flutter/material.dart';

import 'package:expandable/expandable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;

import 'package:thunder/l10n/generated/app_localizations.dart';
import 'package:thunder/src/app/bloc/thunder_bloc.dart';
import 'package:thunder/src/shared/markdown/common_markdown_body.dart';
import 'package:thunder/src/shared/utils/colors.dart';
import 'package:thunder/src/shared/widgets/text/scalable_text.dart';

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
          _buildSpoilerHeader(l10n, theme, state),
          _buildSpoilerContent(state),
        ],
      ),
    );
  }

  Widget _buildSpoilerHeader(AppLocalizations l10n, ThemeData theme, ThunderState state) {
    return InkWell(
      borderRadius: const BorderRadius.all(Radius.elliptical(5, 5)),
      onTap: () {
        expandableController.toggle();
        setState(() {});
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
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
    );
  }

  Widget _buildSpoilerContent(ThunderState state) {
    return Expandable(
      controller: expandableController,
      collapsed: const SizedBox.shrink(),
      expanded: Padding(
        padding: const EdgeInsets.only(left: 4, right: 4, bottom: 4),
        child: CommonMarkdownBody(
          body: widget.body ?? '',
          isComment: true,
        ),
      ),
    );
  }
}
