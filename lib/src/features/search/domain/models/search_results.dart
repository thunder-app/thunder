import 'package:thunder/src/core/domain/domain.dart';

class SearchResults {
  final MetaSearchType type;
  final List<ThunderComment> comments;
  final List<ThunderPost> posts;
  final List<ThunderCommunity> communities;
  final List<ThunderUser> users;

  const SearchResults({required this.type, required this.comments, required this.posts, required this.communities, required this.users});
}
