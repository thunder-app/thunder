import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/l10n/generated/app_localizations.dart';
import 'package:thunder/src/features/account/presentation/state/instance_validation_cubit.dart';
import 'package:thunder/src/foundation/primitives/primitives.dart';

/// Builds an image provider for a detected instance icon URL.
typedef LoginInstanceIconProviderBuilder = ImageProvider<Object> Function(String iconUrl);

/// Displays the app or instance icon and contextual instance links.
class LoginInstanceHeader extends StatelessWidget {
  /// Creates an instance-aware login header.
  const LoginInstanceHeader({
    super.key,
    required this.anonymous,
    required this.onOpenGettingStarted,
    required this.onOpenInstance,
    required this.onCreateAccount,
    this.iconProviderBuilder,
  });

  /// Whether account-registration actions should be hidden.
  final bool anonymous;

  /// Opens the instance-discovery website.
  final VoidCallback onOpenGettingStarted;

  /// Opens the detected instance host.
  final ValueChanged<String> onOpenInstance;

  /// Opens account registration for the detected instance host.
  final ValueChanged<String> onCreateAccount;

  /// Builds the provider used to display a detected instance icon.
  final LoginInstanceIconProviderBuilder? iconProviderBuilder;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<InstanceValidationCubit, InstanceValidationState, _LoginInstanceHeaderState>(
      selector: (state) => _LoginInstanceHeaderState(
        iconUrl: state.instanceInfo?.icon,
        isValid: state.isValid,
        host: state.normalizedHost,
        platform: state.instanceInfo?.platform ?? state.platform,
      ),
      builder: (context, state) {
        final theme = Theme.of(context);
        final l10n = AppLocalizations.of(context)!;
        final iconUrl = state.iconUrl;

        return Column(
          children: [
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 500),
              crossFadeState: iconUrl == null ? CrossFadeState.showFirst : CrossFadeState.showSecond,
              firstChild: Image.asset('assets/logo.png', width: 80, height: 80),
              secondChild: iconUrl == null
                  ? const SizedBox.shrink()
                  : CircleAvatar(
                      key: const Key('login-instance-avatar'),
                      foregroundImage: iconProviderBuilder?.call(iconUrl) ?? CachedNetworkImageProvider(iconUrl),
                      backgroundColor: Colors.transparent,
                      maxRadius: 40,
                    ),
            ),
            const SizedBox(height: 12),
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 250),
              crossFadeState: state.isValid ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              firstChild: _InstanceLinkButton(
                label: l10n.gettingStarted,
                onPressed: onOpenGettingStarted,
              ),
              secondChild: Column(
                spacing: 8,
                children: [
                  if (state.platform == ThreadiversePlatform.piefed)
                    Text(
                      l10n.piefedSupportBeta,
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.secondary),
                      textAlign: TextAlign.center,
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _InstanceLinkButton(
                        label: l10n.openInstance,
                        onPressed: state.host == null ? null : () => onOpenInstance(state.host!),
                      ),
                      if (!anonymous) ...[
                        const SizedBox(width: 12),
                        _InstanceLinkButton(
                          label: l10n.createAccount,
                          onPressed: state.host == null ? null : () => onCreateAccount(state.host!),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _InstanceLinkButton extends StatelessWidget {
  const _InstanceLinkButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return OutlinedButton.icon(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.only(left: 10, right: 16),
        backgroundColor: theme.colorScheme.surface,
        textStyle: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onPrimary),
      ),
      icon: Icon(Icons.insert_link_rounded, color: theme.textTheme.bodySmall?.color),
      label: Text(label, style: theme.textTheme.bodySmall),
    );
  }
}

class _LoginInstanceHeaderState {
  const _LoginInstanceHeaderState({required this.iconUrl, required this.isValid, required this.host, required this.platform});

  final String? iconUrl;
  final bool isValid;
  final String? host;
  final ThreadiversePlatform? platform;

  @override
  bool operator ==(Object other) {
    return other is _LoginInstanceHeaderState && other.iconUrl == iconUrl && other.isValid == isValid && other.host == host && other.platform == platform;
  }

  @override
  int get hashCode => Object.hash(iconUrl, isValid, host, platform);
}
