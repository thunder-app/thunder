import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:thunder/packages/ui/ui.dart';
import 'package:thunder/src/app/shell/state/shell_chrome_cubit.dart';
import 'package:thunder/src/shared/fabs/gesture_fab.dart';

void main() {
  testWidgets('ActionButton closes feed FAB before invoking action', (tester) async {
    final cubit = ShellChromeCubit()..setFeedFabOpen(true);
    var pressed = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(extensions: const [ThunderTheme()]),
        home: BlocProvider.value(
          value: cubit,
          child: Scaffold(
            body: Center(
              child: ActionButton(
                title: 'Refresh',
                icon: const Icon(Icons.refresh),
                onPressed: () => pressed = true,
              ),
            ),
          ),
        ),
      ),
    );

    expect(cubit.state.isFeedFabOpen, isTrue);

    await tester.tap(find.byIcon(Icons.refresh));
    await tester.pump();

    expect(pressed, isTrue);
    expect(cubit.state.isFeedFabOpen, isFalse);
  });

  testWidgets('ActionButton closes post FAB when fabType is post', (tester) async {
    final cubit = ShellChromeCubit()..setPostFabOpen(true);
    var pressed = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(extensions: const [ThunderTheme()]),
        home: BlocProvider.value(
          value: cubit,
          child: Scaffold(
            body: Center(
              child: ActionButton(
                title: 'Reply',
                icon: const Icon(Icons.reply),
                fabType: FabType.post,
                onPressed: () => pressed = true,
              ),
            ),
          ),
        ),
      ),
    );

    expect(cubit.state.isPostFabOpen, isTrue);

    await tester.tap(find.byIcon(Icons.reply));
    await tester.pump();

    expect(pressed, isTrue);
    expect(cubit.state.isPostFabOpen, isFalse);
  });
}
