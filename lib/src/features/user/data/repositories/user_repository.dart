import 'package:thunder/src/core/core.dart';
import 'package:thunder/src/core/networking/resolved_api_client.dart';
import 'package:thunder/src/features/post/post.dart';
import 'package:thunder/src/features/user/domain/models/user_detail.dart';

/// Repository contract for user profile reads and blocks.
abstract class UserRepository {
  /// Fetches a user by their id or username
  Future<UserDetail?> getUser({
    int? userId,
    String? username,
    PostSortType? sort,
    int? page,
    String? cursor,
    int? limit,
    bool? saved,
    bool? includeContent,
  });

  /// Blocks or unblocks a user
  Future<ThunderUser> blockUser(int userId, bool block);
}

/// Implementation of [UserRepository] using the unified API client
class UserRepositoryImpl implements UserRepository {
  /// The account to use for methods invoked in this repository
  final Account account;

  /// The API client to use for the repository
  final ResolvedApiClient _api;

  /// The localization service to use for user-facing errors
  final LocalizationService _localization;

  /// Creates a new UserRepositoryImpl.
  ///
  /// An optional [api] client and [localization] can be provided for testing.
  UserRepositoryImpl({
    required this.account,
    ThunderApiClient? api,
    LocalizationService localization = const ThunderLocalizationService(),
  })  : _api = ResolvedApiClient(account: account, api: api),
        _localization = localization;

  @override
  Future<UserDetail?> getUser({
    int? userId,
    String? username,
    PostSortType? sort,
    int? page,
    String? cursor,
    int? limit,
    bool? saved,
    bool? includeContent,
  }) async {
    final api = await _api.get();
    final response = await api.getUser(
      userId: userId,
      username: username,
      sort: sort,
      page: page,
      cursor: cursor,
      limit: limit,
      saved: saved,
      includeContent: includeContent,
    );

    return UserDetail(
      user: response.user,
      site: response.site,
      posts: await parsePosts(response.posts),
      comments: response.comments,
      moderates: response.moderates,
      nextPage: response.nextPage,
    );
  }

  @override
  Future<ThunderUser> blockUser(int userId, bool block) async {
    final l10n = _localization.l10n;
    if (account.anonymous) throw NotLoggedInException(l10n.userNotLoggedIn);

    final api = await _api.get();
    return api.blockUser(userId: userId, block: block);
  }
}
