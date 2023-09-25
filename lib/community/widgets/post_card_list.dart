import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import 'package:thunder/core/enums/font_scale.dart';
import 'package:thunder/community/bloc/community_bloc.dart';
import 'package:thunder/community/widgets/post_card.dart';
import 'package:thunder/core/models/post_view_media.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/user/bloc/user_bloc.dart';

class PostCardList extends StatefulWidget {
  final List<PostViewMedia>? postViews;
  final int? communityId;
  final int? personId;
  final String? communityName;
  final bool? hasReachedEnd;
  final PostListingType? listingType;
  final FullCommunityView? communityInfo;
  final SubscribedType? subscribeType;
  final BlockedCommunity? blockedCommunity;
  final SortType? sortType;
  final String tagline;
  final bool indicateRead;

  final VoidCallback onScrollEndReached;
  final Function(int, VoteType) onVoteAction;
  final Function(int, bool) onSaveAction;
  final Function(int, bool) onToggleReadAction;

  const PostCardList({
    super.key,
    this.postViews,
    this.communityId,
    this.hasReachedEnd,
    this.listingType,
    this.communityInfo,
    this.communityName,
    this.personId,
    this.subscribeType,
    required this.onScrollEndReached,
    required this.onVoteAction,
    required this.onSaveAction,
    required this.onToggleReadAction,
    this.sortType,
    this.blockedCommunity,
    this.tagline = '',
    this.indicateRead = true,
  });

  @override
  State<PostCardList> createState() => _PostCardListState();
}

class _PostCardListState extends State<PostCardList> {
  final _scrollController = ScrollController(initialScrollOffset: 0);

  @override
  void initState() {
    _scrollController.addListener(_onScroll);

    // Check to see if the initial load did not load enough items to allow for scrolling to occur and fetches more items
    WidgetsBinding.instance.addPostFrameCallback((_) {
      bool isScrollable = _scrollController.position.maxScrollExtent > _scrollController.position.viewportDimension;

      if (context.read<CommunityBloc>().state.hasReachedEnd == false && isScrollable == false) {
        widget.onScrollEndReached();
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.7) {
      widget.onScrollEndReached();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ThunderState state = context.watch<ThunderBloc>().state;

    bool tabletMode = state.tabletMode;
    bool reduceAnimations = state.reduceAnimations;

    const tabletGridDelegate = SliverSimpleGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
    );
    const phoneGridDelegate = SliverSimpleGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 1,
    );

    return BlocListener<ThunderBloc, ThunderState>(
      listenWhen: (previous, current) => (previous.status == ThunderStatus.refreshing && current.status == ThunderStatus.success),
      listener: (context, state) {},
      child: RefreshIndicator(
        onRefresh: () async {
          HapticFeedback.mediumImpact();
          if (widget.personId != null) {
            context.read<UserBloc>().add(GetUserEvent(userId: widget.personId, reset: true));
          } else {
            context.read<CommunityBloc>().add(GetCommunityPostsEvent(
                  reset: true,
                  listingType: widget.communityId != null ? null : widget.listingType,
                  communityId: widget.listingType != null ? null : widget.communityId,
                  communityName: widget.listingType != null ? null : widget.communityName,
                ));
          }
        },
        child: MasonryGridView.builder(
          physics: reduceAnimations ? const BouncingScrollPhysics() : null,
          gridDelegate: tabletMode ? tabletGridDelegate : phoneGridDelegate,
          crossAxisSpacing: 40,
          mainAxisSpacing: 0,
          cacheExtent: 1000,
          controller: _scrollController,
          itemCount: widget.postViews?.length != null
              ? ((widget.communityId != null || widget.communityName != null || widget.tagline.isNotEmpty) ? widget.postViews!.length + 2 : widget.postViews!.length + 1)
              : 1,
          itemBuilder: (context, index) {
            if (index == ((widget.communityId != null || widget.communityName != null || widget.tagline.isNotEmpty) ? widget.postViews!.length + 1 : widget.postViews!.length)) {
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
                        textScaleFactor: MediaQuery.of(context).textScaleFactor * state.metadataFontSizeScale.textScaleFactor,
                      ),
                    ),
                    const SizedBox(
                      height: 160,
                    )
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
              PostViewMedia postViewMedia = widget.postViews![(widget.communityId != null || widget.communityName != null || widget.tagline.isNotEmpty) ? index - 1 : index];
              return PostCard(
                postViewMedia: postViewMedia,
                communityMode: widget.communityId != null || widget.communityName != null,
                onVoteAction: (VoteType voteType) => widget.onVoteAction(postViewMedia.postView.post.id, voteType),
                onSaveAction: (bool saved) => widget.onSaveAction(postViewMedia.postView.post.id, saved),
                onReadAction: (bool read) => widget.onToggleReadAction(postViewMedia.postView.post.id, read),
                listingType: widget.listingType,
                indicateRead: widget.indicateRead,
              );
            }
          },
        ),
      ),
    );
  }
}
