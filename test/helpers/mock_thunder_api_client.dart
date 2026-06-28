import 'package:mocktail/mocktail.dart';

import 'package:thunder/src/foundation/foundation.dart';

class MockThunderApiClient extends Mock implements ThunderApiClient {}

void stubDefaultApiClient(MockThunderApiClient api, {String platformName = 'Lemmy'}) {
  when(() => api.platformName).thenReturn(platformName);
  when(() => api.supportsHidePosts).thenReturn(true);
  when(() => api.supportsSubmitReport).thenReturn(true);
  when(() => api.supportsListReports).thenReturn(true);
  when(() => api.supportsSettingsImportExport).thenReturn(true);
  when(() => api.supportsMedia).thenReturn(true);
  when(() => api.supportsInstanceBlock).thenReturn(true);
}
