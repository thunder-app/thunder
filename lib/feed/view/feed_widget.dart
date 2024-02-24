import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:thunder/community/widgets/post_card.dart';
import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/core/models/post_view_media.dart';
import 'package:thunder/feed/bloc/feed_bloc.dart';
import 'package:thunder/feed/view/feed_page.dart';
import 'package:thunder/post/enums/post_action.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:visibility_detector/visibility_detector.dart';

class FeedPostList extends StatelessWidget {
  final bool tabletMode;
  final bool markPostReadOnScroll;
  final List<int>? queuedForRemoval;
  final List<PostViewMedia> postViewMedias;
  int prevLastTappedIndex = -1;
  int lastTappedIndex = 0;
  List<int> markReadPostIds = [];

  FeedPostList({
    super.key,
    required this.postViewMedias,
    required this.tabletMode,
    required this.markPostReadOnScroll,
    this.queuedForRemoval,
  });

  @override
  Widget build(BuildContext context) {
    final ThunderState thunderState = context.read<ThunderBloc>().state;
    final FeedState state = context.read<FeedBloc>().state;
    final bool isUserLoggedIn = context.read<AuthBloc>().state.isLoggedIn;
    VisibilityDetectorController.instance.updateInterval = Duration.zero;

    // Widget representing the list of posts on the feed
    return SliverMasonryGrid.count(
      crossAxisCount: tabletMode ? 2 : 1,
      crossAxisSpacing: 40,
      mainAxisSpacing: 0,
      itemBuilder: (BuildContext context, int index) {
        return AnimatedSwitcher(
          switchOutCurve: Curves.ease,
          duration: const Duration(milliseconds: 0),
          reverseDuration: const Duration(milliseconds: 400),
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                CurvedAnimation(parent: animation, curve: const Interval(0.5, 1.0)),
              ),
              child: SlideTransition(
                position: Tween<Offset>(begin: const Offset(1.2, 0), end: const Offset(0, 0)).animate(animation),
                child: SizeTransition(
                  sizeFactor: Tween<double>(begin: 0.0, end: 1.0).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: const Interval(0.0, 0.25),
                    ),
                  ),
                  child: child,
                ),
              ),
            );
          },
          child: queuedForRemoval?.contains(postViewMedias[index].postView.post.id) != true
              ? VisibilityDetector(
                  key: Key('post-card-vis-' + index.toString()),
                  onVisibilityChanged: (info) {
                    if (markPostReadOnScroll && isUserLoggedIn && index <= lastTappedIndex && postViewMedias[index].postView.read != true
                          && lastTappedIndex > prevLastTappedIndex && info.visibleFraction < .25 && !markReadPostIds.contains(postViewMedias[index].postView.post.id)) {
                      // Sometimes the event doesn't fire, so check all previous indexes up to the last one marked unread
                      List<int> toAdd = [postViewMedias[index].postView.post.id];
                      for (int i = index - 1; i >= 0; i--) {
                        if (postViewMedias[i].postView.read) break;
                        if (!markReadPostIds.contains(postViewMedias[index].postView.post.id)) {
                          toAdd.add(postViewMedias[i].postView.post.id);
                        }
                      }
                      markReadPostIds = [...markReadPostIds, ...toAdd];
                    }
                  },
                  child: PostCard(
                    postViewMedia: postViewMedias[index],
                    communityMode: state.feedType == FeedType.community,
                    onVoteAction: (int voteType) {
                      context.read<FeedBloc>().add(FeedItemActionedEvent(postId: postViewMedias[index].postView.post.id, postAction: PostAction.vote, value: voteType));
                    },
                    onSaveAction: (bool saved) {
                      context.read<FeedBloc>().add(FeedItemActionedEvent(postId: postViewMedias[index].postView.post.id, postAction: PostAction.save, value: saved));
                    },
                    onReadAction: (bool read) {
                      context.read<FeedBloc>().add(FeedItemActionedEvent(postId: postViewMedias[index].postView.post.id, postAction: PostAction.read, value: read));
                    },
                    onDownAction: () {
                      prevLastTappedIndex = lastTappedIndex;
                      lastTappedIndex = index;
                    },
                    onUpAction: () {
                      if (markPostReadOnScroll && markReadPostIds.length > 0) {
                        context.read<FeedBloc>().add(FeedItemActionedEvent(postIds: [...markReadPostIds], postAction: PostAction.multiRead, value: true));
                        markReadPostIds = [];
                      }
                    },
                    listingType: state.postListingType,
                    indicateRead: thunderState.dimReadPosts,
                  )
                )
              : null,
        );
      },
      childCount: postViewMedias.length,
    );
  }
}
