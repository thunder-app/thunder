import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:thunder/community/widgets/post_card_list.dart';
import 'package:thunder/user/widgets/user_header.dart';
import 'package:thunder/core/models/comment_view_tree.dart';
import 'package:thunder/core/models/post_view_media.dart';
import 'package:thunder/user/bloc/user_bloc.dart';
import 'package:thunder/user/widgets/comment_card.dart';

const List<Widget> userOptionTypes = <Widget>[
  Padding(padding: EdgeInsets.all(8.0), child: Text('Posts')),
  Padding(padding: EdgeInsets.all(8.0), child: Text('Comments')),
];

const List<Widget> accountOptionTypes = <Widget>[
  Padding(padding: EdgeInsets.all(8.0), child: Text('Posts')),
  Padding(padding: EdgeInsets.all(8.0), child: Text('Comments')),
  Padding(padding: EdgeInsets.all(8.0), child: Text('Saved')),
];

class UserPageSuccess extends StatefulWidget {
  final int? userId;
  final PersonViewSafe? personView;
  final bool isAccountUser;

  final List<CommentViewTree>? commentViewTrees;
  final List<PostViewMedia>? postViews;
  final List<PostViewMedia>? savedPostViews;

  final bool hasReachedPostEnd;
  final bool hasReachedSavedPostEnd;

  const UserPageSuccess({
    super.key,
    required this.userId,
    this.isAccountUser = false,
    required this.personView,
    this.commentViewTrees,
    this.postViews,
    this.savedPostViews,
    required this.hasReachedPostEnd,
    required this.hasReachedSavedPostEnd,
  });

  @override
  State<UserPageSuccess> createState() => _UserPageSuccessState();
}

class _UserPageSuccessState extends State<UserPageSuccess> {
  final _scrollController = ScrollController(initialScrollOffset: 0);
  bool hasScrolledToBottom = true;

  int selectedUserOption = 0;
  List<bool> _selectedUserOption = <bool>[true, false, false];

  @override
  void initState() {
    _scrollController.addListener(_onScroll);
    if (!widget.isAccountUser) {
      setState(() {
        _selectedUserOption = <bool>[true, false];
      });
    }
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.7) {
      context.read<UserBloc>().add(const GetUserEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          UserHeader(userInfo: widget.personView),
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
            constraints: BoxConstraints.expand(width: (MediaQuery.of(context).size.width / (widget.isAccountUser ? accountOptionTypes.length : userOptionTypes.length)) - 12.0),
            isSelected: _selectedUserOption,
            children: widget.isAccountUser ? accountOptionTypes : userOptionTypes,
          ),
          const SizedBox(height: 12.0),
          if (selectedUserOption == 0)
            Expanded(
              child: PostCardList(
                postViews: widget.postViews,
                personId: widget.userId,
                hasReachedEnd: widget.hasReachedPostEnd,
                onScrollEndReached: () => context.read<UserBloc>().add(const GetUserEvent()),
                onSaveAction: (int postId, bool save) => context.read<UserBloc>().add(SavePostEvent(postId: postId, save: save)),
                onVoteAction: (int postId, VoteType voteType) => context.read<UserBloc>().add(VotePostEvent(postId: postId, score: voteType)),
              ),
            ),
          if (selectedUserOption == 1)
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: widget.commentViewTrees?.length,
                itemBuilder: (context, index) => CommentCard(comment: widget.commentViewTrees![index].commentView!),
              ),
            ),
          if (selectedUserOption == 2)
            Expanded(
              child: PostCardList(
                postViews: widget.savedPostViews,
                personId: widget.userId,
                hasReachedEnd: widget.hasReachedSavedPostEnd,
                onScrollEndReached: () => context.read<UserBloc>().add(const GetUserSavedEvent()),
                onSaveAction: (int postId, bool save) => context.read<UserBloc>().add(SavePostEvent(postId: postId, save: save)),
                onVoteAction: (int postId, VoteType voteType) => context.read<UserBloc>().add(VotePostEvent(postId: postId, score: voteType)),
              ),
            ),
        ],
      ),
    );
  }
}
