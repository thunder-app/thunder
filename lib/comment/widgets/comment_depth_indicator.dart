import 'package:flutter/material.dart';

import 'package:thunder/core/enums/nested_comment_indicator.dart';
import 'package:thunder/utils/colors.dart';

class CommentDepthIndicatorDecoration extends Decoration {
  /// The [BuildContext] used to access the theme and colors for rendering.
  ///
  /// This is required to determine the appropriate colors based on the current theme.
  final BuildContext context;

  /// The nesting level of the comment.
  ///
  /// This determines how many vertical lines are drawn. A value of 0 means no lines are drawn.
  final int level;

  /// The style of the nested comment indicator.
  ///
  /// - [NestedCommentIndicatorStyle.thick]: Only the current level's line is rendered with a thicker stroke.
  /// - [NestedCommentIndicatorStyle.thin]: All levels' lines are rendered with a thinner stroke.
  final NestedCommentIndicatorStyle style;

  /// The color scheme of the nested comment indicator.
  ///
  /// - [NestedCommentIndicatorColor.monochrome]: Lines are rendered in a single color with reduced opacity.
  /// - [NestedCommentIndicatorColor.colorful]: Lines are rendered in a sequence of colors based on the level.
  final NestedCommentIndicatorColor scheme;

  /// A decoration that visually represents the depth of a comment in a nested comment structure.
  ///
  /// This decoration is applied to a [Container] and draws vertical lines to indicate the nesting level of a comment.
  /// The number of lines corresponds to the [level] of the comment. If the [level] is 0, no lines are drawn.
  ///
  /// The appearance of the lines is controlled by the [style] and [scheme] parameters:
  /// - [style] determines the thickness of the lines and whether all levels or only the current level are rendered.
  /// - [scheme] defines the color scheme of the lines, either monochrome or colorful.
  ///
  /// This widget is useful for visually organizing nested comments in a discussion thread or similar UI.
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
  static const double _offset = 4.0;

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
        paint.color = getCommentLevelColor(_decoration.context, (_decoration.level - 1) % 6);
      }

      // Draw only the current level of the comment indicator
      canvas.drawLine(
        rect.translate(_decoration.level * _spacing + _offset, 0).topLeft,
        rect.translate(_decoration.level * _spacing + _offset, 0).bottomLeft,
        paint,
      );
    }
  }
}
