import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/features/post/post.dart';

List<AccountMediaItem> removeImageByAlias({
  required List<AccountMediaItem> images,
  required String alias,
}) {
  final updated = List<AccountMediaItem>.from(images);
  updated.removeWhere(
    (localImageView) => localImageView.alias == alias,
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
