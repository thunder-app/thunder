import 'package:thunder/src/features/post/post.dart';

List<ThunderPost> hidePostsByIds({
  required List<ThunderPost> posts,
  required Set<int> postIds,
}) {
  final updatedPosts = List<ThunderPost>.from(posts);
  updatedPosts.removeWhere((post) => postIds.contains(post.id));
  return updatedPosts;
}

List<ThunderPost> replaceAt({
  required List<ThunderPost> source,
  required int index,
  required ThunderPost value,
}) {
  final updated = List<ThunderPost>.from(source);
  updated[index] = value;
  return updated;
}

({List<int> indexes, List<int> ids, List<ThunderPost> posts}) collectByIds({
  required List<ThunderPost> source,
  required List<int> ids,
}) {
  final indexes = <int>[];
  final postIds = <int>[];
  final posts = <ThunderPost>[];

  for (var i = 0; i < source.length; i++) {
    if (ids.contains(source[i].id)) {
      indexes.add(i);
      postIds.add(source[i].id);
      posts.add(source[i]);
    }
  }

  return (indexes: indexes, ids: postIds, posts: posts);
}
