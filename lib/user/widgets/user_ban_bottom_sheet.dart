import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:thunder/settings/widgets/toggle_option.dart';

class UserBanBottomSheet extends StatefulWidget {
  const UserBanBottomSheet({super.key, this.title, this.textHint, this.submitLabel, this.errorMessage, required this.onSubmit});

  /// A custom title of the bottom sheet. Defaults to "Reason"
  final String? title;

  /// A custom text hint of the text field. Defaults to "Message"
  final String? textHint;

  /// A custom label of the submit button. Defaults to "Submit"
  final String? submitLabel;

  /// An error message to display
  final String? errorMessage;

  /// Callback function which triggers when the submit button is pressed
  final Function({String? reason, int? expiration, bool? removeData}) onSubmit;

  @override
  State<UserBanBottomSheet> createState() => _UserBanBottomSheetState();
}

class _UserBanBottomSheetState extends State<UserBanBottomSheet> {
  late TextEditingController reasonController;
  late TextEditingController expirationController;

  DateTime? expiration;
  bool removeData = false;

  @override
  void initState() {
    reasonController = TextEditingController();
    expirationController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    reasonController.dispose();
    expirationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.only(left: 26.0, right: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.title ?? l10n.reason,
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 20.0),
            TextFormField(
              controller: reasonController,
              decoration: InputDecoration(
                isDense: true,
                border: const OutlineInputBorder(),
                labelText: widget.textHint ?? l10n.message(0),
                alignLabelWithHint: true,
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 12.0),
            TextFormField(
              controller: expirationController,
              decoration: const InputDecoration(
                isDense: true,
                border: OutlineInputBorder(),
                labelText: 'Expiration Date',
              ),
              onTap: () async {
                final DateTime? selectedDateTime = await showDateTimePicker(
                  context: context,
                  initialDate: null,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
                );

                setState(() => expiration = selectedDateTime);

                if (selectedDateTime != null) {
                  expirationController.text = DateFormat.yMMMMd(Intl.systemLocale).add_jm().format(selectedDateTime);
                } else {
                  expirationController.text = '';
                }
              },
              validator: (value) {
                DateTime? dateTime = DateTime.tryParse(value ?? '');
                if (value != null && dateTime == null) return 'Invalid date';
                return null;
              },
            ),
            const SizedBox(height: 12.0),
            ToggleOption(
              padding: EdgeInsets.zero,
              description: 'Remove data',
              value: removeData,
              onToggle: (bool value) => setState(() => removeData = value),
              highlightKey: null,
              setting: null,
              highlightedSetting: null,
            ),
            const SizedBox(height: 36.0),
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
                  onPressed: widget.errorMessage != null ? null : () => widget.onSubmit(),
                  child: Text(widget.submitLabel ?? l10n.submit),
                )
              ],
            ),
            const SizedBox(height: 16.0),
          ],
        ),
      ),
    );
  }
}

Future<DateTime?> showDateTimePicker({
  required BuildContext context,
  DateTime? initialDate,
  DateTime? firstDate,
  DateTime? lastDate,
}) async {
  final DateTime? selectedDate = await showDatePicker(
    context: context,
    firstDate: DateTime.now(),
    lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
    initialEntryMode: DatePickerEntryMode.calendarOnly,
  );

  if (selectedDate == null) return null;
  if (!context.mounted) return selectedDate;

  final TimeOfDay? selectedTime = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.now(),
    initialEntryMode: TimePickerEntryMode.inputOnly,
  );

  return selectedTime == null
      ? selectedDate
      : DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          selectedTime.hour,
          selectedTime.minute,
        );
}
