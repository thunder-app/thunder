import 'package:flutter_test/flutter_test.dart';
import 'package:thunder/src/features/feed/domain/utils/feed_collection_utils.dart';
import 'package:thunder/src/features/post/post.dart';

ThunderPost _post(int id) {
  return ThunderPost(
    id: id,
    name: 'post-$id',
    creatorId: 1,
    communityId: 1,
    removed: false,
    locked: false,
    published: DateTime(2024, 1, 1),
    deleted: false,
    nsfw: false,
    apId: 'https://example.com/post/$id',
    local: true,
    languageId: 0,
    featuredCommunity: false,
    featuredLocal: false,
  );
}

void main() {
  group('FeedViewUsecase', () {
    test('hidePostsByIds removes only matching post IDs', () {
      final posts = <ThunderPost>[
        _post(1),
        _post(2),
        _post(3),
      ];

      final filtered = hidePostsByIds(
        posts: posts,
        postIds: {2, 99},
      );

      expect(filtered.map((p) => p.id), [1, 3]);
      expect(posts.map((p) => p.id), [1, 2, 3]);
    });
  });
}
