import 'package:flutter_test/flutter_test.dart';

import 'package:thunder/src/foundation/networking/discovery/instance_discovery_service.dart';
import 'package:thunder/src/features/instance/domain/models/federated_instances.dart';
import 'package:thunder/src/features/instance/domain/models/instance_discovery_result.dart';
import 'package:thunder/src/features/instance/data/repositories/instance_repository.dart';
import 'package:thunder/src/foundation/foundation.dart';

import '../../../../helpers/repository_test_fixtures.dart';

void main() {
  setUp(() {
    PlatformVersionCache().clear();
  });

  group('normalizeInstanceHost', () {
    test('returns null for empty input', () {
      expect(normalizeInstanceHost(null), isNull);
      expect(normalizeInstanceHost(''), isNull);
      expect(normalizeInstanceHost('   '), isNull);
    });

    test('normalizes bare host and strips scheme', () {
      expect(normalizeInstanceHost('Lemmy.Test'), 'lemmy.test');
      expect(normalizeInstanceHost('https://lemmy.test/path'), 'lemmy.test');
    });
  });

  group('discoverInstance', () {
    test('returns lemmy discovery for supported platform detector', () async {
      final result = await discoverInstance(
        'lemmy.test',
        platformDetector: (_, {timeout}) async => {
          'platform': ThreadiversePlatform.lemmy,
          'version': '0.19.11',
        },
      );

      expect(result?.host, 'lemmy.test');
      expect(result?.platform, ThreadiversePlatform.lemmy);
      expect(result?.version, '0.19.11');
      expect(PlatformVersionCache().get('lemmy.test')?.toString(), '0.19.11');
    });

    test('returns piefed discovery for supported platform detector', () async {
      final result = await discoverInstance(
        'piefed.test',
        platformDetector: (_, {timeout}) async => {
          'platform': ThreadiversePlatform.piefed,
          'version': '1.6.0',
        },
      );

      expect(result?.platform, ThreadiversePlatform.piefed);
    });

    test('returns null for invalid host', () async {
      expect(await discoverInstance(''), isNull);
      expect(await discoverInstance('not a url!!!'), isNull);
    });

    test('returns null when detector fails', () async {
      final result = await discoverInstance(
        'lemmy.test',
        platformDetector: (_, {timeout}) async => null,
      );

      expect(result, isNull);
    });
  });

  group('loadInstanceInfo', () {
    test('maps site metadata from repository', () async {
      final discovery = InstanceDiscoveryResult(
        host: 'lemmy.test',
        platform: ThreadiversePlatform.lemmy,
        version: '0.19.11',
      );

      final info = await loadInstanceInfo(
        discovery,
        instanceRepositoryFactory: (account) => _FakeInstanceRepository(
          siteResponse: ThunderSiteResponse(
            site: ThunderSite(name: 'Test Site', actorId: 'https://lemmy.test', users: 100),
            version: '0.19.11',
          ),
        ),
      );

      expect(info.success, isTrue);
      expect(info.name, 'Test Site');
      expect(info.platform, ThreadiversePlatform.lemmy);
      expect(info.users, 100);
    });

    test('returns failure metadata when site load throws', () async {
      final discovery = InstanceDiscoveryResult(
        host: 'lemmy.test',
        platform: ThreadiversePlatform.lemmy,
        version: '0.19.11',
      );

      final info = await loadInstanceInfo(
        discovery,
        instanceRepositoryFactory: (account) => _ThrowingInstanceRepository(),
      );

      expect(info.success, isFalse);
      expect(info.domain, 'lemmy.test');
      expect(info.platform, ThreadiversePlatform.lemmy);
    });
  });

  group('getInstanceInfo', () {
    test('returns unsuccessful info when discovery fails', () async {
      final info = await getInstanceInfo(
        'bad host',
        platformDetector: (_, {timeout}) async => null,
      );

      expect(info.success, isFalse);
      expect(info.domain, '');
    });

    test('loads metadata after successful discovery', () async {
      final info = await getInstanceInfo(
        'lemmy.test',
        platformDetector: (_, {timeout}) async => {
          'platform': ThreadiversePlatform.lemmy,
          'version': '0.19.11',
        },
        instanceRepositoryFactory: (account) => _FakeInstanceRepository(
          siteResponse: testSiteResponse(),
        ),
      );

      expect(info.success, isTrue);
      expect(info.name, 'Test Site');
    });
  });
}

class _FakeInstanceRepository implements InstanceRepository {
  _FakeInstanceRepository({required this.siteResponse});

  final ThunderSiteResponse siteResponse;

  Account get account => loggedInAccount();

  @override
  Future<bool> block(int instanceId, bool block) => throw UnimplementedError();

  @override
  Future<FederatedInstances> federated() => throw UnimplementedError();

  @override
  Future<ThunderSiteResponse> info() async => siteResponse;
}

class _ThrowingInstanceRepository implements InstanceRepository {
  Account get account => loggedInAccount();

  @override
  Future<bool> block(int instanceId, bool block) => throw UnimplementedError();

  @override
  Future<FederatedInstances> federated() => throw UnimplementedError();

  @override
  Future<ThunderSiteResponse> info() async => throw Exception('offline');
}
