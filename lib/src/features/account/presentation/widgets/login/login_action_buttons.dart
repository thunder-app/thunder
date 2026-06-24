import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/src/foundation/config/global_context.dart';
import 'package:thunder/src/features/account/presentation/state/instance_validation_cubit.dart';

/// Displays submission and cancellation actions for the login form.
class LoginActionButtons extends StatelessWidget {
  /// Creates login form actions.
  const LoginActionButtons({
    super.key,
    required this.anonymous,
    required this.instanceController,
    required this.usernameController,
    required this.passwordController,
    required this.submitting,
    required this.onSubmit,
    required this.onCancel,
  });

  /// Whether the primary action adds an anonymous session.
  final bool anonymous;

  /// Controls the instance host input used to determine form completeness.
  final TextEditingController instanceController;

  /// Controls the username input used to determine form completeness.
  final TextEditingController usernameController;

  /// Controls the password input used to determine form completeness.
  final TextEditingController passwordController;

  /// Reports whether a session submission is in progress.
  final ValueListenable<bool> submitting;

  /// Submits the current login form.
  final Future<void> Function() onSubmit;

  /// Cancels the current login flow.
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<InstanceValidationCubit, InstanceValidationState, bool>(
      selector: (state) => state.isValid,
      builder: (context, isValid) {
        return ListenableBuilder(
          listenable: Listenable.merge([instanceController, usernameController, passwordController, submitting]),
          builder: (context, _) {
            final theme = Theme.of(context);
            final l10n = GlobalContext.l10n;

            final fieldsAreFilled = instanceController.text.isNotEmpty && (anonymous || (usernameController.text.isNotEmpty && passwordController.text.isNotEmpty));
            final canSubmit = !submitting.value && isValid && fieldsAreFilled;

            return Column(
              spacing: 12.0,
              children: [
                FilledButton(
                  key: const Key('login-submit-button'),
                  style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(60.0)),
                  onPressed: canSubmit ? onSubmit : null,
                  child: Text(anonymous ? l10n.add : l10n.login, style: theme.textTheme.titleMedium),
                ),
                TextButton(
                  key: const Key('login-cancel-button'),
                  style: TextButton.styleFrom(minimumSize: const Size.fromHeight(60.0)),
                  onPressed: submitting.value ? null : onCancel,
                  child: Text(l10n.cancel, style: theme.textTheme.titleMedium),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
