import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/src/features/settings/api.dart';
import 'package:thunder/src/core/domain/domain.dart';
import 'package:thunder/src/features/post/post.dart';

/// Given a list of statuses, returns a list of icons representing the statuses.
class PostStatusIcon extends StatelessWidget {
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

  /// Determines whether the status icons should be dimmed or not. This is usually to indicate when a post has been read.
  final bool dim;

  const PostStatusIcon({
    super.key,
    this.hidden = false,
    this.locked = false,
    this.saved = false,
    this.pinned = false,
    this.deleted = false,
    this.removed = false,
    this.dim = false,
  });

  static Color getDimmedColor(Color color) => color.withValues(alpha: 0.55);

  /// Builds a single status icon.
  Widget _buildStatusIcon(BuildContext context, PostStatusType status, double textScaleFactor) {
    final color = dim ? getDimmedColor(status.getColor(context)) : status.getColor(context);

    return Icon(
      status.icon,
      color: color,
      size: status.getScaledSize(textScaleFactor),
      semanticLabel: status.getLabel(),
    );
  }

  /// Builds the status icons for the post.
  List<Widget> _buildStatusIcons(BuildContext context, double textScaleFactor) {
    final statuses = <Widget>[];

    if (hidden) statuses.add(_buildStatusIcon(context, PostStatusType.hidden, textScaleFactor));
    if (locked) statuses.add(_buildStatusIcon(context, PostStatusType.locked, textScaleFactor));
    if (saved) statuses.add(_buildStatusIcon(context, PostStatusType.saved, textScaleFactor));
    if (pinned) statuses.add(_buildStatusIcon(context, PostStatusType.pinned, textScaleFactor));
    if (deleted) statuses.add(_buildStatusIcon(context, PostStatusType.deleted, textScaleFactor));
    if (removed) statuses.add(_buildStatusIcon(context, PostStatusType.removed, textScaleFactor));

    return statuses;
  }

  @override
  Widget build(BuildContext context) {
    final textScaleFactor = context.select<ThemePreferencesCubit, double>((cubit) => cubit.state.titleFontSizeScale.textScaleFactor);
    final statuses = _buildStatusIcons(context, textScaleFactor);

    if (statuses.isEmpty) return SizedBox.shrink();

    return Wrap(
      spacing: 2.0,
      children: [...statuses, SizedBox(width: 3.5)],
    );
  }
}
