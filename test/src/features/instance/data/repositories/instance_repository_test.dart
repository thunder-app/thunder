import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:thunder/src/features/instance/data/repositories/instance_repository.dart';
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

  group('InstanceRepositoryImpl', () {
    test('info delegates to api site', () async {
      final siteResponse = testSiteResponse();
      when(() => api.site()).thenAnswer((_) async => siteResponse);

      final repository = InstanceRepositoryImpl(
        account: loggedInAccount(),
        api: api,
        localization: testLocalization,
      );

      final result = await repository.info();

      expect(result, siteResponse);
      verify(() => api.site()).called(1);
    });

    test('block throws NotLoggedInException when anonymous', () async {
      final repository = InstanceRepositoryImpl(
        account: anonymousAccount(),
        api: api,
        localization: testLocalization,
      );

      expect(
        () => repository.block(1, true),
        throwsA(isA<NotLoggedInException>()),
      );
    });

    test('block delegates to api without feature flag guard', () async {
      when(() => api.blockInstance(instanceId: 9, block: true)).thenAnswer((_) async => true);

      final repository = InstanceRepositoryImpl(
        account: loggedInAccount(),
        api: api,
        localization: testLocalization,
      );

      final blocked = await repository.block(9, true);

      expect(blocked, isTrue);
      verify(() => api.blockInstance(instanceId: 9, block: true)).called(1);
    });

    test('federated parses json into FederatedInstances linked list', () async {
      when(() => api.federated()).thenAnswer(
        (_) async => {
          'federated_instances': {
            'linked': [
              {
                'id': 1,
                'domain': 'other.test',
              },
            ],
          },
        },
      );

      final repository = InstanceRepositoryImpl(
        account: loggedInAccount(),
        api: api,
        localization: testLocalization,
      );

      final result = await repository.federated();

      expect(result.linked, hasLength(1));
      expect(result.linked.first.domain, 'other.test');
    });
  });
}
