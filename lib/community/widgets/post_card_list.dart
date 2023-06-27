import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lemmy_api_client/v3.dart';

import 'package:thunder/community/bloc/community_bloc.dart';
import 'package:thunder/community/widgets/community_header.dart';
import 'package:thunder/community/widgets/post_card.dart';
import 'package:thunder/core/models/post_view_media.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';

class PostCardList extends StatefulWidget {
  final List<PostViewMedia>? postViews;
  final int? communityId;
  final String? communityName;
  final bool? hasReachedEnd;
  final PostListingType? listingType;
  final FullCommunityView? communityInfo;

  const PostCardList({
    super.key,
    this.postViews,
    this.communityId,
    this.hasReachedEnd,
    this.listingType,
    this.communityInfo,
    this.communityName,
  });

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
      context.read<CommunityBloc>().add(GetCommunityPostsEvent(communityId: widget.communityId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<ThunderBloc, ThunderState>(
      listenWhen: (previous, current) => (previous.status == ThunderStatus.refreshing && current.status == ThunderStatus.success),
      listener: (context, state) {
        // Force a rebuild when the thunderbloc status changes
        setState(() {});
      },
      child: RefreshIndicator(
        onRefresh: () async {
          HapticFeedback.mediumImpact();
          context.read<CommunityBloc>().add(GetCommunityPostsEvent(
                reset: true,
                listingType: widget.communityId != null ? null : widget.listingType,
                communityId: widget.listingType != null ? null : widget.communityId,
              ));
        },
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            children: [
              if (widget.communityId != null || widget.communityName != null) CommunityHeader(communityInfo: widget.communityInfo),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.postViews?.length != null ? widget.postViews!.length + 1 : 1,
                itemBuilder: (context, index) {
                  if (index == widget.postViews!.length) {
                    if (widget.hasReachedEnd == true) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            color: theme.dividerColor.withOpacity(0.1),
                            padding: const EdgeInsets.symmetric(vertical: 32.0),
                            child: Text(
                              'Hmmm. It seems like you\'ve reached the bottom.',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.titleSmall,
                            ),
                          ),
                        ],
                      );
                    } else {
                      return Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 24.0),
                            child: const CircularProgressIndicator(),
                          ),
                        ],
                      );
                    }
                  } else {
                    return PostCard(
                      postViewMedia: widget.postViews![index],
                      showInstanceName: widget.communityId == null,
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
