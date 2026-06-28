import 'package:flutter/foundation.dart';

import 'package:thunder/src/foundation/foundation.dart';
import 'package:thunder/src/features/moderator/domain/enums/report_feed_type.dart';

/// Repository contract for moderator report reads and actions.
abstract class ReportRepository {
  /// Fetches post or comment reports.
  Future<ThunderPage<ThunderReport>> getReports({
    int page = 1,
    String? cursor,
    int limit = 10,
    bool unresolved = false,
    int? communityId,
    int? postId,
    int? commentId,
    required ReportFeedType reportFeedType,
  });

  /// Resolves or unresolves a report.
  Future<bool> resolveReport(ThunderReport report, bool resolved);
}

/// Implementation of [ReportRepository] using the unified API client.
class ReportRepositoryImpl implements ReportRepository {
  /// The account to use for methods invoked in this repository.
  final Account account;

  /// The API client to use for the repository.
  final ThunderApiClient _api;

  /// The localization service to use for user-facing errors.
  final LocalizationService _localization;

  /// Creates a new [ReportRepositoryImpl].
  ///
  /// An optional [api] client and [localization] can be provided for testing.
  ReportRepositoryImpl({
    required this.account,
    ThunderApiClient? api,
    LocalizationService localization = const ThunderLocalizationService(),
  })  : _api = api ?? ApiClientFactory.create(account, debug: kDebugMode),
        _localization = localization;

  @override
  Future<ThunderPage<ThunderReport>> getReports({
    int page = 1,
    String? cursor,
    int limit = 10,
    bool unresolved = false,
    int? communityId,
    int? postId,
    int? commentId,
    required ReportFeedType reportFeedType,
  }) async {
    final kind = switch (reportFeedType) {
      ReportFeedType.post => ReportKind.post,
      ReportFeedType.comment => ReportKind.comment,
    };

    if ((kind == ReportKind.post && !_api.supportsPostReports) || (kind == ReportKind.comment && !_api.supportsCommentReports)) {
      throw UnsupportedFeatureException('${kind.name} reports', platformName: _api.platformName);
    }

    return _api.getReports(
      kind: kind,
      postId: postId,
      commentId: commentId,
      page: page,
      cursor: cursor,
      limit: limit,
      unresolved: unresolved,
      communityId: communityId,
    );
  }

  @override
  Future<bool> resolveReport(ThunderReport report, bool resolved) async {
    final l10n = _localization.l10n;
    if (account.anonymous) throw NotLoggedInException(l10n.userNotLoggedIn);

    final response = await _api.resolveReport(reportId: report.id, kind: report.kind, resolved: resolved);
    return response.resolved == resolved;
  }
}
