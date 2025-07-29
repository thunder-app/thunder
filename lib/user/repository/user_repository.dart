import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:lemmy_api_client/v3.dart';

import 'package:thunder/account/account.dart';
import 'package:thunder/comment/models/thunder_comment.dart';
import 'package:thunder/community/models/thunder_community.dart';
import 'package:thunder/core/data_providers/piefed_api.dart';
import 'package:thunder/core/enums/post_sort_type.dart';
import 'package:thunder/core/enums/threadiverse_platform.dart';
import 'package:thunder/core/models/thunder_site.dart';
import 'package:thunder/post/models/thunder_post.dart';
import 'package:thunder/user/models/thunder_user.dart';
import 'package:thunder/utils/global_context.dart';

/// Interface for a user repository
abstract class UserRepository {
  /// Fetches a user by its ID
  Future<Map<String, dynamic>?> getUser({
    int? userId,
    String? username,
    PostSortType? sort,
    int? page,
    int? limit,
    bool? saved,
  });

  /// Blocks or unblocks a person
  Future<ThunderUser> block(int personId, bool block);
}

/// Implementation of [UserRepository] using Lemmy API
class UserRepositoryImpl implements UserRepository {
  /// The account to use for methods invoked in this repository
  Account account;

  /// The Lemmy client to use for the repository
  late LemmyApiV3 client;

  /// The Piefed client to use for the repository
  late PiefedApi piefed;

  UserRepositoryImpl({required this.account}) {
    switch (account.platform) {
      case ThreadiversePlatform.lemmy:
        client = LemmyApiV3(account.instance, debug: kDebugMode);
        break;
      case ThreadiversePlatform.piefed:
        piefed = PiefedApi(account: account, debug: kDebugMode);
        break;
      default:
        throw Exception('Unsupported platform: ${account.platform}');
    }
  }

  @override
  Future<Map<String, dynamic>?> getUser({
    int? userId,
    String? username,
    PostSortType? sort,
    int? page,
    int? limit,
    bool? saved,
  }) async {
    switch (account.platform) {
      case ThreadiversePlatform.lemmy:
        final response = await client.run(GetPersonDetails(
          auth: account.jwt,
          personId: userId,
          username: username,
          sort: sort?.toLemmyType(),
          page: page,
          limit: limit,
          savedOnly: saved,
        ));

        return {
          'user': ThunderUser.fromLemmyUserView(response.personView.toJson()),
          'site': response.site != null ? ThunderSite.fromLemmySite(response.site!.toJson()) : null,
          'posts': response.posts.map((post) => ThunderPost.fromLemmyPostView(post.toJson())).toList(),
          'comments': response.comments.map((comment) => ThunderComment.fromLemmyCommentView(comment.toJson())).toList(),
          'moderates': response.moderates.map((cmv) => ThunderCommunity.fromLemmyCommunity(cmv.community.toJson())).toList(),
        };
      case ThreadiversePlatform.piefed:
        return await piefed.getUser(userId: userId, username: username, sort: sort, page: page, limit: limit, saved: saved);
      default:
        throw Exception('Unsupported platform: ${account.platform}');
    }
  }

  @override
  Future<ThunderUser> block(int personId, bool block) async {
    final l10n = GlobalContext.l10n;
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    switch (account.platform) {
      case ThreadiversePlatform.lemmy:
        final response = await client.run(BlockPerson(auth: account.jwt!, personId: personId, block: block));
        return ThunderUser.fromLemmyUserView(response.personView.toJson());
      case ThreadiversePlatform.piefed:
        return await piefed.blockUser(userId: personId, block: block);
      default:
        throw Exception('Unsupported platform: ${account.platform}');
    }
  }
}
