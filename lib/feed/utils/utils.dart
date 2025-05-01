import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/feed/feed.dart';
import 'package:thunder/shared/sort_picker.dart';
import 'package:thunder/community/widgets/community_drawer.dart';

String getAppBarTitle(FeedState state) {
  if (state.status == FeedStatus.initial) {
    return '';
  }

  if (state.communityId != null || state.communityName != null) {
    return state.community?.title ?? '';
  }

  if (state.userId != null || state.username != null) {
    return state.fullPersonView?.personView.person.displayName ?? state.fullPersonView?.personView.person.name ?? '';
  }

  return (state.feedListType != null) ? (destinations.firstWhere((destination) => destination.listingType == state.feedListType).label) : '';
}

String getSortName(FeedState state) {
  if (state.status == FeedStatus.initial) {
    return '';
  }

  final sortTypeItemIndex = allSortTypeItems.indexWhere((sortTypeItem) => sortTypeItem.payload == state.sortType);
  final sortTypeItem = sortTypeItemIndex > -1 ? allSortTypeItems[sortTypeItemIndex] : null;

  return sortTypeItem?.label ?? '';
}

IconData? getSortIcon(FeedState state) {
  if (state.status == FeedStatus.initial) {
    return null;
  }

  final sortTypeItemIndex = allSortTypeItems.indexWhere((sortTypeItem) => sortTypeItem.payload == state.sortType);
  final sortTypeItem = sortTypeItemIndex > -1 ? allSortTypeItems[sortTypeItemIndex] : null;

  return sortTypeItem?.icon;
}

Future<void> triggerRefresh(BuildContext context) async {
  FeedState state = context.read<FeedBloc>().state;

  context.read<FeedBloc>().add(
        FeedFetchedEvent(
          feedType: state.feedType,
          feedListType: state.feedListType,
          sortType: state.sortType,
          communityId: state.communityId,
          communityName: state.communityName,
          userId: state.userId,
          username: state.username,
          reset: true,
          showHidden: state.showHidden,
          showSaved: state.showSaved,
        ),
      );
}
