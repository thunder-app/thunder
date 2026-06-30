import 'package:flutter_test/flutter_test.dart';

import 'package:thunder/src/features/community/presentation/widgets/community_header/community_header_actions.dart';
import 'package:thunder/src/foundation/contracts/account.dart';
import 'package:thunder/src/foundation/primitives/enums/threadiverse_platform.dart';

import '../../../../../helpers/repository_test_fixtures.dart';
import '../../../../../helpers/test_setup.dart';
import '../../../../../helpers/widget_test_harness.dart';

void main() {
  setUpAll(setUpRepositoryTests);

  testWidgets('shows modlog action chip for PieFed communities', (tester) async {
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
        isLoggedIn: true,
        child: CommunityHeaderActions(
          community: testCommunity(),
          moderators: const [],
        ),
      ),
    );

    expect(find.text('Modlog'), findsOneWidget);
  });
}
