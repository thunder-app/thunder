import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/community/widgets/post_card_metadata.dart';
import 'package:thunder/core/enums/media_type.dart';
import 'package:thunder/core/enums/view_mode.dart';
import 'package:thunder/core/models/models.dart';
import 'package:thunder/core/models/post_view_media.dart';
import 'package:thunder/core/theme/bloc/theme_bloc.dart';
import 'package:thunder/post/widgets/post_card_title.dart';
import 'package:thunder/shared/media/compact_thumbnail_preview.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';

/// Displays a compact view of a post card. This view is used in the feed related pages.
class PostCardViewCompact extends StatelessWidget {
  /// The associated post information to display in the card.
  final ThunderPost post;

  /// The creator of the post.
  final ThunderUser creator;

  /// The community the post belongs to.
  final ThunderCommunity community;

  /// Determines whether the user is logged in or not.
  final bool isUserLoggedIn;

  /// The callback function to navigate to the post.
  final void Function({PostViewMedia? postViewMedia})? navigateToPost;

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
    required this.isUserLoggedIn,
    this.navigateToPost,
    this.indicateRead,
    this.showMedia = true,
    required this.isLastTapped,
  });

  /// Returns the color of the container based on the current theme and whether the post is dimmed or not.
  ///
  /// If the post is the last tapped post, the container will be highlighted with the primary color.
  Color? getContainerColor(BuildContext context, {bool dim = false}) {
    final theme = Theme.of(context);
    final useDarkTheme = context.select((ThemeBloc bloc) => bloc.state.useDarkTheme);

    if (isLastTapped) {
      return theme.colorScheme.primary.withValues(alpha: 0.15);
    } else if (dim) {
      return theme.colorScheme.onSurface.withValues(alpha: useDarkTheme ? 0.05 : 0.075);
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final showThumbnailPreviewOnRight = context.select((ThunderBloc bloc) => bloc.state.showThumbnailPreviewOnRight);
    final showTextPostIndicator = context.select((ThunderBloc bloc) => bloc.state.showTextPostIndicator);

    bool indicateRead = this.indicateRead ?? context.select((ThunderBloc bloc) => bloc.state.dimReadPosts);

    // Post statuses
    final read = post.read;
    final hidden = post.hidden;
    final removed = post.removed;
    final deleted = post.deleted;
    final saved = post.saved;
    final locked = post.locked;
    final pinned = post.featuredCommunity || post.featuredLocal;

    final dim = indicateRead && read;

    return Container(
      color: getContainerColor(context, dim: dim),
      padding: showMedia ? const EdgeInsets.symmetric(vertical: 10.0) : const EdgeInsets.only(left: 4.0, top: 10.0, bottom: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          !showThumbnailPreviewOnRight && showMedia && (post.media.first.mediaType == MediaType.text ? showTextPostIndicator : true)
              ? CompactThumbnailPreview(media: post.media.first, dim: dim, postId: post.id, navigateToPost: navigateToPost)
              : const SizedBox(width: 8.0),
          Expanded(
            child: Column(
              spacing: 6.0,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PostCardTitle(
                  title: post.title,
                  hidden: hidden,
                  locked: locked,
                  saved: saved,
                  pinned: pinned,
                  deleted: deleted,
                  removed: removed,
                  dim: dim,
                ),
                PostCommunityAndAuthor(user: creator, community: community, dim: dim),
                PostCardMetadata(
                  postCardViewType: ViewMode.compact,
                  score: post.score,
                  upvoteCount: post.upvotes,
                  downvoteCount: post.downvotes,
                  voteType: post.voteType ?? 0,
                  commentCount: post.comments,
                  unreadCommentCount: post.unreadComments,
                  dateTime: post.updated != null ? post.updated?.toIso8601String() : post.created.toIso8601String(),
                  edited: post.updated != null ? true : false,
                  url: post.media.firstOrNull != null ? post.media.first.originalUrl : null,
                  languageId: post.languageId,
                  dim: dim,
                ),
              ],
            ),
          ),
          showThumbnailPreviewOnRight && showMedia && (post.media.first.mediaType == MediaType.text ? showTextPostIndicator : true)
              ? CompactThumbnailPreview(media: post.media.first, dim: dim, postId: post.id, navigateToPost: navigateToPost)
              : const SizedBox(width: 8.0),
        ],
      ),
    );
  }
}
