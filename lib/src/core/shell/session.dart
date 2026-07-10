import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thunder/l10n/generated/app_localizations.dart';

import 'package:thunder/src/features/session/api.dart';

class Session extends StatelessWidget {
  const Session({super.key, required this.builder});

  final Widget Function(BuildContext context, SessionState sessionState) builder;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<SessionBloc, SessionState>(
      builder: (context, sessionState) {
        switch (sessionState.status) {
          case SessionStatus.initial:
          case SessionStatus.loading:
            return const _SessionStatusView();
          case SessionStatus.failure:
            return _SessionStatusView(
              message: sessionState.error,
              actionLabel: l10n.retry,
              onAction: () => context.read<SessionBloc>().add(const SessionInitialized()),
            );
          case SessionStatus.success:
            final account = sessionState.activeAccount;
            if (account == null) {
              return _SessionStatusView(
                message: l10n.unexpectedError,
                actionLabel: l10n.retry,
                onAction: () => context.read<SessionBloc>().add(const SessionInitialized()),
              );
            }

            return builder(context, sessionState);
        }
      },
    );
  }
}

class _SessionStatusView extends StatelessWidget {
  const _SessionStatusView({this.message, this.actionLabel, this.onAction});

  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(message ?? l10n.loading, textAlign: TextAlign.center),
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: 16),
                FilledButton(onPressed: onAction, child: Text(actionLabel!)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
