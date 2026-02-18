import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/features/community/community.dart';
import 'package:thunder/src/features/user/user.dart';

bool isSameUser({
  required ThunderUser user,
  required Account account,
}) {
  return user.id == account.userId;
}

List<ThunderCommunity> filterFavorites({
  required List<ThunderCommunity> subscriptions,
  required List<Favorite> favorites,
}) {
  final favoriteCommunityIds = favorites.map((favorite) => favorite.communityId).toSet();
  return subscriptions.where((community) => favoriteCommunityIds.contains(community.id)).toList();
}
