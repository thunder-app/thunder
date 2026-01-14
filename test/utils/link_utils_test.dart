import 'package:flutter_test/flutter_test.dart';
import 'package:thunder/src/shared/utils/link_utils.dart';

void main() {
  group('ParsedLink', () {
    test('qualified returns value@instance', () {
      const link = ParsedLink(value: 'news', instance: 'lemmy.world');
      expect(link.qualified, 'news@lemmy.world');
    });

    test('equality works correctly', () {
      const link1 = ParsedLink(value: 'news', instance: 'lemmy.world');
      const link2 = ParsedLink(value: 'news', instance: 'lemmy.world');
      const link3 = ParsedLink(value: 'other', instance: 'lemmy.world');
      expect(link1, equals(link2));
      expect(link1, isNot(equals(link3)));
    });
  });

  group('Lemmy Community Parsing', () {
    test('parses full community URL with federation', () {
      final result = parseLemmyCommunity('https://lemmy.world/c/news@lemmy.ml');
      expect(result, isNotNull);
      expect(result!.value, 'news');
      expect(result.instance, 'lemmy.ml');
    });

    test('parses short community URL', () {
      final result = parseLemmyCommunity('https://lemmy.world/c/news');
      expect(result, isNotNull);
      expect(result!.value, 'news');
      expect(result.instance, 'lemmy.world');
    });

    test('parses community mention with !', () {
      final result = parseLemmyCommunity('!news@lemmy.world');
      expect(result, isNotNull);
      expect(result!.value, 'news');
      expect(result.instance, 'lemmy.world');
    });

    test('returns null for user URLs', () {
      expect(parseLemmyCommunity('https://lemmy.world/u/darklightxi'), isNull);
      expect(parseLemmyCommunity('https://lemmy.world/u/darklightxi@lemmy.ca'), isNull);
    });

    test('returns null for @ mentions (users)', () {
      expect(parseLemmyCommunity('@darklightxi@lemmy.world'), isNull);
    });

    test('returns null for PieFed post URLs (/c/community/p/postId)', () {
      expect(parseLemmyCommunity('https://piefed.social/c/thunder_app/p/1422697/thunder-release-v0-8-0-initial-piefed-support'), isNull);
      expect(parseLemmyCommunity('https://piefed.social/c/thunder_app/p/1422697'), isNull);
    });
  });

  group('Lemmy User Parsing', () {
    test('parses full user URL with federation', () {
      final result = parseLemmyUser('https://lemmy.world/u/darklightxi@lemmy.ca');
      expect(result, isNotNull);
      expect(result!.value, 'darklightxi');
      expect(result.instance, 'lemmy.ca');
    });

    test('parses short user URL', () {
      final result = parseLemmyUser('https://lemmy.world/u/darklightxi');
      expect(result, isNotNull);
      expect(result!.value, 'darklightxi');
      expect(result.instance, 'lemmy.world');
    });

    test('parses user mention with @', () {
      final result = parseLemmyUser('@darklightxi@lemmy.world');
      expect(result, isNotNull);
      expect(result!.value, 'darklightxi');
      expect(result.instance, 'lemmy.world');
    });

    test('returns null for community URLs', () {
      expect(parseLemmyUser('https://lemmy.world/c/news'), isNull);
      expect(parseLemmyUser('https://lemmy.world/c/news@lemmy.ml'), isNull);
    });

    test('returns null for ! mentions (communities)', () {
      expect(parseLemmyUser('!news@lemmy.world'), isNull);
    });
  });

  group('Lemmy Post Parsing', () {
    test('parses post URL', () {
      final result = parseLemmyPostId('https://lemmy.world/post/12345');
      expect(result, isNotNull);
      expect(result!.value, '12345');
      expect(result.instance, 'lemmy.world');
    });

    test('returns null for PieFed comment URLs', () {
      expect(parseLemmyPostId('https://piefed.social/post/123/comment/456'), isNull);
    });

    test('returns null for Lemmy new format comment URLs', () {
      expect(parseLemmyPostId('https://lemmy.world/post/123/456'), isNull);
    });
  });

  group('Lemmy Comment Parsing', () {
    test('parses legacy comment URL', () {
      final result = parseLemmyCommentId('https://lemmy.world/comment/12345');
      expect(result, isNotNull);
      expect(result!.value, '12345');
      expect(result.instance, 'lemmy.world');
    });

    test('parses new format comment URL (/post/123/456)', () {
      final result = parseLemmyCommentId('https://lemmy.world/post/123/456');
      expect(result, isNotNull);
      expect(result!.value, '456');
      expect(result.instance, 'lemmy.world');
    });

    test('returns null for pure post URLs', () {
      expect(parseLemmyCommentId('https://lemmy.world/post/123'), isNull);
    });
  });

  group('PieFed Comment Parsing', () {
    test('parses PieFed comment URL (/post/123/comment/456)', () {
      final result = parsePiefedCommentId('https://piefed.social/post/1663157/comment/9679172');
      expect(result, isNotNull);
      expect(result!.value, '9679172');
      expect(result.instance, 'piefed.social');
    });

    test('returns null for Lemmy format comment URLs', () {
      expect(parsePiefedCommentId('https://lemmy.world/comment/123'), isNull);
      expect(parsePiefedCommentId('https://lemmy.world/post/123/456'), isNull);
    });
  });

  group('Unified Parsers', () {
    group('parseCommunity', () {
      test('parses Lemmy community URL', () {
        final result = parseCommunity('https://lemmy.world/c/news');
        expect(result?.qualified, 'news@lemmy.world');
      });

      test('parses PieFed community URL', () {
        final result = parseCommunity('https://piefed.social/c/news@lemmy.world');
        expect(result?.qualified, 'news@lemmy.world');
      });
    });

    group('parseUser', () {
      test('parses Lemmy user URL', () {
        final result = parseUser('https://lemmy.world/u/darklightxi');
        expect(result?.qualified, 'darklightxi@lemmy.world');
      });

      test('parses PieFed user URL', () {
        final result = parseUser('https://piefed.social/u/darklightxi@lemmy.ca');
        expect(result?.qualified, 'darklightxi@lemmy.ca');
      });
    });

    group('parsePostId', () {
      test('parses Lemmy post URL', () {
        final result = parsePostId('https://lemmy.world/post/12345');
        expect(result?.value, '12345');
        expect(result?.instance, 'lemmy.world');
      });

      test('parses PieFed post URL', () {
        final result = parsePostId('https://piefed.social/post/1656906');
        expect(result?.value, '1656906');
        expect(result?.instance, 'piefed.social');
      });

      test('returns null for comment URLs', () {
        expect(parsePostId('https://piefed.social/post/123/comment/456'), isNull);
        expect(parsePostId('https://lemmy.world/post/123/456'), isNull);
      });
    });

    group('parseCommentId', () {
      test('parses PieFed comment URL', () {
        final result = parseCommentId('https://piefed.social/post/1663157/comment/9679172');
        expect(result?.value, '9679172');
        expect(result?.instance, 'piefed.social');
      });

      test('parses Lemmy legacy comment URL', () {
        final result = parseCommentId('https://lemmy.world/comment/12345');
        expect(result?.value, '12345');
        expect(result?.instance, 'lemmy.world');
      });

      test('parses Lemmy new format comment URL', () {
        final result = parseCommentId('https://lemmy.world/post/123/456');
        expect(result?.value, '456');
        expect(result?.instance, 'lemmy.world');
      });
    });
  });

  group('Real-world PieFed URL examples from issue #2036', () {
    test('https://piefed.social/post/1656906', () {
      final result = parsePostId('https://piefed.social/post/1656906');
      expect(result, isNotNull);
      expect(result!.value, '1656906');
      expect(result.instance, 'piefed.social');
    });

    test('https://piefed.social/u/darklightxi@lemmy.ca', () {
      final result = parseUser('https://piefed.social/u/darklightxi@lemmy.ca');
      expect(result, isNotNull);
      expect(result!.value, 'darklightxi');
      expect(result.instance, 'lemmy.ca');
    });

    test('https://piefed.social/c/news@lemmy.world', () {
      final result = parseCommunity('https://piefed.social/c/news@lemmy.world');
      expect(result, isNotNull);
      expect(result!.value, 'news');
      expect(result.instance, 'lemmy.world');
    });

    test('https://piefed.social/post/1663157/comment/9679172', () {
      final result = parseCommentId('https://piefed.social/post/1663157/comment/9679172');
      expect(result, isNotNull);
      expect(result!.value, '9679172');
      expect(result.instance, 'piefed.social');
    });

    test('https://piefed.social/c/thunder_app/p/1422697/thunder-release-v0-8-0-initial-piefed-support (community post format)', () {
      final result = parsePostId('https://piefed.social/c/thunder_app/p/1422697/thunder-release-v0-8-0-initial-piefed-support');
      expect(result, isNotNull);
      expect(result!.value, '1422697');
      expect(result.instance, 'piefed.social');
    });
  });

  group('PieFed Community Post URL Format', () {
    test('parses /c/community/p/postId/slug format', () {
      final result = parsePiefedPostId('https://piefed.social/c/thunder_app/p/1422697/thunder-release-v0-8-0-initial-piefed-support');
      expect(result, isNotNull);
      expect(result!.value, '1422697');
      expect(result.instance, 'piefed.social');
    });

    test('parses /c/community/p/postId format (no slug)', () {
      final result = parsePiefedPostId('https://piefed.social/c/thunder_app/p/1422697');
      expect(result, isNotNull);
      expect(result!.value, '1422697');
      expect(result.instance, 'piefed.social');
    });

    test('unified parsePostId handles PieFed community post format', () {
      final result = parsePostId('https://piefed.social/c/thunder_app/p/1422697/thunder-release-v0-8-0-initial-piefed-support');
      expect(result, isNotNull);
      expect(result!.value, '1422697');
      expect(result.instance, 'piefed.social');
    });
  });
}
