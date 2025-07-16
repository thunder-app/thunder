import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:html_unescape/html_unescape_small.dart';

import 'package:thunder/account/account.dart';
import 'package:thunder/core/enums/font_scale.dart';
import 'package:thunder/core/enums/media_type.dart';
import 'package:thunder/core/enums/post_body_view_type.dart';
import 'package:thunder/core/enums/user_type.dart';
import 'package:thunder/post/models/thunder_post.dart';
import 'package:thunder/shared/avatars/community_avatar.dart';
import 'package:thunder/shared/avatars/user_avatar.dart';
import 'package:thunder/shared/chips/community_chip.dart';
import 'package:thunder/shared/chips/user_chip.dart';
import 'package:thunder/shared/media/compact_thumbnail_preview.dart';
import 'package:thunder/shared/text/scalable_text.dart';
import 'package:thunder/thunder/thunder.dart';
import 'package:thunder/utils/global_context.dart';

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
    final showThumbnailPreviewOnRight = context.select<ThunderBloc, bool>((bloc) => bloc.state.showThumbnailPreviewOnRight);

    final media = post.media.first;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: media.mediaType == MediaType.text || showThumbnailPreviewOnRight ? 12.0 : 0.0).copyWith(top: 8.0, right: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (media.mediaType != MediaType.text && !showThumbnailPreviewOnRight) CompactThumbnailPreview(media: media, postId: post.id),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTitleText(context),
                Padding(
                  padding: const EdgeInsets.only(top: 4.0, bottom: 8.0),
                  child: PostBodyAuthorCommunityMetadata(post: post),
                ),
              ],
            ),
          ),
          if (media.mediaType != MediaType.text && showThumbnailPreviewOnRight) CompactThumbnailPreview(media: media, postId: post.id),
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
                Padding(
                  padding: const EdgeInsets.only(top: 4.0, bottom: 8.0),
                  child: PostBodyAuthorCommunityMetadata(post: post),
                ),
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
    final titleFontSizeScale = context.select<ThunderBloc, FontScale>((bloc) => bloc.state.titleFontSizeScale);

    return ScalableText(
      HtmlUnescape().convert(post.name),
      fontScale: titleFontSizeScale,
      style: theme.textTheme.titleMedium,
    );
  }

  /// Builds the expand/collapse button if post has body
  Widget _buildExpandButton(BuildContext context, PostBodyViewType postBodyViewType) {
    final l10n = GlobalContext.l10n;

    final mediaType = post.media.first.mediaType;
    final hasPostBody = post.body?.isNotEmpty == true;

    if (mediaType == MediaType.text && !hasPostBody) return const SizedBox.shrink();
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
    final profileState = context.read<ProfileBloc>().state;

    if (widget.post.creator?.botAccount == true) userGroups.add(UserType.bot);
    if (widget.post.creatorIsModerator ?? false) userGroups.add(UserType.moderator);
    if (widget.post.creatorIsAdmin ?? false) userGroups.add(UserType.admin);
    if (widget.post.creator?.id == profileState.account.userId) userGroups.add(UserType.self);
    if (widget.post.creator?.published.month == DateTime.now().month && widget.post.creator?.published.day == DateTime.now().day) userGroups.add(UserType.birthday);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final creator = widget.post.creator;
    final community = widget.post.community;

    final postBodyShowUserInstance = context.select<ThunderBloc, bool>((bloc) => bloc.state.postBodyShowUserInstance);
    final postBodyShowCommunityInstance = context.select<ThunderBloc, bool>((bloc) => bloc.state.postBodyShowCommunityInstance);

    return Wrap(
      spacing: 6.0,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        UserChip(
          user: creator!,
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
          communityId: community!.id,
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
