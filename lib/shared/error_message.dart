import 'package:flutter/material.dart';

class ErrorMessage extends StatelessWidget {
  final String? message;
  final String? actionText;
  final VoidCallback? action;

  const ErrorMessage({super.key, this.message, this.action, this.actionText});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.warning_rounded, size: 100, color: Colors.red.shade300),
            const SizedBox(height: 32.0),
            Text('Oops, something went wrong!', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8.0),
            Text(
              message ?? 'No error message available',
              style: theme.textTheme.labelLarge?.copyWith(color: theme.dividerColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32.0),
            ElevatedButton(
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
              onPressed: () => action?.call(),
              child: Text(actionText ?? 'Refresh'),
            ),
          ],
        ),
      ),
    );
  }
}
