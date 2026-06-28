import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:thunder/src/features/account/domain/models/account_settings_update.dart';
import 'package:thunder/src/foundation/foundation.dart';

import 'mock_thunder_api_client.dart';

Future<void> setUpRepositoryTests() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  await UserPreferences.instance.initialize();

  registerFallbackValue(const AccountSettingsUpdate());
  registerFallbackValue(ReportKind.post);
  registerFallbackValue(FeedListType.local);
  registerFallbackValue(PostSortType.active);
  registerFallbackValue(CommentSortType.new_);
  registerFallbackValue(MetaSearchType.all);
  registerFallbackValue(SearchSortType.topAll);
  registerFallbackValue(ModlogActionType.all);
  registerFallbackValue(MockThunderApiClient());
}
