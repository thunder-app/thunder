// Flutter imports
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports
import 'package:expandable/expandable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:html_unescape/html_unescape_small.dart';
import 'package:lemmy_api_client/v3.dart';

// Project imports
import 'package:thunder/account/account.dart';
import 'package:thunder/core/models/models.dart';
import 'package:thunder/utils/navigation.dart';
import 'package:thunder/community/enums/community_action.dart';
import 'package:thunder/feed/bloc/feed_bloc.dart';
import 'package:thunder/shared/media/media_type_badge.dart';
import 'package:thunder/core/enums/media_type.dart';
import 'package:thunder/core/enums/post_body_view_type.dart';
import 'package:thunder/core/enums/user_type.dart';
import 'package:thunder/core/enums/view_mode.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/post/post.dart';
import 'package:thunder/shared/avatars/community_avatar.dart';
import 'package:thunder/shared/avatars/user_avatar.dart';
import 'package:thunder/shared/chips/community_chip.dart';
import 'package:thunder/shared/chips/user_chip.dart';
import 'package:thunder/shared/common_markdown_body.dart';
import 'package:thunder/shared/conditional_parent_widget.dart';
import 'package:thunder/shared/cross_posts.dart';
import 'package:thunder/shared/divider.dart';
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
  final int? selectedCommentId;
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
    this.selectedCommentId,
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

  @override
  void initState() {
    super.initState();

    expandableController = ExpandableController(initialExpanded: !widget.showCompactPostBody);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    final bool showCrossPosts = context.read<ThunderBloc>().state.showCrossPosts;

    final bool isUserLoggedIn = context.watch<ProfileBloc>().state.isLoggedIn;
    final ThunderState thunderState = context.read<ThunderBloc>().state;
    final ProfileState profileState = context.watch<ProfileBloc>().state;

    final bool hideNsfwPreviews = thunderState.hideNsfwPreviews;
    final bool markPostReadOnMediaView = thunderState.markPostReadOnMediaView;

    final post = widget.post;
    final bool isOwnPost = post.creator?.id == context.read<ProfileBloc>().state.account?.userId;

    final List<ThunderPost> sortedCrossPosts = List.from(widget.crossPosts ?? [])..sort((a, b) => b.upvotes!.compareTo(a.upvotes!));

    List<UserType> userGroups = [];

    if (post.creator?.bot == true) userGroups.add(UserType.bot);
    if (post.creatorIsModerator ?? false) userGroups.add(UserType.moderator);
    if (post.creatorIsAdmin ?? false) userGroups.add(UserType.admin);
    if (post.creator?.id == profileState.account?.userId) userGroups.add(UserType.self);
    if (post.creator?.created.month == DateTime.now().month && post.creator?.created.day == DateTime.now().day) userGroups.add(UserType.birthday);

    return ExpandableNotifier(
      controller: expandableController,
      child: Padding(
        padding: EdgeInsets.only(left: 12.0, right: 12.0, bottom: widget.showReplyEditorButtons && post.body?.isNotEmpty == true ? 0.0 : 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  if (thunderState.postBodyViewType == PostBodyViewType.condensed && !thunderState.showThumbnailPreviewOnRight && post.media.first.mediaType != MediaType.text)
                    _getMediaPreview(thunderState, hideNsfwPreviews, markPostReadOnMediaView, isUserLoggedIn),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ScalableText(
                          HtmlUnescape().convert(post.title),
                          fontScale: thunderState.titleFontSizeScale,
                          style: theme.textTheme.titleMedium,
                        ),
                        if (post.media.first.mediaType == MediaType.link && thunderState.postBodyViewType == PostBodyViewType.condensed)
                          Text(
                            Uri.tryParse(post.url ?? '')?.host.replaceFirst('www.', '') ?? '',
                            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                          )
                      ],
                    ),
                  ),
                  if (thunderState.postBodyViewType == PostBodyViewType.condensed && thunderState.showThumbnailPreviewOnRight && post.media.first.mediaType != MediaType.text)
                    _getMediaPreview(thunderState, hideNsfwPreviews, markPostReadOnMediaView, isUserLoggedIn),
                  if ((thunderState.postBodyViewType != PostBodyViewType.condensed || post.media.first.mediaType == MediaType.text) && widget.showExpandableButton)
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      icon: Icon(
                        expandableController.expanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                        semanticLabel: expandableController.expanded ? l10n.collapsePost : l10n.expandPost,
                      ),
                      onPressed: () {
                        expandableController.toggle();
                        setState(() {}); // Update the state to trigger the collapse/expand
                      },
                    ),
                ],
              ),
            ),
            if (thunderState.postBodyViewType != PostBodyViewType.condensed && post.media.first.mediaType != MediaType.text)
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
            if (post.body?.isNotEmpty == true)
              Expandable(
                controller: expandableController,
                collapsed: PostBodyPreview(
                  post: post,
                  expandableController: expandableController,
                  onTapped: () => setState(() {}),
                  viewSource: widget.viewSource,
                ),
                expanded: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
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
                            fontScale: thunderState.contentFontSizeScale,
                          )
                        : CommonMarkdownBody(body: post.body ?? ''),
                  ),
                ),
              ),
            const SizedBox(height: 16.0),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                runSpacing: 8.0,
                children: [
                  Wrap(
                    spacing: 6.0,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      UserChip(
                        user: post.creator!,
                        personAvatar: UserAvatar(
                          user: post.creator!,
                          radius: 10,
                          thumbnailSize: 20,
                          format: 'png',
                        ),
                        userGroups: userGroups,
                        includeInstance: thunderState.postBodyShowUserInstance,
                      ),
                      ScalableText(
                        'to',
                        fontScale: thunderState.metadataFontSizeScale,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                        ),
                      ),
                      CommunityChip(
                        communityId: post.community!.id,
                        communityAvatar: CommunityAvatar(
                          community: post.community!,
                          radius: 10,
                          thumbnailSize: 20,
                          format: 'png',
                        ),
                        communityName: post.community!.name,
                        communityTitle: post.community!.title,
                        communityUrl: post.community!.url,
                        includeInstance: thunderState.postBodyShowCommunityInstance,
                      ),
                    ],
                  ),
                  PostMetadata(
                    commentCount: post.comments,
                    unreadCommentCount: post.unreadComments,
                    dateTime: post.updated != null ? post.updated?.toIso8601String() : post.created.toIso8601String(),
                    hasBeenEdited: post.updated != null ? true : false,
                    url: post.media.firstOrNull != null ? post.media.first.originalUrl : null,
                  ),
                ],
              ),
            ),
            if (showCrossPosts && sortedCrossPosts.isNotEmpty) ...[
              const Divider(),
              CrossPosts(
                crossPosts: sortedCrossPosts,
                originalPost: post,
              ),
            ],
            if (widget.showQuickPostActionBar) ...[
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
                  final account = await fetchActiveProfile();

                  final GetCommunityResponse getCommunityResponse = await LemmyClient.instance.lemmyApiV3.run(GetCommunity(
                    auth: account.jwt,
                    id: post.community?.id,
                  ));

                  navigateToCreatePostPage(
                    context,
                    communityId: post.community?.id,
                    community: ThunderCommunity(getCommunityResponse.communityView.community, communityView: getCommunityResponse.communityView),
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
            ],
            if (widget.showReplyEditorButtons && post.body?.isNotEmpty == true) ...[
              const ThunderDivider(sliver: false, padding: false),
              ReplyToPreviewActions(
                onViewSourceToggled: widget.onViewSourceToggled,
                viewSource: widget.viewSource,
                text: post.body!,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _getMediaPreview(ThunderState thunderState, bool hideNsfwPreviews, bool markPostReadOnMediaView, bool isUserLoggedIn) {
    return Stack(
      alignment: AlignmentDirectional.bottomEnd,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 10.0,
            vertical: 4,
          ),
          child: MediaView(
            media: widget.post.media.first,
            postId: widget.post.id,
            showFullHeightImages: false,
            hideNsfwPreviews: hideNsfwPreviews,
            markPostReadOnMediaView: markPostReadOnMediaView,
            viewMode: ViewMode.compact,
            isUserLoggedIn: isUserLoggedIn,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 6, bottom: 0),
          child: MediaTypeBadge(
            mediaType: widget.post.media.firstOrNull?.mediaType ?? MediaType.text,
            dim: false,
          ),
        ),
      ],
    );
  }
}
