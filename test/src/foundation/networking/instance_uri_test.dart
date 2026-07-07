import 'package:flutter_test/flutter_test.dart';

import 'package:thunder/src/foundation/networking/instance_uri.dart';

void main() {
  group('normalizeInstanceAuthority', () {
    test('normalizes public hosts without ports', () {
      expect(normalizeInstanceAuthority('Lemmy.Test'), 'lemmy.test');
      expect(normalizeInstanceAuthority('https://Lemmy.Test/path'), 'lemmy.test');
    });

    test('preserves local ports', () {
      expect(normalizeInstanceAuthority('127.0.0.1:8536'), '127.0.0.1:8536');
      expect(normalizeInstanceAuthority('http://localhost:8030'), 'localhost:8030');
      expect(normalizeInstanceAuthority('10.0.2.2:8537'), '10.0.2.2:8537');
    });
  });

  group('buildInstanceUri', () {
    test('uses https for public instances', () {
      expect(
        buildInstanceUri('lemmy.test', '/api/v3/site').toString(),
        'https://lemmy.test/api/v3/site',
      );
    });

    test('uses http for local instances with ports', () {
      expect(
        buildInstanceUri('127.0.0.1:8536', '/api/v3/site').toString(),
        'http://127.0.0.1:8536/api/v3/site',
      );
      expect(
        buildInstanceUri('10.0.2.2:8537', '/api/v4/site').toString(),
        'http://10.0.2.2:8537/api/v4/site',
      );
    });

    test('uses http for private LAN instance authorities', () {
      expect(
        buildInstanceUri('192.168.1.42:8536', '/api/v3/site').toString(),
        'http://192.168.1.42:8536/api/v3/site',
      );
      expect(
        buildInstanceUri('172.20.0.10:8537', '/api/v4/site').toString(),
        'http://172.20.0.10:8537/api/v4/site',
      );
    });

    test('keeps query parameters', () {
      expect(
        buildInstanceUri('localhost:8030', '/api/alpha/post/list', queryParameters: {'page': '1'}).toString(),
        'http://localhost:8030/api/alpha/post/list?page=1',
      );
    });
  });
}
