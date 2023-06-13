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
    sortType: SortType.Active,
    icon: Icons.rocket_launch_rounded,
    label: 'Active',
  ),
  SortTypeItem(
    sortType: SortType.Hot,
    icon: Icons.local_fire_department_rounded,
    label: 'Hot',
  ),
  SortTypeItem(
    sortType: SortType.New,
    icon: Icons.auto_awesome_rounded,
    label: 'New',
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
              PopupMenuButton<SortType>(
                icon: Icon(sortTypeIcon),
                position: PopupMenuPosition.under,
                initialValue: sortType,
                onSelected: (SortType value) {
                  setState(() {
                    sortType = value;
                    sortTypeIcon = sortTypeItems.firstWhere((element) => element.sortType == value).icon;
                  });

                  context.read<CommunityBloc>().add(GetCommunityPostsEvent(sortType: sortType, reset: true));
                },
                itemBuilder: (BuildContext context) => sortTypeItems
                    .map((item) => PopupMenuItem<SortType>(
                          value: item.sortType,
                          child: Row(
                            children: [
                              Icon(item.icon),
                              const SizedBox(width: 12.0),
                              Text(
                                item.label,
                                style: theme.textTheme.bodyLarge,
                              ),
                            ],
                          ),
                        ))
                    .toList(),
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
