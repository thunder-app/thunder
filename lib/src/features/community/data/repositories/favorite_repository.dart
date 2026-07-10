import 'package:thunder/src/features/community/data/data_sources/favorite_local_data_source.dart';
import 'package:thunder/src/features/community/domain/models/favorite.dart';

/// Repository contract for local favorite communities.
abstract class FavoriteRepository {
  Future<Favorite?> insertFavorite(Favorite favourite);

  Future<List<Favorite>> favorites(String accountId);

  Future<Favorite?> fetchFavourite(String id);

  Future<void> updateFavourite(Favorite favorite);

  Future<void> deleteFavorite({String? id, int? communityId});
}

/// Implementation of [FavoriteRepository] backed by [FavoriteLocalDataSource].
class FavoriteRepositoryImpl implements FavoriteRepository {
  const FavoriteRepositoryImpl();

  @override
  Future<Favorite?> insertFavorite(Favorite favourite) {
    return FavoriteLocalDataSource.insertFavorite(favourite);
  }

  @override
  Future<List<Favorite>> favorites(String accountId) {
    return FavoriteLocalDataSource.favorites(accountId);
  }

  @override
  Future<Favorite?> fetchFavourite(String id) {
    return FavoriteLocalDataSource.fetchFavourite(id);
  }

  @override
  Future<void> updateFavourite(Favorite favorite) {
    return FavoriteLocalDataSource.updateFavourite(favorite);
  }

  @override
  Future<void> deleteFavorite({String? id, int? communityId}) {
    return FavoriteLocalDataSource.deleteFavorite(id: id, communityId: communityId);
  }
}
