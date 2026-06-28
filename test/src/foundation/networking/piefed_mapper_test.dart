import 'package:flutter_test/flutter_test.dart';

import 'package:thunder/src/foundation/networking/mappers/piefed_mapper.dart';

void main() {
  const mapper = PiefedPrimitiveMapper();

  group('PiefedPrimitiveMapper', () {
    test('maps post view fixture to ThunderPost', () {
      final post = mapper.postView({
        'post': {
          'id': 42,
          'title': 'Hello PieFed',
          'user_id': 7,
          'community_id': 3,
          'published': '2025-06-01T12:00:00Z',
          'ap_id': 'https://piefed.test/post/42',
          'language_id': 1,
        },
        'creator': {
          'id': 7,
          'user_name': 'alice',
          'published': '2025-01-01T00:00:00Z',
          'actor_id': 'https://piefed.test/u/alice',
          'instance_id': 1,
        },
        'community': {
          'id': 3,
          'name': 'news',
          'title': 'News',
          'published': '2025-01-01T00:00:00Z',
          'actor_id': 'https://piefed.test/c/news',
          'instance_id': 1,
        },
        'counts': {
          'comments': 2,
          'score': 10,
          'upvotes': 12,
          'downvotes': 2,
        },
        'subscribed': 'NotSubscribed',
      });

      expect(post.id, 42);
      expect(post.name, 'Hello PieFed');
      expect(post.creator?.name, 'alice');
      expect(post.community?.name, 'news');
      expect(post.counts?.comments, 2);
    });

    test('maps comment view fixture to ThunderComment', () {
      final comment = mapper.commentView({
        'comment': {
          'id': 99,
          'post_id': 42,
          'user_id': 7,
          'body': 'Nice post',
          'published': '2025-06-01T13:00:00Z',
          'ap_id': 'https://piefed.test/comment/99',
          'path': '0.99',
          'language_id': 1,
        },
        'creator': {
          'id': 7,
          'user_name': 'alice',
          'published': '2025-01-01T00:00:00Z',
          'actor_id': 'https://piefed.test/u/alice',
          'instance_id': 1,
        },
        'counts': {
          'score': 3,
          'upvotes': 4,
          'downvotes': 1,
        },
      });

      expect(comment.id, 99);
      expect(comment.content, 'Nice post');
      expect(comment.creator?.name, 'alice');
      expect(comment.counts?.score, 3);
    });
  });
}
