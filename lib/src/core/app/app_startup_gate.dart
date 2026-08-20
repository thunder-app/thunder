import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/l10n/generated/app_localizations.dart';
import 'package:thunder/packages/ui/ui.dart';
import 'package:thunder/src/core/state/app_startup_cubit.dart';

class AppStartupGate extends StatefulWidget {
  const AppStartupGate({super.key, required this.builder, this.onReady});

  /// The builder that will be used to build the app when the app is ready
  final WidgetBuilder builder;

  /// The callback that will be called when the app is ready
  final VoidCallback? onReady;

  @override
  State<AppStartupGate> createState() => _AppStartupGateState();
}

class _AppStartupGateState extends State<AppStartupGate> {
  bool _hasRunReadyCallback = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<AppStartupCubit>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppStartupCubit, AppStartupState>(
      listenWhen: (previous, current) => previous.status != AppStartupStatus.ready && current.status == AppStartupStatus.ready,
      listener: (context, state) {
        if (_hasRunReadyCallback) return;

        _hasRunReadyCallback = true;
        WidgetsBinding.instance.addPostFrameCallback((_) => widget.onReady?.call());
      },
      builder: (context, state) {
        if (state.status == AppStartupStatus.ready) return widget.builder(context);

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          themeMode: ThemeMode.system,
          home: Scaffold(
            body: switch (state.status) {
              AppStartupStatus.failure => Builder(
                builder: (context) => ThunderStateView(
                  title: AppLocalizations.of(context)!.somethingWentWrong,
                  message: state.error,
                  actions: [ThunderStateAction(label: AppLocalizations.of(context)!.retry, onPressed: () => context.read<AppStartupCubit>().initialize(), primary: true)],
                ),
              ),
              AppStartupStatus.initial || AppStartupStatus.running => const Center(child: CircularProgressIndicator()),
              AppStartupStatus.ready => const SizedBox.shrink(),
            },
          ),
        );
      },
    );
  }
}
