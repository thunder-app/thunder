import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/utils/text_input_formatter.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

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
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset('assets/logo.png', width: 196.0, height: 196.0),
              const SizedBox(height: 12.0),
              TextField(
                controller: _usernameTextEditingController,
                decoration: const InputDecoration(
                  isDense: true,
                  border: OutlineInputBorder(),
                  labelText: 'Username',
                ),
                enableSuggestions: false,
              ),
              const SizedBox(height: 12.0),
              TextField(
                controller: _passwordTextEditingController,
                obscureText: !showPassword,
                enableSuggestions: false,
                decoration: InputDecoration(
                  isDense: true,
                  border: const OutlineInputBorder(),
                  labelText: 'Password',
                  suffixIcon: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: IconButton(
                      icon: Icon(showPassword ? Icons.visibility_rounded : Icons.visibility_off_rounded),
                      onPressed: () {
                        setState(() {
                          showPassword = !showPassword;
                        });
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12.0),
              TextField(
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
                style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(60)),
                onPressed: (_usernameTextEditingController.text.isNotEmpty && _passwordTextEditingController.text.isNotEmpty && _instanceTextEditingController.text.isNotEmpty)
                    ? () => {
                          // Perform login authentication
                          context.read<AuthBloc>().add(LoginAttempt(
                                username: _usernameTextEditingController.text,
                                password: _passwordTextEditingController.text,
                                instance: _instanceTextEditingController.text,
                              ))
                        }
                    : null,
                child: Text('Login', style: theme.textTheme.titleMedium),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
