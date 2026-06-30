import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:thunder/src/foundation/config/global_context.dart';
import 'package:thunder/src/foundation/networking/error_message_utils.dart';

import '../../../helpers/widget_test_harness.dart';

void main() {
  testWidgets('maps known api error codes to localized messages', (tester) async {
    await pumpLocalizedWidget(tester, const SizedBox.shrink());
    final context = GlobalContext.context;

    expect(getErrorMessage(context, 'network_error'), 'Unable to reach the server. Check your connection and try again.');
    expect(getErrorMessage(context, 'rate_limit_error'), isNotEmpty);
    expect(getErrorMessage(context, 'only_mods_can_post_in_community'), isNotEmpty);
    expect(getErrorMessage(context, 'cant_block_admin'), isNotEmpty);
    expect(getErrorMessage(context, 'couldnt_find_community', additionalInfo: 'news'), contains('news'));
    expect(getErrorMessage(context, 'couldnt_find_person', additionalInfo: 'alice'), contains('alice'));
    expect(getErrorMessage(context, 'unknown_code'), 'unknown_code');
  });
}
