import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/src/features/settings/api.dart';
import 'package:thunder/src/foundation/primitives/primitives.dart';
import 'package:thunder/src/foundation/utils/utils.dart';
import 'package:thunder/packages/ui/ui.dart' show ScalableText;

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

    final metadataFontSizeScale = context.select<ThemePreferencesCubit, FontScale>((cubit) => cubit.state.metadataFontSizeScale);
    final formattedDate = ScalableText(
      date,
      textScaleFactor: metadataFontSizeScale.textScaleFactor,
      style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface),
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
