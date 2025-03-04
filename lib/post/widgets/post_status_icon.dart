import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/core/enums/font_scale.dart';
import 'package:thunder/post/enums/post_status.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';

/// Given a list of statuses, returns a list of icons representing the statuses.
class PostStatusIcon extends StatelessWidget {
  final bool hidden;
  final bool locked;
  final bool saved;
  final bool pinned;
  final bool deleted;
  final bool removed;
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

  Widget _buildStatusIcon(BuildContext context, PostStatus status, bool isActive, double textScaleFactor) {
    if (!isActive) return const SizedBox.shrink();

    final color = dim ? getDimmedColor(status.getColor(context)) : status.getColor(context);

    return Icon(
      status.icon,
      color: color,
      size: status.getScaledSize(textScaleFactor),
      semanticLabel: status.getLabel(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textScaleFactor = context.select((ThunderBloc bloc) => bloc.state.titleFontSizeScale.textScaleFactor);

    final statusMap = {
      PostStatus.hidden: hidden,
      PostStatus.locked: locked,
      PostStatus.saved: saved,
      PostStatus.pinned: pinned,
      PostStatus.deleted: deleted,
      PostStatus.removed: removed,
    };

    final List<Widget> statuses = statusMap.entries
        .where((entry) => entry.value)
        .map((entry) => _buildStatusIcon(context, entry.key, entry.value, textScaleFactor))
        .whereType<Widget>() // Filter out any null widgets
        .toList();

    return Wrap(
      spacing: 2.0,
      children: [
        ...statuses,
        if (statuses.isNotEmpty) const SizedBox(width: 3.5),
      ],
    );
  }
}
