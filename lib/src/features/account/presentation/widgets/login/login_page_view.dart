import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'package:thunder/src/features/account/presentation/widgets/login/login_action_buttons.dart';
import 'package:thunder/src/features/account/presentation/widgets/login/login_credentials_fields.dart';
import 'package:thunder/src/features/account/presentation/widgets/login/login_instance_field.dart';
import 'package:thunder/src/features/account/presentation/widgets/login/login_instance_header.dart';

/// Renders the login form while delegating validation and submission effects.
class LoginPageView extends StatelessWidget {
  /// Creates the presentation for a login or anonymous-instance flow.
  const LoginPageView({
    super.key,
    required this.anonymous,
    required this.instanceController,
    required this.usernameController,
    required this.passwordController,
    required this.totpController,
    required this.usernameFocusNode,
    required this.submitting,
    required this.submissionInstanceError,
    required this.onSubmit,
    required this.onCancel,
    required this.onOpenGettingStarted,
    required this.onOpenInstance,
    required this.onCreateAccount,
  });

  /// Whether credentials are omitted while adding an anonymous session.
  final bool anonymous;

  /// Controls the instance host field.
  final TextEditingController instanceController;

  /// Controls the username field.
  final TextEditingController usernameController;

  /// Controls the password field.
  final TextEditingController passwordController;

  /// Controls the time-based one-time password field.
  final TextEditingController totpController;

  /// Receives focus after an authenticated instance is submitted.
  final FocusNode usernameFocusNode;

  /// Reports whether a session submission is in progress.
  final ValueListenable<bool> submitting;

  /// Reports instance errors discovered during submission.
  final ValueListenable<String?> submissionInstanceError;

  /// Submits the current login form.
  final Future<void> Function() onSubmit;

  /// Cancels the current login flow.
  final VoidCallback onCancel;

  /// Opens the instance-discovery website.
  final VoidCallback onOpenGettingStarted;

  /// Opens the detected instance host.
  final ValueChanged<String> onOpenInstance;

  /// Opens account registration for the detected instance host.
  final ValueChanged<String> onCreateAccount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.cardColor,
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: EdgeInsets.only(left: 12.0, right: 12.0, bottom: MediaQuery.viewInsetsOf(context).bottom),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                LoginInstanceHeader(anonymous: anonymous, onOpenGettingStarted: onOpenGettingStarted, onOpenInstance: onOpenInstance, onCreateAccount: onCreateAccount),
                const SizedBox(height: 12.0),
                LoginInstanceField(anonymous: anonymous, controller: instanceController, usernameFocusNode: usernameFocusNode, submissionError: submissionInstanceError, onSubmit: onSubmit),
                if (!anonymous) ...[
                  const SizedBox(height: 32.0),
                  LoginCredentialsFields(
                    usernameController: usernameController,
                    passwordController: passwordController,
                    totpController: totpController,
                    usernameFocusNode: usernameFocusNode,
                    isSubmitting: submitting,
                    onSubmit: onSubmit,
                  ),
                ],
                const SizedBox(height: 32.0),
                LoginActionButtons(
                  anonymous: anonymous,
                  instanceController: instanceController,
                  usernameController: usernameController,
                  passwordController: passwordController,
                  submitting: submitting,
                  onSubmit: onSubmit,
                  onCancel: onCancel,
                ),
                const SizedBox(height: 32.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
