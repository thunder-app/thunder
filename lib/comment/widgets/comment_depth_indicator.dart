import 'package:flutter/material.dart';

import 'package:thunder/core/enums/nested_comment_indicator.dart';
import 'package:thunder/utils/colors.dart';

/// A decoration applied to a [Container] that is used to draw the vertical lines that indicate the depth of a comment.
///
/// Given the [level] of the comment, this decoration will draw a vertical line for each level of the comment.
/// When the [level] is 0, no lines will be drawn.
class CommentDepthIndicatorDecoration extends Decoration {
  /// The build context to determine the theme and colours.
  final BuildContext context;

  /// The level of the comment.
  final int level;

  /// The style to use for the nested comment indicator.
  ///
  /// This determines the width of the vertical lines, and whether or not to render all levels of the indicator.
  /// When [style] is [NestedCommentIndicatorStyle.thick], only the current level of the indicator will be rendered.
  /// When [style] is [NestedCommentIndicatorStyle.thin], all levels of the indicator will be rendered.
  final NestedCommentIndicatorStyle style;

  /// The color scheme to use for the nested comment indicator.
  final NestedCommentIndicatorColor scheme;

  const CommentDepthIndicatorDecoration(
    this.context, {
    this.level = 0,
    this.style = NestedCommentIndicatorStyle.thin,
    this.scheme = NestedCommentIndicatorColor.colorful,
  });

  @override
  Path getClipPath(Rect rect, TextDirection textDirection) {
    return Path()..addRect(rect);
  }

  @override
  bool hitTest(Size size, Offset position, {TextDirection? textDirection}) {
    assert((Offset.zero & size).contains(position));
    return true;
  }

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    assert(onChanged != null);
    return _BoxDecorationPainter(this, onChanged);
  }
}

/// An object that paints a [CommentDepthIndicatorDecoration] into a canvas.
class _BoxDecorationPainter extends BoxPainter {
  _BoxDecorationPainter(this._decoration, super.onChanged);

  final CommentDepthIndicatorDecoration _decoration;

  static const double _spacing = 4.0;
  static const double _offset = 2.0;

  /// Paint the box decoration into the given location on the given canvas.
  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    if (_decoration.level == 0) return;
    assert(configuration.size != null);

    final theme = Theme.of(_decoration.context);
    final rect = offset & configuration.size!;
    final paint = Paint()..style = PaintingStyle.stroke;

    if (_decoration.style == NestedCommentIndicatorStyle.thin) {
      paint.strokeWidth = 1.0;

      // Draw each level of the comment indicator
      for (int i = 0; i < _decoration.level; i++) {
        if (_decoration.scheme == NestedCommentIndicatorColor.monochrome) {
          paint.color = theme.hintColor.withValues(alpha: 0.25);
        } else {
          paint.color = getCommentLevelColor(_decoration.context, i % 6);
        }

        canvas.drawLine(
          rect.translate((i + 1) * _spacing, 0).topLeft,
          rect.translate((i + 1) * _spacing, 0).bottomLeft,
          paint,
        );
      }
    } else {
      paint.strokeWidth = 4.0;

      if (_decoration.scheme == NestedCommentIndicatorColor.monochrome) {
        paint.color = theme.hintColor.withValues(alpha: 0.25);
      } else {
        // Fixed: Use proper modulo for level color
        paint.color = getCommentLevelColor(_decoration.context, (_decoration.level - 1) % 6);
      }

      // Draw only the current level of the comment indicator
      canvas.drawLine(
        rect.translate(_decoration.level * _spacing - _offset, 0).topLeft,
        rect.translate(_decoration.level * _spacing - _offset, 0).bottomLeft,
        paint,
      );
    }
  }
}
