import 'package:thunder/src/features/post/post.dart';

List<Map<String, dynamic>> removeImageByAlias({
  required List<Map<String, dynamic>> images,
  required String alias,
}) {
  final updated = List<Map<String, dynamic>>.from(images);
  updated.removeWhere(
    (localImageView) => localImageView['local_image']['pictrs_alias'] == alias,
  );
  return updated;
}

List<ThunderPost> mergeUniquePosts({
  required List<ThunderPost> primary,
  required List<ThunderPost> secondary,
}) {
  final merged = List<ThunderPost>.from(primary);
  merged.addAll(
    secondary.where(
      (candidate) => !merged.any((existing) => existing.id == candidate.id),
    ),
  );
  return merged;
}
