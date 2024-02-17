import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ReasonBottomSheet extends StatefulWidget {
  const ReasonBottomSheet({super.key, this.title, this.textHint, this.submitLabel, this.errorMessage, required this.onSubmit});

  /// A custom title of the bottom sheet. Defaults to "Reason"
  final String? title;

  /// A custom text hint of the text field. Defaults to "Message"
  final String? textHint;

  /// A custom label of the submit button. Defaults to "Submit"
  final String? submitLabel;

  /// An error message to display
  final String? errorMessage;

  /// Callback function which triggers when the submit button is pressed
  final Function(String) onSubmit;

  @override
  State<ReasonBottomSheet> createState() => _ReasonBottomSheetState();
}

class _ReasonBottomSheetState extends State<ReasonBottomSheet> {
  late TextEditingController messageController;

  @override
  void initState() {
    messageController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 26.0, right: 16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              widget.title ?? l10n.reason,
              style: theme.textTheme.titleLarge,
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            decoration: InputDecoration(
              isDense: true,
              border: const OutlineInputBorder(),
              labelText: widget.textHint ?? l10n.message(0),
            ),
            autofocus: true,
            controller: messageController,
            maxLines: 4,
          ),
          const SizedBox(height: 12),
          if (widget.errorMessage != null)
            Text(
              widget.errorMessage!,
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.cancel),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: widget.errorMessage != null ? null : () => widget.onSubmit(messageController.text),
                child: Text(widget.submitLabel ?? l10n.submit),
              )
            ],
          ),
          const SizedBox(height: 16.0),
        ],
      ),
    );
  }
}
