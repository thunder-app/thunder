import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import 'package:flutter_typeahead/flutter_typeahead.dart';

import 'package:thunder/packages/ui/src/widgets/dialogs/thunder_dialog.dart';

/// Shows a typeahead dialog backed by [showThunderDialog].
///
/// The primary action stays disabled until the input field contains text.
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
  final contentKey = GlobalKey<_ThunderTypeaheadDialogContentState<T>>();

  await showThunderDialog(
    context: context,
    title: title,
    onSecondaryButtonPressed: (dialogContext) => Navigator.of(dialogContext).pop(),
    secondaryButtonText: secondaryButtonText,
    primaryButtonInitialEnabled: false,
    onPrimaryButtonPressed: (dialogContext, setPrimaryButtonEnabled) async {
      setPrimaryButtonEnabled(false);
      final submitError = await onSubmitted(value: contentKey.currentState?.controller.text);
      contentKey.currentState?.setError(submitError);
    },
    primaryButtonText: primaryButtonText,
    contentWidgetBuilder: (setPrimaryButtonEnabled) => _ThunderTypeaheadDialogContent<T>(
      key: contentKey,
      inputLabel: inputLabel,
      setPrimaryButtonEnabled: setPrimaryButtonEnabled,
      onSubmitted: onSubmitted,
      getSuggestions: getSuggestions,
      suggestionBuilder: suggestionBuilder,
    ),
  );
}

class _ThunderTypeaheadDialogContent<T> extends StatefulWidget {
  const _ThunderTypeaheadDialogContent({
    super.key,
    required this.inputLabel,
    required this.setPrimaryButtonEnabled,
    required this.onSubmitted,
    required this.getSuggestions,
    required this.suggestionBuilder,
  });

  final String inputLabel;
  final void Function(bool) setPrimaryButtonEnabled;
  final Future<String?> Function({T? payload, String? value}) onSubmitted;
  final FutureOr<List<T>?> Function(String query) getSuggestions;
  final Widget Function(T payload) suggestionBuilder;

  @override
  State<_ThunderTypeaheadDialogContent<T>> createState() => _ThunderTypeaheadDialogContentState<T>();
}

class _ThunderTypeaheadDialogContentState<T> extends State<_ThunderTypeaheadDialogContent<T>> {
  late final TextEditingController controller;
  String? _errorText;

  void setError(String? error) {
    setState(() => _errorText = error);
  }

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _submit({T? payload, String? value}) async {
    widget.setPrimaryButtonEnabled(false);
    final submitError = await widget.onSubmitted(payload: payload, value: value);
    setError(submitError);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: min(MediaQuery.sizeOf(context).width, 700),
      child: TypeAheadField<T>(
        controller: controller,
        builder: (context, textController, focusNode) => TextField(
          controller: textController,
          focusNode: focusNode,
          onChanged: (value) {
            widget.setPrimaryButtonEnabled(value.trim().isNotEmpty);
            setError(null);
          },
          autofocus: true,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            labelText: widget.inputLabel,
            errorText: _errorText,
          ),
          onSubmitted: (text) => _submit(value: text),
        ),
        suggestionsCallback: widget.getSuggestions,
        itemBuilder: (context, payload) => widget.suggestionBuilder(payload),
        onSelected: (payload) => _submit(payload: payload),
        hideOnEmpty: true,
        hideOnLoading: true,
        hideOnError: true,
      ),
    );
  }
}
