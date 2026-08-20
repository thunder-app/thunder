import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

import 'package:thunder/l10n/generated/app_localizations.dart';
import 'package:thunder/src/features/account/presentation/state/instance_validation_cubit.dart';
import 'package:thunder/src/features/instance/data/constants/known_instances.dart';

/// Displays instance suggestions and live validation feedback.
class LoginInstanceField extends StatelessWidget {
  /// Creates an instance input field.
  const LoginInstanceField({super.key, required this.anonymous, required this.controller, required this.usernameFocusNode, required this.submissionError, required this.onSubmit});

  /// Whether a valid submitted host should immediately add an anonymous session.
  final bool anonymous;

  /// Controls the instance host input.
  final TextEditingController controller;

  /// Receives focus after an authenticated instance is submitted.
  final FocusNode usernameFocusNode;

  /// Reports instance errors discovered during submission.
  final ValueListenable<String?> submissionError;

  /// Submits the current login form.
  final Future<void> Function() onSubmit;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<InstanceValidationCubit, InstanceValidationState, _LoginInstanceFieldState>(
      selector: (state) => _LoginInstanceFieldState(input: state.input, status: state.status),
      builder: (context, state) {
        return ValueListenableBuilder<String?>(
          valueListenable: submissionError,
          builder: (context, submissionError, _) {
            final l10n = AppLocalizations.of(context)!;
            final validationError = state.status == InstanceValidationStatus.invalid ? l10n.notValidLemmyInstance(state.input) : null;

            return TypeAheadField<String>(
              controller: controller,
              builder: (context, textController, focusNode) => TextField(
                key: const Key('login-instance-field'),
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.url,
                autocorrect: false,
                controller: textController,
                focusNode: focusNode,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: l10n.instance(1),
                  errorText: submissionError ?? validationError,
                  errorMaxLines: 2,
                  suffixIcon: switch (state.status) {
                    InstanceValidationStatus.detecting => Padding(
                      padding: const EdgeInsets.all(14),
                      child: Semantics(
                        label: l10n.loading,
                        child: const SizedBox.square(key: Key('login-instance-detecting'), dimension: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                      ),
                    ),
                    InstanceValidationStatus.valid => const Icon(Icons.check_circle_rounded, key: Key('login-instance-valid')),
                    _ => null,
                  },
                ),
                enableSuggestions: false,
                onSubmitted: anonymous
                    ? state.status == InstanceValidationStatus.valid
                          ? (_) => onSubmit()
                          : null
                    : (_) => usernameFocusNode.requestFocus(),
              ),
              suggestionsCallback: (pattern) {
                if (pattern.isEmpty) return const <String>[];
                return knownInstances.keys.where((instance) => instance.contains(pattern)).toList();
              },
              itemBuilder: (context, instance) => ListTile(title: Text(instance)),
              onSelected: (suggestion) => controller.text = suggestion,
              hideOnEmpty: true,
              hideOnLoading: true,
              hideOnError: true,
            );
          },
        );
      },
    );
  }
}

class _LoginInstanceFieldState {
  const _LoginInstanceFieldState({required this.input, required this.status});

  final String input;
  final InstanceValidationStatus status;

  @override
  bool operator ==(Object other) => other is _LoginInstanceFieldState && other.input == input && other.status == status;

  @override
  int get hashCode => Object.hash(input, status);
}
