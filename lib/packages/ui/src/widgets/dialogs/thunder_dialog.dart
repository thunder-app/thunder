import 'dart:math';

import 'package:flutter/material.dart';

/// Alert dialog with primary/secondary/tertiary actions and optional custom content.
class ThunderDialog extends StatefulWidget {
  const ThunderDialog({
    super.key,
    required this.title,
    this.contentText,
    this.contentWidgetBuilder,
    this.primaryButtonText,
    this.secondaryButtonText,
    this.onPrimaryButtonPressed,
    this.onSecondaryButtonPressed,
    this.primaryButtonInitialEnabled,
    this.tertiaryButtonText,
    this.onTertiaryButtonPressed,
  });

  /// Dialog title text.
  final String title;

  /// Plain-text dialog body. Mutually exclusive with [contentWidgetBuilder].
  final String? contentText;

  /// Custom dialog body widget. Receives [setPrimaryButtonEnabled].
  final Widget Function(void Function(bool) setPrimaryButtonEnabled)? contentWidgetBuilder;

  /// Label for the primary filled action button.
  final String? primaryButtonText;

  /// Label for the secondary text action button.
  final String? secondaryButtonText;

  /// Called when the primary button is pressed.
  final void Function(BuildContext dialogContext, void Function(bool) setPrimaryButtonEnabled)? onPrimaryButtonPressed;

  /// Called when the secondary button is pressed.
  final void Function(BuildContext dialogContext)? onSecondaryButtonPressed;

  /// Initial enabled state of the primary button.
  final bool? primaryButtonInitialEnabled;

  /// Label for the leading tertiary text action button.
  final String? tertiaryButtonText;

  /// Called when the tertiary button is pressed.
  final void Function(BuildContext dialogContext)? onTertiaryButtonPressed;

  @override
  State<ThunderDialog> createState() => _ThunderDialogState();
}

class _ThunderDialogState extends State<ThunderDialog> {
  late bool _primaryButtonEnabled;

  @override
  void initState() {
    super.initState();
    _primaryButtonEnabled = widget.primaryButtonInitialEnabled ?? true;
  }

  void _setPrimaryButtonEnabled(bool enabled) {
    setState(() => _primaryButtonEnabled = enabled);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: min(MediaQuery.of(context).size.width, 700),
        child: widget.contentText != null ? Text(widget.contentText!) : widget.contentWidgetBuilder!(_setPrimaryButtonEnabled),
      ),
      actions: [
        _ThunderDialogActions(
          primaryButtonEnabled: _primaryButtonEnabled,
          primaryButtonText: widget.primaryButtonText,
          secondaryButtonText: widget.secondaryButtonText,
          tertiaryButtonText: widget.tertiaryButtonText,
          onPrimaryButtonPressed: widget.onPrimaryButtonPressed == null ? null : () => widget.onPrimaryButtonPressed!(context, _setPrimaryButtonEnabled),
          onSecondaryButtonPressed: widget.onSecondaryButtonPressed == null ? null : () => widget.onSecondaryButtonPressed!(context),
          onTertiaryButtonPressed: widget.onTertiaryButtonPressed == null ? null : () => widget.onTertiaryButtonPressed!(context),
        ),
      ],
    );
  }
}

/// Dialog action button row for [ThunderDialog].
class _ThunderDialogActions extends StatelessWidget {
  const _ThunderDialogActions({
    required this.primaryButtonEnabled,
    this.primaryButtonText,
    this.secondaryButtonText,
    this.tertiaryButtonText,
    this.onPrimaryButtonPressed,
    this.onSecondaryButtonPressed,
    this.onTertiaryButtonPressed,
  });

  /// Whether the primary button is enabled.
  final bool primaryButtonEnabled;

  /// Label for the primary filled action button.
  final String? primaryButtonText;

  /// Label for the secondary text action button.
  final String? secondaryButtonText;

  /// Label for the leading tertiary text action button.
  final String? tertiaryButtonText;

  /// Called when the primary button is pressed.
  final void Function()? onPrimaryButtonPressed;

  /// Called when the secondary button is pressed.
  final void Function()? onSecondaryButtonPressed;

  /// Called when the tertiary button is pressed.
  final void Function()? onTertiaryButtonPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        if (tertiaryButtonText != null) ...[
          TextButton(
            onPressed: onTertiaryButtonPressed,
            child: Text(tertiaryButtonText!),
          ),
        ],
        const Spacer(),
        if (secondaryButtonText != null) ...[
          TextButton(
            onPressed: onSecondaryButtonPressed,
            child: Text(secondaryButtonText!),
          ),
          const SizedBox(width: 5.0),
        ],
        if (primaryButtonText != null)
          FilledButton(
            onPressed: !primaryButtonEnabled || onPrimaryButtonPressed == null ? null : onPrimaryButtonPressed,
            child: Text(primaryButtonText!),
          ),
      ],
    );
  }
}

/// Presents a [ThunderDialog] with optional custom content and action buttons.
///
/// Either [contentText] or [contentWidgetBuilder] must be provided, but not both.
Future<T?> showThunderDialog<T>({
  required BuildContext context,
  required String title,
  String? contentText,
  Widget Function(void Function(bool) setPrimaryButtonEnabled)? contentWidgetBuilder,
  String? primaryButtonText,
  String? secondaryButtonText,
  void Function(BuildContext dialogContext, void Function(bool) setPrimaryButtonEnabled)? onPrimaryButtonPressed,
  void Function(BuildContext dialogContext)? onSecondaryButtonPressed,
  Widget Function(Widget alertDialog)? customBuilder,
  bool? primaryButtonInitialEnabled,
  String? tertiaryButtonText,
  void Function(BuildContext dialogContext)? onTertiaryButtonPressed,
}) {
  assert((contentText != null || contentWidgetBuilder != null) && !(contentText != null && contentWidgetBuilder != null));

  Widget buildDialog() {
    return ThunderDialog(
      title: title,
      contentText: contentText,
      contentWidgetBuilder: contentWidgetBuilder,
      primaryButtonText: primaryButtonText,
      secondaryButtonText: secondaryButtonText,
      onPrimaryButtonPressed: onPrimaryButtonPressed,
      onSecondaryButtonPressed: onSecondaryButtonPressed,
      primaryButtonInitialEnabled: primaryButtonInitialEnabled,
      tertiaryButtonText: tertiaryButtonText,
      onTertiaryButtonPressed: onTertiaryButtonPressed,
    );
  }

  return showDialog(
    context: context,
    builder: (BuildContext context) {
      final dialog = buildDialog();
      return customBuilder != null ? customBuilder(dialog) : dialog;
    },
  );
}
