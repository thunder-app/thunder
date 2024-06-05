import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:html/parser.dart';
import 'package:html_unescape/html_unescape_small.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:markdown/markdown.dart' hide Text;

import 'package:thunder/account/bloc/account_bloc.dart';
import 'package:thunder/community/utils/post_card_action_helpers.dart';
import 'package:thunder/community/widgets/post_card_actions.dart';
import 'package:thunder/community/widgets/post_card_metadata.dart';
import 'package:thunder/core/enums/font_scale.dart';
import 'package:thunder/core/enums/media_type.dart';
import 'package:thunder/core/enums/view_mode.dart';
import 'package:thunder/core/models/post_view_media.dart';
import 'package:thunder/core/theme/bloc/theme_bloc.dart';
import 'package:thunder/feed/view/feed_page.dart';
import 'package:thunder/shared/media_view.dart';
import 'package:thunder/shared/text/scalable_text.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';

class PostCardViewComfortable extends StatelessWidget {
  final Function(int) onVoteAction;
  final Function(bool) onSaveAction;

  final PostViewMedia postViewMedia;
  final bool hideThumbnails;
  final bool showThumbnailPreviewOnRight;
  final bool hideNsfwPreviews;
  final bool edgeToEdgeImages;
  final bool showTitleFirst;
  final FeedType? feedType;
  final bool showPostAuthor;
  final bool showFullHeightImages;
  final bool showVoteActions;
  final bool showSaveAction;
  final bool showCommunityIcons;
  final bool showTextContent;
  final bool isUserLoggedIn;
  final bool markPostReadOnMediaView;
  final ListingType? listingType;
  final void Function({PostViewMedia? postViewMedia})? navigateToPost;
  final bool indicateRead;

  const PostCardViewComfortable({
    super.key,
    required this.postViewMedia,
    required this.hideThumbnails,
    required this.showThumbnailPreviewOnRight,
    required this.hideNsfwPreviews,
    required this.edgeToEdgeImages,
    required this.showTitleFirst,
    required this.feedType,
    required this.showPostAuthor,
    required this.showFullHeightImages,
    required this.showVoteActions,
    required this.showSaveAction,
    required this.showCommunityIcons,
    required this.showTextContent,
    required this.isUserLoggedIn,
    required this.onVoteAction,
    required this.onSaveAction,
    required this.markPostReadOnMediaView,
    required this.listingType,
    required this.indicateRead,
    this.navigateToPost,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ThunderState state = context.read<ThunderBloc>().state;

    final showCommunitySubscription = (listingType == ListingType.all || listingType == ListingType.local) &&
        isUserLoggedIn &&
        context.read<AccountBloc>().state.subsciptions.map((subscription) => subscription.community.actorId).contains(postViewMedia.postView.community.actorId);

    final String textContent = postViewMedia.postView.post.body ?? "";
    Color? communityAndAuthorColorTransformation(Color? color) => indicateRead && postViewMedia.postView.read ? color?.withOpacity(0.45) : color?.withOpacity(0.85);

    final Color? readColor = indicateRead && postViewMedia.postView.read ? theme.textTheme.bodyMedium?.color?.withOpacity(0.45) : theme.textTheme.bodyMedium?.color?.withOpacity(0.90);

    Widget mediaView = MediaView(
      scrapeMissingPreviews: state.scrapeMissingPreviews,
      postViewMedia: postViewMedia,
      showFullHeightImages: showFullHeightImages,
      hideNsfwPreviews: hideNsfwPreviews,
      hideThumbnails: hideThumbnails,
      edgeToEdgeImages: edgeToEdgeImages,
      markPostReadOnMediaView: markPostReadOnMediaView,
      isUserLoggedIn: isUserLoggedIn,
      navigateToPost: navigateToPost,
      read: indicateRead && postViewMedia.postView.read,
    );
    final bool useSaveButton = state.showSaveAction;
    final double textScaleFactor = state.titleFontSizeScale.textScaleFactor;

    final bool darkTheme = context.read<ThemeBloc>().state.useDarkTheme;

    return Container(
      color: indicateRead && postViewMedia.postView.read ? theme.colorScheme.onBackground.withOpacity(darkTheme ? 0.05 : 0.075) : null,
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showTitleFirst)
            Padding(
              padding: const EdgeInsets.only(left: 12, right: 12, bottom: 4),
              child: Text.rich(
                TextSpan(
                  children: [
                    if (postViewMedia.postView.post.locked) ...[
                      WidgetSpan(
                          child: Icon(
                        Icons.lock,
                        color:
                            indicateRead && postViewMedia.postView.read ? context.read<ThunderBloc>().state.upvoteColor.color.withOpacity(0.55) : context.read<ThunderBloc>().state.upvoteColor.color,
                        size: 15 * textScaleFactor,
                      )),
                    ],
                    if (!useSaveButton && postViewMedia.postView.saved)
                      WidgetSpan(
                        child: Icon(
                          Icons.star_rounded,
                          color: indicateRead && postViewMedia.postView.read ? context.read<ThunderBloc>().state.saveColor.color.withOpacity(0.55) : context.read<ThunderBloc>().state.saveColor.color,
                          size: 17 * textScaleFactor,
                          semanticLabel: 'Saved',
                        ),
                      ),
                    if (postViewMedia.postView.post.featuredCommunity || postViewMedia.postView.post.featuredLocal)
                      WidgetSpan(
                        child: Icon(
                          Icons.push_pin_rounded,
                          size: 15 * textScaleFactor,
                          color: indicateRead && postViewMedia.postView.read ? Colors.green.withOpacity(0.55) : Colors.green,
                        ),
                      ),
                    if (postViewMedia.postView.post.deleted)
                      WidgetSpan(
                        child: Icon(
                          Icons.delete_rounded,
                          size: 16 * textScaleFactor,
                          color: indicateRead && postViewMedia.postView.read ? Colors.red.withOpacity(0.55) : Colors.red,
                        ),
                      ),
                    if (postViewMedia.postView.post.removed)
                      WidgetSpan(
                        child: Icon(
                          Icons.delete_forever_rounded,
                          size: 16 * textScaleFactor,
                          color: indicateRead && postViewMedia.postView.read ? Colors.red.withOpacity(0.55) : Colors.red,
                        ),
                      ),
                    if (postViewMedia.postView.post.deleted ||
                        postViewMedia.postView.post.removed ||
                        postViewMedia.postView.post.featuredCommunity ||
                        postViewMedia.postView.post.featuredLocal ||
                        (!useSaveButton && postViewMedia.postView.saved) ||
                        postViewMedia.postView.post.locked)
                      const WidgetSpan(
                        child: SizedBox(
                          width: 3.5,
                        ),
                      ),
                    TextSpan(
                      text: HtmlUnescape().convert(postViewMedia.postView.post.name),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: MediaQuery.textScalerOf(context).scale(theme.textTheme.bodyMedium!.fontSize! * state.titleFontSizeScale.textScaleFactor),
                        color: postViewMedia.postView.post.featuredCommunity || postViewMedia.postView.post.featuredLocal
                            ? (indicateRead && postViewMedia.postView.read ? Colors.green.withOpacity(0.55) : Colors.green)
                            : (indicateRead && postViewMedia.postView.read ? theme.textTheme.bodyMedium?.color?.withOpacity(0.55) : null),
                      ),
                    ),
                  ],
                ),
                textScaler: TextScaler.noScaling,
              ),
            ),
          if (postViewMedia.media.first.mediaType != MediaType.text && edgeToEdgeImages)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: mediaView,
            ),
          if (postViewMedia.media.first.mediaType != MediaType.text && !edgeToEdgeImages)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: mediaView,
            ),
          if (!showTitleFirst)
            Padding(
                padding: const EdgeInsets.only(top: 4.0, bottom: 6.0, left: 12.0, right: 12.0),
                child: Text.rich(
                  TextSpan(
                    children: [
                      if (postViewMedia.postView.post.locked) ...[
                        WidgetSpan(
                            child: Icon(
                          Icons.lock,
                          color:
                              indicateRead && postViewMedia.postView.read ? context.read<ThunderBloc>().state.upvoteColor.color.withOpacity(0.55) : context.read<ThunderBloc>().state.upvoteColor.color,
                          size: 15 * textScaleFactor,
                        )),
                      ],
                      if (!useSaveButton && postViewMedia.postView.saved)
                        WidgetSpan(
                          child: Icon(
                            Icons.star_rounded,
                            color:
                                indicateRead && postViewMedia.postView.read ? context.read<ThunderBloc>().state.saveColor.color.withOpacity(0.55) : context.read<ThunderBloc>().state.saveColor.color,
                            size: 17 * textScaleFactor,
                            semanticLabel: 'Saved',
                          ),
                        ),
                      if (postViewMedia.postView.post.featuredCommunity || postViewMedia.postView.post.featuredLocal)
                        WidgetSpan(
                          child: Icon(
                            Icons.push_pin_rounded,
                            size: 15 * textScaleFactor,
                            color: indicateRead && postViewMedia.postView.read ? Colors.green.withOpacity(0.55) : Colors.green,
                          ),
                        ),
                      if (postViewMedia.postView.post.deleted)
                        WidgetSpan(
                          child: Icon(
                            Icons.delete_rounded,
                            size: 16 * textScaleFactor,
                            color: indicateRead && postViewMedia.postView.read ? Colors.red.withOpacity(0.55) : Colors.red,
                          ),
                        ),
                      if (postViewMedia.postView.post.removed)
                        WidgetSpan(
                          child: Icon(
                            Icons.delete_forever_rounded,
                            size: 16 * textScaleFactor,
                            color: indicateRead && postViewMedia.postView.read ? Colors.red.withOpacity(0.55) : Colors.red,
                          ),
                        ),
                      if (postViewMedia.postView.post.deleted ||
                          postViewMedia.postView.post.removed ||
                          postViewMedia.postView.post.featuredCommunity ||
                          postViewMedia.postView.post.featuredLocal ||
                          (!useSaveButton && postViewMedia.postView.saved) ||
                          postViewMedia.postView.post.locked)
                        const WidgetSpan(
                          child: SizedBox(
                            width: 3.5,
                          ),
                        ),
                      TextSpan(
                        text: postViewMedia.postView.post.name,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: MediaQuery.textScalerOf(context).scale(theme.textTheme.bodyMedium!.fontSize! * state.titleFontSizeScale.textScaleFactor),
                          color: postViewMedia.postView.post.featuredCommunity || postViewMedia.postView.post.featuredLocal
                              ? (indicateRead && postViewMedia.postView.read ? Colors.green.withOpacity(0.55) : Colors.green)
                              : (indicateRead && postViewMedia.postView.read ? theme.textTheme.bodyMedium?.color?.withOpacity(0.55) : null),
                        ),
                      ),
                    ],
                  ),
                  textScaler: TextScaler.noScaling,
                )),
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
                  color: postViewMedia.postView.read ? readColor : theme.textTheme.bodyMedium?.color?.withOpacity(0.70),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PostCommunityAndAuthor(
                        showCommunityIcons: showCommunityIcons,
                        feedType: feedType,
                        postView: postViewMedia.postView,
                        authorColorTransformation: communityAndAuthorColorTransformation,
                        communityColorTransformation: communityAndAuthorColorTransformation,
                        compactMode: false,
                        showCommunitySubscription: showCommunitySubscription,
                      ),
                      const SizedBox(height: 8.0),
                      PostCardMetadata(
                        postCardViewType: ViewMode.comfortable,
                        score: postViewMedia.postView.counts.score,
                        upvoteCount: postViewMedia.postView.counts.upvotes,
                        downvoteCount: postViewMedia.postView.counts.downvotes,
                        voteType: postViewMedia.postView.myVote ?? 0,
                        commentCount: postViewMedia.postView.counts.comments,
                        unreadCommentCount: postViewMedia.postView.unreadComments,
                        dateTime: postViewMedia.postView.post.updated != null ? postViewMedia.postView.post.updated?.toIso8601String() : postViewMedia.postView.post.published.toIso8601String(),
                        hasBeenEdited: postViewMedia.postView.post.updated != null ? true : false,
                        url: postViewMedia.media.firstOrNull != null ? postViewMedia.media.first.originalUrl : null,
                        hasBeenRead: indicateRead && postViewMedia.postView.read,
                      ),
                    ],
                  ),
                ),
                IconButton(
                    icon: const Icon(
                      Icons.more_horiz_rounded,
                      semanticLabel: 'Actions',
                    ),
                    visualDensity: VisualDensity.compact,
                    onPressed: () {
                      showPostActionBottomModalSheet(
                        context,
                        postViewMedia,
                      );
                      HapticFeedback.mediumImpact();
                    }),
                if (isUserLoggedIn)
                  PostCardActions(
                    postId: postViewMedia.postView.post.id,
                    voteType: postViewMedia.postView.myVote ?? 0,
                    saved: postViewMedia.postView.saved,
                    onVoteAction: onVoteAction,
                    onSaveAction: onSaveAction,
                  ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
