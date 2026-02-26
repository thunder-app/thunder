import 'package:flutter/material.dart';

class ThunderErrorAction {
  const ThunderErrorAction({
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.primary = false,
  });

  final String label;
  final VoidCallback onPressed;
  final bool loading;
  final bool primary;
}

class ThunderErrorState extends StatelessWidget {
  const ThunderErrorState({
    super.key,
    this.title,
    this.message,
    this.actions = const [],
    this.icon,
  });

  final String? title;
  final String? message;
  final List<ThunderErrorAction> actions;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon ?? Icons.warning_rounded, size: 100, color: theme.colorScheme.error),
            const SizedBox(height: 32),
            Text(
              title ?? 'Something went wrong',
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message ?? 'An unexpected error occurred.',
              style: theme.textTheme.labelLarge?.copyWith(color: theme.dividerColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            if (actions.isNotEmpty)
              Column(
                children: [
                  for (int i = 0; i < actions.length; i++) ...[
                    SizedBox(
                      width: double.infinity,
                      child: actions[i].primary || i == 0
                          ? ElevatedButton(
                              onPressed: actions[i].loading ? null : actions[i].onPressed,
                              child: actions[i].loading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator()) : Text(actions[i].label),
                            )
                          : TextButton(
                              onPressed: actions[i].loading ? null : actions[i].onPressed,
                              child: actions[i].loading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator()) : Text(actions[i].label),
                            ),
                    ),
                    if (i != actions.length - 1) const SizedBox(height: 12),
                  ],
                ],
              ),
          ],
        ),
      ),
    );
  }
}
