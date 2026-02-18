import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/src/foundation/primitives/primitives.dart';
import 'package:thunder/src/features/account/api.dart';
import 'package:thunder/src/features/feed/api.dart';
import 'package:thunder/src/shared/widgets/media/media_type_badge.dart';
import 'package:thunder/src/features/content/presentation/widgets/media/media_view.dart';

/// App adapter for compact media thumbnail previews.
class CompactThumbnailPreview extends StatelessWidget {
  /// The media to display in the thumbnail.
  final Media media;

  /// Whether or not to dim the thumbnail.
  final bool dim;

  /// The post associated with the media.
  final int? postId;

  /// The callback function to navigate to the post.
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
    final hideNsfwPreviews = context.select<FeedPreferencesCubit, bool>(
      (cubit) => cubit.state.hideNsfwPreviews,
    );
    final markPostReadOnMediaView = context.select<FeedPreferencesCubit, bool>(
      (cubit) => cubit.state.markPostReadOnMediaView,
    );

    final isUserLoggedIn = context.select((ProfileBloc bloc) => bloc.state.isLoggedIn);

    return RepaintBoundary(
      child: ExcludeSemantics(
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
      ),
    );
  }
}
