import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/account/account.dart';
import 'package:thunder/shared/media/media_type_badge.dart';
import 'package:thunder/core/enums/view_mode.dart';
import 'package:thunder/core/models/media.dart';
import 'package:thunder/shared/media/media_view.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';

/// Displays a compact thumbnail preview for a post card.
class CompactThumbnailPreview extends StatelessWidget {
  /// The media to display in the thumbnail
  final Media media;

  /// Whether or not to dim the thumbnail. This is used when a post has been read.
  /// This value can be overridden for special cases (e.g., viewing user account)
  final bool dim;

  /// The post associated with the media
  final int? postId;

  /// The callback function to navigate to the post
  final void Function()? navigateToPost;

  const CompactThumbnailPreview({
    super.key,
    required this.media,
    this.dim = false,
    this.postId,
    this.navigateToPost,
  });

  @override
  Widget build(BuildContext context) {
    final state = context.select((ThunderBloc bloc) => (bloc.state.hideNsfwPreviews, bloc.state.markPostReadOnMediaView));
    final hideNsfwPreviews = state.$1;
    final markPostReadOnMediaView = state.$2;

    final isUserLoggedIn = context.select((ProfileBloc bloc) => bloc.state.isLoggedIn);

    return ExcludeSemantics(
      child: Stack(
        alignment: AlignmentDirectional.bottomEnd,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
            child: MediaView(
              media: media,
              postId: postId,
              showFullHeightImages: false,
              hideNsfwPreviews: hideNsfwPreviews,
              markPostReadOnMediaView: markPostReadOnMediaView,
              viewMode: ViewMode.compact,
              isUserLoggedIn: isUserLoggedIn,
              navigateToPost: navigateToPost,
              read: dim,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 6.0),
            child: MediaTypeBadge(mediaType: media.mediaType, dim: dim),
          ),
        ],
      ),
    );
  }
}
