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

class FeedPostList extends StatelessWidget {
  final bool tabletMode;
  final bool markPostReadOnScroll;
  final List<int>? queuedForRemoval;
  final List<PostViewMedia> postViewMedias;

  const FeedPostList({
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
              ? PostCard(
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
                  onUpAction: () {
                    if (markPostReadOnScroll) {
                      // Past count tested on multiple devices to ensure posts marked read are above the 0 point
                      // Reducing this will cause elements still on the screen to be marked read
                      int past = 6;
                      if (tabletMode && thunderState.useCompactView) {
                        past = 22;
                      } else if (tabletMode && !thunderState.useCompactView) {
                        past = 12;
                      } else if (!tabletMode && thunderState.useCompactView) {
                        past = 11;
                      }
                      if (isUserLoggedIn && index > past) {
                        List<int> markRead = [];
                        for (var i = 0; i < index - past; i++) {
                          if (postViewMedias[i].postView.read != true) {
                            markRead.add(postViewMedias[i].postView.post.id);
                          }
                        }
                        if (markRead.length > 0) {
                          context.read<FeedBloc>().add(FeedItemActionedEvent(postIds: markRead, postAction: PostAction.multiRead, value: true));
                        }
                      }
                    }
                  },
                  listingType: state.postListingType,
                  indicateRead: thunderState.dimReadPosts,
                )
              : null,
        );
      },
      childCount: postViewMedias.length,
    );
  }
}
