import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thunder/core/auth/bloc/auth_bloc.dart';

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

  @override
  void initState() {
    super.initState();
    _usernameTextEditingController = TextEditingController();
    _passwordTextEditingController = TextEditingController();
    _instanceTextEditingController = TextEditingController();
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

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset('assets/logo.png', width: 196.0, height: 196.0),
        const SizedBox(height: 12.0),
        TextField(
          controller: _usernameTextEditingController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Username',
          ),
        ),
        const SizedBox(height: 12.0),
        TextField(
          controller: _passwordTextEditingController,
          obscureText: !showPassword,
          decoration: InputDecoration(
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
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Instance',
            hintText: 'lemmy.ml',
          ),
        ),
        const SizedBox(height: 32.0),
        ElevatedButton(
          style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(60)),
          onPressed: () => {
            // Perform login authentication
            context.read<AuthBloc>().add(LoginAttempt(
                  username: _usernameTextEditingController.value.text,
                  password: _passwordTextEditingController.value.text,
                  instance: _instanceTextEditingController.value.text,
                ))
          },
          child: Text('Login', style: theme.textTheme.titleMedium),
        ),
      ],
    );
  }
}
