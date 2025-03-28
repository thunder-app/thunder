import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/shared/text/scalable_text.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/utils/date_time.dart';

/// A widget that displays the timestamp for a comment, with special styling for recent comments.
///
/// Recent comments are displayed with a special background and an icon.
class CommentCardHeaderDate extends StatelessWidget {
  /// The date when the comment was created
  final DateTime created;

  /// The date when the comment was updated, if any.
  /// If provided, this date will be displayed instead of [created].
  final DateTime? updated;

  /// Defines a comment as "recent" if it was created within the given threshold
  static const int _recentThresholdMinutes = 15;

  const CommentCardHeaderDate({super.key, required this.created, this.updated});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final metadataFontSizeScale = context.select((ThunderBloc bloc) => bloc.state.metadataFontSizeScale);

    final recent = DateTime.now().toUtc().difference(created).inMinutes < _recentThresholdMinutes;

    final formattedDate = ScalableText(
      formatTimeToString(dateTime: (updated ?? created).toIso8601String()),
      fontScale: metadataFontSizeScale,
      style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface),
    );

    if (!recent) return formattedDate;

    return Container(
      decoration: BoxDecoration(
        color: theme.splashColor,
        borderRadius: const BorderRadius.all(Radius.elliptical(5.0, 5.0)),
      ),
      padding: const EdgeInsets.only(left: 5.0, right: 5.0),
      child: Row(
        spacing: 5.0,
        children: [
          Icon(Icons.auto_awesome_rounded, size: 16.0, color: theme.colorScheme.primary),
          formattedDate,
        ],
      ),
    );
  }
}
