import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:thunder/account/utils/profiles.dart';

import 'package:thunder/community/bloc/community_bloc.dart' as community;
import 'package:thunder/community/widgets/post_card_list.dart';
import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/user/widgets/user_header.dart';
import 'package:thunder/shared/error_message.dart';
import 'package:thunder/user/bloc/user_bloc.dart';
import 'package:thunder/user/widgets/comment_card.dart';

const List<Widget> userOptionTypes = <Widget>[
  Padding(padding: EdgeInsets.all(8.0), child: Text('Posts')),
  Padding(padding: EdgeInsets.all(8.0), child: Text('Comments')),
  Padding(padding: EdgeInsets.all(8.0), child: Text('Saved')),
];

class UserPage extends StatefulWidget {
  final int? userId;
  final bool isAccountUser;

  const UserPage({super.key, this.userId, this.isAccountUser = false});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  final _scrollController = ScrollController(initialScrollOffset: 0);
  bool hasScrolledToBottom = true;

  int selectedUserOption = 0;
  final List<bool> _selectedUserOption = <bool>[true, false, false];

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
              return Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    UserHeader(userInfo: state.personView),
                    const SizedBox(height: 12.0),
                    ToggleButtons(
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      direction: Axis.horizontal,
                      onPressed: (int index) {
                        setState(() {
                          // The button that is tapped is set to true, and the others to false.
                          for (int i = 0; i < _selectedUserOption.length; i++) {
                            _selectedUserOption[i] = i == index;
                          }

                          selectedUserOption = index;
                        });
                        if (index == 2) {
                          context.read<UserBloc>().add(GetUserSavedEvent(userId: widget.userId, reset: false));
                        }
                      },
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                      constraints: BoxConstraints.expand(width: (MediaQuery.of(context).size.width / userOptionTypes.length) - 12.0),
                      isSelected: _selectedUserOption,
                      children: userOptionTypes,
                    ),
                    const SizedBox(height: 12.0),
                    if (selectedUserOption == 0)
                      Expanded(
                        child: PostCardList(
                          postViews: state.posts,
                          personId: widget.userId,
                          hasReachedEnd: state.hasReachedPostEnd,
                          onScrollEndReached: () => context.read<UserBloc>().add(const GetUserEvent()),
                          onSaveAction: (int postId, bool save) => context.read<UserBloc>().add(SavePostEvent(postId: postId, save: save)),
                          onVoteAction: (int postId, VoteType voteType) => context.read<UserBloc>().add(VotePostEvent(postId: postId, score: voteType)),
                        ),
                      ),
                    if (selectedUserOption == 1)
                      Expanded(
                        child: ListView.builder(
                          itemCount: state.comments.length,
                          itemBuilder: (context, index) => CommentCard(comment: state.comments[index].comment!),
                        ),
                      ),
                    if (selectedUserOption == 2)
                      Expanded(
                        child: PostCardList(
                          postViews: state.savedPosts,
                          personId: state.userId,
                          hasReachedEnd: state.hasReachedSavedPostEnd,
                          onScrollEndReached: () => context.read<UserBloc>().add(const GetUserEvent()),
                          onSaveAction: (int postId, bool save) => context.read<UserBloc>().add(SavePostEvent(postId: postId, save: save)),
                          onVoteAction: (int postId, VoteType voteType) => context.read<UserBloc>().add(VotePostEvent(postId: postId, score: voteType)),
                        ),
                      ),
                  ],
                ),
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
