import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:html/parser.dart';
import 'package:markdown/markdown.dart' hide Text;

import 'package:thunder/community/enums/community_action.dart';
import 'package:thunder/post/enums/post_action.dart';
import 'package:thunder/post/models/thunder_post.dart';
import 'package:thunder/post/widgets/post_bottom_sheet/post_action_bottom_sheet.dart';
import 'package:thunder/community/widgets/post_card_actions.dart';
import 'package:thunder/community/widgets/post_card_metadata.dart';
import 'package:thunder/core/enums/media_type.dart';
import 'package:thunder/core/enums/view_mode.dart';
import 'package:thunder/core/theme/bloc/theme_bloc.dart';
import 'package:thunder/feed/feed.dart';
import 'package:thunder/post/widgets/post_card_title.dart';
import 'package:thunder/shared/media/media_view.dart';
import 'package:thunder/shared/text/scalable_text.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/user/enums/user_action.dart';
import 'package:thunder/utils/global_context.dart';

/// Displays a card view of a post card. This view is used in the feed related pages.
class PostCardViewComfortable extends StatelessWidget {
  /// The post to display.
  final ThunderPost post;

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

  const PostCardViewComfortable({
    super.key,
    required this.post,
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

    showPostActionBottomModalSheet(
      context,
      post,
      onAction: ({postAction, userAction, communityAction, post}) {
        if (postAction == null && userAction == null && communityAction == null) return;
        if (post != null) context.read<FeedBloc>().add(FeedItemUpdatedEvent(post: post));

        switch (postAction) {
          case PostAction.hide:
            context.read<FeedBloc>().add(FeedDismissHiddenPostEvent(postId: post!.id));
            break;
          default:
            break;
        }

        switch (userAction) {
          case UserAction.block:
            context.read<FeedBloc>().add(FeedDismissBlockedEvent(userId: post!.creator!.id));
            break;
          default:
            break;
        }

        switch (communityAction) {
          case CommunityAction.block:
            context.read<FeedBloc>().add(FeedDismissBlockedEvent(communityId: post!.community!.id));
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

    final state = context.select((ThunderBloc bloc) => (bloc.state.dimReadPosts, bloc.state.contentFontSizeScale));
    final dimReadPosts = state.$1;
    final contentFontSizeScale = state.$2;

    final useDarkTheme = context.select((ThemeBloc bloc) => bloc.state.useDarkTheme);

    final media = post.media.firstOrNull;
    final indicateRead = this.indicateRead ?? dimReadPosts;
    final dim = indicateRead && post.read == true;
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
      );
    }

    final postCardTitle = Padding(
      padding: const EdgeInsets.only(left: 12.0, right: 12.0),
      child: PostCardTitle(
        title: post.name,
        hidden: post.hidden ?? false,
        locked: post.locked,
        saved: post.saved ?? false,
        pinned: post.featuredCommunity || post.featuredLocal,
        deleted: post.deleted,
        removed: post.removed,
        dim: dim,
      ),
    );

    return Container(
      color: containerColor,
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        spacing: 2.0,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showTitleFirst) postCardTitle,
          if (media != null && media.mediaType != MediaType.text)
            Padding(
              padding: edgeToEdgeImages ? const EdgeInsets.symmetric(vertical: 8.0) : const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              child: mediaView,
            ),
          if (!showTitleFirst) postCardTitle,
          if (showTextContent && textContent.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 6.0, left: 12.0, right: 12.0),
              child: ScalableText(
                parse(markdownToHtml(textContent)).documentElement?.text.trim() ?? textContent,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                fontScale: contentFontSizeScale,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: post.read == true ? readColor : theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.70),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(bottom: 4.0, left: 12.0, right: 12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    spacing: 8.0,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PostCommunityAndAuthor(
                        user: post.creator!,
                        community: post.community!,
                        dim: dim,
                      ),
                      PostCardMetadata(
                        postCardViewType: ViewMode.comfortable,
                        score: post.score,
                        upvoteCount: post.upvotes,
                        downvoteCount: post.downvotes,
                        voteType: post.myVote ?? 0,
                        commentCount: post.comments,
                        unreadCommentCount: post.unreadComments,
                        dateTime: dateTime,
                        edited: edited,
                        url: media?.originalUrl,
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
                if (isUserLoggedIn) PostCardActions(voteType: post.myVote ?? 0, saved: post.saved ?? false, onVoteAction: onVoteAction, onSaveAction: onSaveAction),
              ],
            ),
          )
        ],
      ),
    );
  }
}
