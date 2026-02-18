import 'package:flutter/material.dart';

import 'package:expandable/expandable.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;

import 'package:thunder/packages/ui/src/widgets/markdown/common_markdown_body.dart';

/// Markdown inline syntax for spoiler tags.
class SpoilerInlineSyntax extends md.InlineSyntax {
  static const String _pattern = r'(:::\s?spoiler\s(.*?)\s?:::)';

  SpoilerInlineSyntax() : super(_pattern);

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    final body = match[2]!;

    final md.Node spoiler = md.Element('span', [
      md.Element('spoiler', [
        md.UnparsedContent('_inline:::$body'),
      ]),
    ]);

    parser.addNode(spoiler);
    return true;
  }
}

/// Markdown block syntax for spoiler blocks.
class SpoilerBlockSyntax extends md.BlockSyntax {
  RegExp endPattern = RegExp(r'^\s{0,3}:{3,}\s*$');

  @override
  RegExp get pattern => RegExp(r'^\s{0,3}:{3,}\s*spoiler\s+(\S.*)$');

  @override
  bool canParse(md.BlockParser parser) {
    return pattern.hasMatch(parser.current.content);
  }

  @override
  md.Node parse(md.BlockParser parser) {
    final Match? match = pattern.firstMatch(parser.current.content);
    final String? title = match?.group(1)?.trim();

    parser.advance();

    final List<String> body = [];

    while (!parser.isDone) {
      if (endPattern.hasMatch(parser.current.content)) {
        parser.advance();
        break;
      } else {
        body.add(parser.current.content);
        parser.advance();
      }
    }

    final md.Node spoiler = md.Element('p', [
      md.Element('spoiler', [
        md.Text('${title ?? '_block'}:::/-/:::${body.join('\n')}'),
      ]),
    ]);

    return spoiler;
  }
}

/// Creates a builder that renders spoiler markdown nodes.
class SpoilerElementBuilder extends MarkdownElementBuilder {
  SpoilerElementBuilder();

  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final rawText = element.textContent;
    final parts = rawText.split(':::/-/:::');

    if (parts.length < 2) {
      return Container();
    }

    final title = parts[0].trim();
    final body = parts[1].trim();
    return SpoilerWidget(title: title, body: body);
  }
}

/// A widget that toggles the visibility of spoiler content.
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
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: const BorderRadius.all(Radius.elliptical(5, 5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSpoilerHeader(theme),
          _buildSpoilerContent(),
        ],
      ),
    );
  }

  Widget _buildSpoilerHeader(ThemeData theme) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
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
                semanticLabel: expandableController.expanded ? 'Collapse spoiler' : 'Expand spoiler',
                size: 20,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  widget.title ?? 'Spoiler',
                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpoilerContent() {
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
