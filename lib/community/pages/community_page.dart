import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:lemmy/lemmy.dart';

import 'package:thunder/community/bloc/community_bloc.dart';
import 'package:thunder/community/widgets/community_drawer.dart';
import 'package:thunder/community/widgets/post_card_list.dart';

class SortTypeItem {
  const SortTypeItem({required this.sortType, required this.icon, required this.label});

  final SortType sortType;
  final IconData icon;
  final String label;
}

const sortTypeItems = [
  SortTypeItem(
    sortType: SortType.Hot,
    icon: Icons.local_fire_department_rounded,
    label: 'Hot',
  ),
  SortTypeItem(
    sortType: SortType.Active,
    icon: Icons.rocket_launch_rounded,
    label: 'Active',
  ),
  SortTypeItem(
    sortType: SortType.New,
    icon: Icons.auto_awesome_rounded,
    label: 'New',
  ),
  SortTypeItem(
    sortType: SortType.Old,
    icon: Icons.history_toggle_off_rounded,
    label: 'Old',
  ),
  SortTypeItem(
    sortType: SortType.MostComments,
    icon: Icons.comment_bank_rounded,
    label: 'Most Comments',
  ),
  SortTypeItem(
    sortType: SortType.NewComments,
    icon: Icons.add_comment_rounded,
    label: 'New Comments',
  ),
];

class CommunityPage extends StatefulWidget {
  final int? communityId;
  const CommunityPage({super.key, this.communityId});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> with AutomaticKeepAliveClientMixin<CommunityPage> {
  @override
  bool get wantKeepAlive => true;

  SortType? sortType = SortType.Hot;
  IconData sortTypeIcon = Icons.local_fire_department_rounded;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider<CommunityBloc>(
      create: (context) => CommunityBloc(),
      child: BlocConsumer<CommunityBloc, CommunityState>(
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
          return BlocBuilder<CommunityBloc, CommunityState>(
            builder: (context, state) {
              return Scaffold(
                appBar: AppBar(
                  title: Text(
                    (state.status == CommunityStatus.loading || state.status == CommunityStatus.initial)
                        ? ''
                        : (state.communityId != null)
                            ? (state.postViews?.firstOrNull?.community.name ?? '')
                            : ((state.listingType != null) ? (destinations.firstWhere((destination) => destination.listingType == state.listingType).label) : ''),
                  ),
                  centerTitle: false,
                  toolbarHeight: 70.0,
                  actions: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: Icon(sortTypeIcon),
                          onPressed: () {
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
                          },
                        ),
                        const SizedBox(width: 8.0),
                      ],
                    )
                  ],
                ),
                drawer: (widget.communityId != null) ? null : const CommunityDrawer(),
                // floatingActionButton: (state.communityId != null)
                //     ? FloatingActionButton(
                //         onPressed: () {
                //           Navigator.of(context).push(MaterialPageRoute(builder: (context) => CreatePostPage(communityId: state.communityId!)));
                //         },
                //         child: const Icon(Icons.add),
                //       )
                //     : null,
                body: SafeArea(child: _getBody(context, state)),
              );
            },
          );
        },
      ),
    );
  }

  Widget _getBody(BuildContext context, CommunityState state) {
    final theme = Theme.of(context);

    switch (state.status) {
      case CommunityStatus.initial:
        context.read<CommunityBloc>().add(GetCommunityPostsEvent(reset: true, communityId: widget.communityId));
        return const Center(child: CircularProgressIndicator());
      case CommunityStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case CommunityStatus.refreshing:
      case CommunityStatus.networkFailure:
      case CommunityStatus.success:
        return PostCardList(
          postViews: state.postViews,
          communityId: widget.communityId,
          hasReachedEnd: state.hasReachedEnd,
        );
      case CommunityStatus.empty:
      case CommunityStatus.failure:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.warning_rounded,
                  size: 100,
                  color: Colors.red.shade300,
                ),
                const SizedBox(height: 32.0),
                Text('Oops, something went wrong!', style: theme.textTheme.titleLarge),
                const SizedBox(height: 8.0),
                Text(
                  state.errorMessage ?? 'No error message available',
                  style: theme.textTheme.labelLarge?.copyWith(color: theme.dividerColor),
                ),
                const SizedBox(height: 32.0),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                  onPressed: () => context.read<CommunityBloc>().add(GetCommunityPostsEvent(reset: true, communityId: widget.communityId)),
                  child: const Text('Refresh Content'),
                ),
              ],
            ),
          ),
        );
    }
  }
}
