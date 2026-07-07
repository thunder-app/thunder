import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:thunder/packages/ui/ui.dart';

import '../../helpers/ui_test_harness.dart';

void main() {
  testWidgets('ThunderSectionHeader settings variant shows title and description', (tester) async {
    await pumpUiWidget(
      tester,
      const ThunderSectionHeader(
        title: 'General',
        description: 'Account settings',
      ),
    );

    expect(find.text('General'), findsOneWidget);
    expect(find.text('Account settings'), findsOneWidget);
  });

  testWidgets('ThunderSectionHeader sidebar variant shows title row', (tester) async {
    await pumpUiWidget(
      tester,
      const ThunderSectionHeader(
        title: 'Stats',
        variant: ThunderSectionHeaderVariant.sidebar,
      ),
    );

    expect(find.text('Stats'), findsOneWidget);
    expect(find.byType(Divider), findsOneWidget);
  });

  testWidgets('ThunderSectionHeader sliver variant renders title and actions', (tester) async {
    await pumpUiWidget(
      tester,
      CustomScrollView(
        slivers: [
          ThunderSectionHeader(
            title: 'Accounts',
            variant: ThunderSectionHeaderVariant.sliver,
            actions: [
              IconButton(onPressed: () {}, icon: const Icon(Icons.add)),
            ],
          ),
        ],
      ),
    );

    expect(find.text('Accounts'), findsOneWidget);
    expect(find.byType(SliverToBoxAdapter), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
  });
}
