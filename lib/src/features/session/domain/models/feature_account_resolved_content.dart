import 'package:equatable/equatable.dart';

import 'package:thunder/src/features/comment/comment.dart';
import 'package:thunder/src/features/community/community.dart';
import 'package:thunder/src/features/post/post.dart';

class FeatureAccountResolvedContent extends Equatable {
  const FeatureAccountResolvedContent({
    this.community,
    this.post,
    this.parentComment,
  });

  final ThunderCommunity? community;
  final ThunderPost? post;
  final ThunderComment? parentComment;

  @override
  List<Object?> get props => [community, post, parentComment];
}
