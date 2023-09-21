import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lemmy_api_client/v3.dart';

import 'package:thunder/community/widgets/post_card.dart';
import 'package:thunder/core/models/post_view_media.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/feed/bloc/feed_bloc.dart';
import 'package:thunder/feed/utils/utils.dart';
import 'package:thunder/feed/widgets/feed_page_app_bar.dart';
import 'package:thunder/post/enums/post_action.dart';
import 'package:thunder/post/utils/post.dart';
import 'package:thunder/shared/snackbar.dart';

enum FeedType { community, user, general }

/// Creates a [FeedPage] which holds a list of posts for a given user, community, or custom feed.
///
/// A [FeedType] must be provided which indicates the type of feed to display.
///
/// If [FeedType.community] is provided, one of [communityId] or [communityName] must be provided. If both are provided, [communityId] will take precedence.
/// If [FeedType.user] is provided, one of [userId] or [username] must be provided. If both are provided, [userId] will take precedence.
/// If [FeedType.general] is provided, [postListingType] must be provided.
class FeedPage extends StatelessWidget {
  const FeedPage({
    super.key,
    required this.feedType,
    this.postListingType,
    required this.sortType,
    this.communityId,
    this.communityName,
    this.userId,
    this.username,
  });

  /// The type of feed to display.
  final FeedType feedType;

  /// The type of general feed to display: all, local, subscribed.
  final PostListingType? postListingType;

  /// The sorting to be applied to the feed.
  final SortType? sortType;

  /// The id of the community to display posts for.
  final int? communityId;

  /// The name of the community to display posts for.
  final String? communityName;

  /// The id of the user to display posts for.
  final int? userId;

  /// The username of the user to display posts for.
  final String? username;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<FeedBloc>(
      create: (_) => FeedBloc(lemmyClient: LemmyClient.instance)
        ..add(FeedFetched(
          feedType: feedType,
          postListingType: postListingType,
          sortType: sortType,
          communityId: communityId,
          communityName: communityName,
          userId: userId,
          username: username,
          reset: true,
        )),
      child: const FeedView(),
    );
  }
}

class FeedView extends StatefulWidget {
  const FeedView({super.key});

  @override
  State<FeedView> createState() => _FeedViewState();
}

class _FeedViewState extends State<FeedView> {
  final ScrollController _scrollController = ScrollController();

  bool showAppBarTitle = false;

  @override
  void initState() {
    super.initState();

    // Attach the scroll controller and listen for scroll events
    _scrollController.addListener(() {
      if (_scrollController.position.pixels > 100.0 && showAppBarTitle == false) {
        setState(() => showAppBarTitle = true);
      } else if (_scrollController.position.pixels < 100.0 && showAppBarTitle == true) {
        setState(() => showAppBarTitle = false);
      }

      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        context.read<FeedBloc>().add(const FeedFetched());
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FeedBloc, FeedState>(
      listener: (context, state) {
        if (state.status == FeedStatus.failure && state.message != null) {
          showSnackbar(context, state.message!);
          context.read<FeedBloc>().add(FeedClearMessage()); // Clear the message so that it does not spam
        }
      },
      builder: (context, state) {
        List<PostViewMedia> postViewMedias = state.postViewMedias;

        return RefreshIndicator(
          onRefresh: () async {
            HapticFeedback.mediumImpact();
          },
          edgeOffset: 120.0,
          child: CustomScrollView(
            controller: _scrollController,
            slivers: <Widget>[
              FeedPageAppBar(showAppBarTitle: showAppBarTitle),
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 20.0),
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: const FeedHeader(),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    if (index < postViewMedias.length) {
                      return PostCard(
                        postViewMedia: postViewMedias[index],
                        communityMode: state.feedType == FeedType.community,
                        onVoteAction: (VoteType voteType) {
                          context.read<FeedBloc>().add(FeedItemActioned(postId: postViewMedias[index].postView.post.id, postAction: PostAction.vote, value: voteType));
                        },
                        onSaveAction: (bool saved) {
                          context.read<FeedBloc>().add(FeedItemActioned(postId: postViewMedias[index].postView.post.id, postAction: PostAction.save, value: saved));
                        },
                        onReadAction: (bool read) {
                          context.read<FeedBloc>().add(FeedItemActioned(postId: postViewMedias[index].postView.post.id, postAction: PostAction.purge, value: read));
                        },
                        listingType: state.postListingType,
                        indicateRead: true,
                      );
                    } else {
                      return const SizedBox(height: 40.0, child: Center(child: CircularProgressIndicator()));
                    }
                  },
                  childCount: postViewMedias.length + 1,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class FeedHeader extends StatelessWidget {
  const FeedHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final FeedBloc feedBloc = context.watch<FeedBloc>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          getCommunityName(feedBloc.state),
          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4.0),
        Row(
          children: [
            Icon(getSortIcon(feedBloc.state), size: 17),
            const SizedBox(width: 4),
            Text(
              getSortName(feedBloc.state),
              style: theme.textTheme.titleMedium,
            ),
          ],
        ),
      ],
    );
  }
}
