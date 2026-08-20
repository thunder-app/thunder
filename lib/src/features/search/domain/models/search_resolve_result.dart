import 'package:thunder/src/core/domain/models/thunder_comment.dart';
import 'package:thunder/src/core/domain/models/thunder_community.dart';
import 'package:thunder/src/core/domain/models/thunder_post.dart';
import 'package:thunder/src/core/domain/models/thunder_user.dart';

class SearchResolveResult {
  final ThunderCommunity? community;
  final ThunderPost? post;
  final ThunderComment? comment;
  final ThunderUser? user;

  const SearchResolveResult({this.community, this.post, this.comment, this.user});
}
