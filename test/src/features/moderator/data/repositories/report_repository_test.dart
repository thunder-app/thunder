import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:thunder/src/features/moderator/data/repositories/report_repository.dart';
import 'package:thunder/src/features/moderator/domain/enums/report_feed_type.dart';
import 'package:thunder/src/foundation/foundation.dart';

import '../../../../../helpers/mock_thunder_api_client.dart';
import '../../../../../helpers/repository_test_fixtures.dart';
import '../../../../../helpers/test_setup.dart';

void main() {
  late MockThunderApiClient api;

  setUpAll(setUpRepositoryTests);

  setUp(() {
    api = MockThunderApiClient();
    stubDefaultApiClient(api);
  });

  group('ReportRepositoryImpl', () {
    test('getReports throws UnsupportedFeatureException when post reports unsupported', () async {
      when(() => api.supportsPostReports).thenReturn(false);

      final repository = ReportRepositoryImpl(
        account: loggedInAccount(),
        api: api,
        localization: testLocalization,
      );

      expect(
        () => repository.getReports(reportFeedType: ReportFeedType.post),
        throwsA(isA<UnsupportedFeatureException>()),
      );
    });

    test('getReports maps post feed type to post kind and delegates', () async {
      const page = ThunderPage<ThunderReport>(items: []);
      when(() => api.getReports(
            kind: ReportKind.post,
            postId: any(named: 'postId'),
            commentId: any(named: 'commentId'),
            page: any(named: 'page'),
            cursor: any(named: 'cursor'),
            limit: any(named: 'limit'),
            unresolved: any(named: 'unresolved'),
            communityId: any(named: 'communityId'),
          )).thenAnswer((_) async => page);

      final repository = ReportRepositoryImpl(
        account: loggedInAccount(),
        api: api,
        localization: testLocalization,
      );

      final result = await repository.getReports(reportFeedType: ReportFeedType.post);

      expect(result, page);
      verify(() => api.getReports(kind: ReportKind.post, page: 1, cursor: null, limit: 10, unresolved: false, communityId: null, postId: null, commentId: null)).called(1);
    });

    test('resolveReport returns true when api resolved matches requested value', () async {
      const report = ThunderReport(id: 1, kind: ReportKind.post, reason: 'spam', resolved: false);
      when(() => api.resolveReport(reportId: 1, kind: ReportKind.post, resolved: true)).thenAnswer(
        (_) async => report.copyWith(resolved: true),
      );

      final repository = ReportRepositoryImpl(
        account: loggedInAccount(),
        api: api,
        localization: testLocalization,
      );

      final result = await repository.resolveReport(report, true);

      expect(result, isTrue);
    });

    test('resolveReport throws NotLoggedInException when anonymous', () async {
      const report = ThunderReport(id: 1, kind: ReportKind.post, reason: 'spam', resolved: false);

      final repository = ReportRepositoryImpl(
        account: anonymousAccount(),
        api: api,
        localization: testLocalization,
      );

      expect(
        () => repository.resolveReport(report, true),
        throwsA(isA<NotLoggedInException>()),
      );
    });
  });
}
