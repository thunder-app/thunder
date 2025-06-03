import 'dart:math';

import 'package:flutter/material.dart';

import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:html/parser.dart';
import 'package:markdown/markdown.dart' hide Text;

import 'package:thunder/core/enums/view_mode.dart';
import 'package:thunder/notification/utils/notification_utils.dart';

/// Creates a [MediaViewText] widget which displays a preview of the text content of a post.
///
/// This widget should only be used when ViewMode is [ViewMode.compact]
class MediaViewText extends StatelessWidget {
  /// The text content of the post.
  final String? text;

  /// Whether the post has been read. This will affect the opacity of the text.
  final bool? read;

  const MediaViewText({
    super.key,
    this.text,
    this.read,
  });

  /// Extracts plain text from markdown/HTML content.
  /// TODO: Move this parsing outside of the UI layer to improve performance.
  String? parseText() {
    if (text?.isNotEmpty != true) return null;

    final htmlText = cleanImagesFromHtml(markdownToHtml(text!));
    return parse(parse(htmlText).body?.text).documentElement?.text ?? text;
  }

  /// Calculates the optimal font size based on text length.
  double _calculateFontSize(String text) {
    return min(20, max(4.5, (20 * (1 / log(text.length)))));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final baseColor = theme.colorScheme.onSecondaryContainer;
    final readColor = baseColor.withValues(alpha: 0.55);
    final unreadColor = baseColor.withValues(alpha: 0.7);
    final color = read == true ? readColor : unreadColor;

    final plainText = parseText();

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: ViewMode.compact.height,
        width: ViewMode.compact.height,
        color: theme.cardColor.darken(5),
        child: plainText != null
            ? Padding(
                padding: const EdgeInsets.all(10.0),
                child: Center(
                  child: Text(
                    plainText,
                    style: TextStyle(
                      fontSize: _calculateFontSize(plainText),
                      color: color,
                    ),
                  ),
                ),
              )
            : Icon(Icons.text_fields_rounded, color: color),
      ),
    );
  }
}
