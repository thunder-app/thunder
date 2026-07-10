import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/src/core/navigation/link_navigation_utils.dart';
import 'package:thunder/src/core/app/dependency_factories.dart';
import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/features/account/presentation/state/instance_validation_cubit.dart';
import 'package:thunder/src/features/account/presentation/widgets/login/login_page_view.dart';
import 'package:thunder/src/features/instance/domain/models/instance_discovery_result.dart';
import 'package:thunder/src/features/session/api.dart';
import 'package:thunder/src/core/config/global_context.dart';
import 'package:thunder/packages/ui/ui.dart';

/// Coordinates instance validation and session submission for the login flow.
class LoginPage extends StatefulWidget {
  /// Creates a login page.
  const LoginPage({super.key, required this.popRegister, required this.popModal, this.anonymous = false});

  /// Closes the registration or anonymous-instance flow.
  final VoidCallback popRegister;

  /// Closes the surrounding account modal after an authenticated login.
  final VoidCallback popModal;

  /// Whether the page adds an anonymous session instead of signing in.
  final bool anonymous;

  /// Creates the instance validator owned by this route.
  ///
  /// Subclasses may override this in widget tests to avoid live discovery.
  @protected
  @visibleForTesting
  InstanceValidationCubit buildInstanceValidationCubit() => createInstanceValidationCubit();

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final TextEditingController _instanceController;
  late final TextEditingController _usernameController;
  late final TextEditingController _passwordController;
  late final TextEditingController _totpController;
  late final InstanceValidationCubit _instanceValidationCubit;

  final FocusNode _usernameFocusNode = FocusNode();
  final ValueNotifier<bool> _isSubmitting = ValueNotifier<bool>(false);
  final ValueNotifier<String?> _submissionInstanceError = ValueNotifier<String?>(null);

  @override
  void initState() {
    super.initState();

    _instanceController = TextEditingController()..addListener(_handleInstanceChanged);
    _usernameController = TextEditingController();
    _passwordController = TextEditingController();
    _totpController = TextEditingController();
    _instanceValidationCubit = widget.buildInstanceValidationCubit();
  }

  @override
  void dispose() {
    _instanceController
      ..removeListener(_handleInstanceChanged)
      ..dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _totpController.dispose();
    _usernameFocusNode.dispose();
    _isSubmitting.dispose();
    _submissionInstanceError.dispose();
    unawaited(_instanceValidationCubit.close());
    super.dispose();
  }

  void _handleInstanceChanged() {
    _submissionInstanceError.value = null;
    _instanceValidationCubit.instanceChanged(_instanceController.text);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _instanceValidationCubit,
      child: BlocListener<SessionBloc, SessionState>(
        listenWhen: (previous, current) => previous.mutationStatus != current.mutationStatus,
        listener: _handleSessionState,
        child: LoginPageView(
          anonymous: widget.anonymous,
          instanceController: _instanceController,
          usernameController: _usernameController,
          passwordController: _passwordController,
          totpController: _totpController,
          usernameFocusNode: _usernameFocusNode,
          submitting: _isSubmitting,
          submissionInstanceError: _submissionInstanceError,
          onSubmit: _handleLogin,
          onCancel: widget.popRegister,
          onOpenGettingStarted: () => handleLink(context, url: 'https://join-lemmy.org/'),
          onOpenInstance: (host) => handleLink(context, url: 'https://$host'),
          onCreateAccount: (host) => handleLink(context, url: 'https://$host/signup'),
        ),
      ),
    );
  }

  void _handleSessionState(BuildContext context, SessionState state) {
    final expectedMutation = widget.anonymous ? SessionMutationType.addAnonymousSession : SessionMutationType.authenticatedLogin;
    if (state.lastMutation != expectedMutation) return;

    switch (state.mutationStatus) {
      case SessionMutationStatus.loading:
        _isSubmitting.value = true;
      case SessionMutationStatus.failure:
        _isSubmitting.value = false;
        showThunderSnackbar(GlobalContext.l10n.loginFailed(state.error ?? GlobalContext.l10n.missingErrorMessage));
      case SessionMutationStatus.success:
        _isSubmitting.value = false;
        if (widget.anonymous) {
          widget.popRegister();
        } else {
          widget.popModal();
          showThunderSnackbar(GlobalContext.l10n.loginSucceeded);
        }
      case SessionMutationStatus.idle:
        break;
    }
  }

  Future<void> _handleLogin() async {
    final l10n = GlobalContext.l10n;
    if (_isSubmitting.value) return;

    if (!_instanceValidationCubit.state.isValid) {
      showThunderSnackbar(l10n.notValidLemmyInstance(_instanceController.text));
      return;
    }

    _isSubmitting.value = true;
    await _instanceValidationCubit.completeMetadata();
    if (!mounted) return;

    final validationState = _instanceValidationCubit.state;
    final instanceInfo = validationState.instanceInfo;
    final instanceHost = validationState.normalizedHost;
    final platform = validationState.platform;
    if (!validationState.isValid || instanceInfo == null || instanceHost == null || platform == null) {
      _isSubmitting.value = false;
      showThunderSnackbar(l10n.notValidLemmyInstance(_instanceController.text));
      return;
    }

    if (instanceInfo.contentWarning != null && !await _acceptContentWarning(instanceInfo.contentWarning!)) {
      _isSubmitting.value = false;
      return;
    }

    TextInput.finishAutofillContext();

    if (widget.anonymous) {
      await _addAnonymousSession(validationState, instanceHost);
      return;
    }

    context.read<SessionBloc>().add(
          AuthenticatedLoginRequested(
            username: _usernameController.text,
            password: _passwordController.text,
            discovery: InstanceDiscoveryResult(
              host: instanceHost,
              platform: platform,
              version: validationState.detectedVersion,
            ),
            totp: _totpController.text,
          ),
        );
  }

  /// Accepts the content warning for the instance.
  Future<bool> _acceptContentWarning(String contentWarning) async {
    bool accepted = false;

    await showThunderDialog<void>(
      context: context,
      title: GlobalContext.l10n.contentWarning,
      contentText: contentWarning,
      onSecondaryButtonPressed: (dialogContext) => Navigator.of(dialogContext).pop(),
      secondaryButtonText: GlobalContext.l10n.decline,
      onPrimaryButtonPressed: (dialogContext, _) async {
        accepted = true;
        Navigator.of(dialogContext).pop();
      },
      primaryButtonText: GlobalContext.l10n.accept,
    );

    return accepted;
  }

  /// Adds an anonymous session to the account.
  Future<void> _addAnonymousSession(InstanceValidationState validationState, String instanceHost) async {
    final anonymousInstances = await createSessionRepository().getAnonymousSessions();
    if (!mounted) return;

    if (anonymousInstances.any((anonymousInstance) => anonymousInstance.instance == instanceHost)) {
      _isSubmitting.value = false;
      _submissionInstanceError.value = GlobalContext.l10n.instanceHasAlreadyBenAdded(instanceHost);
      return;
    }

    context.read<SessionBloc>().add(
          AnonymousSessionAdded(
            account: Account(
              id: '',
              instance: instanceHost,
              index: -1,
              anonymous: true,
              platform: validationState.platform,
            ),
            activate: true,
          ),
        );
  }
}
