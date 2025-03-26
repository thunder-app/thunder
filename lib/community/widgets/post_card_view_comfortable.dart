import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:html/parser.dart';
import 'package:markdown/markdown.dart' hide Text;

import 'package:thunder/community/enums/community_action.dart';
import 'package:thunder/core/models/models.dart';
import 'package:thunder/post/enums/post_action.dart';
import 'package:thunder/post/widgets/post_action_bottom_sheet.dart';
import 'package:thunder/community/widgets/post_card_actions.dart';
import 'package:thunder/community/widgets/post_card_metadata.dart';
import 'package:thunder/core/enums/media_type.dart';
import 'package:thunder/core/enums/view_mode.dart';
import 'package:thunder/core/models/post_view_media.dart';
import 'package:thunder/core/theme/bloc/theme_bloc.dart';
import 'package:thunder/feed/feed.dart';
import 'package:thunder/post/widgets/post_card_title.dart';
import 'package:thunder/shared/media/media_view.dart';
import 'package:thunder/shared/text/scalable_text.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/user/enums/user_action.dart';

class PostCardViewComfortable extends StatelessWidget {
  final Function(int) onVoteAction;
  final Function(bool) onSaveAction;

  final PostViewMedia postViewMedia;
  final bool hideThumbnails;
  final bool hideNsfwPreviews;
  final bool edgeToEdgeImages;
  final bool showTitleFirst;
  final bool showPostAuthor;
  final bool showFullHeightImages;
  final bool showVoteActions;
  final bool showSaveAction;
  final bool showTextContent;
  final bool isUserLoggedIn;
  final bool markPostReadOnMediaView;
  final void Function({PostViewMedia? postViewMedia})? navigateToPost;
  final bool? indicateRead;
  final bool isLastTapped;

  const PostCardViewComfortable({
    super.key,
    required this.postViewMedia,
    required this.hideThumbnails,
    required this.hideNsfwPreviews,
    required this.edgeToEdgeImages,
    required this.showTitleFirst,
    required this.showPostAuthor,
    required this.showFullHeightImages,
    required this.showVoteActions,
    required this.showSaveAction,
    required this.showTextContent,
    required this.isUserLoggedIn,
    required this.onVoteAction,
    required this.onSaveAction,
    required this.markPostReadOnMediaView,
    this.indicateRead,
    required this.isLastTapped,
    this.navigateToPost,
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
    final theme = Theme.of(context);
    final state = context.read<ThunderBloc>().state;

    final postView = postViewMedia.postView;
    final post = postView.post;
    final counts = postView.counts;
    final media = postViewMedia.media.firstOrNull;

    bool indicateRead = this.indicateRead ?? context.select((ThunderBloc bloc) => bloc.state.dimReadPosts);
    final textContent = post.body ?? "";
    final readColor = indicateRead && postView.read ? theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.45) : theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.90);

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
        read: indicateRead && postView.read,
      );
    }

    // Post statuses
    final read = postView.read;
    final hidden = postView.hidden;
    final removed = post.removed;
    final deleted = post.deleted;
    final saved = postView.saved;
    final locked = post.locked;
    final pinned = post.featuredCommunity || post.featuredLocal;

    final dim = indicateRead && read;

    Widget postCardTitle = Padding(
      padding: const EdgeInsets.only(left: 12.0, right: 12.0),
      child: PostCardTitle(
        title: post.name,
        hidden: hidden ?? false,
        locked: locked,
        saved: saved,
        pinned: pinned,
        deleted: deleted,
        removed: removed,
        dim: dim,
      ),
    );

    return Container(
      color: getContainerColor(context, dim: dim),
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
          Visibility(
            visible: showTextContent && textContent.isNotEmpty,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 6.0, left: 12.0, right: 12.0),
              child: ScalableText(
                parse(markdownToHtml(textContent)).documentElement?.text.trim() ?? textContent,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                fontScale: state.contentFontSizeScale,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: postView.read ? readColor : theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.70),
                ),
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
                        user: ThunderUser(postViewMedia.postView.creator),
                        community: ThunderCommunity(postViewMedia.postView.community),
                        dim: dim,
                      ),
                      PostCardMetadata(
                        postCardViewType: ViewMode.comfortable,
                        score: counts.score,
                        upvoteCount: counts.upvotes,
                        downvoteCount: counts.downvotes,
                        voteType: postView.myVote ?? 0,
                        commentCount: counts.comments,
                        unreadCommentCount: postView.unreadComments,
                        dateTime: post.updated != null ? post.updated?.toIso8601String() : post.published.toIso8601String(),
                        edited: post.updated != null ? true : false,
                        url: media?.originalUrl,
                        languageId: post.languageId,
                        dim: dim,
                      ),
                    ],
                  ),
                ),
                IconButton(
                    icon: const Icon(Icons.more_horiz_rounded, semanticLabel: 'Actions'),
                    visualDensity: VisualDensity.compact,
                    onPressed: () {
                      showPostActionBottomModalSheet(
                        context,
                        postViewMedia,
                        onAction: ({postAction, userAction, communityAction, required postViewMedia}) async {
                          if (postAction == null && userAction == null && communityAction == null) return;

                          switch (postAction) {
                            case PostAction.hide:
                              context.read<FeedBloc>().add(FeedDismissHiddenPostEvent(postId: post.id));
                              break;
                            default:
                              break;
                          }

                          switch (userAction) {
                            case UserAction.block:
                              context.read<FeedBloc>().add(FeedDismissBlockedEvent(userId: postView.creator.id));
                              break;
                            default:
                              break;
                          }

                          switch (communityAction) {
                            case CommunityAction.block:
                              context.read<FeedBloc>().add(FeedDismissBlockedEvent(communityId: postView.community.id));
                              break;
                            default:
                              break;
                          }
                        },
                      );

                      HapticFeedback.mediumImpact();
                    }),
                if (isUserLoggedIn) PostCardActions(voteType: postView.myVote ?? 0, saved: postView.saved, onVoteAction: onVoteAction, onSaveAction: onSaveAction),
              ],
            ),
          )
        ],
      ),
    );
  }
}
