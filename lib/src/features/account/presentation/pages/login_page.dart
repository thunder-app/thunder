import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/core/enums/threadiverse_platform.dart';
import 'package:thunder/src/core/models/thunder_instance_info.dart';
import 'package:thunder/instances.dart';
import 'package:thunder/src/shared/dialogs.dart';
import 'package:thunder/src/shared/snackbar.dart';
import 'package:thunder/src/app/bloc/thunder_bloc.dart';
import 'package:thunder/src/app/utils/global_context.dart';
import 'package:thunder/src/shared/utils/instance.dart';
import 'package:thunder/src/shared/utils/links.dart';
import 'package:thunder/src/shared/utils/text_input_formatter.dart';
import 'package:thunder/l10n/generated/app_localizations.dart';

class LoginPage extends StatefulWidget {
  /// The callback to pop the register page.
  final VoidCallback popRegister;

  /// The callback to pop the modal.
  final VoidCallback popModal;

  /// Whether to login as an anonymous user.
  final bool anonymous;

  const LoginPage({super.key, required this.popRegister, required this.popModal, this.anonymous = false});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  /// The controller for the instance text field.
  late TextEditingController _instanceTextEditingController;

  /// The controller for the username text field.
  late TextEditingController _usernameTextEditingController;

  /// The controller for the password text field.
  late TextEditingController _passwordTextEditingController;

  /// The controller for the TOTP text field.
  late TextEditingController _totpTextEditingController;

  /// The focus node for the username field.
  final FocusNode _usernameFieldFocusNode = FocusNode();

  /// The instance info for the current instance.
  ThunderInstanceInfo? instanceInfo;

  bool showPassword = false;
  Timer? instanceTextDebounceTimer;
  Timer? instanceValidationDebounceTimer;
  String? instanceError;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    _usernameTextEditingController = TextEditingController();
    _passwordTextEditingController = TextEditingController();
    _totpTextEditingController = TextEditingController();
    _instanceTextEditingController = TextEditingController();

    _usernameTextEditingController.addListener(() => setState(() {}));
    _passwordTextEditingController.addListener(() => setState(() {}));

    // Fetches the instance information and updates the icon
    _instanceTextEditingController.addListener(() async {
      if (instanceTextDebounceTimer?.isActive == true) instanceTextDebounceTimer!.cancel();
      instanceTextDebounceTimer = Timer(const Duration(milliseconds: 300), () async {
        if (_instanceTextEditingController.text.isEmpty) return;
        final instanceInfo = await getInstanceInfo(_instanceTextEditingController.text);

        if (instanceInfo.success) {
          return setState(() {
            this.instanceInfo = instanceInfo;
            instanceError = null;
          });
        }

        setState(() {
          this.instanceInfo = null;
          instanceError = GlobalContext.l10n.notValidLemmyInstance(_instanceTextEditingController.text);
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

  bool _areFieldsFilledIn() {
    if (widget.anonymous) {
      return _instanceTextEditingController.text.isNotEmpty;
    } else {
      return _instanceTextEditingController.text.isNotEmpty && _usernameTextEditingController.text.isNotEmpty && _passwordTextEditingController.text.isNotEmpty;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = GlobalContext.l10n;
    final theme = Theme.of(context);

    return MultiBlocListener(
      listeners: [
        BlocListener<ProfileBloc, ProfileState>(
          listenWhen: (previous, current) {
            if (previous.status == ProfileStatus.initial && current.status == ProfileStatus.success) {
              widget.popModal();
              showSnackbar(l10n.loginSucceeded);
            }
            return true;
          },
          listener: (listenerContext, state) async {
            if (state.status == ProfileStatus.loading) {
              setState(() => isLoading = true);
            } else if (state.status == ProfileStatus.failure) {
              setState(() => isLoading = false);
              showSnackbar(l10n.loginFailed(state.error ?? l10n.missingErrorMessage));
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
                    crossFadeState: instanceInfo?.icon == null ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                    firstChild: Image.asset('assets/logo.png', width: 80.0, height: 80.0),
                    secondChild: instanceInfo?.icon == null
                        ? Container()
                        : CircleAvatar(
                            foregroundImage: CachedNetworkImageProvider(instanceInfo!.icon!),
                            backgroundColor: Colors.transparent,
                            maxRadius: 40,
                          ),
                  ),
                  const SizedBox(height: 12.0),
                  AnimatedCrossFade(
                    crossFadeState: _instanceTextEditingController.text.isNotEmpty && instanceError == null ? CrossFadeState.showSecond : CrossFadeState.showFirst,
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
                    secondChild: Column(
                      spacing: 8.0,
                      children: [
                        // TODO: Remove once PieFed support is stable
                        if (instanceInfo?.platform == ThreadiversePlatform.piefed) ...[
                          Text(
                            'PieFed support is currently in beta.\nNot all features are supported yet.',
                            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.secondary),
                            textAlign: TextAlign.center,
                          ),
                        ],
                        Row(
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
                        border: const OutlineInputBorder(),
                        labelText: AppLocalizations.of(context)!.instance(1),
                        errorText: instanceError,
                        errorMaxLines: 2,
                      ),
                      enableSuggestions: false,
                      onSubmitted: !widget.anonymous
                          ? (_) => _usernameFieldFocusNode.requestFocus()
                          : controller.text.isNotEmpty
                              ? (_) => _handleLogin()
                              : null,
                    ),
                    suggestionsCallback: (String pattern) {
                      if (pattern.isNotEmpty != true) return [];
                      return instances.where((instance) => instance.contains(pattern)).toList();
                    },
                    itemBuilder: (BuildContext context, String itemData) {
                      return ListTile(title: Text(itemData));
                    },
                    onSelected: (String suggestion) {
                      _instanceTextEditingController.text = suggestion;
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
                            focusNode: _usernameFieldFocusNode,
                            autofillHints: const [AutofillHints.username],
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              labelText: AppLocalizations.of(context)!.username,
                            ),
                            enableSuggestions: false,
                          ),
                          const SizedBox(height: 12.0),
                          TextField(
                            onSubmitted: (!isLoading && _areFieldsFilledIn()) ? (_) => _handleLogin() : null,
                            autocorrect: false,
                            controller: _passwordTextEditingController,
                            obscureText: !showPassword,
                            enableSuggestions: false,
                            maxLength: 60, // This is what lemmy retricts password length to
                            autofillHints: const [AutofillHints.password],
                            decoration: InputDecoration(
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
                    onPressed: (isLoading || !_areFieldsFilledIn()) ? null : _handleLogin,
                    child: Text(
                      widget.anonymous ? l10n.add : l10n.login,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: !isLoading && _areFieldsFilledIn() ? theme.colorScheme.onPrimary : theme.colorScheme.primary,
                      ),
                    ),
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

  void _handleLogin() async {
    final l10n = GlobalContext.l10n;

    // Prevent login if we cannot detect the platform
    if (instanceInfo?.platform == null) {
      showSnackbar(l10n.notValidLemmyInstance(_instanceTextEditingController.text));
      return;
    }

    // If the instance has a content warning, display it and ask the user to accept it before proceeding
    if (instanceInfo?.contentWarning != null) {
      bool acceptedContentWarning = false;

      await showThunderDialog<void>(
        context: context,
        title: l10n.contentWarning,
        contentText: instanceInfo?.contentWarning,
        onSecondaryButtonPressed: (dialogContext) => Navigator.of(dialogContext).pop(),
        secondaryButtonText: l10n.decline,
        onPrimaryButtonPressed: (dialogContext, _) async {
          Navigator.of(dialogContext).pop();
          acceptedContentWarning = true;
        },
        primaryButtonText: l10n.accept,
      );

      if (!acceptedContentWarning) return;
    }

    TextInput.finishAutofillContext();

    // Handle anonymous login
    if (widget.anonymous) {
      final anonymousInstances = await Account.anonymousInstances();

      if (anonymousInstances.any((anonymousInstance) => anonymousInstance.instance == _instanceTextEditingController.text)) {
        setState(() => instanceError = l10n.instanceHasAlreadyBenAdded(_instanceTextEditingController.text));
        return;
      }

      await Account.insertAnonymousInstance(Account(
        id: '',
        instance: _instanceTextEditingController.text,
        index: -1,
        anonymous: true,
        platform: instanceInfo?.platform,
      ));

      context.read<ThunderBloc>().add(OnSetCurrentAnonymousInstance(_instanceTextEditingController.text));
      context.read<ProfileBloc>().add(SwitchProfile(accountId: _instanceTextEditingController.text));
      widget.popRegister();

      return;
    }

    // Perform login authentication
    context.read<ProfileBloc>().add(
          AddProfile(
            username: _usernameTextEditingController.text,
            password: _passwordTextEditingController.text,
            instance: _instanceTextEditingController.text.trim(),
            totp: _totpTextEditingController.text,
            showContentWarning: false,
          ),
        );
  }
}
