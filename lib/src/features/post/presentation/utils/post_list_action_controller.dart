import 'package:thunder/src/features/post/post.dart';

class PostListActionController {
  const PostListActionController({required PostRepository postRepository}) : _postRepository = postRepository;

  final PostRepository _postRepository;

  List<ThunderPost> reconcile({
    required List<ThunderPost> sourcePosts,
    required List<ThunderPost> currentPosts,
  }) {
    if (currentPosts.isEmpty) return sourcePosts;

    final currentById = {for (final post in currentPosts) post.id: post};
    return sourcePosts.map((post) => currentById[post.id] ?? post).toList(growable: false);
  }

  List<ThunderPost> updatePost(List<ThunderPost> posts, ThunderPost updatedPost) {
    return posts.map((post) {
      if (post.id != updatedPost.id) return post;
      final preserveMedia = updatedPost.media.isEmpty && post.media.isNotEmpty;
      return preserveMedia ? updatedPost.copyWith(media: post.media) : updatedPost;
    }).toList(growable: false);
  }

  List<ThunderPost> dismissHiddenPost(List<ThunderPost> posts, int postId) {
    return posts.where((post) => post.id != postId).toList(growable: false);
  }

  List<ThunderPost> dismissBlocked(List<ThunderPost> posts, {int? userId, int? communityId}) {
    return posts.where((post) {
      if (userId != null && post.creator?.id == userId) return false;
      if (communityId != null && post.community?.id == communityId) return false;
      return true;
    }).toList(growable: false);
  }

  Future<List<ThunderPost>> vote(List<ThunderPost> posts, ThunderPost post, int value) async {
    final optimisticPosts = updatePost(posts, optimisticallyVotePost(post, value));

    try {
      final updatedPost = await _postRepository.vote(post, value);
      return updatePost(optimisticPosts, updatedPost);
    } catch (_) {
      return posts;
    }
  }

  Future<List<ThunderPost>> save(List<ThunderPost> posts, ThunderPost post, bool value) async {
    final optimisticPosts = updatePost(posts, optimisticallySavePost(post, value));

    try {
      final updatedPost = await _postRepository.save(post, value);
      return updatePost(optimisticPosts, updatedPost);
    } catch (_) {
      return posts;
    }
  }

  Future<List<ThunderPost>> read(List<ThunderPost> posts, ThunderPost post, bool value) async {
    final optimisticPosts = updatePost(posts, optimisticallyReadPost(post, value));

    try {
      final success = await _postRepository.read(post.id, value);
      return success ? optimisticPosts : posts;
    } catch (_) {
      return posts;
    }
  }

  Future<List<ThunderPost>> multiRead(List<ThunderPost> posts, List<int> postIds, bool value) async {
    if (postIds.isEmpty) return posts;

    final targetIds = postIds.toSet();
    final originalById = {for (final post in posts.where((post) => targetIds.contains(post.id))) post.id: post};
    final optimisticPosts = posts.map((post) => targetIds.contains(post.id) ? optimisticallyReadPost(post, value) : post).toList(growable: false);

    try {
      final failedIndexes = await _postRepository.readMultiple(postIds, value);
      if (failedIndexes.isEmpty) return optimisticPosts;

      final failedIds = failedIndexes.where((index) => index >= 0 && index < postIds.length).map((index) => postIds[index]).toSet();
      return optimisticPosts.map((post) => failedIds.contains(post.id) ? (originalById[post.id] ?? post) : post).toList(growable: false);
    } catch (_) {
      return posts;
    }
  }

  Future<List<ThunderPost>> hide(List<ThunderPost> posts, ThunderPost post, bool value) async {
    final optimisticPosts = updatePost(posts, optimisticallyHidePost(post, value));

    try {
      final success = await _postRepository.hide(post.id, value);
      return success ? optimisticPosts : posts;
    } catch (_) {
      return posts;
    }
  }
}
