import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:go_router/go_router.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/core/enums/local_settings.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/core/singletons/preferences.dart';
import 'package:thunder/instances.dart';
import 'package:thunder/shared/dialogs.dart';
import 'package:thunder/shared/snackbar.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/utils/instance.dart';
import 'package:thunder/utils/links.dart';
import 'package:thunder/utils/text_input_formatter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback popRegister;
  final bool anonymous;

  const LoginPage({super.key, required this.popRegister, this.anonymous = false});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  late TextEditingController _usernameTextEditingController;
  late TextEditingController _passwordTextEditingController;
  late TextEditingController _totpTextEditingController;
  late TextEditingController _instanceTextEditingController;

  bool showPassword = false;
  bool fieldsFilledIn = false;
  String? instanceIcon;
  String? currentInstance;
  Timer? instanceTextDebounceTimer;
  Timer? instanceValidationDebounceTimer;
  bool instanceValidated = true;
  bool instanceAwaitingValidation = true;
  String? instanceError;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _usernameTextEditingController = TextEditingController();
    _passwordTextEditingController = TextEditingController();
    _totpTextEditingController = TextEditingController();
    _instanceTextEditingController = TextEditingController();

    _usernameTextEditingController.addListener(() {
      if (_instanceTextEditingController.text.isNotEmpty && (widget.anonymous || (_usernameTextEditingController.text.isNotEmpty && _passwordTextEditingController.text.isNotEmpty))) {
        setState(() => fieldsFilledIn = true);
      } else {
        setState(() => fieldsFilledIn = false);
      }
    });

    _passwordTextEditingController.addListener(() {
      if (_instanceTextEditingController.text.isNotEmpty && (widget.anonymous || (_usernameTextEditingController.text.isNotEmpty && _passwordTextEditingController.text.isNotEmpty))) {
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

      if (_instanceTextEditingController.text.isNotEmpty && (widget.anonymous || (_usernameTextEditingController.text.isNotEmpty && _passwordTextEditingController.text.isNotEmpty))) {
        setState(() => fieldsFilledIn = true);
      } else {
        setState(() => fieldsFilledIn = false);
      }

      // Debounce
      if (instanceTextDebounceTimer?.isActive == true) {
        instanceTextDebounceTimer!.cancel();
      }
      instanceTextDebounceTimer = Timer(const Duration(milliseconds: 500), () async {
        await getInstanceInfo(_instanceTextEditingController.text).then((value) {
          // Make sure the icon we looked up still matches the text
          if (currentInstance == _instanceTextEditingController.text) {
            setState(() => instanceIcon = value.icon);
          }
        });
      });

      // Debounce
      setState(() {
        instanceAwaitingValidation = true;
      });
      if (instanceValidationDebounceTimer?.isActive == true) {
        instanceValidationDebounceTimer!.cancel();
      }
      instanceValidationDebounceTimer = Timer(const Duration(seconds: 1), () async {
        await (_instanceTextEditingController.text.isEmpty ? Future<bool>.value(true) : isLemmyInstance(_instanceTextEditingController.text)).then((value) => {
              if (currentInstance == _instanceTextEditingController.text)
                {
                  setState(() {
                    instanceAwaitingValidation = false;
                    instanceValidated = value;
                    instanceError = AppLocalizations.of(context)!.notValidLemmyInstance(currentInstance ?? '');
                  })
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
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return MultiBlocListener(
      listeners: [
        BlocListener<AuthBloc, AuthState>(
          listener: (listenerContext, state) async {
            if (state.status == AuthStatus.loading) {
              setState(() {
                isLoading = true;
              });
            } else if (state.status == AuthStatus.failure) {
              setState(() {
                isLoading = false;
              });

              showSnackbar(AppLocalizations.of(context)!.loginFailed(state.errorMessage ?? AppLocalizations.of(context)!.missingErrorMessage));
            } else if (state.status == AuthStatus.success && context.read<AuthBloc>().state.isLoggedIn) {
              context.pop();

              showSnackbar(AppLocalizations.of(context)!.loginSucceeded);
            } else if (state.status == AuthStatus.contentWarning) {
              bool acceptedContentWarning = false;

              await showThunderDialog<void>(
                context: context,
                title: l10n.contentWarning,
                contentText: state.contentWarning,
                onSecondaryButtonPressed: (dialogContext) => Navigator.of(dialogContext).pop(),
                secondaryButtonText: l10n.decline,
                onPrimaryButtonPressed: (dialogContext, _) async {
                  Navigator.of(dialogContext).pop();
                  acceptedContentWarning = true;
                },
                primaryButtonText: l10n.accept,
              );

              if (context.mounted) {
                if (acceptedContentWarning) {
                  // Do another login attempt, this time without the content warning
                  _handleLogin(showContentWarning: false);
                } else {
                  // Cancel the login
                  context.read<AuthBloc>().add(const CancelLoginAttempt());
                }
              }
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: theme.cardColor,
        resizeToAvoidBottomInset: false,
        body: Padding(
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
                    crossFadeState: instanceIcon == null ? CrossFadeState.showFirst : CrossFadeState.showSecond,
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
                  AnimatedCrossFade(
                    crossFadeState: _instanceTextEditingController.text.isNotEmpty && !instanceAwaitingValidation && instanceValidated ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 250),
                    firstChild: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        OutlinedButton(
                          onPressed: () {
                            handleLink(context, url: 'https://join-lemmy.org/');
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.only(left: 10, right: 16),
                            backgroundColor: theme.colorScheme.surface,
                            textStyle: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.onPrimary,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.insert_link_rounded,
                                color: theme.textTheme.bodySmall?.color,
                              ),
                              const SizedBox(
                                width: 8,
                              ),
                              Text(
                                AppLocalizations.of(context)!.gettingStarted,
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    secondChild: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        OutlinedButton(
                          onPressed: () {
                            handleLink(context, url: 'https://${_instanceTextEditingController.text}');
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.only(left: 10, right: 16),
                            backgroundColor: theme.colorScheme.surface,
                            textStyle: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.onPrimary,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.insert_link_rounded,
                                color: theme.textTheme.bodySmall?.color,
                              ),
                              const SizedBox(
                                width: 8,
                              ),
                              Text(
                                AppLocalizations.of(context)!.openInstance,
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        if (!widget.anonymous) ...[
                          const SizedBox(width: 12),
                          OutlinedButton(
                            onPressed: () {
                              handleLink(context, url: 'https://${_instanceTextEditingController.text}/signup');
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.only(left: 10, right: 16),
                              backgroundColor: theme.colorScheme.surface,
                              textStyle: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.onPrimary,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.insert_link_rounded,
                                  color: theme.textTheme.bodySmall?.color,
                                ),
                                const SizedBox(
                                  width: 8,
                                ),
                                Text(
                                  AppLocalizations.of(context)!.createAccount,
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  TypeAheadField<String>(
                    controller: _instanceTextEditingController,
                    builder: (context, controller, focusNode) => TextField(
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.url,
                      autocorrect: false,
                      controller: controller,
                      focusNode: focusNode,
                      inputFormatters: [LowerCaseTextFormatter()],
                      decoration: InputDecoration(
                        isDense: true,
                        border: const OutlineInputBorder(),
                        labelText: AppLocalizations.of(context)!.instance(1),
                        errorText: instanceValidated ? null : instanceError,
                        errorMaxLines: 2,
                      ),
                      enableSuggestions: false,
                      onSubmitted: (controller.text.isNotEmpty && widget.anonymous) ? (_) => _addAnonymousInstance(context) : null,
                    ),
                    suggestionsCallback: (String pattern) {
                      if (pattern.isNotEmpty != true) {
                        return [];
                      }
                      return instances.where((instance) => instance.contains(pattern)).toList();
                    },
                    itemBuilder: (BuildContext context, String itemData) {
                      return ListTile(title: Text(itemData));
                    },
                    onSelected: (String suggestion) {
                      _instanceTextEditingController.text = suggestion;
                      setState(() {
                        instanceValidated = true;
                      });
                    },
                    hideOnEmpty: true,
                    hideOnLoading: true,
                    hideOnError: true,
                  ),
                  if (!widget.anonymous) ...[
                    const SizedBox(height: 32.0),
                    AutofillGroup(
                      child: Column(
                        children: <Widget>[
                          TextField(
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.url,
                            autocorrect: false,
                            controller: _usernameTextEditingController,
                            autofillHints: const [AutofillHints.username],
                            decoration: InputDecoration(
                              isDense: true,
                              border: const OutlineInputBorder(),
                              labelText: AppLocalizations.of(context)!.username,
                            ),
                            enableSuggestions: false,
                          ),
                          const SizedBox(height: 12.0),
                          TextField(
                            onSubmitted:
                                (!isLoading && _passwordTextEditingController.text.isNotEmpty && _passwordTextEditingController.text.isNotEmpty && _instanceTextEditingController.text.isNotEmpty)
                                    ? (_) => _handleLogin()
                                    : (_instanceTextEditingController.text.isNotEmpty && widget.anonymous)
                                        ? (_) => _addAnonymousInstance(context)
                                        : null,
                            autocorrect: false,
                            controller: _passwordTextEditingController,
                            obscureText: !showPassword,
                            enableSuggestions: false,
                            maxLength: 60, // This is what lemmy retricts password length to
                            autofillHints: const [AutofillHints.password],
                            decoration: InputDecoration(
                              isDense: true,
                              border: const OutlineInputBorder(),
                              labelText: AppLocalizations.of(context)!.password,
                              suffixIcon: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                child: IconButton(
                                  icon: Icon(
                                    showPassword ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                                    semanticLabel: showPassword ? AppLocalizations.of(context)!.hidePassword : AppLocalizations.of(context)!.showPassword,
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
                      decoration: InputDecoration(
                        isDense: true,
                        border: const OutlineInputBorder(),
                        labelText: AppLocalizations.of(context)!.totp,
                        hintText: '000000',
                      ),
                      enableSuggestions: false,
                    ),
                  ],
                  const SizedBox(height: 32.0),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(60),
                      backgroundColor: theme.colorScheme.primary,
                      textStyle: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                    onPressed: (!isLoading && _passwordTextEditingController.text.isNotEmpty && _passwordTextEditingController.text.isNotEmpty && _instanceTextEditingController.text.isNotEmpty)
                        ? _handleLogin
                        : (_instanceTextEditingController.text.isNotEmpty && widget.anonymous)
                            ? () => _addAnonymousInstance(context)
                            : null,
                    child: Text(widget.anonymous ? AppLocalizations.of(context)!.add : AppLocalizations.of(context)!.login,
                        style: theme.textTheme.titleMedium?.copyWith(color: !isLoading && fieldsFilledIn ? theme.colorScheme.onPrimary : theme.colorScheme.primary)),
                  ),
                  const SizedBox(height: 12.0),
                  TextButton(
                    style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(60)),
                    onPressed: !isLoading ? () => widget.popRegister() : null,
                    child: Text(AppLocalizations.of(context)!.cancel, style: theme.textTheme.titleMedium),
                  ),
                  const SizedBox(height: 32.0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleLogin({bool showContentWarning = true}) {
    TextInput.finishAutofillContext();
    // Perform login authentication
    context.read<AuthBloc>().add(
          LoginAttempt(
            username: _usernameTextEditingController.text,
            password: _passwordTextEditingController.text,
            instance: _instanceTextEditingController.text.trim(),
            totp: _totpTextEditingController.text,
            showContentWarning: showContentWarning,
          ),
        );
  }

  void _addAnonymousInstance(BuildContext context) async {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    if (await isLemmyInstance(_instanceTextEditingController.text)) {
      final SharedPreferences prefs = (await UserPreferences.instance).sharedPreferences;
      List<String> anonymousInstances = prefs.getStringList(LocalSettings.anonymousInstances.name) ?? ['lemmy.ml'];
      if (anonymousInstances.contains(_instanceTextEditingController.text)) {
        setState(() {
          instanceValidated = false;
          instanceError = AppLocalizations.of(context)!.instanceHasAlreadyBenAdded(currentInstance ?? '');
        });
      } else {
        // Check for content warning on anyonmous instance
        GetSiteResponse getSiteResponse = await (LemmyClient()..changeBaseUrl(_instanceTextEditingController.text)).lemmyApiV3.run(const GetSite());

        bool acceptedContentWarning = true;

        if (getSiteResponse.siteView.site.contentWarning?.isNotEmpty == true) {
          acceptedContentWarning = false;

          await showThunderDialog<void>(
            context: context,
            title: l10n.contentWarning,
            contentText: getSiteResponse.siteView.site.contentWarning,
            onSecondaryButtonPressed: (dialogContext) => Navigator.of(dialogContext).pop(),
            secondaryButtonText: l10n.decline,
            onPrimaryButtonPressed: (dialogContext, _) async {
              Navigator.of(dialogContext).pop();
              acceptedContentWarning = true;
            },
            primaryButtonText: l10n.accept,
          );
        }

        if (acceptedContentWarning) {
          context.read<AuthBloc>().add(const LogOutOfAllAccounts());
          context.read<ThunderBloc>().add(OnAddAnonymousInstance(_instanceTextEditingController.text));
          context.read<ThunderBloc>().add(OnSetCurrentAnonymousInstance(_instanceTextEditingController.text));
          widget.popRegister();
        }
      }
    }
  }
}
