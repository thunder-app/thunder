import 'package:thunder/src/core/config/global_context.dart';
import 'package:thunder/l10n/generated/app_localizations.dart';
import 'package:thunder/src/core/domain/enums/threadiverse_platform.dart';

enum MetaSearchType {
  all(searchType: 'All'),
  comments(searchType: 'Comments'),
  posts(searchType: 'Posts'),
  communities(searchType: 'Communities'),
  users(searchType: 'Users'),
  url(searchType: 'Url'),
  instances();

  /// The type of search to perform.
  final String? searchType;

  /// The platform this meta search type is used on. If null, it is used on all platforms.
  final ThreadiversePlatform? platform = null;

  const MetaSearchType({this.searchType});

  /// Fetches the name of the meta search type.
  String get name =>
      searchType ??
      switch (this) {
        instances => AppLocalizations.of(GlobalContext.context)!.instance(2),
        _ => '',
      };
}
