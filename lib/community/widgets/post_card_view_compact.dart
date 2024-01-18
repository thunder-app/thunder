import 'package:flutter/material.dart';

import 'package:lemmy_api_client/v3.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:html_unescape/html_unescape_small.dart';

import 'package:thunder/account/bloc/account_bloc.dart';
import 'package:thunder/community/widgets/post_card_metadata.dart';
import 'package:thunder/community/widgets/post_card_type_badge.dart';
import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/core/enums/font_scale.dart';
import 'package:thunder/core/enums/media_type.dart';
import 'package:thunder/core/enums/view_mode.dart';
import 'package:thunder/core/models/post_view_media.dart';
import 'package:thunder/core/theme/bloc/theme_bloc.dart';
import 'package:thunder/shared/media_view.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';

class PostCardViewCompact extends StatelessWidget {
  final PostViewMedia postViewMedia;
  final bool communityMode;
  final bool isUserLoggedIn;
  final ListingType? listingType;
  final void Function({PostViewMedia? postViewMedia})? navigateToPost;

  const PostCardViewCompact({
    super.key,
    required this.postViewMedia,
    required this.communityMode,
    required this.isUserLoggedIn,
    required this.listingType,
    this.navigateToPost,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ThunderState state = context.watch<ThunderBloc>().state;

    bool showThumbnailPreviewOnRight = state.showThumbnailPreviewOnRight;
    bool showTextPostIndicator = state.showTextPostIndicator;
    bool indicateRead = state.dimReadPosts;

    final showCommunitySubscription = (listingType == ListingType.all || listingType == ListingType.local) &&
        isUserLoggedIn &&
        context.read<AccountBloc>().state.subsciptions.map((subscription) => subscription.community.actorId).contains(postViewMedia.postView.community.actorId);

    final TextStyle? textStyleCommunityAndAuthor = theme.textTheme.bodyMedium?.copyWith(
      color: indicateRead && postViewMedia.postView.read ? theme.textTheme.bodyMedium?.color?.withOpacity(0.45) : theme.textTheme.bodyMedium?.color?.withOpacity(0.75),
    );

    final Color? readColor = indicateRead && postViewMedia.postView.read ? theme.textTheme.bodyMedium?.color?.withOpacity(0.45) : theme.textTheme.bodyMedium?.color?.withOpacity(0.90);
    final double textScaleFactor = state.titleFontSizeScale.textScaleFactor;

    final bool darkTheme = context.read<ThemeBloc>().state.useDarkTheme;

    return Container(
      color: indicateRead && postViewMedia.postView.read ? theme.colorScheme.onBackground.withOpacity(darkTheme ? 0.05 : 0.075) : null,
      padding: const EdgeInsets.only(bottom: 8.0, top: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          !showThumbnailPreviewOnRight && (postViewMedia.media.isNotEmpty || showTextPostIndicator)
              ? ThumbnailPreview(postViewMedia: postViewMedia, navigateToPost: navigateToPost)
              : const SizedBox(width: 8.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      if (postViewMedia.postView.post.locked) ...[
                        WidgetSpan(
                          child: Icon(
                            Icons.lock,
                            color: indicateRead && postViewMedia.postView.read ? Colors.red.withOpacity(0.55) : Colors.red,
                            size: 15 * textScaleFactor,
                          ),
                        ),
                      ],
                      if (postViewMedia.postView.saved)
                        WidgetSpan(
                          child: Icon(
                            Icons.star_rounded,
                            color: indicateRead && postViewMedia.postView.read ? Colors.purple.withOpacity(0.55) : Colors.purple,
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
                      if (postViewMedia.postView.post.featuredCommunity || postViewMedia.postView.post.featuredLocal || postViewMedia.postView.saved || postViewMedia.postView.post.locked)
                        const WidgetSpan(child: SizedBox(width: 3.5)),
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
                const SizedBox(height: 6.0),
                PostCommunityAndAuthor(
                  compactMode: true,
                  showCommunityIcons: false,
                  communityMode: communityMode,
                  postView: postViewMedia.postView,
                  textStyleCommunity: textStyleCommunityAndAuthor,
                  textStyleAuthor: textStyleCommunityAndAuthor,
                  showCommunitySubscription: showCommunitySubscription,
                ),
                const SizedBox(height: 6.0),
                PostCardMetaData(
                  readColor: readColor,
                  score: postViewMedia.postView.counts.score,
                  voteType: postViewMedia.postView.myVote ?? 0,
                  comments: postViewMedia.postView.counts.comments,
                  unreadComments: postViewMedia.postView.unreadComments,
                  hasBeenEdited: postViewMedia.postView.post.updated != null ? true : false,
                  published: postViewMedia.postView.post.updated != null ? postViewMedia.postView.post.updated! : postViewMedia.postView.post.published,
                  hostURL: postViewMedia.media.firstOrNull != null ? postViewMedia.media.first.originalUrl : null,
                ),
              ],
            ),
          ),
          showThumbnailPreviewOnRight && (postViewMedia.media.isNotEmpty || showTextPostIndicator)
              ? ThumbnailPreview(postViewMedia: postViewMedia, navigateToPost: navigateToPost)
              : const SizedBox(width: 8.0),
        ],
      ),
    );
  }
}

/// Displays the thumbnail preview for the post. This can be text, media, or links.
class ThumbnailPreview extends StatelessWidget {
  /// The [PostViewMedia] to display the thumbnail preview for
  final PostViewMedia postViewMedia;

  /// The callback function to navigate to the post
  final void Function({PostViewMedia? postViewMedia})? navigateToPost;

  const ThumbnailPreview({
    super.key,
    required this.postViewMedia,
    required this.navigateToPost,
  });

  @override
  Widget build(BuildContext context) {
    final state = context.read<ThunderBloc>().state;
    final isUserLoggedIn = context.read<AuthBloc>().state.isLoggedIn;

    final indicateRead = state.dimReadPosts;
    final hideNsfwPreviews = state.hideNsfwPreviews;
    final markPostReadOnMediaView = state.markPostReadOnMediaView;

    return ExcludeSemantics(
      child: Stack(
        alignment: AlignmentDirectional.bottomEnd,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4),
            child: MediaView(
              scrapeMissingPreviews: state.scrapeMissingPreviews,
              postView: postViewMedia,
              showFullHeightImages: false,
              hideNsfwPreviews: hideNsfwPreviews,
              markPostReadOnMediaView: markPostReadOnMediaView,
              viewMode: ViewMode.compact,
              isUserLoggedIn: isUserLoggedIn,
              navigateToPost: navigateToPost,
              read: indicateRead && postViewMedia.postView.read,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 6, bottom: 0),
            child: TypeBadge(
              mediaType: postViewMedia.media.firstOrNull?.mediaType ?? MediaType.text,
              dim: indicateRead && postViewMedia.postView.read,
            ),
          ),
        ],
      ),
    );
  }
}
