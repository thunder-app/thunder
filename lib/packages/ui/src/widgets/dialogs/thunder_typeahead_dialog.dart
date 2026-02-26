import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import 'package:flutter_typeahead/flutter_typeahead.dart';

import 'package:thunder/packages/ui/src/widgets/dialogs/thunder_dialog.dart';

Future<void> showThunderTypeaheadDialog<T>({
  required BuildContext context,
  required String title,
  required String inputLabel,
  required String primaryButtonText,
  required String secondaryButtonText,
  required Future<String?> Function({T? payload, String? value}) onSubmitted,
  required FutureOr<List<T>?> Function(String query) getSuggestions,
  required Widget Function(T payload) suggestionBuilder,
}) async {
  final textController = TextEditingController();
  StateSetter? contentWidgetSetState;
  String? contentWidgetError;

  await showThunderDialog(
    context: context,
    title: title,
    onSecondaryButtonPressed: (dialogContext) => Navigator.of(dialogContext).pop(),
    secondaryButtonText: secondaryButtonText,
    primaryButtonInitialEnabled: false,
    onPrimaryButtonPressed: (dialogContext, setPrimaryButtonEnabled) async {
      setPrimaryButtonEnabled(false);
      final submitError = await onSubmitted(value: textController.text);
      contentWidgetSetState?.call(() => contentWidgetError = submitError);
    },
    primaryButtonText: primaryButtonText,
    contentWidgetBuilder: (setPrimaryButtonEnabled) => StatefulBuilder(
      builder: (context, setState) {
        contentWidgetSetState = setState;

        return SizedBox(
          width: min(MediaQuery.of(context).size.width, 700),
          child: TypeAheadField<T>(
            controller: textController,
            builder: (context, controller, focusNode) => TextField(
              controller: controller,
              focusNode: focusNode,
              onChanged: (value) {
                setPrimaryButtonEnabled(value.trim().isNotEmpty);
                setState(() => contentWidgetError = null);
              },
              autofocus: true,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: inputLabel,
                errorText: contentWidgetError,
              ),
              onSubmitted: (text) async {
                setPrimaryButtonEnabled(false);
                final submitError = await onSubmitted(value: text);
                setState(() => contentWidgetError = submitError);
              },
            ),
            suggestionsCallback: getSuggestions,
            itemBuilder: (context, payload) => suggestionBuilder(payload),
            onSelected: (payload) async {
              setPrimaryButtonEnabled(false);
              final submitError = await onSubmitted(payload: payload);
              setState(() => contentWidgetError = submitError);
            },
            hideOnEmpty: true,
            hideOnLoading: true,
            hideOnError: true,
          ),
        );
      },
    ),
  );
}
