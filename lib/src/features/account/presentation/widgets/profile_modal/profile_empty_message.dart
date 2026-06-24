import 'package:flutter/material.dart';

/// Displays an italic empty-state message within a sliver list.
class ProfileEmptyMessage extends StatelessWidget {
  const ProfileEmptyMessage({
    super.key,
    required this.message,
  });

  /// Localized message describing the empty section.
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(left: 24.0, bottom: 16.0),
        child: Text(
          message,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontStyle: FontStyle.italic,
            color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }
}
