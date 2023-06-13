import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/community/bloc/community_bloc.dart';
import 'package:thunder/community/widgets/post_card_list.dart';

class CommunityPage extends StatelessWidget {
  const CommunityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
