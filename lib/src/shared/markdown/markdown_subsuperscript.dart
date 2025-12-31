import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;

import 'package:thunder/src/app/cubits/theme_preferences_cubit/theme_preferences_cubit.dart';
import 'package:thunder/src/shared/widgets/text/scalable_text.dart';

enum CustomMarkdownType { superscript, subscript }

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
    final contentFontSizeScale = context.read<ThemePreferencesCubit>().state.contentFontSizeScale;

    return RichText(
      text: TextSpan(
        children: [
          WidgetSpan(
            child: Transform.translate(
              offset: Offset(0.0, type == CustomMarkdownType.subscript ? 3.0 : -5.0),
              child: ScalableText(
                text,
                fontScale: contentFontSizeScale,
                style: theme.textTheme.bodyMedium?.copyWith(fontSize: 11),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
