import 'package:equatable/equatable.dart';

class FeatureAccountResolutionRequest extends Equatable {
  const FeatureAccountResolutionRequest({
    this.communityActorId,
    this.postActorId,
    this.parentCommentActorId,
  });

  final String? communityActorId;
  final String? postActorId;
  final String? parentCommentActorId;

  bool get hasTargets => _hasValue(communityActorId) || _hasValue(postActorId) || _hasValue(parentCommentActorId);

  @override
  List<Object?> get props => [communityActorId, postActorId, parentCommentActorId];
}

bool _hasValue(String? value) => value?.isNotEmpty == true;
