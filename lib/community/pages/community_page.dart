import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lemmy/lemmy.dart';

import 'package:thunder/community/bloc/community_bloc.dart';
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
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  SortType? sortType = SortType.Active;
  IconData sortTypeIcon = Icons.rocket_launch_rounded;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Local'),
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

                                    context.read<CommunityBloc>().add(GetCommunityPostsEvent(sortType: sortTypeItems[index].sortType, reset: true));
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
      body: SafeArea(
        child: BlocBuilder<CommunityBloc, CommunityState>(
          builder: (context, state) {
            switch (state.status) {
              case CommunityStatus.initial:
                context.read<CommunityBloc>().add(const GetCommunityPostsEvent(reset: true));
                return const Center(child: CircularProgressIndicator());
              case CommunityStatus.loading:
                return const Center(child: CircularProgressIndicator());
              case CommunityStatus.refreshing:
              case CommunityStatus.success:
                return PostCardList(postViews: state.postViews);
              case CommunityStatus.empty:
              case CommunityStatus.failure:
                return const Center(child: Text('Something went wrong'));
            }
          },
        ),
      ),
    );
  }
}
