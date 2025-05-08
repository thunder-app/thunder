// Flutter imports
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports
import 'package:expandable/expandable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:html_unescape/html_unescape_small.dart';

// Project imports
import 'package:thunder/account/account.dart';
import 'package:thunder/community/widgets/post_card_metadata.dart';
import 'package:thunder/core/enums/font_scale.dart';
import 'package:thunder/core/models/media.dart';
import 'package:thunder/core/models/models.dart';
import 'package:thunder/shared/snackbar.dart';
import 'package:thunder/utils/global_context.dart';
import 'package:thunder/utils/navigation.dart';
import 'package:thunder/community/enums/community_action.dart';
import 'package:thunder/feed/bloc/feed_bloc.dart';
import 'package:thunder/shared/media/media_type_badge.dart';
import 'package:thunder/core/enums/media_type.dart';
import 'package:thunder/core/enums/post_body_view_type.dart';
import 'package:thunder/core/enums/user_type.dart';
import 'package:thunder/core/enums/view_mode.dart';
import 'package:thunder/post/post.dart';
import 'package:thunder/shared/avatars/community_avatar.dart';
import 'package:thunder/shared/avatars/user_avatar.dart';
import 'package:thunder/shared/chips/community_chip.dart';
import 'package:thunder/shared/chips/user_chip.dart';
import 'package:thunder/shared/common_markdown_body.dart';
import 'package:thunder/shared/conditional_parent_widget.dart';
import 'package:thunder/shared/cross_posts.dart';
import 'package:thunder/shared/media/media_view.dart';
import 'package:thunder/shared/reply_to_preview_actions.dart';
import 'package:thunder/shared/text/scalable_text.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/user/enums/user_action.dart';
import 'package:thunder/utils/numbers.dart';

/// A widget that displays the body of a post. This includes the title, body, media, and metadata.
///
/// This is typically used in the post page, but can also be used in other places where a post is displayed (e.g., create comment page).
class PostBody extends StatefulWidget {
  final ThunderPost post;
  final List<ThunderPost>? crossPosts;
  final bool viewSource;
  final void Function()? onViewSourceToggled;
  final bool showQuickPostActionBar;
  final bool showExpandableButton;
  final bool selectable;
  final bool showReplyEditorButtons;
  final void Function(String? selection)? onSelectionChanged;
  final bool showCompactPostBody;

  const PostBody({
    super.key,
    required this.post,
    required this.crossPosts,
    required this.viewSource,
    this.onViewSourceToggled,
    this.showQuickPostActionBar = true,
    this.showExpandableButton = true,
    this.selectable = false,
    this.showReplyEditorButtons = false,
    this.onSelectionChanged,
    this.showCompactPostBody = false,
  });

  @override
  State<PostBody> createState() => _PostBodyState();
}

class _PostBodyState extends State<PostBody> with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  late ExpandableController expandableController;
  final FocusNode _selectableRegionFocusNode = FocusNode();

  // Add these variables to store computed values
  late List<ThunderPost> sortedCrossPosts = [];
  late bool isOwnPost = false;

  @override
  void initState() {
    super.initState();
    expandableController = ExpandableController(initialExpanded: !widget.showCompactPostBody);
    _initializeData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateIsOwnPost();
  }

  @override
  void didUpdateWidget(PostBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.post != widget.post || oldWidget.crossPosts != widget.crossPosts) {
      _initializeData();
    }

    if (oldWidget.post.creator?.id != widget.post.creator?.id) {
      _updateIsOwnPost();
    }
  }

  void _initializeData() {
    // Initialize sorted cross posts
    sortedCrossPosts = List.from(widget.crossPosts ?? [])..sort((a, b) => b.upvotes!.compareTo(a.upvotes!));
  }

  void _updateIsOwnPost() {
    final userId = context.read<ProfileBloc>().state.account?.userId;
    isOwnPost = widget.post.creator?.id == userId;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final theme = Theme.of(context);
    final isUserLoggedIn = context.watch<ProfileBloc>().state.isLoggedIn;

    final state = context.read<ThunderBloc>().state;
    final hideNsfwPreviews = state.hideNsfwPreviews;
    final markPostReadOnMediaView = state.markPostReadOnMediaView;
    final showCrossPosts = state.showCrossPosts;

    final post = widget.post;

    List<Widget> children = [
      PostBodyTitle(
        post: post,
        expandableController: expandableController,
        onToggleExpand: () => setState(() {}),
        showExpandableButton: widget.showExpandableButton,
      ),
    ];

    if (state.postBodyViewType != PostBodyViewType.condensed && post.media.first.mediaType != MediaType.text) {
      children.add(
        Expandable(
          controller: expandableController,
          collapsed: Container(),
          expanded: MediaView(
            viewMode: ViewMode.comfortable,
            media: post.media.first,
            postId: post.id,
            showFullHeightImages: true,
            allowUnconstrainedImageHeight: true,
            hideNsfwPreviews: hideNsfwPreviews,
            markPostReadOnMediaView: markPostReadOnMediaView,
            isUserLoggedIn: isUserLoggedIn,
          ),
        ),
      );
    }

    if (post.body?.isNotEmpty == true) {
      children.add(
        Expandable(
          controller: expandableController,
          collapsed: PostBodyPreview(
            post: post,
            expandableController: expandableController,
            onTapped: () => setState(() {}),
            viewSource: widget.viewSource,
          ),
          expanded: Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
            child: ConditionalParentWidget(
              condition: widget.selectable,
              parentBuilder: (child) {
                return SelectableRegion(
                  focusNode: _selectableRegionFocusNode,
                  // See comments on [SelectableTextModal] regarding the next two properties
                  selectionControls: Platform.isIOS ? cupertinoTextSelectionHandleControls : materialTextSelectionHandleControls,
                  contextMenuBuilder: (context, selectableRegionState) {
                    return AdaptiveTextSelectionToolbar.buttonItems(
                      buttonItems: selectableRegionState.contextMenuButtonItems,
                      anchors: selectableRegionState.contextMenuAnchors,
                    );
                  },
                  onSelectionChanged: (value) => widget.onSelectionChanged?.call(value?.plainText),
                  child: child,
                );
              },
              child: widget.viewSource
                  ? ScalableText(
                      post.body ?? '',
                      style: theme.textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
                      fontScale: state.contentFontSizeScale,
                    )
                  : CommonMarkdownBody(body: post.body ?? ''),
            ),
          ),
        ),
      );
    }

    children.add(
      PostMetadata(
        commentCount: post.comments,
        unreadCommentCount: post.unreadComments,
        dateTime: post.updated != null ? post.updated?.toIso8601String() : post.created.toIso8601String(),
        hasBeenEdited: post.updated != null ? true : false,
      ),
    );

    if (showCrossPosts && sortedCrossPosts.isNotEmpty) {
      children.addAll([
        const Divider(),
        CrossPosts(
          crossPosts: sortedCrossPosts,
          originalPost: post,
        ),
      ]);
    }

    if (widget.showQuickPostActionBar) {
      children.addAll([
        const Divider(),
        PostQuickActionsBar(
          vote: post.voteType,
          upvotes: post.upvotes,
          downvotes: post.downvotes,
          saved: post.saved,
          locked: post.locked,
          isOwnPost: isOwnPost,
          onVote: (int score) {
            HapticFeedback.mediumImpact();
            context.read<PostBloc>().add(VotePostEvent(postId: post.id, score: score));
          },
          onSave: (bool saved) {
            HapticFeedback.mediumImpact();
            context.read<PostBloc>().add(SavePostEvent(postId: post.id, save: saved));
          },
          onShare: () {
            showPostActionBottomModalSheet(
              context,
              post,
              page: GeneralPostAction.share,
              onAction: ({postAction, userAction, communityAction, post}) {
                if (postAction == null && userAction == null && communityAction == null) return;

                switch (postAction) {
                  case PostAction.hide:
                    context.read<FeedBloc>().add(FeedDismissHiddenPostEvent(postId: post!.id));
                    break;
                  default:
                    break;
                }

                switch (userAction) {
                  case UserAction.block:
                    context.read<FeedBloc>().add(FeedDismissBlockedEvent(userId: post!.creator!.id));
                    break;
                  default:
                    break;
                }

                switch (communityAction) {
                  case CommunityAction.block:
                    context.read<FeedBloc>().add(FeedDismissBlockedEvent(communityId: post!.community!.id));
                    break;
                  default:
                    break;
                }
              },
            );
          },
          onEdit: () async {
            navigateToCreatePostPage(
              context,
              communityId: post.community?.id,
              community: post.community,
              post: post,
              onPostSuccess: (ThunderPost post, _) {
                context.read<PostBloc>().add(PostUpdatedEvent(post: post));
              },
            );
          },
          onReply: () async => navigateToCreateCommentPage(
            context,
            post: post,
            onCommentSuccess: (commentView, userChanged) {
              if (!userChanged) {
                context.read<PostBloc>().add(CommentItemUpdatedEvent(commentView: commentView));
              }
            },
          ),
        ),
      ]);
    }

    if (widget.showReplyEditorButtons && post.body?.isNotEmpty == true) {
      children.add(
        ReplyToPreviewActions(
          onViewSourceToggled: widget.onViewSourceToggled,
          viewSource: widget.viewSource,
          text: post.body!,
        ),
      );
    }

    return ExpandableNotifier(
      controller: expandableController,
      child: Padding(
        padding: EdgeInsets.only(left: 12.0, right: 12.0, bottom: widget.showReplyEditorButtons && post.body?.isNotEmpty == true ? 0.0 : 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }
}

class PostBodyTitle extends StatelessWidget {
  final ThunderPost post;

  final ExpandableController expandableController;

  final Function onToggleExpand;

  final bool showExpandableButton;

  const PostBodyTitle({
    super.key,
    required this.post,
    required this.expandableController,
    required this.onToggleExpand,
    this.showExpandableButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final postBodyViewType = context.select<ThunderBloc, PostBodyViewType>((bloc) => bloc.state.postBodyViewType);
    final showThumbnailPreviewOnRight = context.select<ThunderBloc, bool>((bloc) => bloc.state.showThumbnailPreviewOnRight);
    final titleFontSizeScale = context.select<ThunderBloc, FontScale>((bloc) => bloc.state.titleFontSizeScale);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (postBodyViewType == PostBodyViewType.condensed && !showThumbnailPreviewOnRight && post.media.first.mediaType != MediaType.text)
            PostBodyMediaPreview(media: post.media.first, postId: post.id),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ScalableText(
                  HtmlUnescape().convert(post.title),
                  fontScale: titleFontSizeScale,
                  style: theme.textTheme.titleMedium,
                ),
                if (post.media.first.mediaType == MediaType.link && postBodyViewType == PostBodyViewType.condensed)
                  Text(
                    Uri.tryParse(post.url)?.host.replaceFirst('www.', '') ?? '',
                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                  ),
                Padding(
                  padding: const EdgeInsets.only(top: 4.0, bottom: 8.0),
                  child: PostBodyAuthorCommunityMetadata(post: post),
                ),
              ],
            ),
          ),
          if (postBodyViewType == PostBodyViewType.condensed && showThumbnailPreviewOnRight && post.media.first.mediaType != MediaType.text)
            PostBodyMediaPreview(media: post.media.first, postId: post.id),
          if ((postBodyViewType != PostBodyViewType.condensed || post.media.first.mediaType == MediaType.text) && showExpandableButton)
            IconButton(
              visualDensity: VisualDensity.compact,
              icon: Icon(
                expandableController.expanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                semanticLabel: expandableController.expanded ? l10n.collapsePost : l10n.expandPost,
              ),
              onPressed: () {
                expandableController.toggle();
                onToggleExpand();
              },
            ),
        ],
      ),
    );
  }
}

class PostBodyMediaPreview extends StatelessWidget {
  final Media media;

  final int postId;

  const PostBodyMediaPreview({super.key, required this.media, required this.postId});

  @override
  Widget build(BuildContext context) {
    final isUserLoggedIn = context.watch<ProfileBloc>().state.isLoggedIn;

    final state = context.read<ThunderBloc>().state;
    final hideNsfwPreviews = state.hideNsfwPreviews;
    final markPostReadOnMediaView = state.markPostReadOnMediaView;

    return Stack(
      alignment: AlignmentDirectional.bottomEnd,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4),
          child: MediaView(
            media: media,
            postId: postId,
            showFullHeightImages: false,
            hideNsfwPreviews: hideNsfwPreviews,
            markPostReadOnMediaView: markPostReadOnMediaView,
            viewMode: ViewMode.compact,
            isUserLoggedIn: isUserLoggedIn,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 6, bottom: 0.0),
          child: MediaTypeBadge(mediaType: media.mediaType, dim: false),
        ),
      ],
    );
  }
}

/// Contains metadata related to the post's creator and community.
class PostBodyAuthorCommunityMetadata extends StatefulWidget {
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

    if (widget.post.creator?.bot == true) userGroups.add(UserType.bot);
    if (widget.post.creatorIsModerator ?? false) userGroups.add(UserType.moderator);
    if (widget.post.creatorIsAdmin ?? false) userGroups.add(UserType.admin);
    if (widget.post.creator?.id == profileState.account?.userId) userGroups.add(UserType.self);
    if (widget.post.creator?.created.month == DateTime.now().month && widget.post.creator?.created.day == DateTime.now().day) userGroups.add(UserType.birthday);
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
          personAvatar: UserAvatar(user: creator, radius: 10, thumbnailSize: 20, format: 'png'),
          userGroups: userGroups,
          includeInstance: true,
          // includeInstance: postBodyShowUserInstance,
        ),
        Icon(
          Icons.arrow_forward,
          size: 16,
          color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
        ),
        CommunityChip(
          communityId: community!.id,
          communityAvatar: CommunityAvatar(community: community, radius: 10, thumbnailSize: 20, format: 'png'),
          communityName: community.name,
          communityTitle: community.title,
          communityUrl: community.url,
          includeInstance: postBodyShowCommunityInstance,
        )
      ],
    );
  }
}

/// Contains metadata related to a given post, usually displayed at the bottom of the post body.
///
/// This includes the total number of comments and the date/time the post was created or updated.
class PostMetadata extends StatelessWidget {
  /// The number of comments on the post. If null, no comment count will be displayed.
  final int? commentCount;

  /// The number of unread comments on the post. If null, no unread comment count will be displayed.
  final int? unreadCommentCount;

  /// The date/time the post was created or updated. This string should conform to ISO-8601 format.
  final String? dateTime;

  /// Whether or not the post has been edited. This determines the icon for the [dateTime] field.
  final bool? hasBeenEdited;

  const PostMetadata({
    super.key,
    this.commentCount,
    this.unreadCommentCount,
    this.dateTime,
    this.hasBeenEdited = false,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 4.0,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        CommentCountPostCardMetaData(commentCount: commentCount, unreadCommentCount: unreadCommentCount ?? 0, dim: false),
        DateTimePostCardMetaData(dateTime: dateTime!, dim: false, edited: hasBeenEdited ?? false)
      ],
    );
  }
}

/// A widget that displays the quick actions bar for a post
class PostQuickActionsBar extends StatelessWidget {
  const PostQuickActionsBar({
    super.key,
    this.vote,
    this.upvotes,
    this.downvotes,
    this.saved = false,
    this.locked = false,
    this.isOwnPost = false,
    this.onVote,
    this.onSave,
    this.onShare,
    this.onReply,
    this.onEdit,
  });

  /// The number of upvotes the post has
  final int? upvotes;

  /// The number of downvotes the post has
  final int? downvotes;

  /// The vote of the user for the given post. If 1, the user has voted up. If -1, the user has voted down.
  final int? vote;

  /// Whether the user has saved the post
  final bool saved;

  /// Whether the post is locked
  final bool locked;

  /// Whether the user is the creator of the post
  final bool isOwnPost;

  /// Called when the user wants to vote on the post
  final Function(int score)? onVote;

  /// Called when the user wants to save the post
  final Function(bool save)? onSave;

  /// Called when the user wants to share the post
  final Function()? onShare;

  /// Called when the user wants to reply to the post
  final Function()? onReply;

  /// Called when the user wants to edit the post
  final Function()? onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = GlobalContext.l10n;

    return BlocBuilder<ProfileBloc, ProfileState>(
      buildWhen: (previous, current) => previous.isLoggedIn != current.isLoggedIn,
      builder: (context, state) {
        bool isUserLoggedIn = state.isLoggedIn;
        bool downvotesEnabled = state.downvotesEnabled;
        bool showScores = state.getSiteResponse?.myUser?.localUserView.localUser.showScores ?? true;

        return Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: TextButton(
                onPressed: isUserLoggedIn ? () => onVote?.call(vote == 1 ? 0 : 1) : null,
                style: TextButton.styleFrom(
                  fixedSize: const Size.fromHeight(40),
                  foregroundColor: vote == 1 ? theme.textTheme.bodyMedium?.color : context.read<ThunderBloc>().state.upvoteColor.color,
                  padding: EdgeInsets.zero,
                ),
                child: Wrap(
                  spacing: 4.0,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Icon(
                      Icons.arrow_upward_rounded,
                      semanticLabel: vote == 1 ? l10n.upvoted : l10n.upvote,
                      color: isUserLoggedIn ? (vote == 1 ? context.read<ThunderBloc>().state.upvoteColor.color : theme.textTheme.bodyMedium?.color) : null,
                      size: 24.0,
                    ),
                    if (showScores)
                      Text(
                        formatNumberToK(upvotes ?? 0),
                        style: TextStyle(
                          color: isUserLoggedIn ? (vote == 1 ? context.read<ThunderBloc>().state.upvoteColor.color : theme.textTheme.bodyMedium?.color) : null,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            if (downvotesEnabled)
              Expanded(
                child: TextButton(
                  onPressed: isUserLoggedIn ? () => onVote?.call(vote == -1 ? 0 : -1) : null,
                  style: TextButton.styleFrom(
                    fixedSize: const Size.fromHeight(40),
                    foregroundColor: vote == -1 ? theme.textTheme.bodyMedium?.color : context.read<ThunderBloc>().state.downvoteColor.color,
                    padding: EdgeInsets.zero,
                  ),
                  child: Wrap(
                    spacing: 4.0,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Icon(
                        Icons.arrow_downward_rounded,
                        semanticLabel: vote == -1 ? l10n.downvoted : l10n.downvote,
                        color: isUserLoggedIn ? (vote == -1 ? context.read<ThunderBloc>().state.downvoteColor.color : theme.textTheme.bodyMedium?.color) : null,
                        size: 24.0,
                      ),
                      if (showScores)
                        Text(
                          formatNumberToK(downvotes ?? 0),
                          style: TextStyle(
                            color: isUserLoggedIn ? (vote == -1 ? context.read<ThunderBloc>().state.downvoteColor.color : theme.textTheme.bodyMedium?.color) : null,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            Expanded(
              child: IconButton(
                onPressed: isUserLoggedIn ? () => onSave?.call(!saved) : null,
                style: IconButton.styleFrom(foregroundColor: saved ? null : context.read<ThunderBloc>().state.saveColor.color),
                icon: Icon(
                  saved ? Icons.star_rounded : Icons.star_border_rounded,
                  semanticLabel: saved ? l10n.saved : l10n.save,
                  color: isUserLoggedIn ? (saved ? context.read<ThunderBloc>().state.saveColor.color : theme.textTheme.bodyMedium?.color) : null,
                ),
              ),
            ),
            if (locked)
              Expanded(
                child: IconButton(
                  onPressed: () => showSnackbar(l10n.postLocked),
                  icon: Icon(Icons.lock, semanticLabel: l10n.postLocked, color: theme.colorScheme.error),
                ),
              ),
            if (!locked && isOwnPost)
              Expanded(
                child: IconButton(
                  onPressed: isUserLoggedIn ? () => onEdit?.call() : null,
                  icon: Icon(Icons.edit_rounded, semanticLabel: l10n.edit),
                ),
              ),
            if (!locked && !isOwnPost)
              Expanded(
                child: IconButton(
                  onPressed: isUserLoggedIn ? () => onReply?.call() : null,
                  icon: Icon(Icons.reply_rounded, semanticLabel: l10n.reply(0)),
                ),
              ),
            Expanded(
              child: IconButton(
                onPressed: () => onShare?.call(),
                icon: Icon(Icons.share_rounded, semanticLabel: l10n.share),
              ),
            ),
          ],
        );
      },
    );
  }
}
