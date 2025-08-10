import 'package:lemmy_api_client/v3.dart' as lemmy;

import 'package:thunder/src/app/utils/global_context.dart';
import 'package:thunder/l10n/generated/app_localizations.dart';

enum MetaSearchType {
  all(searchType: 'All'), // v0.18.0
  comments(searchType: 'Comments'), // v0.18.0
  posts(searchType: 'Posts'), // v0.18.0
  communities(searchType: 'Communities'), // v0.18.0
  users(searchType: 'Users'), // v0.18.0
  url(searchType: 'Url'), // v0.18.0
  instances(), // Custom
  ;

  final String? searchType;

  const MetaSearchType({this.searchType});

  /// A user-friendly name
  String get name =>
      searchType ??
      switch (this) {
        instances => AppLocalizations.of(GlobalContext.context)!.instance(2),
        _ => '',
      };

  lemmy.SearchType toLemmyType() {
    switch (this) {
      case MetaSearchType.all:
        return lemmy.SearchType.all;
      case MetaSearchType.comments:
        return lemmy.SearchType.comments;
      case MetaSearchType.posts:
        return lemmy.SearchType.posts;
      case MetaSearchType.communities:
        return lemmy.SearchType.communities;
      case MetaSearchType.users:
        return lemmy.SearchType.users;
      case MetaSearchType.url:
        return lemmy.SearchType.url;
      case MetaSearchType.instances:
        throw UnimplementedError();
    }
  }
}
