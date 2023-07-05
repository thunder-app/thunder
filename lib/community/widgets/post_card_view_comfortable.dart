import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:lemmy_api_client/v3.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:thunder/community/utils/post_card_action_helpers.dart';
import 'package:thunder/community/widgets/post_card_actions.dart';
import 'package:thunder/community/widgets/post_card_metadata.dart';
import 'package:thunder/core/enums/font_scale.dart';
import 'package:thunder/core/models/post_view_media.dart';
import 'package:thunder/shared/media_view.dart';
import 'package:thunder/utils/font_size.dart';
import 'package:thunder/utils/instance.dart';

class PostCardViewComfortable extends StatefulWidget {
  final Function(VoteType) onVoteAction;
  final Function(bool) onSaveAction;

  final PostViewMedia postViewMedia;
  final bool showThumbnailPreviewOnRight;
  final bool hideNsfwPreviews;
  final bool edgeToEdgeImages;
  final bool showTitleFirst;
  final bool showInstanceName;
  final bool showFullHeightImages;
  final bool showVoteActions;
  final bool showSaveAction;
  final bool showTextContent;
  final bool isUserLoggedIn;

  const PostCardViewComfortable({
    super.key,
    required this.postViewMedia,
    required this.showThumbnailPreviewOnRight,
    required this.hideNsfwPreviews,
    required this.edgeToEdgeImages,
    required this.showTitleFirst,
    required this.showInstanceName,
    required this.showFullHeightImages,
    required this.showVoteActions,
    required this.showSaveAction,
    required this.showTextContent,
    required this.isUserLoggedIn,
    required this.onVoteAction,
    required this.onSaveAction,
  });

  @override
  State<PostCardViewComfortable> createState() => _PostCardViewComfortableState();
}

class _PostCardViewComfortableState extends State<PostCardViewComfortable> {
  double titleFontSizeScaleFactor = FontScale.base.textScaleFactor;
  double contentFontSizeScaleFactor = FontScale.base.textScaleFactor;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initPreferences());
  }

  // @override
  // void didUpdateWidget(covariant PostCardViewComfortable oldWidget) {
  //   WidgetsBinding.instance.addPostFrameCallback((_) => _initPreferences());
  //   super.didUpdateWidget(oldWidget);
  // }

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
    final String textContent = widget.postViewMedia.postView.post.body ?? "";

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.showTitleFirst)
            Padding(
              padding: const EdgeInsets.only(left: 12, right: 12, bottom: 4),
              child: Text(widget.postViewMedia.postView.post.name,
                  textScaleFactor: titleFontSizeScaleFactor,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: widget.postViewMedia.postView.read ? theme.textTheme.titleMedium?.color?.withOpacity(0.4) : null,
                  ),
                  softWrap: true),
            ),
          if (widget.edgeToEdgeImages)
            MediaView(
              postView: widget.postViewMedia,
              showFullHeightImages: widget.showFullHeightImages,
              hideNsfwPreviews: widget.hideNsfwPreviews,
              edgeToEdgeImages: widget.edgeToEdgeImages,
            ),
          if (!widget.edgeToEdgeImages)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: MediaView(
                postView: widget.postViewMedia,
                showFullHeightImages: widget.showFullHeightImages,
                hideNsfwPreviews: widget.hideNsfwPreviews,
                edgeToEdgeImages: widget.edgeToEdgeImages,
              ),
            ),
          if (!widget.showTitleFirst)
            Padding(
              padding: const EdgeInsets.only(top: 4.0, bottom: 6.0, left: 12.0, right: 12.0),
              child: Text(widget.postViewMedia.postView.post.name,
                  textScaleFactor: titleFontSizeScaleFactor,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: widget.postViewMedia.postView.read ? theme.textTheme.titleMedium?.color?.withOpacity(0.4) : null,
                  ),
                  softWrap: true),
            ),
          Visibility(
            visible: widget.showTextContent && textContent.isNotEmpty,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 6.0, left: 12.0, right: 12.0),
              child: Text(
                textContent,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                textScaleFactor: contentFontSizeScaleFactor,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: widget.postViewMedia.postView.read ? theme.textTheme.bodyMedium?.color?.withOpacity(0.4) : theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 4.0, left: 12.0, right: 12.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        child: Text(
                          '${widget.postViewMedia.postView.community.name}${widget.showInstanceName ? ' · ${fetchInstanceNameFromUrl(widget.postViewMedia.postView.community.actorId)}' : ''}',
                          textScaleFactor: contentFontSizeScaleFactor,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontSize: theme.textTheme.titleSmall!.fontSize! * 1.05,
                            color: widget.postViewMedia.postView.read ? theme.textTheme.titleSmall?.color?.withOpacity(0.4) : null,
                          ),
                        ),
                        onTap: () => onTapCommunityName(context, widget.postViewMedia.postView.community.id),
                      ),
                      const SizedBox(height: 8.0),
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
                IconButton(
                    icon: const Icon(
                      Icons.more_horiz_rounded,
                      semanticLabel: 'Actions',
                    ),
                    visualDensity: VisualDensity.compact,
                    onPressed: () {
                      showPostActionBottomModalSheet(context, widget.postViewMedia);
                      HapticFeedback.mediumImpact();
                    }),
                if (widget.isUserLoggedIn)
                  PostCardActions(
                    postId: widget.postViewMedia.postView.post.id,
                    voteType: widget.postViewMedia.postView.myVote ?? VoteType.none,
                    saved: widget.postViewMedia.postView.saved,
                    onVoteAction: widget.onVoteAction,
                    onSaveAction: widget.onSaveAction,
                  ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
