import 'package:thunder/core/enums/enums.dart';
import 'package:thunder/core/models/models.dart';

class CommunityView {
  Community community;

  SubscribedType subscribed;

  bool blocked;

  CommunityAggregates counts;

  bool? bannedFromCommunity;

  CommunityView({
    required this.community, // v0.18.0
    required this.subscribed, // v0.18.0
    required this.blocked, // v0.18.0
    required this.counts, // v0.18.0
    this.bannedFromCommunity, // v0.19.4 (required)
  });
}
