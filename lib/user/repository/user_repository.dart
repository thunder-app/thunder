import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:http/http.dart' as http;
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
  Future<BlockPersonResponse> block(int personId, bool block);
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
        Map<String, dynamic> body = {
          'person_id': userId,
          'username': username,
          'sort': sort?.value,
          'page': page,
          'limit': limit,
          'saved_only': saved,
          'include_content': true,
        };

        // Remove null values and convert values to strings
        body.removeWhere((key, value) => value == null);
        body = body.map((key, value) => MapEntry(key, value.toString()));

        final uri = Uri.https(account.instance, '/api/alpha/user', body);
        final headers = {if (account.jwt != null) 'Authorization': 'Bearer ${account.jwt}'};

        final response = await http.get(uri, headers: headers);

        final json = jsonDecode(response.body);

        return {
          'user': ThunderUser.fromPiefedUserView(json['person_view']),
          'site': json['site'] != null ? ThunderSite.fromPiefedSite(json['site']) : null,
          'posts': json['posts'].map<ThunderPost>((pv) => ThunderPost.fromPiefedPostView(pv)).toList(),
          'comments': json['comments'].map<ThunderComment>((cv) => ThunderComment.fromPiefedCommentView(cv)).toList(),
          'moderates': json['moderates'].map<ThunderCommunity>((cmv) => ThunderCommunity.fromPiefedCommunity(cmv['community'])).toList(),
        };
      default:
        throw Exception('Unsupported platform: ${account.platform}');
    }
  }

  @override
  Future<BlockPersonResponse> block(int personId, bool block) async {
    final l10n = GlobalContext.l10n;
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    switch (account.platform) {
      case ThreadiversePlatform.lemmy:
        return await client.run(BlockPerson(auth: account.jwt!, personId: personId, block: block));
      case ThreadiversePlatform.piefed:
        // TODO: Implement action on Piefed
        throw Exception('This feature is not yet available');
      default:
        throw Exception('Unsupported platform: ${account.platform}');
    }
  }
}
