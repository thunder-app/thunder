import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:lemmy_api_client/v3.dart';

import 'package:thunder/community/utils/post_card_action_helpers.dart';
import 'package:thunder/community/widgets/post_card_metadata.dart';
import 'package:thunder/core/enums/font_scale.dart';
import 'package:thunder/core/enums/view_mode.dart';
import 'package:thunder/core/models/post_view_media.dart';
import 'package:thunder/shared/media_view.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/utils/instance.dart';

class PostCardViewCompact extends StatelessWidget {
  final PostViewMedia postViewMedia;
  final bool showThumbnailPreviewOnRight;
  final bool hideNsfwPreviews;
  final bool showInstanceName;

  const PostCardViewCompact({
    super.key,
    required this.postViewMedia,
    required this.showThumbnailPreviewOnRight,
    required this.hideNsfwPreviews,
    required this.showInstanceName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ThunderState state = context.read<ThunderBloc>().state;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (!showThumbnailPreviewOnRight)
            MediaView(
              postView: postViewMedia,
              showFullHeightImages: false,
              hideNsfwPreviews: hideNsfwPreviews,
              viewMode: ViewMode.compact,
            ),
          if (!showThumbnailPreviewOnRight) const SizedBox(width: 8.0),
          Flexible(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(postViewMedia.postView.post.name,
                        textScaleFactor: state.titleFontSizeScale.textScaleFactor,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: postViewMedia.postView.read ? theme.textTheme.bodyMedium?.color?.withOpacity(0.4) : null,
                        )),
                    const SizedBox(height: 4.0),
                    GestureDetector(
                      child: Text(
                        '${postViewMedia.postView.community.name}${showInstanceName ? ' · ${fetchInstanceNameFromUrl(postViewMedia.postView.community.actorId)}' : ''}',
                        textScaleFactor: state.contentFontSizeScale.textScaleFactor,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: postViewMedia.postView.read ? theme.textTheme.bodyMedium?.color?.withOpacity(0.4) : theme.textTheme.bodyMedium?.color?.withOpacity(0.75),
                        ),
                      ),
                      onTap: () => onTapCommunityName(context, postViewMedia.postView.community.id),
                    ),
                    const SizedBox(height: 8.0),
                  ],
                ),
                PostCardMetaData(
                  score: postViewMedia.postView.counts.score,
                  voteType: postViewMedia.postView.myVote ?? VoteType.none,
                  comments: postViewMedia.postView.counts.comments,
                  hasBeenEdited: postViewMedia.postView.post.updated != null ? true : false,
                  published: postViewMedia.postView.post.updated != null ? postViewMedia.postView.post.updated! : postViewMedia.postView.post.published,
                  saved: postViewMedia.postView.saved,
                  distinguised: postViewMedia.postView.post.featuredCommunity,
                )
              ],
            ),
          ),
          if (showThumbnailPreviewOnRight) const SizedBox(width: 8.0),
          if (showThumbnailPreviewOnRight)
            MediaView(
              postView: postViewMedia,
              showFullHeightImages: false,
              hideNsfwPreviews: hideNsfwPreviews,
              viewMode: ViewMode.compact,
            ),
        ],
      ),
    );
  }
}
