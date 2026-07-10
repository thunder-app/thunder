import 'package:thunder/src/features/user/data/data_sources/user_label_local_data_source.dart';
import 'package:thunder/src/features/user/domain/models/user_label.dart';

/// Repository contract for local user labels.
abstract class UserLabelRepository {
  Future<UserLabel?> upsertUserLabel(UserLabel userLabel);

  Future<UserLabel?> fetchUserLabel(String username);

  Future<void> deleteUserLabel(String username);

  Future<List<UserLabel>> fetchAllUserLabels();
}

/// Implementation of [UserLabelRepository] backed by [UserLabelLocalDataSource].
class UserLabelRepositoryImpl implements UserLabelRepository {
  const UserLabelRepositoryImpl();

  @override
  Future<UserLabel?> upsertUserLabel(UserLabel userLabel) {
    return UserLabelLocalDataSource.upsertUserLabel(userLabel);
  }

  @override
  Future<UserLabel?> fetchUserLabel(String username) {
    return UserLabelLocalDataSource.fetchUserLabel(username);
  }

  @override
  Future<void> deleteUserLabel(String username) {
    return UserLabelLocalDataSource.deleteUserLabel(username);
  }

  @override
  Future<List<UserLabel>> fetchAllUserLabels() {
    return UserLabelLocalDataSource.fetchAllUserLabels();
  }
}
