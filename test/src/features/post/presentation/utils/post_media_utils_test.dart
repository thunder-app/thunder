import 'package:flutter_test/flutter_test.dart';

import 'package:thunder/src/features/post/post.dart';

import '../../../../../helpers/repository_test_fixtures.dart';

void main() {
  group('buildTextPreviewsForPosts', () {
    test('does not invoke the batch parser when previews are disabled', () async {
      var invoked = false;

      final previews = await buildTextPreviewsForPosts(
        ['**bold**'],
        enabled: false,
        runner: (bodies) async {
          invoked = true;
          return bodies;
        },
      );

      expect(invoked, isFalse);
      expect(previews, [isNull]);
    });

    test('delegates one ordered batch when previews are enabled', () async {
      var invocationCount = 0;

      final previews = await buildTextPreviewsForPosts(
        ['first', 'second'],
        enabled: true,
        runner: (bodies) async {
          invocationCount += 1;
          return bodies.reversed.toList();
        },
      );

      expect(invocationCount, 1);
      expect(previews, ['second', 'first']);
    });
  });

  group('buildTextPreviews', () {
    test('preserves order while stripping markdown syntax', () {
      final previews = buildTextPreviews([
        '# Heading\n\n**bold** and [link](https://example.com)',
        null,
        '',
        'Unicode: 👨‍👩‍👧‍👦 漢字 مرحبا e\u0301',
      ]);

      expect(previews, [
        'Heading\nbold and link',
        null,
        null,
        'Unicode: 👨‍👩‍👧‍👦 漢字 مرحبا e\u0301',
      ]);
    });

    test('preserves the current behavior for inline images', () {
      expect(buildTextPreviews(['Before ![useful alt](https://example.com/image.png) after']).single, 'Before  after');
    });
  });

  test('parsePost accepts a precomputed preview without changing the body', () async {
    final post = testPost(body: '**source**');

    final parsed = await parsePost(
      post,
      false,
      false,
      false,
      textPreview: 'source',
    );

    expect(parsed.body, '**source**');
    expect(parsed.textPreview, 'source');
  });
}
