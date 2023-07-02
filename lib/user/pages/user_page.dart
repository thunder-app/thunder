import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/account/utils/profiles.dart';
import 'package:thunder/community/bloc/community_bloc.dart' as community;
import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/user/pages/user_page_success.dart';
import 'package:thunder/shared/error_message.dart';
import 'package:thunder/user/bloc/user_bloc.dart';

class UserPage extends StatefulWidget {
  final int? userId;
  final bool isAccountUser;

  const UserPage({super.key, this.userId, this.isAccountUser = false});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        leading: widget.isAccountUser
            ? IconButton(
                onPressed: () => context.read<AuthBloc>().add(RemoveAccount(accountId: context.read<AuthBloc>().state.account!.id)),
                icon: const Icon(
                  Icons.logout,
                  semanticLabel: 'Log out',
                ),
              )
            : null,
        actions: [
          if (widget.isAccountUser)
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: IconButton(
                onPressed: () => showProfileModalSheet(context),
                icon: const Icon(
                  Icons.people_alt_rounded,
                  semanticLabel: 'Profiles',
                ),
              ),
            ),
        ],
      ),
      body: MultiBlocProvider(
        providers: [
          BlocProvider<UserBloc>(create: (BuildContext context) => UserBloc()),
          BlocProvider(create: (context) => community.CommunityBloc()),
        ],
        child: BlocBuilder<UserBloc, UserState>(builder: (context, state) {
          switch (state.status) {
            case UserStatus.initial:
              context.read<UserBloc>().add(GetUserEvent(userId: widget.userId, reset: true));
              context.read<UserBloc>().add(GetUserSavedEvent(userId: widget.userId, reset: true));
              return const Center(child: CircularProgressIndicator());
            case UserStatus.loading:
              return const Center(child: CircularProgressIndicator());
            case UserStatus.refreshing:
            case UserStatus.success:
              return UserPageSuccess(
                userId: widget.userId,
                isAccountUser: widget.isAccountUser,
                personView: state.personView,
                commentViewTrees: state.comments,
                postViews: state.posts,
                savedPostViews: state.savedPosts,
                hasReachedPostEnd: state.hasReachedPostEnd,
                hasReachedSavedPostEnd: state.hasReachedSavedPostEnd,
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
