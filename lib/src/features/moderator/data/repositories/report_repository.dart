import 'package:thunder/src/core/core.dart';
import 'package:thunder/src/core/networking/resolved_api_client.dart';
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
  final ResolvedApiClient _api;

  /// The localization service to use for user-facing errors.
  final LocalizationService _localization;

  /// Creates a new [ReportRepositoryImpl].
  ///
  /// An optional [api] client and [localization] can be provided for testing.
  ReportRepositoryImpl({
    required this.account,
    ThunderApiClient? api,
    LocalizationService localization = const ThunderLocalizationService(),
  })  : _api = ResolvedApiClient(account: account, api: api),
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
    final api = await _api.get();
    final kind = switch (reportFeedType) {
      ReportFeedType.post => ReportKind.post,
      ReportFeedType.comment => ReportKind.comment,
    };

    if (!api.supportsListReports) {
      throw UnsupportedFeatureException('${kind.name} reports', platformName: api.platformName);
    }

    return api.getReports(
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

    final api = await _api.get();
    final response = await api.resolveReport(reportId: report.id, kind: report.kind, resolved: resolved);
    return response.resolved == resolved;
  }
}
