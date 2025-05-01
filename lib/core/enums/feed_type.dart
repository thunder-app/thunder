import 'package:collection/collection.dart';
import 'package:lemmy_api_client/v3.dart';

enum FeedListType {
  all('All'),
  local('Local'),
  subscribed('Subscribed'),
  moderatorView('ModeratorView');

  /// The value of the enum. This corresponds to the value used in the request.
  final String value;

  const FeedListType(this.value);

  @override
  String toString() => value;

  /// Converts the FeedListType to ListingType
  ListingType? toLemmyType() {
    return ListingType.values.firstWhereOrNull((listingType) => listingType.name == name);
  }

  /// Converts ListingType to FeedListType
  static FeedListType? fromLemmyType(ListingType? listingType) {
    return FeedListType.values.firstWhereOrNull((feedListType) => feedListType.name == listingType?.name);
  }
}
