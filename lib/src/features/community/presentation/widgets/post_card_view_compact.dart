import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/src/features/community/community.dart';
import 'package:thunder/src/foundation/primitives/primitives.dart';
import 'package:thunder/src/features/settings/api.dart';
import 'package:thunder/src/features/post/post.dart';
import 'package:thunder/src/shared/media/compact_thumbnail_preview.dart';
import 'package:thunder/src/features/feed/api.dart';

/// Displays a compact view of a post card. This view is used in the feed related pages.
class PostCardViewCompact extends StatelessWidget {
  /// The associated post information to display in the card.
  final ThunderPost post;

  /// The creator of the post.
  final ThunderUser creator;

  /// The community the post belongs to.
  final ThunderCommunity community;

  /// The callback function to navigate to the post.
  final void Function({ThunderPost? post})? navigateToPost;

  /// Determines whether the post should be dimmed or not. This is usually to indicate when a post has been read.
  final bool? indicateRead;

  /// Optional feed type override for contexts without a FeedBloc.
  final FeedType? feedType;

  /// Optional feed list type override for contexts without a FeedBloc.
  final FeedListType? feedListType;

  /// Flairs to render with the title.
  final List<ThunderFlair> flairs;

  /// Determines whether the media thumbnails should be shown or not.
  final bool showMedia;

  /// Determines whether the post is the last tapped post. This is used to highlight the post.
  final bool isLastTapped;

  const PostCardViewCompact({
    super.key,
    required this.post,
    required this.creator,
    required this.community,
    this.navigateToPost,
    this.indicateRead,
    this.feedType,
    this.feedListType,
    this.flairs = const [],
    this.showMedia = true,
    required this.isLastTapped,
  });

  /// Returns the color of the container based on the current theme and whether the post is dimmed or not.
  ///
  /// If the post is the last tapped post, the container will be highlighted with the primary color.
  Color? _getContainerColor(ThemeData theme, bool useDarkTheme, bool dim) {
    if (isLastTapped) {
      return theme.colorScheme.primary.withValues(alpha: 0.15);
    } else if (dim) {
      return theme.colorScheme.onSurface.withValues(alpha: useDarkTheme ? 0.05 : 0.075);
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final showThumbnailPreviewOnRight = context.select<FeedPreferencesCubit, bool>((cubit) => cubit.state.showThumbnailPreviewOnRight);
    final showTextPostIndicator = context.select<FeedPreferencesCubit, bool>((cubit) => cubit.state.showTextPostIndicator);
    final dimReadPostsSetting = context.select<FeedPreferencesCubit, bool>((cubit) => cubit.state.dimReadPosts);
    final showCommunityFirst = context.select<FeedPreferencesCubit, bool>((cubit) => cubit.state.showPostCommunityFirst);

    final useDarkTheme = context.select((ThemePreferencesCubit cubit) => cubit.state.useDarkTheme);

    final indicateRead = this.indicateRead ?? dimReadPostsSetting;
    final dim = indicateRead && post.context.read == true;

    final hasMedia = post.media.isNotEmpty;
    final isTextPost = hasMedia && post.media.first.mediaType == MediaType.text;
    final shouldShowThumbnail = showMedia && hasMedia && (isTextPost ? showTextPostIndicator : true);

    final containerColor = _getContainerColor(theme, useDarkTheme, dim);
    final containerPadding = showMedia ? const EdgeInsets.symmetric(vertical: 10.0) : const EdgeInsets.only(left: 4.0, top: 10.0, bottom: 10.0);

    final dateTime = post.updated?.toIso8601String() ?? post.published.toIso8601String();
    final edited = post.updated != null;
    final mediaUrl = post.media.firstOrNull?.originalUrl;

    final postCardAuthor = PostCommunityAndAuthor(user: creator, community: community, dim: dim, feedType: feedType, feedListType: feedListType);

    return Container(
      color: containerColor,
      padding: containerPadding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          !showThumbnailPreviewOnRight && shouldShowThumbnail
              ? CompactThumbnailPreview(media: post.media.first, dim: dim, postId: post.id, navigateToPost: navigateToPost)
              : const SizedBox(width: 8.0),
          Expanded(
            child: Column(
              spacing: 6.0,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showCommunityFirst) postCardAuthor,
                PostCardTitle(
                  title: post.name,
                  hidden: post.context.hidden ?? false,
                  locked: post.status.locked,
                  saved: post.context.saved ?? false,
                  pinned: post.status.featuredCommunity || post.status.featuredLocal,
                  deleted: post.status.deleted,
                  removed: post.status.removed,
                  dim: dim,
                  flairs: flairs,
                ),
                if (!showCommunityFirst) postCardAuthor,
                PostCardMetadata(
                  postCardViewType: ViewMode.compact,
                  score: post.counts.score,
                  upvoteCount: post.counts.upvotes,
                  downvoteCount: post.counts.downvotes,
                  voteType: post.context.vote.score,
                  commentCount: post.counts.comments,
                  unreadCommentCount: post.counts.unreadComments,
                  dateTime: dateTime,
                  edited: edited,
                  url: post.media.firstOrNull?.mediaType == MediaType.image ? null : mediaUrl,
                  languageId: post.languageId,
                  dim: dim,
                ),
              ],
            ),
          ),
          showThumbnailPreviewOnRight && shouldShowThumbnail ? CompactThumbnailPreview(media: post.media.first, dim: dim, postId: post.id, navigateToPost: navigateToPost) : const SizedBox(width: 8.0),
        ],
      ),
    );
  }
}
