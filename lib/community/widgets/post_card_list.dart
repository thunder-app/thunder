import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/community/bloc/community_bloc.dart';
import 'package:thunder/community/widgets/post_card.dart';
import 'package:thunder/core/models/post_view_media.dart';

class PostCardList extends StatefulWidget {
  final List<PostViewMedia>? postViews;

  const PostCardList({super.key, this.postViews});

  @override
  State<PostCardList> createState() => _PostCardListState();
}

class _PostCardListState extends State<PostCardList> {
  final _scrollController = ScrollController(initialScrollOffset: 0);

  @override
  void initState() {
    _scrollController.addListener(_onScroll);
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.8) {
      context.read<CommunityBloc>().add(const GetCommunityPostsEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        HapticFeedback.mediumImpact();
        context.read<CommunityBloc>().add(const GetCommunityPostsEvent(reset: true));
      },
      child: ListView.builder(
        controller: _scrollController,
        itemCount: widget.postViews?.length ?? 0,
        itemBuilder: (context, index) {
          return PostCard(postView: widget.postViews![index]);
        },
      ),
    );
  }
}
