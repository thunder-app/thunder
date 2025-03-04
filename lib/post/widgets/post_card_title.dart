import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:html_unescape/html_unescape_small.dart';

import 'package:thunder/core/enums/font_scale.dart';
import 'package:thunder/post/widgets/post_status_icon.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';

/// Creates the title of a post card. This includes the post title and any status icons.
class PostCardTitle extends StatelessWidget {
  /// The title of the post. If there are any escaped characters, they will be unescaped.
  final String title;

  /// The post status to indicate whether the post is hidden.
  final bool hidden;

  /// The post status to indicate whether the post is locked.
  final bool locked;

  /// The post status to indicate whether the post is saved.
  final bool saved;

  /// The post status to indicate whether the post is pinned.
  final bool pinned;

  /// The post status to indicate whether the post is deleted.
  final bool deleted;

  /// The post status to indicate whether the post is removed.
  final bool removed;

  /// Determines whether the title should be dimmed or not. This is usually to indicate when a post has been read.
  final bool dim;

  const PostCardTitle({
    super.key,
    required this.title,
    this.hidden = false,
    this.locked = false,
    this.saved = false,
    this.pinned = false,
    this.deleted = false,
    this.removed = false,
    this.dim = false,
  });

  static final _html = HtmlUnescape();

  Color? _getDimmedColor(Color? color) => color?.withValues(alpha: 0.55);

  Color? _getTitleColor(ThemeData theme) {
    if (pinned) return dim ? _getDimmedColor(Colors.green) : Colors.green;
    if (dim) return _getDimmedColor(theme.textTheme.bodyMedium?.color);

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final textStyle = theme.textTheme.bodyMedium;
    final fontSize = textStyle?.fontSize ?? 14.0;

    final textScaleFactor = context.select((ThunderBloc bloc) => bloc.state.titleFontSizeScale.textScaleFactor);

    return Text.rich(
      TextSpan(
        children: [
          WidgetSpan(
            child: PostStatusIcon(
              hidden: hidden,
              locked: locked,
              saved: saved,
              pinned: pinned,
              deleted: deleted,
              removed: removed,
              dim: dim,
            ),
          ),
          TextSpan(
            text: _html.convert(title),
            style: textStyle?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: MediaQuery.textScalerOf(context).scale(fontSize * textScaleFactor),
              color: _getTitleColor(theme),
            ),
          ),
        ],
      ),
      textScaler: TextScaler.noScaling,
    );
  }
}
