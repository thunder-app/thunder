import 'package:flutter/foundation.dart';

import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/features/comment/comment.dart';
import 'package:thunder/src/features/community/community.dart';
import 'package:thunder/src/features/post/post.dart';
import 'package:thunder/src/features/search/search.dart';
import 'package:thunder/src/features/session/domain/models/feature_account_resolution_request.dart';
import 'package:thunder/src/features/session/domain/models/feature_account_resolved_content.dart';

class FeatureAccountContentResolver {
  FeatureAccountContentResolver({
    SearchRepository Function(Account account)? searchRepositoryFactory,
    Future<List<ThunderPost>> Function(List<ThunderPost> posts)? postParser,
  })  : _searchRepositoryFactory = searchRepositoryFactory ?? ((account) => SearchRepositoryImpl(account: account)),
        _postParser = postParser ?? ((posts) => parsePosts(posts));

  final SearchRepository Function(Account account) _searchRepositoryFactory;
  final Future<List<ThunderPost>> Function(List<ThunderPost> posts) _postParser;

  Future<FeatureAccountResolvedContent> resolve({required Account account, required FeatureAccountResolutionRequest request}) async {
    final repository = _searchRepositoryFactory(account);

    final community = await _resolveCommunity(repository, request.communityActorId);
    final post = await _resolvePost(repository, request.postActorId);
    final parentComment = await _resolveParentComment(repository, request.parentCommentActorId);

    return FeatureAccountResolvedContent(
      community: community,
      post: post,
      parentComment: parentComment,
    );
  }

  Future<ThunderCommunity?> _resolveCommunity(SearchRepository repository, String? actorId) async {
    if (actorId?.isNotEmpty != true) return null;

    try {
      final response = await repository.resolve(query: actorId!);
      return response.community;
    } catch (error) {
      debugPrint('Failed to resolve community: $error');
      return null;
    }
  }

  Future<ThunderPost?> _resolvePost(SearchRepository repository, String? actorId) async {
    if (actorId?.isNotEmpty != true) return null;

    try {
      final response = await repository.resolve(query: actorId!);
      final post = response.post;
      if (post == null) return null;

      final parsedPosts = await _postParser([post]);
      return parsedPosts.isNotEmpty ? parsedPosts.first : null;
    } catch (error) {
      debugPrint('Failed to resolve post: $error');
      return null;
    }
  }

  Future<ThunderComment?> _resolveParentComment(SearchRepository repository, String? actorId) async {
    if (actorId?.isNotEmpty != true) return null;

    try {
      final response = await repository.resolve(query: actorId!);
      return response.comment;
    } catch (error) {
      debugPrint('Failed to resolve parent comment: $error');
      return null;
    }
  }
}
