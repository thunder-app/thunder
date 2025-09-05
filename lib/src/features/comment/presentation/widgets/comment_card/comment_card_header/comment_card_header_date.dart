import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/src/app/thunder.dart';
import 'package:thunder/src/core/enums/font_scale.dart';
import 'package:thunder/src/shared/utils/date_time.dart';
import 'package:thunder/src/shared/widgets/text/scalable_text.dart';

/// A widget that displays the timestamp for a comment, with special styling for recent comments.
///
/// Recent comments are displayed with a special background and an icon.
class CommentCardHeaderDate extends StatelessWidget {
  /// The date when the comment was created
  final DateTime created;

  /// The date when the comment was updated, if any. If provided, this date will be displayed instead of [created].
  final DateTime? updated;

  /// The date to display
  final String date;

  /// Whether the date is recent
  final bool recent;

  CommentCardHeaderDate({super.key, required this.created, this.updated})
      : date = formatTimeToString(dateTime: (updated ?? created).toIso8601String()),
        recent = DateTime.now().toUtc().difference(created).inMinutes < 15;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final formattedDate = BlocSelector<ThunderBloc, ThunderState, FontScale>(
      selector: (state) => state.metadataFontSizeScale,
      builder: (context, metadataFontSizeScale) {
        return ScalableText(
          date,
          fontScale: metadataFontSizeScale,
          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface),
        );
      },
    );

    if (!recent) return formattedDate;

    return Container(
      decoration: BoxDecoration(
        color: theme.splashColor,
        borderRadius: const BorderRadius.all(Radius.elliptical(5.0, 5.0)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
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
