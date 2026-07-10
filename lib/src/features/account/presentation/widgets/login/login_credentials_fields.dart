import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/src/core/config/global_context.dart';
import 'package:thunder/src/features/account/presentation/state/instance_validation_cubit.dart';
import 'package:thunder/src/core/domain/domain.dart';

/// Displays username, password, and optional one-time-password inputs.
class LoginCredentialsFields extends StatelessWidget {
  /// Creates the credential fields for authenticated login.
  const LoginCredentialsFields({
    super.key,
    required this.usernameController,
    required this.passwordController,
    required this.totpController,
    required this.usernameFocusNode,
    required this.isSubmitting,
    required this.onSubmit,
  });

  /// Controls the username input.
  final TextEditingController usernameController;

  /// Controls the password input.
  final TextEditingController passwordController;

  /// Controls the time-based one-time password input.
  final TextEditingController totpController;

  /// Receives focus when instance entry is complete.
  final FocusNode usernameFocusNode;

  /// Reports whether a session submission is in progress.
  final ValueListenable<bool> isSubmitting;

  /// Submits the current login form.
  final Future<void> Function() onSubmit;

  @override
  Widget build(BuildContext context) {
    final l10n = GlobalContext.l10n;

    return BlocSelector<InstanceValidationCubit, InstanceValidationState, ThreadiversePlatform?>(
      selector: (state) => state.instanceInfo?.platform ?? state.platform,
      builder: (context, platform) {
        final showTotp = platform != ThreadiversePlatform.piefed;

        return Column(
          spacing: 12.0,
          children: [
            AutofillGroup(
              child: Column(
                spacing: 12.0,
                children: [
                  TextField(
                    key: const Key('login-username-field'),
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.url,
                    autocorrect: false,
                    controller: usernameController,
                    focusNode: usernameFocusNode,
                    autofillHints: const [AutofillHints.username],
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: l10n.username,
                    ),
                    enableSuggestions: false,
                  ),
                  _LoginPasswordField(
                    usernameController: usernameController,
                    passwordController: passwordController,
                    isSubmitting: isSubmitting,
                    onSubmit: onSubmit,
                  ),
                ],
              ),
            ),
            if (showTotp)
              TextField(
                key: const Key('login-totp-field'),
                autocorrect: false,
                controller: totpController,
                maxLength: 6,
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: l10n.totp,
                  hintText: '000000',
                ),
                enableSuggestions: false,
              ),
          ],
        );
      },
    );
  }
}

class _LoginPasswordField extends StatefulWidget {
  const _LoginPasswordField({
    required this.usernameController,
    required this.passwordController,
    required this.isSubmitting,
    required this.onSubmit,
  });

  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final ValueListenable<bool> isSubmitting;
  final Future<void> Function() onSubmit;

  @override
  State<_LoginPasswordField> createState() => _LoginPasswordFieldState();
}

class _LoginPasswordFieldState extends State<_LoginPasswordField> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<InstanceValidationCubit, InstanceValidationState, _PasswordValidationState>(
      selector: (state) => _PasswordValidationState(isValid: state.isValid, platform: state.instanceInfo?.platform ?? state.platform),
      builder: (context, validation) {
        return ListenableBuilder(
          listenable: Listenable.merge([widget.usernameController, widget.passwordController, widget.isSubmitting]),
          builder: (context, _) {
            final l10n = GlobalContext.l10n;
            final canSubmit = !widget.isSubmitting.value && validation.isValid && widget.usernameController.text.isNotEmpty && widget.passwordController.text.isNotEmpty;

            return TextField(
              key: const Key('login-password-field'),
              onSubmitted: canSubmit ? (_) => widget.onSubmit() : null,
              autocorrect: false,
              controller: widget.passwordController,
              obscureText: _obscurePassword,
              enableSuggestions: false,
              maxLength: validation.platform?.maxPasswordLength ?? ThreadiversePlatform.piefed.maxPasswordLength,
              autofillHints: const [AutofillHints.password],
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: l10n.password,
                suffixIcon: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: IconButton(
                    key: const Key('login-password-visibility'),
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                      semanticLabel: _obscurePassword ? l10n.showPassword : l10n.hidePassword,
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _PasswordValidationState {
  const _PasswordValidationState({required this.isValid, required this.platform});

  final bool isValid;
  final ThreadiversePlatform? platform;

  @override
  bool operator ==(Object other) => other is _PasswordValidationState && other.isValid == isValid && other.platform == platform;

  @override
  int get hashCode => Object.hash(isValid, platform);
}
