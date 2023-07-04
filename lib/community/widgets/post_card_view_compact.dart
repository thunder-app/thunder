import 'package:flutter/material.dart';

import 'package:lemmy_api_client/v3.dart';

import 'package:thunder/community/utils/post_card_action_helpers.dart';
import 'package:thunder/community/widgets/post_card_metadata.dart';
import 'package:thunder/core/enums/font_scale.dart';
import 'package:thunder/core/enums/view_mode.dart';
import 'package:thunder/core/models/post_view_media.dart';
import 'package:thunder/shared/media_view.dart';
import 'package:thunder/utils/font_size.dart';
import 'package:thunder/utils/instance.dart';

class PostCardViewCompact extends StatefulWidget {
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
  State<PostCardViewCompact> createState() => _PostCardViewCompactState();
}

class _PostCardViewCompactState extends State<PostCardViewCompact> {
  double titleFontSizeScaleFactor = FontScale.base.textScaleFactor;
  double contentFontSizeScaleFactor = FontScale.base.textScaleFactor;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _initPreferences());
    super.initState();
  }

  @override
  void didUpdateWidget(covariant PostCardViewCompact oldWidget) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _initPreferences());
    super.didUpdateWidget(oldWidget);
  }

  Future<void> _initPreferences() async {
    Map<String, double> textScaleFactor = await getTextScaleFactor();

    setState(() {
      titleFontSizeScaleFactor = textScaleFactor['titleFontSizeScaleFactor'] ?? FontScale.base.textScaleFactor;
      contentFontSizeScaleFactor = textScaleFactor['contentFontSizeScaleFactor'] ?? FontScale.base.textScaleFactor;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (!widget.showThumbnailPreviewOnRight)
            MediaView(
              postView: widget.postViewMedia,
              showFullHeightImages: false,
              hideNsfwPreviews: widget.hideNsfwPreviews,
              viewMode: ViewMode.compact,
            ),
          if (!widget.showThumbnailPreviewOnRight) const SizedBox(width: 8.0),
          Flexible(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(widget.postViewMedia.postView.post.name,
                        textScaleFactor: titleFontSizeScaleFactor,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: widget.postViewMedia.postView.read ? theme.textTheme.bodyMedium?.color?.withOpacity(0.4) : null,
                        )),
                    const SizedBox(height: 4.0),
                    GestureDetector(
                      child: Text(
                        '${widget.postViewMedia.postView.community.name}${widget.showInstanceName ? ' · ${fetchInstanceNameFromUrl(widget.postViewMedia.postView.community.actorId)}' : ''}',
                        textScaleFactor: contentFontSizeScaleFactor,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: widget.postViewMedia.postView.read ? theme.textTheme.bodyMedium?.color?.withOpacity(0.4) : theme.textTheme.bodyMedium?.color?.withOpacity(0.75),
                        ),
                      ),
                      onTap: () => onTapCommunityName(context, widget.postViewMedia.postView.community.id),
                    ),
                    const SizedBox(height: 8.0),
                  ],
                ),
                PostCardMetaData(
                  score: widget.postViewMedia.postView.counts.score,
                  voteType: widget.postViewMedia.postView.myVote ?? VoteType.none,
                  comments: widget.postViewMedia.postView.counts.comments,
                  published: widget.postViewMedia.postView.post.published,
                  saved: widget.postViewMedia.postView.saved,
                  distinguised: widget.postViewMedia.postView.post.featuredCommunity,
                )
              ],
            ),
          ),
          if (widget.showThumbnailPreviewOnRight) const SizedBox(width: 8.0),
          if (widget.showThumbnailPreviewOnRight)
            MediaView(
              postView: widget.postViewMedia,
              showFullHeightImages: false,
              hideNsfwPreviews: widget.hideNsfwPreviews,
              viewMode: ViewMode.compact,
            ),
        ],
      ),
    );
  }
}
