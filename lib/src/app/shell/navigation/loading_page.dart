import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/src/features/settings/api.dart';
import 'package:thunder/src/app/shell/navigation/swipeable_page_route.dart';
import 'package:thunder/src/app/state/thunder/thunder_bloc.dart';
import 'package:thunder/src/foundation/config/config.dart';

bool isLoadingPageShown = false;

class LoadingPage extends StatelessWidget {
  const LoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      body: Container(
        color: theme.colorScheme.surface,
        child: SafeArea(
          top: false,
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                toolbarHeight: APP_BAR_HEIGHT,
                leading: IconButton(
                  icon: !kIsWeb && Platform.isIOS
                      ? Icon(
                          Icons.arrow_back_ios_new_rounded,
                          semanticLabel: MaterialLocalizations.of(context).backButtonTooltip,
                        )
                      : Icon(Icons.arrow_back_rounded, semanticLabel: MaterialLocalizations.of(context).backButtonTooltip),
                  onPressed: null,
                ),
              ),
              const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void showLoadingPage(BuildContext context) {
  if (isLoadingPageShown) return;

  isLoadingPageShown = true;

  final enableFullScreenSwipeNavigationGesture = context.read<GesturePreferencesCubit>().state.enableFullScreenSwipeNavigationGesture;
  final reduceAnimations = context.read<ThemePreferencesCubit>().state.reduceAnimations;

  Navigator.of(context).push(
    SwipeablePageRoute(
      transitionDuration: reduceAnimations ? const Duration(milliseconds: 100) : null,
      backGestureDetectionWidth: 45,
      canOnlySwipeFromEdge: !enableFullScreenSwipeNavigationGesture,
      canSwipe: false,
      builder: (context) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: context.read<ThunderCubit>()),
        ],
        child: PopScope(
          onPopInvokedWithResult: (didPop, result) => isLoadingPageShown = !didPop,
          child: const LoadingPage(),
        ),
      ),
    ),
  );
}

Future<void> hideLoadingPage(BuildContext context, {bool delay = false}) async {
  if (isLoadingPageShown) {
    isLoadingPageShown = false;

    if (delay) {
      await Future.delayed(const Duration(seconds: 1));
    }

    if (context.mounted) {
      Navigator.of(context).maybePop();
    }
  }
}

Future<dynamic> pushOnTopOfLoadingPage(BuildContext context, Route route) async {
  if (isLoadingPageShown) {
    isLoadingPageShown = false;
    return await Navigator.of(context).pushReplacement(route);
  } else {
    return await Navigator.of(context).push(route);
  }
}
