// Flutter imports
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports
import 'package:expandable/expandable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports
import 'package:thunder/account/account.dart';
import 'package:thunder/core/models/models.dart';
import 'package:thunder/post/widgets/post_body/post_body_action_bar.dart';
import 'package:thunder/post/widgets/post_body/post_body_metadata.dart';
import 'package:thunder/post/widgets/post_body/post_body_title.dart';
import 'package:thunder/utils/colors.dart';
import 'package:thunder/utils/navigation.dart';
import 'package:thunder/community/enums/community_action.dart';
import 'package:thunder/feed/bloc/feed_bloc.dart';
import 'package:thunder/core/enums/media_type.dart';
import 'package:thunder/core/enums/post_body_view_type.dart';
import 'package:thunder/core/enums/view_mode.dart';
import 'package:thunder/post/post.dart';
import 'package:thunder/shared/common_markdown_body.dart';
import 'package:thunder/shared/conditional_parent_widget.dart';
import 'package:thunder/shared/cross_posts.dart';
import 'package:thunder/shared/media/media_view.dart';
import 'package:thunder/shared/reply_to_preview_actions.dart';
import 'package:thunder/shared/text/scalable_text.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/user/enums/user_action.dart';

/// A widget that displays the body of a post. This includes the title, body, media, and metadata.
///
/// This is typically used in the post page, but can also be used in other places where a post is displayed (e.g., create comment page).
class PostBody extends StatefulWidget {
  final ThunderPost post;
  final List<ThunderPost>? crossPosts;
  final bool viewSource;
  final void Function()? onViewSourceToggled;
  final bool showQuickPostActionBar;
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

    final postBodyViewType = state.postBodyViewType;

    List<Widget> children = [
      PostBodyTitle(
        post: post,
        postBodyViewType: postBodyViewType,
        expandableController: expandableController,
        onToggleExpand: () => setState(() {}),
      ),
    ];

    if (postBodyViewType != PostBodyViewType.condensed && post.media.first.mediaType != MediaType.text) {
      children.add(
        Expandable(
          controller: expandableController,
          collapsed: Container(),
          expanded: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: MediaView(
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
        ),
      );
    }

    if (post.body?.isNotEmpty == true) {
      children.add(
        Expandable(
          controller: expandableController,
          collapsed: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: PostBodyPreview(
              post: post,
              viewSource: widget.viewSource,
              gradientBackgroundColor: widget.showReplyEditorButtons ? getBackgroundColor(context) : null,
              onTap: () {
                expandableController.toggle();
                setState(() {});
              },
            ),
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
                      fontScale: state.contentFontSizeScale,
                    )
                  : CommonMarkdownBody(body: post.body ?? ''),
            ),
          ),
        ),
      );
    }

    children.add(
      PostBodyMetadata(
        commentCount: post.comments,
        unreadCommentCount: post.unreadComments,
        dateTime: post.updated != null ? post.updated?.toIso8601String() : post.created.toIso8601String(),
        hasBeenEdited: post.updated != null ? true : false,
        url: post.media.first.mediaType != MediaType.image ? post.link : null,
      ),
    );

    if (showCrossPosts && sortedCrossPosts.isNotEmpty) {
      children.addAll([
        const Divider(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: CrossPosts(
            crossPosts: sortedCrossPosts,
            originalPost: post,
          ),
        ),
      ]);
    }

    if (widget.showQuickPostActionBar) {
      children.addAll([
        const Divider(),
        PostBodyActionsBar(
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
