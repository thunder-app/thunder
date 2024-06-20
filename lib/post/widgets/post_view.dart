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
import 'package:swipeable_page_route/swipeable_page_route.dart';

// Project imports
import 'package:thunder/account/bloc/account_bloc.dart';
import 'package:thunder/account/models/account.dart';
import 'package:thunder/comment/utils/navigate_comment.dart';
import 'package:thunder/community/pages/create_post_page.dart';
import 'package:thunder/community/utils/post_card_action_helpers.dart';
import 'package:thunder/community/widgets/post_card_type_badge.dart';
import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/core/auth/helpers/fetch_account.dart';
import 'package:thunder/core/enums/media_type.dart';
import 'package:thunder/core/enums/post_body_view_type.dart';
import 'package:thunder/core/enums/user_type.dart';
import 'package:thunder/core/enums/view_mode.dart';
import 'package:thunder/core/models/post_view_media.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/post/bloc/post_bloc.dart';
import 'package:thunder/post/cubit/create_post_cubit.dart';
import 'package:thunder/post/widgets/post_metadata.dart';
import 'package:thunder/post/widgets/post_quick_actions_bar.dart';
import 'package:thunder/shared/avatars/community_avatar.dart';
import 'package:thunder/shared/avatars/user_avatar.dart';
import 'package:thunder/shared/chips/community_chip.dart';
import 'package:thunder/shared/chips/user_chip.dart';
import 'package:thunder/shared/common_markdown_body.dart';
import 'package:thunder/shared/conditional_parent_widget.dart';
import 'package:thunder/shared/cross_posts.dart';
import 'package:thunder/shared/divider.dart';
import 'package:thunder/shared/media_view.dart';
import 'package:thunder/shared/reply_to_preview_actions.dart';
import 'package:thunder/shared/text/scalable_text.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';

class PostSubview extends StatefulWidget {
  final PostViewMedia postViewMedia;
  final bool useDisplayNames;
  final int? selectedCommentId;
  final List<PostView>? crossPosts;
  final bool viewSource;
  final void Function()? onViewSourceToggled;
  final bool showQuickPostActionBar;
  final bool showExpandableButton;
  final bool selectable;
  final bool showReplyEditorButtons;

  const PostSubview({
    super.key,
    this.selectedCommentId,
    required this.useDisplayNames,
    required this.postViewMedia,
    required this.crossPosts,
    required this.viewSource,
    this.onViewSourceToggled,
    this.showQuickPostActionBar = true,
    this.showExpandableButton = true,
    this.selectable = false,
    this.showReplyEditorButtons = false,
  });

  @override
  State<PostSubview> createState() => _PostSubviewState();
}

class _PostSubviewState extends State<PostSubview> with SingleTickerProviderStateMixin {
  final ExpandableController expandableController = ExpandableController(initialExpanded: true);
  late PostViewMedia postViewMedia;
  final FocusNode _selectableRegionFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    postViewMedia = widget.postViewMedia;
  }

  @override
  void didUpdateWidget(covariant PostSubview oldWidget) {
    super.didUpdateWidget(oldWidget);
    postViewMedia = widget.postViewMedia;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    final bool showCrossPosts = context.read<ThunderBloc>().state.showCrossPosts;

    PostView postView = postViewMedia.postView;
    Post post = postView.post;

    final bool isUserLoggedIn = context.watch<AuthBloc>().state.isLoggedIn;
    final bool downvotesEnabled = context.read<AuthBloc>().state.downvotesEnabled;
    final ThunderState thunderState = context.read<ThunderBloc>().state;
    final AuthState authState = context.watch<AuthBloc>().state;

    final bool showScores = authState.getSiteResponse?.myUser?.localUserView.localUser.showScores ?? true;

    final bool scrapeMissingPreviews = thunderState.scrapeMissingPreviews;
    final bool hideNsfwPreviews = thunderState.hideNsfwPreviews;
    final bool markPostReadOnMediaView = thunderState.markPostReadOnMediaView;

    final bool isOwnPost = postView.creator.id == context.read<AuthBloc>().state.account?.userId;

    final List<PostView> sortedCrossPosts = List.from(widget.crossPosts ?? [])..sort((a, b) => b.counts.upvotes.compareTo(a.counts.upvotes));

    List<UserType> userGroups = [];

    if (postView.creator.botAccount) userGroups.add(UserType.bot);
    if (postView.creatorIsModerator ?? false) userGroups.add(UserType.moderator);
    if (postView.creatorIsAdmin ?? false) userGroups.add(UserType.admin);
    if (postView.creator.id == authState.account?.userId) userGroups.add(UserType.self);
    if (postView.creator.published.month == DateTime.now().month && postView.creator.published.day == DateTime.now().day) userGroups.add(UserType.birthday);

    return ExpandableNotifier(
      controller: expandableController,
      child: Padding(
        padding: const EdgeInsets.only(left: 12.0, right: 12.0, bottom: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  if (thunderState.postBodyViewType == PostBodyViewType.condensed && !thunderState.showThumbnailPreviewOnRight && postViewMedia.media.first.mediaType != MediaType.text)
                    _getMediaPreview(thunderState, hideNsfwPreviews, markPostReadOnMediaView, isUserLoggedIn),
                  Expanded(
                    child: ScalableText(
                      HtmlUnescape().convert(post.name),
                      fontScale: thunderState.titleFontSizeScale,
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                  if (thunderState.postBodyViewType == PostBodyViewType.condensed && thunderState.showThumbnailPreviewOnRight && postViewMedia.media.first.mediaType != MediaType.text)
                    _getMediaPreview(thunderState, hideNsfwPreviews, markPostReadOnMediaView, isUserLoggedIn),
                  if ((thunderState.postBodyViewType != PostBodyViewType.condensed || postViewMedia.media.first.mediaType == MediaType.text) && widget.showExpandableButton)
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
            if (thunderState.postBodyViewType != PostBodyViewType.condensed)
              Expandable(
                controller: expandableController,
                collapsed: Container(),
                expanded: MediaView(
                  scrapeMissingPreviews: scrapeMissingPreviews,
                  postViewMedia: widget.postViewMedia,
                  showFullHeightImages: true,
                  allowUnconstrainedImageHeight: true,
                  hideNsfwPreviews: hideNsfwPreviews,
                  markPostReadOnMediaView: markPostReadOnMediaView,
                  isUserLoggedIn: isUserLoggedIn,
                ),
              ),
            if (widget.postViewMedia.postView.post.body?.isNotEmpty == true)
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
                        child: child,
                      );
                    },
                    child: widget.viewSource
                        ? ScalableText(
                            post.body ?? '',
                            style: theme.textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
                            fontScale: thunderState.contentFontSizeScale,
                          )
                        : CommonMarkdownBody(
                            body: post.body ?? '',
                          ),
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
                        person: postView.creator,
                        personAvatar: UserAvatar(person: postView.creator, radius: 10, thumbnailSize: 20, format: 'png'),
                        userGroups: userGroups,
                        includeInstance: thunderState.postBodyShowCommunityInstance,
                      ),
                      ScalableText(
                        'to',
                        fontScale: thunderState.metadataFontSizeScale,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                        ),
                      ),
                      CommunityChip(
                        communityId: postView.community.id,
                        communityAvatar: CommunityAvatar(community: postView.community, radius: 10, thumbnailSize: 20, format: 'png'),
                        communityName: postView.community.name,
                        communityUrl: postView.community.actorId,
                      ),
                    ],
                  ),
                  PostMetadata(
                    commentCount: postViewMedia.postView.counts.comments,
                    unreadCommentCount: postViewMedia.postView.unreadComments,
                    dateTime: postViewMedia.postView.post.updated != null ? postViewMedia.postView.post.updated?.toIso8601String() : postViewMedia.postView.post.published.toIso8601String(),
                    hasBeenEdited: postViewMedia.postView.post.updated != null ? true : false,
                    url: postViewMedia.media.firstOrNull != null ? postViewMedia.media.first.originalUrl : null,
                  ),
                  if (widget.showReplyEditorButtons && widget.postViewMedia.postView.post.body?.isNotEmpty == true) ...[
                    const ThunderDivider(sliver: false, padding: false),
                    ReplyToPreviewActions(
                      onViewSourceToggled: widget.onViewSourceToggled,
                      viewSource: widget.viewSource,
                      text: widget.postViewMedia.postView.post.body!,
                    ),
                  ],
                ],
              ),
            ),
            if (showCrossPosts && sortedCrossPosts.isNotEmpty) ...[
              const Divider(),
              CrossPosts(
                crossPosts: sortedCrossPosts,
                originalPost: widget.postViewMedia,
              ),
            ],
            if (widget.showQuickPostActionBar) ...[
              const Divider(),
              PostQuickActionsBar(
                vote: postView.myVote,
                upvotes: postView.counts.upvotes,
                downvotes: postView.counts.downvotes,
                saved: postView.saved,
                locked: postView.post.locked,
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
                    widget.postViewMedia,
                    page: PostActionBottomSheetPage.share,
                  );
                },
                onEdit: () async {
                  ThunderBloc thunderBloc = context.read<ThunderBloc>();
                  AccountBloc accountBloc = context.read<AccountBloc>();
                  CreatePostCubit createPostCubit = CreatePostCubit();

                  final ThunderState thunderState = context.read<ThunderBloc>().state;
                  final bool reduceAnimations = thunderState.reduceAnimations;

                  final Account? account = await fetchActiveProfileAccount();
                  final GetCommunityResponse getCommunityResponse = await LemmyClient.instance.lemmyApiV3.run(GetCommunity(
                    auth: account?.jwt,
                    id: postViewMedia.postView.community.id,
                  ));

                  if (context.mounted) {
                    Navigator.of(context).push(
                      SwipeablePageRoute(
                        transitionDuration: reduceAnimations ? const Duration(milliseconds: 100) : null,
                        canOnlySwipeFromEdge: true,
                        backGestureDetectionWidth: 45,
                        builder: (context) {
                          return MultiBlocProvider(
                            providers: [
                              BlocProvider<ThunderBloc>.value(value: thunderBloc),
                              BlocProvider<AccountBloc>.value(value: accountBloc),
                              BlocProvider<CreatePostCubit>.value(value: createPostCubit),
                            ],
                            child: CreatePostPage(
                              communityId: postViewMedia.postView.community.id,
                              communityView: getCommunityResponse.communityView,
                              postView: postViewMedia.postView,
                              onPostSuccess: (PostViewMedia pvm, _) {
                                setState(() => postViewMedia = pvm);
                              },
                            ),
                          );
                        },
                      ),
                    );
                  }
                },
                onReply: () async => navigateToCreateCommentPage(
                  context,
                  postViewMedia: widget.postViewMedia,
                  onCommentSuccess: (commentView, userChanged) {
                    if (!userChanged) {
                      context.read<PostBloc>().add(UpdateCommentEvent(commentView: commentView, isEdit: false));
                    }
                  },
                ),
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
            scrapeMissingPreviews: thunderState.scrapeMissingPreviews,
            postViewMedia: postViewMedia,
            showFullHeightImages: false,
            hideNsfwPreviews: hideNsfwPreviews,
            markPostReadOnMediaView: markPostReadOnMediaView,
            viewMode: ViewMode.compact,
            isUserLoggedIn: isUserLoggedIn,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 6, bottom: 0),
          child: TypeBadge(
            mediaType: postViewMedia.media.firstOrNull?.mediaType ?? MediaType.text,
            dim: false,
          ),
        ),
      ],
    );
  }
}

/// Provides a preview of the post body when the post is collapsed.
class PostBodyPreview extends StatelessWidget {
  const PostBodyPreview({
    super.key,
    required this.post,
    required this.expandableController,
    required this.onTapped,
    required this.viewSource,
  });

  /// The post to display the preview of
  final Post post;

  /// The expandable controller used to toggle the expanded/collapsed state of the post
  final ExpandableController expandableController;

  /// Callback function which triggers when the post preview is tapped
  final Function() onTapped;

  /// Whether to view the raw post source
  final bool viewSource;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ThunderState thunderState = context.read<ThunderBloc>().state;

    return LimitedBox(
      maxHeight: 80.0,
      child: GestureDetector(
        onTap: () {
          expandableController.toggle();
          onTapped();
        },
        child: Stack(
          children: [
            Wrap(
              direction: Axis.horizontal,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: viewSource
                      ? ScalableText(
                          post.body ?? '',
                          style: theme.textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
                          fontScale: thunderState.contentFontSizeScale,
                        )
                      : CommonMarkdownBody(
                          body: post.body ?? '',
                        ),
                ),
              ],
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 70,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.0, 1.0],
                    colors: [
                      theme.scaffoldBackgroundColor.withOpacity(0.0),
                      theme.scaffoldBackgroundColor,
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
