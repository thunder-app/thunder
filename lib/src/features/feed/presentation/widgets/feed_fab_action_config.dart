import 'package:thunder/src/features/feed/feed.dart';
import 'package:thunder/src/foundation/primitives/primitives.dart';

/// Resolved action configuration for [FeedFAB].
class FeedFabActionConfig {
  const FeedFabActionConfig({
    required this.singlePressAction,
    required this.longPressAction,
    required this.disabledActions,
    required this.isPostLocked,
  });

  /// Action executed by a normal FAB press.
  final FeedFabAction singlePressAction;

  /// Action executed by a long FAB press.
  final FeedFabAction longPressAction;

  /// Actions hidden from the expanded FAB menu.
  final List<FeedFabAction> disabledActions;

  /// Whether new-post creation is locked to community moderators.
  final bool isPostLocked;
}

/// Resolves feed FAB actions for the current route and account permissions.
FeedFabActionConfig resolveFeedFabActionConfig({
  required FeedFabAction preferredSinglePressAction,
  required FeedFabAction preferredLongPressAction,
  required FeedStatus status,
  required FeedType? feedType,
  required ThunderCommunity? community,
  required bool isLoggedIn,
  required List<ThunderCommunity> moderates,
  required bool isNavigatedFeed,
}) {
  final isGeneralFeed = status != FeedStatus.initial && feedType == FeedType.general;
  final isCommunityFeed = status != FeedStatus.initial && feedType == FeedType.community;
  final isUserFeed = status != FeedStatus.initial && feedType == FeedType.user;

  final disabledActions = switch ((isGeneralFeed, isCommunityFeed && isNavigatedFeed, isUserFeed && isNavigatedFeed)) {
    (true, _, _) => const <FeedFabAction>[],
    (_, true, _) => const <FeedFabAction>[FeedFabAction.subscriptions],
    (_, _, true) => const <FeedFabAction>[FeedFabAction.subscriptions, FeedFabAction.newPost, FeedFabAction.dismissRead],
    _ => const <FeedFabAction>[],
  };

  final isPostLocked = isLoggedIn && isCommunityFeed && community != null && community.status.postingRestrictedToMods && !moderates.any((moderatedCommunity) => moderatedCommunity.id == community.id);

  return FeedFabActionConfig(
    singlePressAction: disabledActions.contains(preferredSinglePressAction) ? FeedFabAction.openFab : preferredSinglePressAction,
    longPressAction: disabledActions.contains(preferredLongPressAction) ? FeedFabAction.openFab : preferredLongPressAction,
    disabledActions: disabledActions,
    isPostLocked: isPostLocked,
  );
}
