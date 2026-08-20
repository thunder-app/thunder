import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/src/features/feed/feed.dart';
import 'package:thunder/src/shared/sort_picker.dart';
import 'package:thunder/src/features/community/community.dart';

String getAppBarTitle(FeedState state) {
  if (state.status == FeedStatus.initial) {
    return '';
  }

  if (state.communityId != null || state.communityName != null) {
    return state.community?.title ?? '';
  }

  if (state.userId != null || state.username != null) {
    return state.user?.displayName ?? state.user?.name ?? '';
  }

  return (state.feedListType != null) ? (destinations.firstWhere((destination) => destination.listingType == state.feedListType).label) : '';
}

String getSortName(FeedState state) {
  if (state.status == FeedStatus.initial) {
    return '';
  }

  final postSortTypeItemIndex = allPostSortTypeItems.indexWhere((item) => item.payload == state.postSortType);
  final postSortTypeItem = postSortTypeItemIndex > -1 ? allPostSortTypeItems[postSortTypeItemIndex] : null;

  return postSortTypeItem?.label ?? '';
}

IconData? getSortIcon(FeedState state) {
  if (state.status == FeedStatus.initial) {
    return null;
  }

  final postSortTypeItemIndex = allPostSortTypeItems.indexWhere((item) => item.payload == state.postSortType);
  final postSortTypeItem = postSortTypeItemIndex > -1 ? allPostSortTypeItems[postSortTypeItemIndex] : null;

  return postSortTypeItem?.icon;
}

Future<void> triggerRefresh(BuildContext context) async {
  FeedState state = context.read<FeedBloc>().state;

  context.read<FeedBloc>().add(
    FeedFetchedEvent(
      feedType: state.feedType,
      feedListType: state.feedListType,
      postSortType: state.postSortType,
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
