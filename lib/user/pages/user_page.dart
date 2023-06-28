import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thunder/community/bloc/community_bloc.dart';
import 'package:thunder/shared/error_message.dart';

import 'package:thunder/user/bloc/user_bloc.dart';
import 'package:thunder/user/pages/user_page_success.dart';

class UserPage extends StatefulWidget {
  final int? userId;

  const UserPage({super.key, this.userId});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  final _scrollController = ScrollController(initialScrollOffset: 0);
  bool hasScrolledToBottom = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
      ),
      body: MultiBlocProvider(
        providers: [
          BlocProvider<UserBloc>(create: (BuildContext context) => UserBloc()),
          BlocProvider(create: (context) => CommunityBloc()),
        ],
        child: BlocBuilder<UserBloc, UserState>(builder: (context, state) {
          switch (state.status) {
            case UserStatus.initial:
              context.read<UserBloc>().add(GetUserEvent(userId: widget.userId, reset: true));
              return const Center(child: CircularProgressIndicator());
            case UserStatus.loading:
              return const Center(child: CircularProgressIndicator());
            case UserStatus.refreshing:
            case UserStatus.success:
              return UserPageSuccess(
                userId: widget.userId,
                personView: state.personView,
                comments: state.comments,
                posts: state.posts,
                hasReachedPostEnd: state.hasReachedPostEnd,
                hasReachedCommentEnd: state.hasReachedCommentEnd,
              );
            case UserStatus.empty:
              return Container();
            case UserStatus.failure:
              return ErrorMessage(
                message: state.errorMessage,
                action: () {
                  context.read<UserBloc>().add(GetUserEvent(userId: widget.userId, reset: true));
                },
                actionText: 'Refresh Content',
              );
          }
        }),
      ),
    );
  }
}
