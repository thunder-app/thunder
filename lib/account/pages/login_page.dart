import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/utils/instance.dart';
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
  late TextEditingController _totpTextEditingController;
  late TextEditingController _instanceTextEditingController;

  bool showPassword = false;
  bool fieldsFilledIn = false;
  String? instanceIcon;
  String? currentInstance;
  Timer? instanceTextDebounceTimer;
  
  bool isLoading = false;
  bool isFailure = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _usernameTextEditingController = TextEditingController();
    _passwordTextEditingController = TextEditingController();
    _totpTextEditingController = TextEditingController();
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

    _instanceTextEditingController.addListener(() async {
      if (currentInstance != _instanceTextEditingController.text) {
        setState(() => instanceIcon = null);
        currentInstance = _instanceTextEditingController.text;
      }

      if (_usernameTextEditingController.text.isNotEmpty && _passwordTextEditingController.text.isNotEmpty && _instanceTextEditingController.text.isNotEmpty) {
        setState(() => fieldsFilledIn = true);
      } else {
        setState(() => fieldsFilledIn = false);
      }
      
      // Debounce
      if (instanceTextDebounceTimer?.isActive == true) {
        instanceTextDebounceTimer!.cancel();
      }
      instanceTextDebounceTimer = Timer(const Duration(milliseconds: 500), () async {
        await getInstanceIcon(_instanceTextEditingController.text).then((value) { 
          // Make sure the icon we looked up still matches the text
          if (currentInstance == _instanceTextEditingController.text) {
            setState(() => instanceIcon = value);
          }
        });
      });
    });
  }

  @override
  void dispose() {
    _usernameTextEditingController.dispose();
    _passwordTextEditingController.dispose();
    _totpTextEditingController.dispose();
    _instanceTextEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MultiBlocListener(
      listeners: [
        BlocListener<AuthBloc, AuthState>(
          listener: (listenerContext, state) {
            if (state.status == AuthStatus.loading) {
              setState(() {
                isLoading = true;
                isFailure = false;
              });
            } else if (state.status == AuthStatus.failure) {
              setState(() {
                isLoading = false;
                isFailure = true;
                errorMessage = state.errorMessage ?? 'Unknown';
              });
            } else if (state.status == AuthStatus.success) {
              context.pop();
            }
          }
        ),
      ],
      child: Padding(
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
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 500),
                  crossFadeState: instanceIcon == null
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,
                  firstChild: Image.asset('assets/logo.png', width: 80.0, height: 80.0),
                  secondChild: instanceIcon == null
                    ? Container()
                    : CircleAvatar(
                        foregroundImage: CachedNetworkImageProvider(instanceIcon!),
                        backgroundColor: Colors.transparent,
                        maxRadius: 40,
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
                    hintText: 'e.g., lemmy.ml, lemmy.world, etc.',
                  ),
                  enableSuggestions: false,
                ),
                const SizedBox(height: 35.0),
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
                  controller: _totpTextEditingController,
                  maxLength: 6,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    isDense: true,
                    border: OutlineInputBorder(),
                    labelText: 'TOTP (optional)',
                    hintText: '000000',
                  ),
                  enableSuggestions: false,
                ),
                Opacity(
                  opacity: isFailure
                    ? 1
                    : 0,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 10),
                    child: Text(
                      'Login failed, please try again ($errorMessage)',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w500
                      ),
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(60),
                    backgroundColor: theme.colorScheme.primary,
                    textStyle: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onPrimary,
                    ),
                  ),
                  onPressed: (!isLoading && _passwordTextEditingController.text.isNotEmpty && _passwordTextEditingController.text.isNotEmpty && _instanceTextEditingController.text.isNotEmpty)
                      ? () {
                          TextInput.finishAutofillContext();
                          // Perform login authentication
                          context.read<AuthBloc>().add(
                                LoginAttempt(
                                  username: _usernameTextEditingController.text,
                                  password: _passwordTextEditingController.text,
                                  instance: _instanceTextEditingController.text.trim(),
                                  totp: _totpTextEditingController.text,
                                ),
                              );
                        }
                      : null,
                  child: Text('Login', style: theme.textTheme.titleMedium?.copyWith(color: !isLoading && fieldsFilledIn ? theme.colorScheme.onPrimary : theme.colorScheme.primary)),
                ),
                TextButton(
                  style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(60)),
                  onPressed: !isLoading
                    ? () => widget.popRegister()
                    : null,
                  child: Text('Cancel', style: theme.textTheme.titleMedium),
                ),
                const SizedBox(height: 32.0),
              ],
            ),
          ),
        ),
      )
    );
  }
}
