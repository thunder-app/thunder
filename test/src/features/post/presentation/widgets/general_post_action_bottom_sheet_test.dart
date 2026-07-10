import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:thunder/src/features/post/presentation/widgets/post_bottom_sheet/general_post_action_bottom_sheet.dart';
import 'package:thunder/src/core/domain/models/account.dart';
import 'package:thunder/src/core/domain/enums/threadiverse_platform.dart';

import '../../../../../helpers/repository_test_fixtures.dart';
import '../../../../../helpers/test_setup.dart';
import '../../../../../helpers/widget_test_harness.dart';

void main() {
  setUpAll(setUpRepositoryTests);

  testWidgets('shows hide action for PieFed accounts', (tester) async {
    const account = Account(
      id: '1',
      index: 0,
      instance: 'piefed.test',
      platform: ThreadiversePlatform.piefed,
      jwt: 'token',
      userId: 1,
    );

    await pumpLocalizedWidget(
      tester,
      wrapWithThemePreferences(
        Builder(
          builder: (context) {
            return GeneralPostActionBottomSheetPage(
              context: context,
              account: account,
              post: testPost(),
              downvotesEnabled: true,
              onSwitchActivePage: (_) {},
              onAction: (_, __) {},
            );
          },
        ),
      ),
    );

    expect(find.bySemanticsLabel('Hide'), findsOneWidget);
  });
}
