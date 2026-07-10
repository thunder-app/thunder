import 'package:flutter_test/flutter_test.dart';

import 'package:thunder/src/core/networking/mappers/lemmy_v4_mapper.dart';

void main() {
  const mapper = LemmyV4PrimitiveMapper();

  group('LemmyV4PrimitiveMapper', () {
    test('maps post view fixture to ThunderPost', () {
      final post = mapper.postView({
        'post': {
          'id': 42,
          'name': 'Hello Lemmy 1.0',
          'creator_id': 7,
          'community_id': 3,
          'published_at': '2025-06-01T12:00:00Z',
          'comments': 2,
          'score': 10,
          'upvotes': 12,
          'downvotes': 2,
          'ap_id': 'https://lemmy.test/post/42',
          'language_id': 1,
        },
        'creator': {
          'id': 7,
          'name': 'alice',
          'published_at': '2025-01-01T00:00:00Z',
          'ap_id': 'https://lemmy.test/u/alice',
          'instance_id': 1,
        },
        'community': {
          'id': 3,
          'name': 'news',
          'title': 'News',
          'published_at': '2025-01-01T00:00:00Z',
          'ap_id': 'https://lemmy.test/c/news',
          'instance_id': 1,
        },
        'post_actions': {
          'read_at': '2025-06-01T12:00:00Z',
          'vote_is_upvote': true,
        },
        'community_actions': {
          'follow_state': 'accepted',
        },
      });

      expect(post.id, 42);
      expect(post.name, 'Hello Lemmy 1.0');
      expect(post.creator?.name, 'alice');
      expect(post.community?.name, 'news');
      expect(post.counts.comments, 2);
      expect(post.context.read, isTrue);
    });

    test('maps comment view fixture to ThunderComment', () {
      final comment = mapper.commentView({
        'comment': {
          'id': 99,
          'post_id': 42,
          'creator_id': 7,
          'content': 'Nice post',
          'published_at': '2025-06-01T13:00:00Z',
          'score': 3,
          'upvotes': 4,
          'downvotes': 1,
          'ap_id': 'https://lemmy.test/comment/99',
          'path': '0.99',
          'language_id': 1,
        },
        'creator': {
          'id': 7,
          'name': 'alice',
          'published_at': '2025-01-01T00:00:00Z',
          'ap_id': 'https://lemmy.test/u/alice',
          'instance_id': 1,
        },
        'comment_actions': {
          'saved': false,
          'vote': 1,
        },
      });

      expect(comment.id, 99);
      expect(comment.content, 'Nice post');
      expect(comment.creator?.name, 'alice');
      expect(comment.counts.score, 3);
    });
  });
}
