import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:thunder/src/features/instance/presentation/widgets/instance_page_app_bar.dart';
import 'package:thunder/src/core/core.dart';

import '../../../../../helpers/test_setup.dart';
import '../../../../../helpers/widget_test_harness.dart';

void main() {
  setUpAll(setUpRepositoryTests);

  testWidgets('instance app bar menu includes modlog for PieFed instances', (tester) async {
    const account = Account(
      id: '1',
      index: 0,
      instance: 'piefed.test',
      platform: ThreadiversePlatform.piefed,
      anonymous: true,
    );

    await pumpLocalizedWidget(
      tester,
      wrapWithProfileBloc(
        account: account,
        child: CustomScrollView(
          slivers: [
            InstancePageAppBar(
              instance: const ThunderInstanceInfo(
                domain: 'https://piefed.test',
                name: 'PieFed Test',
                platform: ThreadiversePlatform.piefed,
                success: true,
              ),
              searchSortType: SearchSortType.topAll,
              account: account,
              onSortSelected: (_) {},
              onQueryChanged: (_) {},
            ),
          ],
        ),
      ),
    );

    await tester.tap(find.byType(PopupMenuButton<dynamic>));
    await tester.pumpAndSettle();

    expect(find.text('Modlog'), findsOneWidget);
  });
}
