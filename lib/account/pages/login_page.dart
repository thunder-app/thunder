import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/utils/text_input_formatter.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback popRegister;

  const LoginPage({super.key, required this.popRegister});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late TextEditingController _usernameTextEditingController;
  late TextEditingController _passwordTextEditingController;
  late TextEditingController _instanceTextEditingController;

  bool showPassword = false;
  bool fieldsFilledIn = false;

  @override
  void initState() {
    super.initState();
    _usernameTextEditingController = TextEditingController();
    _passwordTextEditingController = TextEditingController();
    _instanceTextEditingController = TextEditingController();

    _usernameTextEditingController.addListener(() {
      if (_usernameTextEditingController.text.isNotEmpty && _passwordTextEditingController.text.isNotEmpty && _instanceTextEditingController.text.isNotEmpty) {
        setState(() => fieldsFilledIn = true);
      } else {
        setState(() => fieldsFilledIn = false);
      }
    });

    _passwordTextEditingController.addListener(() {
      if (_usernameTextEditingController.text.isNotEmpty && _passwordTextEditingController.text.isNotEmpty && _instanceTextEditingController.text.isNotEmpty) {
        setState(() => fieldsFilledIn = true);
      } else {
        setState(() => fieldsFilledIn = false);
      }
    });

    _instanceTextEditingController.addListener(() {
      if (_usernameTextEditingController.text.isNotEmpty && _passwordTextEditingController.text.isNotEmpty && _instanceTextEditingController.text.isNotEmpty) {
        setState(() => fieldsFilledIn = true);
      } else {
        setState(() => fieldsFilledIn = false);
      }
    });
  }

  @override
  void dispose() {
    _usernameTextEditingController.dispose();
    _passwordTextEditingController.dispose();
    _instanceTextEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        left: 12.0,
        right: 12.0,
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset('assets/logo.png', width: 196.0, height: 196.0),
              const SizedBox(height: 12.0),
              AutofillGroup(
                child: Column(
                  children: <Widget>[
                    TextField(
                      autocorrect: false,
                      controller: _usernameTextEditingController,
                      autofillHints: const [AutofillHints.username],
                      decoration: const InputDecoration(
                        isDense: true,
                        border: OutlineInputBorder(),
                        labelText: 'Username',
                      ),
                      enableSuggestions: false,
                    ),
                    const SizedBox(height: 12.0),
                    TextField(
                      autocorrect: false,
                      controller: _passwordTextEditingController,
                      obscureText: !showPassword,
                      enableSuggestions: false,
                      maxLength: 60, // This is what lemmy retricts password length to
                      autofillHints: const [AutofillHints.password],
                      decoration: InputDecoration(
                        isDense: true,
                        border: const OutlineInputBorder(),
                        labelText: 'Password',
                        suffixIcon: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: IconButton(
                            icon: Icon(
                              showPassword ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                              semanticLabel: showPassword ? 'Hide Password' : 'Show Password',
                            ),
                            onPressed: () {
                              setState(() {
                                showPassword = !showPassword;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12.0),
              TextField(
                autocorrect: false,
                controller: _instanceTextEditingController,
                inputFormatters: [LowerCaseTextFormatter()],
                decoration: const InputDecoration(
                  isDense: true,
                  border: OutlineInputBorder(),
                  labelText: 'Instance',
                  hintText: 'lemmy.ml',
                ),
                enableSuggestions: false,
              ),
              const SizedBox(height: 32.0),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(60),
                  backgroundColor: theme.colorScheme.primary,
                  textStyle: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
                onPressed: (_usernameTextEditingController.text.isNotEmpty && _passwordTextEditingController.text.isNotEmpty && _instanceTextEditingController.text.isNotEmpty)
                    ? () {
                        TextInput.finishAutofillContext();
                        // Perform login authentication
                        context.read<AuthBloc>().add(
                              LoginAttempt(
                                username: _usernameTextEditingController.text,
                                password: _passwordTextEditingController.text,
                                instance: _instanceTextEditingController.text.trim(),
                              ),
                            );
                        context.pop();
                      }
                    : null,
                child: Text('Login', style: theme.textTheme.titleMedium?.copyWith(color: fieldsFilledIn ? theme.colorScheme.onPrimary : theme.colorScheme.primary)),
              ),
              TextButton(
                style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(60)),
                onPressed: () => widget.popRegister(),
                child: Text('Cancel', style: theme.textTheme.titleMedium),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
