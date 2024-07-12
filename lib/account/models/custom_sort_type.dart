import 'package:flutter/foundation.dart';

import 'package:drift/drift.dart';
import 'package:lemmy_api_client/v3.dart';

import 'package:thunder/core/database/database.dart';
import 'package:thunder/core/database/type_converters.dart';
import 'package:thunder/main.dart';

class CustomSortType {
  /// The type of sort (community/feed)
  final SortType sortType;

  /// The account id
  final int accountId;

  /// The community id
  final int? communityId;

  /// The feed type
  final ListingType? feedType;

  const CustomSortType({
    required this.sortType,
    required this.accountId,
    this.communityId,
    this.feedType,
  });

  CustomSortType copyWith({
    SortType? sortType,
    int? accountId,
    int? communityId,
    ListingType? feedType,
  }) =>
      CustomSortType(
        sortType: sortType ?? this.sortType,
        accountId: accountId ?? this.accountId,
        communityId: communityId ?? this.communityId,
        feedType: feedType ?? this.feedType,
      );

  /// Create or update a custom sort type in the db
  static Future<CustomSortType?> upsertCustomSortType(CustomSortType customSortType) async {
    try {
      final existingCustomSortType = await (database.select(database.customSortType)
            ..where((t) => t.accountId.equals(customSortType.accountId))
            ..where((t) => customSortType.communityId == null ? t.communityId.isNull() : t.communityId.equals(customSortType.communityId!))
            ..where((t) => customSortType.feedType == null ? t.feedType.isNull() : t.feedType.equals(const ListingTypeConverter().toSql(customSortType.feedType!))))
          .getSingleOrNull();

      if (existingCustomSortType == null) {
        final id = await database.into(database.customSortType).insert(
              CustomSortTypeCompanion.insert(
                sortType: customSortType.sortType,
                accountId: customSortType.accountId,
                communityId: Value(customSortType.communityId),
                feedType: Value(customSortType.feedType),
              ),
            );
        return customSortType;
      }

      await database.update(database.customSortType).replace(
            CustomSortTypeCompanion(
              id: Value(existingCustomSortType.id),
              sortType: Value(customSortType.sortType),
              accountId: Value(customSortType.accountId),
              communityId: Value(customSortType.communityId),
              feedType: Value(customSortType.feedType),
            ),
          );
      return customSortType;
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  /// Retrieve a custom sort type from the db
  static Future<CustomSortType?> fetchCustomSortType(int accountId, int? communityId, ListingType? feedType) async {
    try {
      final customSortType = await (database.select(database.customSortType)
            ..where((t) => t.accountId.equals(accountId))
            ..where((t) => communityId == null ? t.communityId.isNull() : t.communityId.equals(communityId))
            ..where((t) => feedType == null ? t.feedType.isNull() : t.feedType.equals(const ListingTypeConverter().toSql(feedType))))
          .getSingleOrNull();

      if (customSortType == null) return null;

      return CustomSortType(
        sortType: customSortType.sortType,
        accountId: customSortType.accountId,
        communityId: customSortType.communityId,
        feedType: customSortType.feedType,
      );
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  /// Delete a custom sort type from the db
  static Future<void> deleteCustomSortType(int accountId, int? communityId, ListingType? feedType) async {
    try {
      await (database.delete(database.customSortType)
            ..where((t) => t.accountId.equals(accountId))
            ..where((t) => communityId == null ? t.communityId.isNull() : t.communityId.equals(communityId))
            ..where((t) => feedType == null ? t.feedType.isNull() : t.feedType.equals(const ListingTypeConverter().toSql(feedType))))
          .go();
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
