import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lemmy_api_client/v3.dart';

import 'package:thunder/account/bloc/account_bloc.dart';
import 'package:thunder/community/bloc/community_bloc.dart';
import 'package:thunder/community/pages/create_post_page.dart';
import 'package:thunder/community/widgets/community_drawer.dart';
import 'package:thunder/community/widgets/post_card_list.dart';
import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/shared/error_message.dart';

class SortTypeItem {
  const SortTypeItem({required this.sortType, required this.icon, required this.label});

  final SortType sortType;
  final IconData icon;
  final String label;
}

const sortTypeItems = [
  SortTypeItem(
    sortType: SortType.hot,
    icon: Icons.local_fire_department_rounded,
    label: 'Hot',
  ),
  SortTypeItem(
    sortType: SortType.active,
    icon: Icons.rocket_launch_rounded,
    label: 'Active',
  ),
  SortTypeItem(
    sortType: SortType.new_,
    icon: Icons.auto_awesome_rounded,
    label: 'New',
  ),
  // SortTypeItem(
  //   sortType: SortType.,
  //   icon: Icons.history_toggle_off_rounded,
  //   label: 'Old',
  // ),
  SortTypeItem(
    sortType: SortType.mostComments,
    icon: Icons.comment_bank_rounded,
    label: 'Most Comments',
  ),
  SortTypeItem(
    sortType: SortType.newComments,
    icon: Icons.add_comment_rounded,
    label: 'New Comments',
  ),
];

class CommunityPage extends StatefulWidget {
  final int? communityId;
  final String? communityName;
  final GlobalKey<ScaffoldState>? scaffoldKey;

  const CommunityPage({super.key, this.communityId, this.communityName, this.scaffoldKey});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> with AutomaticKeepAliveClientMixin<CommunityPage> {
  @override
  bool get wantKeepAlive => true;

  SortType? sortType;
  IconData? sortTypeIcon;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final bool isUserLoggedIn = context.read<AuthBloc>().state.isLoggedIn;

    return BlocProvider<CommunityBloc>(
      create: (context) => CommunityBloc(),
      child: BlocConsumer<CommunityBloc, CommunityState>(
        listenWhen: (previousState, currentState) {
          if (previousState.subscribedType != currentState.subscribedType) {
            context.read<AccountBloc>().add(GetAccountInformation());
          }

          if (previousState.sortType != currentState.sortType) {
            setState(() {
              sortType = currentState.sortType;
              sortTypeIcon = sortTypeItems.firstWhere((sortTypeItem) => sortTypeItem.sortType == currentState.sortType).icon;
            });
          }
          return true;
        },
        listener: (context, state) {
          if (state.status == CommunityStatus.networkFailure) {
            SnackBar snackBar = SnackBar(
              content: Text(state.errorMessage ?? 'No error message available'),
              behavior: SnackBarBehavior.floating,
            );
            WidgetsBinding.instance.addPostFrameCallback((timeStamp) => ScaffoldMessenger.of(context).showSnackBar(snackBar));
          }
        },
        builder: (context, state) {
          return Scaffold(
            key: widget.scaffoldKey,
            appBar: AppBar(
              title: Text(getCommunityName(state)),
              centerTitle: false,
              toolbarHeight: 70.0,
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if ((state.communityId != null || state.communityName != null) && isUserLoggedIn)
                      IconButton(
                        icon: Icon(
                          (state.subscribedType == SubscribedType.notSubscribed || state.subscribedType == null) ? Icons.library_add_check_outlined : Icons.library_add_check_rounded,
                          semanticLabel: (state.subscribedType == SubscribedType.notSubscribed || state.subscribedType == null) ? 'Subscribe' : 'Unsubscribe',
                        ),
                        onPressed: () => {
                          context.read<CommunityBloc>().add(
                                ChangeCommunitySubsciptionStatusEvent(
                                  communityId: state.communityId!,
                                  follow: (state.subscribedType == null) ? true : (state.subscribedType == SubscribedType.notSubscribed ? true : false),
                                ),
                              )
                        },
                      ),
                    IconButton(
                      icon: Icon(sortTypeIcon, semanticLabel: 'Sort By'),
                      onPressed: () => showSortBottomSheet(context, state),
                    ),
                    const SizedBox(width: 8.0),
                  ],
                )
              ],
            ),
            drawer: (widget.communityId != null || widget.communityName != null) ? null : const CommunityDrawer(),
            floatingActionButton: ((state.communityId != null || widget.communityName != null) && isUserLoggedIn)
                ? FloatingActionButton(
                    onPressed: () {
                      CommunityBloc communityBloc = context.read<CommunityBloc>();

                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) {
                            return BlocProvider<CommunityBloc>.value(
                              value: communityBloc,
                              child: CreatePostPage(communityId: state.communityId!, communityInfo: state.communityInfo),
                            );
                          },
                        ),
                      );
                    },
                    child: const Icon(
                      Icons.add,
                      semanticLabel: 'Create Post',
                    ),
                  )
                : null,
            body: SafeArea(child: _getBody(context, state)),
          );
        },
      ),
    );
  }

  Widget _getBody(BuildContext context, CommunityState state) {
    switch (state.status) {
      case CommunityStatus.initial:
        // communityId and communityName are mutually exclusive - only one of the two should be passed in
        context.read<CommunityBloc>().add(GetCommunityPostsEvent(reset: true, communityId: widget.communityId, communityName: widget.communityName));
        return const Center(child: CircularProgressIndicator());
      case CommunityStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case CommunityStatus.refreshing:
      case CommunityStatus.networkFailure:
      case CommunityStatus.success:
        return PostCardList(
          postViews: state.postViews,
          listingType: state.communityId != null ? null : state.listingType,
          communityId: widget.communityId ?? state.communityId,
          communityName: widget.communityName ?? state.communityName,
          hasReachedEnd: state.hasReachedEnd,
          communityInfo: state.communityInfo,
        );
      case CommunityStatus.empty:
      case CommunityStatus.failure:
        return ErrorMessage(
          message: state.errorMessage,
          action: () => context.read<CommunityBloc>().add(GetCommunityPostsEvent(reset: true, communityId: widget.communityId)),
          actionText: 'Refresh Content',
        );
    }
  }

  void showSortBottomSheet(BuildContext context, CommunityState state) {
    final theme = Theme.of(context);

    showModalBottomSheet<void>(
      showDragHandle: true,
      context: context,
      builder: (BuildContext bottomSheetContext) {
        return SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0, left: 16.0, right: 16.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Sort Options',
                    style: theme.textTheme.titleLarge!.copyWith(),
                  ),
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: sortTypeItems.length,
                itemBuilder: (BuildContext itemBuilderContext, int index) {
                  return ListTile(
                    title: Text(
                      sortTypeItems[index].label,
                      style: theme.textTheme.bodyMedium,
                    ),
                    leading: Icon(sortTypeItems[index].icon),
                    onTap: () {
                      setState(() {
                        sortType = sortTypeItems[index].sortType;
                        sortTypeIcon = sortTypeItems[index].icon;
                      });

                      context.read<CommunityBloc>().add(
                            GetCommunityPostsEvent(
                              sortType: sortTypeItems[index].sortType,
                              reset: true,
                              listingType: state.communityId != null ? null : state.listingType,
                              communityId: widget.communityId ?? state.communityId,
                            ),
                          );
                      Navigator.of(context).pop();
                    },
                  );
                },
              ),
              const SizedBox(height: 16.0),
            ],
          ),
        );
      },
    );
  }

  String getCommunityName(CommunityState state) {
    if (state.status == CommunityStatus.initial || state.status == CommunityStatus.loading) {
      return '';
    }

    if (state.communityId != null || state.communityName != null) {
      // return state.postViews?.firstOrNull?.community.name ?? '';
      return '';
    }

    return (state.listingType != null) ? (destinations.firstWhere((destination) => destination.listingType == state.listingType).label) : '';
  }
}
