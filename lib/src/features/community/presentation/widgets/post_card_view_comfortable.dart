import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/src/features/feed/api.dart';
import 'package:thunder/src/features/community/community.dart';
import 'package:thunder/src/features/post/post.dart';
import 'package:thunder/src/foundation/primitives/primitives.dart';
import 'package:thunder/src/features/settings/api.dart';
import 'package:thunder/src/features/feed/feed.dart';
import 'package:thunder/src/shared/media/media_view.dart';
import 'package:thunder/src/features/user/user.dart';
import 'package:thunder/src/foundation/config/global_context.dart';
import 'package:thunder/packages/ui/ui.dart';

/// Displays a card view of a post card. This view is used in the feed related pages.
class PostCardViewComfortable extends StatelessWidget {
  /// The post to display.
  final ThunderPost post;

  /// Optional feed type override for contexts without a FeedBloc.
  final FeedType? feedType;

  /// Optional feed list type override for contexts without a FeedBloc.
  final FeedListType? feedListType;

  /// Flairs to render with the title.
  final List<ThunderFlair> flairs;

  /// Whether to hide thumbnails.
  final bool hideThumbnails;

  /// Whether to hide NSFW previews.
  final bool hideNsfwPreviews;

  /// Whether to use edge-to-edge images.
  final bool edgeToEdgeImages;

  /// Whether to show the title first.
  final bool showTitleFirst;

  /// Whether to show full height images.
  final bool showFullHeightImages;

  /// Whether to show text content.
  final bool showTextContent;

  /// Whether the user is logged in.
  final bool isUserLoggedIn;

  /// Whether to mark the post as read on media view.
  final bool markPostReadOnMediaView;

  /// Whether to indicate read posts.
  final bool? indicateRead;

  /// Whether the post is the last tapped post.
  final bool isLastTapped;

  /// The function to navigate to the post.
  final void Function({ThunderPost? post})? navigateToPost;

  /// The function to handle vote actions.
  final Function(int) onVoteAction;

  /// The function to handle save actions.
  final Function(bool) onSaveAction;

  /// Optional callback for replacing a post in the current list.
  final void Function(ThunderPost post)? onPostUpdated;

  /// Optional callback for dismissing a hidden post from view.
  final void Function(int postId)? onDismissHiddenPost;

  /// Optional callback for dismissing blocked content from view.
  final void Function({int? userId, int? communityId})? onDismissBlocked;

  /// Optional callback for marking a post as read from media interactions.
  final Future<void> Function()? onMarkPostRead;

  const PostCardViewComfortable({
    super.key,
    required this.post,
    this.feedType,
    this.feedListType,
    this.flairs = const [],
    required this.hideThumbnails,
    required this.hideNsfwPreviews,
    required this.edgeToEdgeImages,
    required this.showTitleFirst,
    required this.showFullHeightImages,
    required this.showTextContent,
    required this.isUserLoggedIn,
    required this.markPostReadOnMediaView,
    this.indicateRead,
    required this.isLastTapped,
    this.navigateToPost,
    required this.onVoteAction,
    required this.onSaveAction,
    this.onPostUpdated,
    this.onDismissHiddenPost,
    this.onDismissBlocked,
    this.onMarkPostRead,
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

  void onPostActionBottomSheetPressed(BuildContext context, ThunderPost post) {
    HapticFeedback.mediumImpact();
    final hasFeedBloc = context.findAncestorWidgetOfExactType<BlocProvider<FeedBloc>>() != null;

    showPostActionBottomModalSheet(
      context,
      post,
      onAction: ({postAction, userAction, communityAction, post}) {
        if (postAction == null && userAction == null && communityAction == null) return;
        if (post != null) {
          if (onPostUpdated != null) {
            onPostUpdated!(post);
          } else if (hasFeedBloc) {
            context.read<FeedBloc>().add(FeedItemUpdatedEvent(post: post));
          }
        }

        switch (postAction) {
          case PostAction.hide:
            if (onDismissHiddenPost != null) {
              onDismissHiddenPost!(post!.id);
            } else {
              FeedActionScope.maybeOf(context)?.dismissHiddenPost(post!.id);
            }
            break;
          default:
            break;
        }

        switch (userAction) {
          case UserAction.block:
            if (onDismissBlocked != null) {
              onDismissBlocked!(userId: post!.creator!.id);
            } else {
              FeedActionScope.maybeOf(context)?.dismissBlocked(userId: post!.creator!.id);
            }
            break;
          default:
            break;
        }

        switch (communityAction) {
          case CommunityAction.block:
            if (onDismissBlocked != null) {
              onDismissBlocked!(communityId: post!.community!.id);
            } else {
              FeedActionScope.maybeOf(context)?.dismissBlocked(communityId: post!.community!.id);
            }
            break;
          default:
            break;
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = GlobalContext.l10n;

    final dimReadPosts = context.select<FeedPreferencesCubit, bool>((cubit) => cubit.state.dimReadPosts);
    final contentFontSizeScale = context.select<ThemePreferencesCubit, FontScale>((cubit) => cubit.state.contentFontSizeScale);
    final showCommunityFirst = context.select<FeedPreferencesCubit, bool>((cubit) => cubit.state.showPostCommunityFirst);

    final useDarkTheme = context.select((ThemePreferencesCubit cubit) => cubit.state.useDarkTheme);

    final media = post.media.firstOrNull;
    final indicateRead = this.indicateRead ?? dimReadPosts;
    final dim = indicateRead && post.context.read == true;
    final textContent = post.body ?? "";

    final readColor = dim ? theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.45) : theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.90);

    final containerColor = _getContainerColor(theme, useDarkTheme, dim);
    final dateTime = post.updated?.toIso8601String() ?? post.published.toIso8601String();
    final edited = post.updated != null;

    Widget mediaView;

    if (media == null || media.mediaType == MediaType.text) {
      mediaView = const SizedBox.shrink();
    } else {
      mediaView = MediaView(
        media: media,
        postId: post.id,
        showFullHeightImages: showFullHeightImages,
        hideNsfwPreviews: hideNsfwPreviews,
        hideThumbnails: hideThumbnails,
        edgeToEdgeImages: edgeToEdgeImages,
        markPostReadOnMediaView: markPostReadOnMediaView,
        isUserLoggedIn: isUserLoggedIn,
        navigateToPost: navigateToPost,
        read: dim,
        onMarkPostRead: onMarkPostRead,
      );
    }

    final postCardAuthor = PostCommunityAndAuthor(
      user: post.creator!,
      community: post.community!,
      dim: dim,
      feedType: feedType,
      feedListType: feedListType,
    );

    final edgesPadding = const EdgeInsets.symmetric(horizontal: 12.0);

    final postCardTitle = Padding(
      padding: edgesPadding,
      child: PostCardTitle(
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
    );

    return Container(
      color: containerColor,
      padding: showCommunityFirst ? const EdgeInsets.only(top: 12.0) : const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        spacing: 2.0,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showCommunityFirst) Padding(padding: edgesPadding, child: postCardAuthor),
          if (showTitleFirst) postCardTitle,
          if (media != null && media.mediaType != MediaType.text)
            Padding(
              padding: edgeToEdgeImages ? const EdgeInsets.symmetric(vertical: 8.0) : edgesPadding + const EdgeInsets.symmetric(vertical: 8.0),
              child: mediaView,
            ),
          if (!showTitleFirst) postCardTitle,
          if (showTextContent && textContent.isNotEmpty)
            Padding(
              padding: showCommunityFirst ? edgesPadding : edgesPadding + const EdgeInsets.only(bottom: 6.0),
              child: ThunderScalableText(
                post.textPreview ?? textContent,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                textScaleFactor: contentFontSizeScale.textScaleFactor,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: post.context.read == true ? readColor : theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.70),
                ),
              ),
            ),
          Padding(
            padding: edgesPadding + const EdgeInsets.only(bottom: 4.0),
            child: Row(
              crossAxisAlignment: showCommunityFirst ? CrossAxisAlignment.center : CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    spacing: 8.0,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!showCommunityFirst) postCardAuthor,
                      PostCardMetadata(
                        postCardViewType: ViewMode.comfortable,
                        score: post.counts.score,
                        upvoteCount: post.counts.upvotes,
                        downvoteCount: post.counts.downvotes,
                        voteType: post.context.vote.score,
                        commentCount: post.counts.comments,
                        unreadCommentCount: post.counts.unreadComments,
                        dateTime: dateTime,
                        edited: edited,
                        url: media?.mediaType == MediaType.image ? null : media?.originalUrl,
                        languageId: post.languageId,
                        dim: dim,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.more_horiz_rounded, semanticLabel: l10n.actions),
                  visualDensity: VisualDensity.compact,
                  onPressed: () => onPostActionBottomSheetPressed(context, post),
                ),
                if (isUserLoggedIn) PostCardActions(voteType: post.context.vote.score, saved: post.context.saved ?? false, onVoteAction: onVoteAction, onSaveAction: onSaveAction),
              ],
            ),
          )
        ],
      ),
    );
  }
}
