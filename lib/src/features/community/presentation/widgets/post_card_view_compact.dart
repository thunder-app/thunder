import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/src/features/community/community.dart';
import 'package:thunder/src/core/enums/media_type.dart';
import 'package:thunder/src/core/enums/view_mode.dart';
import 'package:thunder/src/app/theme/bloc/theme_bloc.dart';
import 'package:thunder/src/features/post/post.dart';
import 'package:thunder/src/shared/widgets/media/compact_thumbnail_preview.dart';
import 'package:thunder/src/app/bloc/thunder_bloc.dart';
import 'package:thunder/src/features/user/user.dart';

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

    final state = context.select((ThunderBloc bloc) => (bloc.state.showThumbnailPreviewOnRight, bloc.state.showTextPostIndicator, bloc.state.dimReadPosts));
    final showThumbnailPreviewOnRight = state.$1;
    final showTextPostIndicator = state.$2;
    final dimReadPostsSetting = state.$3;

    final useDarkTheme = context.select((ThemeBloc bloc) => bloc.state.useDarkTheme);

    final indicateRead = this.indicateRead ?? dimReadPostsSetting;
    final dim = indicateRead && post.read == true;

    final hasMedia = post.media.isNotEmpty;
    final isTextPost = hasMedia && post.media.first.mediaType == MediaType.text;
    final shouldShowThumbnail = showMedia && hasMedia && (isTextPost ? showTextPostIndicator : true);

    final containerColor = _getContainerColor(theme, useDarkTheme, dim);
    final containerPadding = showMedia ? const EdgeInsets.symmetric(vertical: 10.0) : const EdgeInsets.only(left: 4.0, top: 10.0, bottom: 10.0);

    final dateTime = post.updated?.toIso8601String() ?? post.published.toIso8601String();
    final edited = post.updated != null;
    final mediaUrl = post.media.firstOrNull?.originalUrl;

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
                PostCardTitle(
                  title: post.name,
                  hidden: post.hidden ?? false,
                  locked: post.locked,
                  saved: post.saved ?? false,
                  pinned: post.featuredCommunity || post.featuredLocal,
                  deleted: post.deleted,
                  removed: post.removed,
                  dim: dim,
                ),
                PostCommunityAndAuthor(user: creator, community: community, dim: dim),
                PostCardMetadata(
                  postCardViewType: ViewMode.compact,
                  score: post.score,
                  upvoteCount: post.upvotes,
                  downvoteCount: post.downvotes,
                  voteType: post.myVote ?? 0,
                  commentCount: post.comments,
                  unreadCommentCount: post.unreadComments,
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
