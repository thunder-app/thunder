import 'package:flutter_test/flutter_test.dart';
import 'package:thunder/src/features/post/post.dart';
import 'package:thunder/src/features/user/domain/utils/user_media_utils.dart';

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
  group('UserMediaUsecase', () {
    test('removes images by alias', () {
      final images = [
        {
          'local_image': {'pictrs_alias': 'a'},
        },
        {
          'local_image': {'pictrs_alias': 'b'},
        },
      ];

      final updated = removeImageByAlias(
        images: images,
        alias: 'b',
      );

      expect(updated.length, 1);
      expect(updated.first['local_image']['pictrs_alias'], 'a');
    });

    test('merges posts without duplicates by ID', () {
      final merged = mergeUniquePosts(
        primary: [_post(1), _post(2)],
        secondary: [_post(2), _post(3)],
      );

      expect(merged.map((post) => post.id), [1, 2, 3]);
    });
  });
}
