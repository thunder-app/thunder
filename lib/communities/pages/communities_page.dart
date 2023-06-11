import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:lemmy/lemmy.dart';

import 'package:thunder/communities/bloc/communities_bloc.dart';

class CommunityPage extends StatelessWidget {
  const CommunityPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<CommunitiesBloc, CommunitiesState>(
          builder: (context, state) {
            switch (state.status) {
              case CommunitiesStatus.initial:
                context.read<CommunitiesBloc>().add(ListCommunitiesEvent());
                return const Center(child: CircularProgressIndicator());
              case CommunitiesStatus.loading:
                return const Center(child: CircularProgressIndicator());
              case CommunitiesStatus.refreshing:
              case CommunitiesStatus.success:
                return SingleChildScrollView(
                  child: Column(
                    children: List.generate(state.communities?.length ?? 0, (index) {
                      CommunitySafe community = state.communities![index].community;
                      return ListTile(
                        title: Text(community.name, style: theme.textTheme.titleMedium),
                        subtitle: Text(community.description ?? 'No description'),
                      );
                    }),
                  ),
                );
              case CommunitiesStatus.empty:
              case CommunitiesStatus.failure:
                return const Center(child: Text('Something went wrong'));
            }
          },
        ),
      ),
    );
  }
}
