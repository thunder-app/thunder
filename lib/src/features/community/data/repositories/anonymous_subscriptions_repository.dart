import 'package:thunder/src/core/domain/domain.dart';
import 'package:thunder/src/features/community/data/data_sources/anonymous_subscriptions_local_data_source.dart';
import 'package:thunder/src/features/community/domain/models/local_community.dart';

/// Repository contract for anonymous local community subscriptions.
abstract class AnonymousSubscriptionsRepository {
  Future<List<ThunderCommunity>> getSubscriptions();

  Future<void> insertSubscriptions(Set<ThunderCommunity> communities);

  Future<void> deleteCommunities(Set<String> urls);

  Future<List<LocalCommunity>> getSubscribedCommunities();
}

/// Implementation of [AnonymousSubscriptionsRepository] backed by [AnonymousSubscriptionsLocalDataSource].
class AnonymousSubscriptionsRepositoryImpl implements AnonymousSubscriptionsRepository {
  const AnonymousSubscriptionsRepositoryImpl();

  @override
  Future<List<ThunderCommunity>> getSubscriptions() {
    return AnonymousSubscriptionsLocalDataSource.getSubscriptions();
  }

  @override
  Future<void> insertSubscriptions(Set<ThunderCommunity> communities) {
    return AnonymousSubscriptionsLocalDataSource.insertSubscriptions(communities);
  }

  @override
  Future<void> deleteCommunities(Set<String> urls) {
    return AnonymousSubscriptionsLocalDataSource.deleteCommunities(urls);
  }

  @override
  Future<List<LocalCommunity>> getSubscribedCommunities() {
    return AnonymousSubscriptionsLocalDataSource.getSubscribedCommunities();
  }
}
