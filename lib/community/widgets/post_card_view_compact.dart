import 'package:flutter/material.dart';

import 'package:lemmy_api_client/v3.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:html_unescape/html_unescape_small.dart';

import 'package:thunder/community/widgets/post_card_metadata.dart';
import 'package:thunder/core/enums/font_scale.dart';
import 'package:thunder/core/enums/media_type.dart';
import 'package:thunder/core/enums/view_mode.dart';
import 'package:thunder/core/models/post_view_media.dart';
import 'package:thunder/core/theme/bloc/theme_bloc.dart';
import 'package:thunder/feed/view/feed_page.dart';
import 'package:thunder/post/widgets/post_status_icon.dart';
import 'package:thunder/shared/media/compact_thumbnail_preview.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';

/// Displays a compact view of a post card. This view is used in the feed related pages.
class PostCardViewCompact extends StatelessWidget {
  final PostViewMedia postViewMedia;
  final FeedType? feedType;
  final bool isUserLoggedIn;
  final ListingType? listingType;
  final void Function({PostViewMedia? postViewMedia})? navigateToPost;
  final bool? indicateRead;
  final bool showMedia;
  final bool isLastTapped;

  const PostCardViewCompact({
    super.key,
    required this.postViewMedia,
    required this.feedType,
    required this.isUserLoggedIn,
    required this.listingType,
    this.navigateToPost,
    this.indicateRead,
    this.showMedia = true,
    required this.isLastTapped,
  });

  Color getDimmedColor(Color color) => color.withValues(alpha: 0.55);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final showThumbnailPreviewOnRight = context.select((ThunderBloc bloc) => bloc.state.showThumbnailPreviewOnRight);
    final showTextPostIndicator = context.select((ThunderBloc bloc) => bloc.state.showTextPostIndicator);
    final textScaleFactor = context.select((ThunderBloc bloc) => bloc.state.titleFontSizeScale.textScaleFactor);
    final showCommunitySubscription = isUserLoggedIn && (listingType == ListingType.all || listingType == ListingType.local) && postViewMedia.postView.subscribed != SubscribedType.notSubscribed;

    final darkTheme = context.select((ThemeBloc bloc) => bloc.state.useDarkTheme);

    bool indicateRead = this.indicateRead ?? context.select((ThunderBloc bloc) => bloc.state.dimReadPosts);

    final read = postViewMedia.postView.read;
    final hidden = postViewMedia.postView.hidden;
    final removed = postViewMedia.postView.post.removed;
    final deleted = postViewMedia.postView.post.deleted;
    final saved = postViewMedia.postView.saved;
    final locked = postViewMedia.postView.post.locked;
    final pinned = postViewMedia.postView.post.featuredCommunity || postViewMedia.postView.post.featuredLocal;

    Color? communityAndAuthorColorTransformation(Color? color) => indicateRead && read ? color?.withValues(alpha: 0.45) : color?.withValues(alpha: 0.75);

    return Container(
      color: isLastTapped
          ? theme.colorScheme.primary.withValues(alpha: 0.15)
          : indicateRead && read
              ? theme.colorScheme.onSurface.withValues(alpha: darkTheme ? 0.05 : 0.075)
              : null,
      padding: showMedia ? const EdgeInsets.only(bottom: 8.0, top: 6) : const EdgeInsets.only(left: 4.0, top: 10.0, bottom: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          !showThumbnailPreviewOnRight && showMedia && (postViewMedia.media.first.mediaType == MediaType.text ? showTextPostIndicator : true)
              ? CompactThumbnailPreview(media: postViewMedia.media.first, dim: indicateRead && read, navigateToPost: navigateToPost)
              : const SizedBox(width: 8.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      WidgetSpan(
                        child: PostStatusIcon(
                          hidden: hidden ?? false,
                          locked: locked,
                          saved: saved,
                          pinned: pinned,
                          deleted: deleted,
                          removed: removed,
                          dim: indicateRead && read,
                        ),
                      ),
                      TextSpan(
                        text: HtmlUnescape().convert(postViewMedia.postView.post.name),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: MediaQuery.textScalerOf(context).scale(theme.textTheme.bodyMedium!.fontSize! * textScaleFactor),
                          color: pinned ? (indicateRead && read ? getDimmedColor(Colors.green) : Colors.green) : (indicateRead && read ? getDimmedColor(theme.textTheme.bodyMedium!.color!) : null),
                        ),
                      ),
                    ],
                  ),
                  textScaler: TextScaler.noScaling,
                ),
                const SizedBox(height: 6.0),
                PostCommunityAndAuthor(
                  compactMode: true,
                  showCommunityIcons: false,
                  feedType: feedType,
                  postView: postViewMedia.postView,
                  communityColorTransformation: communityAndAuthorColorTransformation,
                  authorColorTransformation: communityAndAuthorColorTransformation,
                  showCommunitySubscription: showCommunitySubscription,
                ),
                const SizedBox(height: 6.0),
                PostCardMetadata(
                  postCardViewType: ViewMode.compact,
                  score: postViewMedia.postView.counts.score,
                  upvoteCount: postViewMedia.postView.counts.upvotes,
                  downvoteCount: postViewMedia.postView.counts.downvotes,
                  voteType: postViewMedia.postView.myVote ?? 0,
                  commentCount: postViewMedia.postView.counts.comments,
                  unreadCommentCount: postViewMedia.postView.unreadComments,
                  dateTime: postViewMedia.postView.post.updated != null ? postViewMedia.postView.post.updated?.toIso8601String() : postViewMedia.postView.post.published.toIso8601String(),
                  hasBeenEdited: postViewMedia.postView.post.updated != null ? true : false,
                  url: postViewMedia.media.firstOrNull != null ? postViewMedia.media.first.originalUrl : null,
                  languageId: postViewMedia.postView.post.languageId,
                  hasBeenRead: indicateRead && read,
                ),
              ],
            ),
          ),
          showThumbnailPreviewOnRight && showMedia && (postViewMedia.media.first.mediaType == MediaType.text ? showTextPostIndicator : true)
              ? CompactThumbnailPreview(media: postViewMedia.media.first, dim: indicateRead && read, navigateToPost: navigateToPost)
              : const SizedBox(width: 8.0),
        ],
      ),
    );
  }
}
