// Flutter imports
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports
import 'package:expandable/expandable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports
import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/features/post/post.dart';
import 'package:thunder/src/shared/utils/colors.dart';
import 'package:thunder/src/app/utils/navigation.dart';
import 'package:thunder/src/features/community/community.dart';
import 'package:thunder/src/features/feed/feed.dart';
import 'package:thunder/src/app/cubits/feed_ui_cubit/feed_ui_cubit.dart';
import 'package:thunder/src/core/enums/font_scale.dart';
import 'package:thunder/src/core/enums/media_type.dart';
import 'package:thunder/src/core/enums/post_body_view_type.dart';
import 'package:thunder/src/core/enums/view_mode.dart';
import 'package:thunder/src/shared/markdown/common_markdown_body.dart';
import 'package:thunder/src/shared/conditional_parent_widget.dart';
import 'package:thunder/src/shared/cross_posts.dart';
import 'package:thunder/src/shared/widgets/media/media_view.dart';
import 'package:thunder/src/shared/reply_to_preview_actions.dart';
import 'package:thunder/src/shared/widgets/text/scalable_text.dart';
import 'package:thunder/src/app/cubits/feed_preferences_cubit/feed_preferences_cubit.dart';
import 'package:thunder/src/app/cubits/theme_preferences_cubit/theme_preferences_cubit.dart';
import 'package:thunder/src/features/user/user.dart';

/// A widget that displays the body of a post. This includes the title, body, media, and metadata.
///
/// This is typically used in the post page, but can also be used in other places where a post is displayed (e.g., create comment page).
class PostBody extends StatefulWidget {
  /// The post to display
  final ThunderPost post;

  /// The cross posts related to the post
  final List<ThunderPost>? crossPosts;

  /// Whether to show the source of the post
  final bool viewSource;

  /// Callback function which triggers when the view source is toggled
  final void Function()? onViewSourceToggled;

  /// Whether to show the quick post action bar
  final bool showQuickPostActionBar;

  /// Whether the post body is selectable
  final bool selectable;

  /// Whether to show the reply editor buttons (e.g., "Reply" and "View Source")
  final bool showReplyEditorButtons;

  /// Callback function which triggers when the selection changes
  final void Function(String? selection)? onSelectionChanged;

  /// Whether to show the post body in compact mode initially
  final bool showCompactPostBody;

  const PostBody({
    super.key,
    required this.post,
    required this.crossPosts,
    required this.viewSource,
    this.onViewSourceToggled,
    this.showQuickPostActionBar = true,
    this.selectable = false,
    this.showReplyEditorButtons = false,
    this.onSelectionChanged,
    this.showCompactPostBody = false,
  });

  @override
  State<PostBody> createState() => _PostBodyState();
}

class _PostBodyState extends State<PostBody> with SingleTickerProviderStateMixin {
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
    final userId = context.read<ProfileBloc>().state.account.userId;
    isOwnPost = widget.post.creator?.id == userId;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final hideNsfwPreviews = context.select<FeedPreferencesCubit, bool>((cubit) => cubit.state.hideNsfwPreviews);
    final showCrossPosts = context.select<FeedPreferencesCubit, bool>((cubit) => cubit.state.showCrossPosts);
    final postBodyViewType = context.select<FeedPreferencesCubit, PostBodyViewType>((cubit) => cubit.state.postBodyViewType);
    final contentFontSizeScale = context.select<ThemePreferencesCubit, FontScale>((cubit) => cubit.state.contentFontSizeScale);

    final post = widget.post;
    final media = post.media.first;

    List<Widget> children = [
      PostBodyTitle(
        post: post,
        postBodyViewType: postBodyViewType,
        expanded: expandableController.expanded,
        onToggleExpand: () {
          expandableController.toggle();
          setState(() {});
        },
      ),
    ];

    if (postBodyViewType != PostBodyViewType.condensed && media.mediaType != MediaType.text) {
      children.add(
        Expandable(
          controller: expandableController,
          collapsed: SizedBox.shrink(),
          expanded: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
            child: MediaView(
              viewMode: ViewMode.comfortable,
              media: media,
              postId: post.id,
              showFullHeightImages: true,
              allowUnconstrainedImageHeight: true,
              hideNsfwPreviews: hideNsfwPreviews,
            ),
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
            viewSource: widget.viewSource,
            gradientBackgroundColor: widget.showReplyEditorButtons ? getBackgroundColor(context) : null,
            onTap: () {
              expandableController.toggle();
              setState(() {});
            },
          ),
          expanded: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
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
                      fontScale: contentFontSizeScale,
                    )
                  : CommonMarkdownBody(body: post.body ?? '', nsfw: post.nsfw && hideNsfwPreviews),
            ),
          ),
        ),
      );
    }

    children.add(
      PostBodyMetadata(
        languageId: post.languageId,
        commentCount: post.comments,
        unreadCommentCount: post.unreadComments,
        dateTime: post.updated?.toIso8601String() ?? post.published.toIso8601String(),
        hasBeenEdited: post.updated != null,
        url: media.mediaType != MediaType.image ? post.url : null,
      ),
    );

    if (showCrossPosts && sortedCrossPosts.isNotEmpty) {
      children.add(CrossPosts(originalPost: post, crossPosts: sortedCrossPosts));
    }

    if (widget.showQuickPostActionBar) {
      children.addAll([
        (showCrossPosts && sortedCrossPosts.isNotEmpty) ? SizedBox(height: 8.0) : Divider(),
        PostBodyActionsBar(
          vote: post.myVote,
          upvotes: post.upvotes,
          downvotes: post.downvotes,
          saved: post.saved ?? false,
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
                if (post != null) context.read<FeedBloc>().add(FeedItemUpdatedEvent(post: post));

                switch (postAction) {
                  case PostAction.hide:
                    context.read<FeedUiCubit>().dismissHiddenPost(post!.id);
                    break;
                  default:
                    break;
                }

                switch (userAction) {
                  case UserAction.block:
                    context.read<FeedUiCubit>().dismissBlocked(userId: post!.creator!.id);
                    break;
                  default:
                    break;
                }

                switch (communityAction) {
                  case CommunityAction.block:
                    context.read<FeedUiCubit>().dismissBlocked(communityId: post!.community!.id);
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
            onCommentSuccess: (comment, userChanged) {
              if (!userChanged) {
                context.read<PostBloc>().add(CommentItemInsertedEvent(comment: comment));
              }
            },
          ),
        ),
      ]);
    }

    if (widget.showReplyEditorButtons && post.body?.isNotEmpty == true) {
      children.add(
        ReplyToPreviewActions(
          text: post.body!,
          viewSource: widget.viewSource,
          onViewSourceToggled: widget.onViewSourceToggled,
        ),
      );
    }

    return ExpandableNotifier(
      controller: expandableController,
      child: Padding(
        padding: EdgeInsets.only(bottom: widget.showReplyEditorButtons && post.body?.isNotEmpty == true ? 0.0 : 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }
}
