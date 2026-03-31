import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/src/foundation/primitives/primitives.dart';
import 'package:thunder/src/features/session/api.dart';
import 'package:thunder/src/shared/identity/widgets/avatars/community_avatar.dart';
import 'package:thunder/src/shared/identity/widgets/avatars/user_avatar.dart';
import 'package:thunder/src/shared/widgets/chips/community_chip.dart';
import 'package:thunder/src/shared/widgets/chips/user_chip.dart';
import 'package:thunder/src/shared/content/widgets/media/compact_thumbnail_preview.dart';
import 'package:thunder/packages/ui/ui.dart' show ScalableText;
import 'package:thunder/src/features/settings/api.dart';
import 'package:thunder/src/features/feed/api.dart';
import 'package:thunder/src/foundation/config/global_context.dart';
import 'package:thunder/src/features/post/presentation/widgets/post_flair_tags.dart';

/// Displays the title and related information for a given post.
///
/// This includes the post title alongside the post's creator and community metadata.
class PostBodyTitle extends StatelessWidget {
  /// The post to display the title and related information for
  final ThunderPost post;

  /// The type of view for the post body
  final PostBodyViewType postBodyViewType;

  /// Whether the post body is in expanded mode
  final bool expanded;

  /// Callback function which triggers when the post title is tapped
  final Function onToggleExpand;

  const PostBodyTitle({
    super.key,
    required this.post,
    required this.postBodyViewType,
    required this.expanded,
    required this.onToggleExpand,
  });

  @override
  Widget build(BuildContext context) {
    return switch (postBodyViewType) {
      PostBodyViewType.condensed => _buildCondensedTitle(context),
      PostBodyViewType.expanded => _buildExpandedTitle(context),
    };
  }

  /// Builds the title section for condensed view
  Widget _buildCondensedTitle(BuildContext context) {
    final showThumbnailPreviewOnRight = context.select<FeedPreferencesCubit, bool>((cubit) => cubit.state.showThumbnailPreviewOnRight);

    final media = post.media.firstOrNull;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: media?.mediaType == MediaType.text || media == null || showThumbnailPreviewOnRight ? 12.0 : 0.0).copyWith(top: 8.0, right: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (media != null && media.mediaType != MediaType.text && !showThumbnailPreviewOnRight) CompactThumbnailPreview(media: media, postId: post.id),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTitleText(context),
                _buildAuthorCommunityAndFlairs(),
              ],
            ),
          ),
          if (media != null && media.mediaType != MediaType.text && showThumbnailPreviewOnRight) CompactThumbnailPreview(media: media, postId: post.id),
          _buildExpandButton(context, postBodyViewType),
        ],
      ),
    );
  }

  /// Builds the title section for expanded view
  Widget _buildExpandedTitle(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0).copyWith(top: 8.0, right: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTitleText(context),
                _buildAuthorCommunityAndFlairs(),
              ],
            ),
          ),
          _buildExpandButton(context, postBodyViewType),
        ],
      ),
    );
  }

  /// Builds the title text widget
  Widget _buildTitleText(BuildContext context) {
    final theme = Theme.of(context);
    final titleFontSizeScale = context.select<ThemePreferencesCubit, FontScale>((cubit) => cubit.state.titleFontSizeScale);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ScalableText(
          post.name,
          textScaleFactor: titleFontSizeScale.textScaleFactor,
          style: theme.textTheme.titleMedium,
        ),
      ],
    );
  }

  Widget _buildAuthorCommunityAndFlairs() {
    return Padding(
      padding: const EdgeInsets.only(top: 4.0, bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PostBodyAuthorCommunityMetadata(post: post),
          if (post.flairs.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: PostFlairTags(flairs: post.flairs),
            ),
        ],
      ),
    );
  }

  /// Builds the expand/collapse button if post has body
  Widget _buildExpandButton(BuildContext context, PostBodyViewType postBodyViewType) {
    final l10n = GlobalContext.l10n;

    final mediaType = post.media.firstOrNull?.mediaType;
    final hasPostBody = post.body?.isNotEmpty == true;

    if (mediaType == MediaType.text && !hasPostBody) return const SizedBox.shrink();
    if (mediaType == null && !hasPostBody) return const SizedBox.shrink();
    if (postBodyViewType == PostBodyViewType.condensed && !hasPostBody) return const SizedBox.shrink();

    return IconButton(
      visualDensity: VisualDensity.compact,
      icon: Icon(
        expanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
        semanticLabel: expanded ? l10n.collapsePost : l10n.expandPost,
      ),
      onPressed: () => onToggleExpand(),
    );
  }
}

/// Contains metadata related to the post's creator and community.
class PostBodyAuthorCommunityMetadata extends StatefulWidget {
  /// The post to display metadata for
  final ThunderPost post;

  const PostBodyAuthorCommunityMetadata({super.key, required this.post});

  @override
  State<PostBodyAuthorCommunityMetadata> createState() => _PostBodyAuthorCommunityMetadataState();
}

class _PostBodyAuthorCommunityMetadataState extends State<PostBodyAuthorCommunityMetadata> {
  List<UserType> userGroups = [];

  @override
  void initState() {
    super.initState();
    determineUserGroups();
  }

  @override
  void didUpdateWidget(PostBodyAuthorCommunityMetadata oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.post.creator?.id != widget.post.creator?.id) {
      userGroups.clear();
      determineUserGroups();
    }
  }

  void determineUserGroups() {
    final account = resolveEffectiveAccount(context);

    if (widget.post.creator?.botAccount == true) userGroups.add(UserType.bot);
    if (widget.post.creatorIsModerator ?? false) userGroups.add(UserType.moderator);
    if (widget.post.creatorIsAdmin ?? false) userGroups.add(UserType.admin);
    if (widget.post.creator?.id == account.userId) userGroups.add(UserType.self);
    if (widget.post.creator?.published.month == DateTime.now().month && widget.post.creator?.published.day == DateTime.now().day) userGroups.add(UserType.birthday);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final creator = widget.post.creator;
    final community = widget.post.community;

    // Return empty widget if creator or community is null
    if (creator == null || community == null) {
      return const SizedBox.shrink();
    }

    final postBodyShowUserInstance = context.select<FeedPreferencesCubit, bool>((cubit) => cubit.state.postBodyShowUserInstance);
    final postBodyShowCommunityInstance = context.select<FeedPreferencesCubit, bool>((cubit) => cubit.state.postBodyShowCommunityInstance);

    return Wrap(
      spacing: 6.0,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        UserChip(
          user: creator,
          personAvatar: UserAvatar(user: creator, radius: 8, thumbnailSize: 20, format: 'png'),
          userGroups: userGroups,
          includeInstance: postBodyShowUserInstance,
        ),
        Icon(
          Icons.trending_flat_rounded,
          size: 22,
          color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
        ),
        CommunityChip(
          communityId: community.id,
          communityAvatar: CommunityAvatar(community: community, radius: 8, thumbnailSize: 20, format: 'png'),
          communityName: community.name,
          communityTitle: community.title,
          communityUrl: community.actorId,
          includeInstance: postBodyShowCommunityInstance,
        )
      ],
    );
  }
}
