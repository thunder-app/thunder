import 'package:flutter/material.dart';

import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;

enum CustomMarkdownType { superscript, subscript }

/// A Markdown extension to handle subscript tags.
class SubscriptInlineSyntax extends md.InlineSyntax {
  SubscriptInlineSyntax() : super(r'~([^~\s]+)~');

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    parser.addNode(md.Element.text('sub', match[1]!));
    return true;
  }
}

/// A Markdown extension to handle superscript tags.
class SuperscriptInlineSyntax extends md.InlineSyntax {
  SuperscriptInlineSyntax() : super(r'\^([^\s^]+)\^');

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    parser.addNode(md.Element.text('sup', match[1]!));
    return true;
  }
}

class SubscriptElementBuilder extends MarkdownElementBuilder {
  @override
  Widget visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final textContent = element.textContent;

    return SuperscriptSubscriptWidget(
      text: textContent,
      type: CustomMarkdownType.subscript,
      preferredStyle: preferredStyle,
    );
  }
}

class SuperscriptElementBuilder extends MarkdownElementBuilder {
  @override
  Widget visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final textContent = element.textContent;

    return SuperscriptSubscriptWidget(
      text: textContent,
      type: CustomMarkdownType.superscript,
      preferredStyle: preferredStyle,
    );
  }
}

/// Creates a widget that displays the given [text] in superscript/subscript.
class SuperscriptSubscriptWidget extends StatelessWidget {
  final String text;
  final CustomMarkdownType type;
  final TextStyle? preferredStyle;

  const SuperscriptSubscriptWidget({
    super.key,
    required this.text,
    required this.type,
    this.preferredStyle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseStyle = preferredStyle ?? theme.textTheme.bodyMedium ?? const TextStyle(fontSize: 14);

    return RichText(
      text: TextSpan(
        style: baseStyle,
        children: [
          WidgetSpan(
            child: Transform.translate(
              offset: Offset(
                0.0,
                type == CustomMarkdownType.subscript ? 3.0 : -5.0,
              ),
              child: Text(
                text,
                style: baseStyle.copyWith(
                  fontSize: (baseStyle.fontSize ?? 14) * 0.8,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
