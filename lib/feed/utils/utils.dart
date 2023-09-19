import 'package:flutter/widgets.dart';

import 'package:thunder/feed/feed.dart';
import 'package:thunder/shared/sort_picker.dart';
import 'package:thunder/community/widgets/community_drawer.dart';

String getCommunityName(FeedState state) {
  if (state.status == FeedStatus.initial) {
    return '';
  }

  if (state.communityId != null || state.communityName != null) {
    // return state?.communityInfo?.communityView.community.title ?? '';
    return '';
  }

  return (state.postListingType != null) ? (destinations.firstWhere((destination) => destination.listingType == state.postListingType).label) : '';
}

String getSortName(FeedState state) {
  if (state.status == FeedStatus.initial) {
    return '';
  }

  final sortTypeItem = allSortTypeItems.firstWhere((sortTypeItem) => sortTypeItem.payload == state.sortType);
  return sortTypeItem.label;
}

IconData? getSortIcon(FeedState state) {
  if (state.status == FeedStatus.initial) {
    return null;
  }

  final sortTypeItem = allSortTypeItems.firstWhere((sortTypeItem) => sortTypeItem.payload == state.sortType);
  return sortTypeItem.icon;
}
