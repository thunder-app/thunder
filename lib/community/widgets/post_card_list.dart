import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lemmy_api_client/v3.dart';

import 'package:thunder/community/bloc/community_bloc.dart';
import 'package:thunder/community/widgets/community_header.dart';
import 'package:thunder/community/widgets/post_card.dart';
import 'package:thunder/core/models/post_view_media.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/user/bloc/user_bloc.dart';

import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../account/bloc/account_bloc.dart';

class PostCardList extends StatefulWidget {
  final List<PostViewMedia>? postViews;
  final int? communityId;
  final int? personId;
  final String? communityName;
  final bool? hasReachedEnd;
  final PostListingType? listingType;
  final FullCommunityView? communityInfo;
  final SortType? sortType;

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
    required this.onScrollEndReached,
    required this.onVoteAction,
    required this.onSaveAction,
    required this.onToggleReadAction,
    this.sortType,
  });

  @override
  State<PostCardList> createState() => _PostCardListState();
}

class _PostCardListState extends State<PostCardList> with TickerProviderStateMixin {
  final _scrollController = ScrollController(initialScrollOffset: 0);
  bool _showReturnToTopButton = false;
  int _previousScrollId = 0;
  bool disableFabs = false;

  bool showFABMenu = false;
  bool showRead = true;

  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: 200),
    vsync: this,
  );

  // Animation for comment collapse
  late final Animation<Offset> _offsetAnimation = Tween<Offset>(
    begin: Offset.zero,
    end: const Offset(0.0, 2.0),
  ).animate(CurvedAnimation(
    parent: _controller,
    curve: Curves.fastOutSlowIn,
  ));

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
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.7) {
      widget.onScrollEndReached();
    }

    if (!disableFabs) {
      // Adjust the threshold as needed
      if (_scrollController.offset > 300 && !_showReturnToTopButton) {
        setState(() {
          _showReturnToTopButton = true;
        });
      } else if (_scrollController.offset <= 300 && _showReturnToTopButton) {
        setState(() {
          _showReturnToTopButton = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ThunderState state = context.watch<ThunderBloc>().state;
    disableFabs = state.disableFeedFab;

    bool tabletMode = state.tabletMode;
    bool compactMode = state.useCompactView;

    const tabletGridDelegate = SliverSimpleGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
    );
    const phoneGridDelegate = SliverSimpleGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 1,
    );

    if (state.scrollToTopId > _previousScrollId) {
      scrollToTop();
      _previousScrollId = state.scrollToTopId;
    }

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
        child: Stack(
          children: [
            MasonryGridView.builder(
              gridDelegate: tabletMode ? tabletGridDelegate : phoneGridDelegate,
              crossAxisSpacing: 40,
              mainAxisSpacing: 0,
              cacheExtent: 500,
              controller: _scrollController,
              itemCount: widget.postViews?.length != null ? ((widget.communityId != null || widget.communityName != null) ? widget.postViews!.length + 1 : widget.postViews!.length + 1) : 1,
              itemBuilder: (context, index) {
                if (index == 0 && (widget.communityId != null || widget.communityName != null)) {
                  return CommunityHeader(communityInfo: widget.communityInfo);
                }
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
                  PostViewMedia postViewMedia = widget.postViews![(widget.communityId != null || widget.communityName != null) ? index - 1 : index];
                  return AnimatedSwitcher(
                    duration: Duration(milliseconds: postViewMedia.postView.read ? 500 : 0),
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      return FadeTransition(
                        opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                          CurvedAnimation(
                            parent: animation,
                            curve: const Interval(0.0, 0.5),
                          ),
                        ),
                        child: SizeTransition(
                          sizeFactor: Tween<double>(begin: 0.0, end: 1.0).animate(
                            CurvedAnimation(
                              parent: animation,
                              curve: const Interval(0.5, 1.0),
                            ),
                          ),
                          child: child),
                      );
                    },
                    child: !postViewMedia.postView.read || showRead ? PostCard(
                      postViewMedia: postViewMedia,
                      showInstanceName: widget.communityId == null,
                      onVoteAction: (VoteType voteType) => widget.onVoteAction(postViewMedia.postView.post.id, voteType),
                      onSaveAction: (bool saved) => widget.onSaveAction(postViewMedia.postView.post.id, saved),
                      onToggleReadAction: (bool read) => widget.onToggleReadAction(postViewMedia.postView.post.id, read),
                    ) : Container(),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> dismissRead() async {
    if (widget.postViews != null) {
      setState(() {
        showRead = false;
      });
      await Future.delayed(const Duration(milliseconds: 1000));
      setState(() {
        widget.postViews!.removeWhere( (e) => e.postView.read);
        showRead = true;
      });
      widget.onScrollEndReached();
    }
  }

  void scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }
}


