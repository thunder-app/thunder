import 'package:lemmy_api_client/v3.dart';
import 'package:thunder/utils/global_context.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// A wrapper around [SearchType] that includes instances
class MetaSearchType {
  static const MetaSearchType all = MetaSearchType(searchType: SearchType.all);
  static const MetaSearchType comments = MetaSearchType(searchType: SearchType.comments);
  static const MetaSearchType posts = MetaSearchType(searchType: SearchType.posts);
  static const MetaSearchType communities = MetaSearchType(searchType: SearchType.communities);
  static const MetaSearchType users = MetaSearchType(searchType: SearchType.users);
  static const MetaSearchType url = MetaSearchType(searchType: SearchType.url);
  static const MetaSearchType instances = MetaSearchType();

  /// The underlying [SearchType], if applicable
  final SearchType? searchType;

  /// A user-friendly name
  String get name =>
      searchType?.name ??
      switch (this) {
        instances => AppLocalizations.of(GlobalContext.context)!.instance(2),
        _ => '',
      };

  const MetaSearchType({this.searchType});
}
