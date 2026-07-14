import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:thunder/src/core/app/app_startup_gate.dart';
import 'package:thunder/src/core/state/app_startup_cubit.dart';

void main() {
  testWidgets('shows startup progress before constructing the ready app', (tester) async {
    final maintenance = Completer<void>();
    var readyBuilds = 0;

    await tester.pumpWidget(
      BlocProvider(
        create: (context) => AppStartupCubit(taskRunner: () => maintenance.future),
        child: AppStartupGate(
          builder: (context) {
            readyBuilds++;
            return const MaterialApp(home: Text('Ready app'));
          },
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Ready app'), findsNothing);
    expect(readyBuilds, 0);

    maintenance.complete();
    await tester.pumpAndSettle();

    expect(find.text('Ready app'), findsOneWidget);
    expect(readyBuilds, 1);
  });

  testWidgets('shows a failure with retry and recovers', (tester) async {
    var attempts = 0;

    await tester.pumpWidget(
      BlocProvider(
        create: (context) => AppStartupCubit(
          taskRunner: () async {
            attempts++;
            if (attempts == 1) throw StateError('maintenance failed');
          },
        ),
        child: AppStartupGate(
          builder: (context) => const MaterialApp(home: Text('Ready app')),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('maintenance failed'), findsOneWidget);

    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(attempts, 2);
    expect(find.text('Ready app'), findsOneWidget);
  });
}
