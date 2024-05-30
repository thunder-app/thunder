import 'dart:async';
import 'dart:io';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter/material.dart';

import 'package:share_plus/share_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:thunder/account/bloc/account_bloc.dart';

import 'package:thunder/community/bloc/community_bloc.dart';
import 'package:thunder/community/enums/community_action.dart';
import 'package:thunder/core/enums/full_name.dart';
import 'package:thunder/core/enums/media_type.dart';
import 'package:thunder/core/models/post_view_media.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/feed/bloc/feed_bloc.dart';
import 'package:thunder/feed/utils/utils.dart';
import 'package:thunder/feed/view/feed_page.dart';
import 'package:thunder/instance/bloc/instance_bloc.dart';
import 'package:thunder/instance/enums/instance_action.dart';
import 'package:thunder/post/enums/post_action.dart';
import 'package:thunder/post/widgets/reason_bottom_sheet.dart';
import 'package:thunder/shared/advanced_share_sheet.dart';
import 'package:thunder/shared/picker_item.dart';
import 'package:thunder/shared/snackbar.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/user/bloc/user_bloc.dart';
import 'package:thunder/user/enums/user_action.dart';
import 'package:thunder/utils/instance.dart';
import 'package:thunder/instance/utils/navigate_instance.dart';
import 'package:lemmy_api_client/v3.dart';

import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/shared/multi_picker_item.dart';
import 'package:thunder/utils/global_context.dart';

enum PostCardAction {
  userActions,
  visitProfile,
  blockUser,
  communityActions,
  visitCommunity,
  subscribeToCommunity,
  unsubscribeFromCommunity,
  blockCommunity,
  instanceActions,
  visitInstance,
  blockInstance,
  sharePost,
  sharePostLocal,
  shareImage,
  shareMedia,
  shareLink,
  shareAdvanced,
  upvote,
  downvote,
  save,
  toggleRead,
  share,
  delete,
  moderatorActions,
  moderatorLockPost,
  moderatorPinCommunity,
  moderatorRemovePost,
}

class ExtendedPostCardActions {
  const ExtendedPostCardActions({
    required this.postCardAction,
    required this.icon,
    this.trailingIcon,
    required this.label,
    this.getColor,
    this.getForegroundColor,
    this.getOverrideIcon,
    this.getOverrideLabel,
    this.getSubtitleLabel,
    this.shouldShow,
    this.shouldEnable,
  });

  final PostCardAction postCardAction;
  final IconData icon;
  final IconData? trailingIcon;
  final String label;
  final Color Function(BuildContext context)? getColor;
  final Color? Function(BuildContext context, PostView postView)? getForegroundColor;
  final IconData? Function(PostView postView)? getOverrideIcon;
  final String? Function(BuildContext context, PostView postView)? getOverrideLabel;
  final String? Function(BuildContext context, PostViewMedia postViewMedia)? getSubtitleLabel;
  final bool Function(BuildContext context, PostView commentView)? shouldShow;
  final bool Function(bool isUserLoggedIn)? shouldEnable;
}

final l10n = AppLocalizations.of(GlobalContext.context)!;

final List<ExtendedPostCardActions> postCardActionItems = [
  ExtendedPostCardActions(
    postCardAction: PostCardAction.userActions,
    icon: Icons.person_rounded,
    label: l10n.user,
    getSubtitleLabel: (context, postViewMedia) => generateUserFullName(context, postViewMedia.postView.creator.name, fetchInstanceNameFromUrl(postViewMedia.postView.creator.actorId)),
    trailingIcon: Icons.chevron_right_rounded,
  ),
  ExtendedPostCardActions(
    postCardAction: PostCardAction.visitProfile,
    icon: Icons.person_search_rounded,
    label: l10n.visitUserProfile,
  ),
  ExtendedPostCardActions(
    postCardAction: PostCardAction.blockUser,
    icon: Icons.block,
    label: l10n.blockUser,
    shouldEnable: (isUserLoggedIn) => isUserLoggedIn,
  ),
  ExtendedPostCardActions(
    postCardAction: PostCardAction.communityActions,
    icon: Icons.people_rounded,
    label: l10n.community,
    getSubtitleLabel: (context, postViewMedia) => generateCommunityFullName(context, postViewMedia.postView.community.name, fetchInstanceNameFromUrl(postViewMedia.postView.community.actorId)),
    trailingIcon: Icons.chevron_right_rounded,
  ),
  ExtendedPostCardActions(
    postCardAction: PostCardAction.visitCommunity,
    icon: Icons.home_work_rounded,
    label: l10n.visitCommunity,
  ),
  ExtendedPostCardActions(
    postCardAction: PostCardAction.subscribeToCommunity,
    icon: Icons.add_circle_outline_rounded,
    label: l10n.subscribeToCommunity,
    shouldEnable: (isUserLoggedIn) => isUserLoggedIn,
  ),
  ExtendedPostCardActions(
    postCardAction: PostCardAction.unsubscribeFromCommunity,
    icon: Icons.remove_circle_outline_rounded,
    label: l10n.unsubscribeFromCommunity,
    shouldEnable: (isUserLoggedIn) => isUserLoggedIn,
  ),
  ExtendedPostCardActions(
    postCardAction: PostCardAction.blockCommunity,
    icon: Icons.block_rounded,
    label: l10n.blockCommunity,
    shouldEnable: (isUserLoggedIn) => isUserLoggedIn,
  ),
  ExtendedPostCardActions(
    postCardAction: PostCardAction.instanceActions,
    icon: Icons.language_rounded,
    label: l10n.instance(1),
    getSubtitleLabel: (context, postViewMedia) => fetchInstanceNameFromUrl(postViewMedia.postView.community.actorId) ?? '',
    trailingIcon: Icons.chevron_right_rounded,
  ),
  ExtendedPostCardActions(
    postCardAction: PostCardAction.visitInstance,
    icon: Icons.language,
    label: l10n.visitInstance,
  ),
  ExtendedPostCardActions(
    postCardAction: PostCardAction.blockInstance,
    icon: Icons.block_rounded,
    label: l10n.blockInstance,
    shouldEnable: (isUserLoggedIn) => isUserLoggedIn,
  ),
  ExtendedPostCardActions(
    postCardAction: PostCardAction.sharePost,
    icon: Icons.share_rounded,
    label: l10n.sharePost,
    getSubtitleLabel: (context, postViewMedia) => postViewMedia.postView.post.apId,
  ),
  ExtendedPostCardActions(
    postCardAction: PostCardAction.sharePostLocal,
    icon: Icons.share_rounded,
    label: l10n.sharePostLocal,
    getSubtitleLabel: (context, postViewMedia) => LemmyClient.instance.generatePostUrl(postViewMedia.postView.post.id),
  ),
  ExtendedPostCardActions(
    postCardAction: PostCardAction.shareImage,
    icon: Icons.image_rounded,
    label: l10n.shareImage,
    getSubtitleLabel: (context, postViewMedia) => postViewMedia.media.first.imageUrl,
  ),
  ExtendedPostCardActions(
    postCardAction: PostCardAction.shareMedia,
    icon: Icons.personal_video_rounded,
    label: l10n.shareMediaLink,
    getSubtitleLabel: (context, postViewMedia) => postViewMedia.media.first.mediaUrl,
  ),
  ExtendedPostCardActions(
    postCardAction: PostCardAction.shareLink,
    icon: Icons.link_rounded,
    label: l10n.shareLink,
    getSubtitleLabel: (context, postViewMedia) => postViewMedia.media.first.originalUrl,
  ),
  ExtendedPostCardActions(
    postCardAction: PostCardAction.shareAdvanced,
    icon: Icons.screen_share_rounded,
    label: l10n.advanced,
    getSubtitleLabel: (context, postViewMedia) => l10n.useAdvancedShareSheet,
  ),
  ExtendedPostCardActions(
    postCardAction: PostCardAction.upvote,
    label: l10n.upvote,
    icon: Icons.arrow_upward_rounded,
    getColor: (context) => context.read<ThunderBloc>().state.upvoteColor.color,
    getForegroundColor: (context, postView) => postView.myVote == 1 ? context.read<ThunderBloc>().state.upvoteColor.color : null,
    shouldEnable: (isUserLoggedIn) => isUserLoggedIn,
  ),
  ExtendedPostCardActions(
    postCardAction: PostCardAction.downvote,
    label: l10n.downvote,
    icon: Icons.arrow_downward_rounded,
    getColor: (context) => context.read<ThunderBloc>().state.downvoteColor.color,
    getForegroundColor: (context, postView) => postView.myVote == -1 ? context.read<ThunderBloc>().state.downvoteColor.color : null,
    shouldShow: (context, commentView) => context.read<AuthBloc>().state.downvotesEnabled,
    shouldEnable: (isUserLoggedIn) => isUserLoggedIn,
  ),
  ExtendedPostCardActions(
    postCardAction: PostCardAction.save,
    label: l10n.save,
    icon: Icons.star_border_rounded,
    getColor: (context) => context.read<ThunderBloc>().state.saveColor.color,
    getForegroundColor: (context, postView) => postView.saved ? context.read<ThunderBloc>().state.saveColor.color : null,
    getOverrideIcon: (postView) => postView.saved ? Icons.star_rounded : null,
    shouldEnable: (isUserLoggedIn) => isUserLoggedIn,
  ),
  ExtendedPostCardActions(
    postCardAction: PostCardAction.toggleRead,
    label: l10n.toggelRead,
    icon: Icons.mail_outline_outlined,
    getColor: (context) => context.read<ThunderBloc>().state.markReadColor.color,
    getOverrideIcon: (postView) => postView.read ? Icons.mark_email_unread_rounded : Icons.mark_email_read_outlined,
    shouldEnable: (isUserLoggedIn) => isUserLoggedIn,
  ),
  ExtendedPostCardActions(
    postCardAction: PostCardAction.share,
    icon: Icons.share_rounded,
    label: l10n.share,
  ),
  ExtendedPostCardActions(
    postCardAction: PostCardAction.delete,
    icon: Icons.delete_rounded,
    label: l10n.delete,
    getOverrideIcon: (postView) => postView.post.deleted ? Icons.restore_from_trash_rounded : Icons.delete_rounded,
    getOverrideLabel: (context, postView) => postView.post.deleted ? l10n.restore : l10n.delete,
  ),
  ExtendedPostCardActions(
    postCardAction: PostCardAction.moderatorActions,
    icon: Icons.shield_rounded,
    trailingIcon: Icons.chevron_right_rounded,
    label: l10n.moderatorActions,
  ),
  ExtendedPostCardActions(
    postCardAction: PostCardAction.moderatorLockPost,
    icon: Icons.lock,
    label: l10n.lockPost,
    getOverrideIcon: (postView) => postView.post.locked ? Icons.lock_open_rounded : Icons.lock,
    getOverrideLabel: (context, postView) => postView.post.locked ? l10n.unlockPost : l10n.lockPost,
  ),
  ExtendedPostCardActions(
    postCardAction: PostCardAction.moderatorPinCommunity,
    icon: Icons.push_pin_rounded,
    label: l10n.pinToCommunity,
    getOverrideIcon: (postView) => postView.post.featuredCommunity ? Icons.push_pin_rounded : Icons.push_pin_outlined,
    getOverrideLabel: (context, postView) => postView.post.featuredCommunity ? l10n.unpinFromCommunity : l10n.pinToCommunity,
  ),
  ExtendedPostCardActions(
    postCardAction: PostCardAction.moderatorRemovePost,
    icon: Icons.delete_forever_rounded,
    label: l10n.removePost,
    getOverrideIcon: (postView) => postView.post.removed ? Icons.restore_from_trash_rounded : Icons.delete_forever_rounded,
    getOverrideLabel: (context, postView) => postView.post.removed ? l10n.restorePost : l10n.removePost,
  )
];

enum PostActionBottomSheetPage {
  general,
  share,
  moderator,
  user,
  community,
  instance,
}

void showPostActionBottomModalSheet(
  BuildContext context,
  PostViewMedia postViewMedia, {
  PostActionBottomSheetPage page = PostActionBottomSheetPage.general,
}) {
  final bool isOwnPost = postViewMedia.postView.creator.id == context.read<AuthBloc>().state.account?.userId;

  final bool isModerator =
      context.read<AccountBloc>().state.moderates.any((CommunityModeratorView communityModeratorView) => communityModeratorView.community.id == postViewMedia.postView.community.id);

  // Generate the list of default actions for the general page
  final List<ExtendedPostCardActions> defaultPostCardActions = postCardActionItems
      .where((extendedAction) => [
            PostCardAction.userActions,
            PostCardAction.communityActions,
            PostCardAction.instanceActions,
          ].contains(extendedAction.postCardAction))
      .toList();

  // Add the moderator actions submenu
  if (isModerator) {
    defaultPostCardActions.add(postCardActionItems.firstWhere((ExtendedPostCardActions extendedPostCardActions) => extendedPostCardActions.postCardAction == PostCardAction.moderatorActions));
  }

  // Generate the list of default multi actions
  final List<ExtendedPostCardActions> defaultMultiPostCardActions = postCardActionItems
      .where((extendedAction) => [
            PostCardAction.upvote,
            PostCardAction.downvote,
            PostCardAction.save,
            PostCardAction.toggleRead,
            PostCardAction.share,
            if (isOwnPost) PostCardAction.delete,
          ].contains(extendedAction.postCardAction))
      .toList();

  // Generate the list of moderator actions
  final List<ExtendedPostCardActions> moderatorPostCardActions = postCardActionItems
      .where((extendedAction) => [
            PostCardAction.moderatorLockPost,
            PostCardAction.moderatorPinCommunity,
            PostCardAction.moderatorRemovePost,
          ].contains(extendedAction.postCardAction))
      .toList();

  // Generate the list of share actions
  final List<ExtendedPostCardActions> sharePostCardActions = postCardActionItems
      .where((extendedAction) => [
            PostCardAction.sharePost,
            PostCardAction.sharePostLocal,
            PostCardAction.shareImage,
            PostCardAction.shareMedia,
            PostCardAction.shareLink,
            PostCardAction.shareAdvanced,
          ].contains(extendedAction.postCardAction))
      .toList();

  // Remove the share link option if there is no link
  // Or if the media link is the same as the external link
  if (postViewMedia.media.isEmpty || postViewMedia.media.first.originalUrl == postViewMedia.media.first.imageUrl || postViewMedia.media.first.originalUrl == postViewMedia.media.first.mediaUrl) {
    sharePostCardActions.removeWhere((extendedAction) => extendedAction.postCardAction == PostCardAction.shareLink);
  }

  // Remove the share image option if there is no image
  if (postViewMedia.media.isEmpty || postViewMedia.media.first.imageUrl?.isNotEmpty != true) {
    sharePostCardActions.removeWhere((extendedAction) => extendedAction.postCardAction == PostCardAction.shareImage);
  }

  // Remove the share media option if there is no media
  if (postViewMedia.media.isEmpty || postViewMedia.media.first.mediaUrl?.isNotEmpty != true) {
    sharePostCardActions.removeWhere((extendedAction) => extendedAction.postCardAction == PostCardAction.shareMedia);
  }

  // Remove the share local option if it is the same as the original
  if (postViewMedia.postView.post.apId == LemmyClient.instance.generatePostUrl(postViewMedia.postView.post.id)) {
    sharePostCardActions.removeWhere((extendedAction) => extendedAction.postCardAction == PostCardAction.sharePostLocal);
  }

  // Generate the list of user actions
  final List<ExtendedPostCardActions> userActions = postCardActionItems
      .where((extendedAction) => [
            PostCardAction.visitProfile,
            PostCardAction.blockUser,
          ].contains(extendedAction.postCardAction))
      .toList();

  // Generate the list of community actions
  final List<ExtendedPostCardActions> communityActions = postCardActionItems
      .where((extendedAction) => [
            PostCardAction.visitCommunity,
            postViewMedia.postView.subscribed == SubscribedType.notSubscribed ? PostCardAction.subscribeToCommunity : PostCardAction.unsubscribeFromCommunity,
            PostCardAction.blockCommunity,
          ].contains(extendedAction.postCardAction))
      .toList();

  // Hide the option to block a community if the user is subscribed to it
  if (communityActions.any((extendedAction) => extendedAction.postCardAction == PostCardAction.blockCommunity) && postViewMedia.postView.subscribed != SubscribedType.notSubscribed) {
    communityActions.removeWhere((ExtendedPostCardActions postCardActionItem) => postCardActionItem.postCardAction == PostCardAction.blockCommunity);
  }

  // Generate the list of instance actions
  final List<ExtendedPostCardActions> instanceActions = postCardActionItems
      .where((extendedAction) => [
            PostCardAction.visitInstance,
            PostCardAction.blockInstance,
          ].contains(extendedAction.postCardAction))
      .toList();

// Remove block if unsupported
  if (instanceActions.any((extendedAction) => extendedAction.postCardAction == PostCardAction.blockInstance) && !LemmyClient.instance.supportsFeature(LemmyFeature.blockInstance)) {
    instanceActions.removeWhere((ExtendedPostCardActions postCardActionItem) => postCardActionItem.postCardAction == PostCardAction.blockInstance);
  }

  showModalBottomSheet<void>(
    showDragHandle: true,
    isScrollControlled: true,
    context: context,
    builder: (builderContext) => PostCardActionPicker(
      postViewMedia: postViewMedia,
      page: page,
      postCardActions: {
        PostActionBottomSheetPage.general: defaultPostCardActions,
        PostActionBottomSheetPage.moderator: moderatorPostCardActions,
        PostActionBottomSheetPage.share: sharePostCardActions,
        PostActionBottomSheetPage.user: userActions,
        PostActionBottomSheetPage.community: communityActions,
        PostActionBottomSheetPage.instance: instanceActions,
      },
      multiPostCardActions: {PostActionBottomSheetPage.general: defaultMultiPostCardActions},
      titles: {
        PostActionBottomSheetPage.general: l10n.actions,
        PostActionBottomSheetPage.moderator: l10n.moderatorActions,
        PostActionBottomSheetPage.share: l10n.share,
        PostActionBottomSheetPage.user: l10n.userActions,
        PostActionBottomSheetPage.community: l10n.communityActions,
        PostActionBottomSheetPage.instance: l10n.instanceActions,
      },
      outerContext: context,
    ),
  );
}

class PostCardActionPicker extends StatefulWidget {
  /// The post
  final PostViewMedia postViewMedia;

  /// This is the list of quick actions that are shown horizontally across the top of the sheet
  final Map<PostActionBottomSheetPage, List<ExtendedPostCardActions>> multiPostCardActions;

  /// This is the set of full actions to display vertically in a list
  final Map<PostActionBottomSheetPage, List<ExtendedPostCardActions>> postCardActions;

  /// This is the set of titles to show for each page
  final Map<PostActionBottomSheetPage, String> titles;

  /// The current page
  final PostActionBottomSheetPage page;

  /// The context from whoever invoked this sheet (useful for blocs that would otherwise be missing)
  final BuildContext outerContext;

  const PostCardActionPicker({
    super.key,
    required this.postViewMedia,
    required this.page,
    required this.postCardActions,
    required this.multiPostCardActions,
    required this.titles,
    required this.outerContext,
  });

  @override
  State<StatefulWidget> createState() => _PostCardActionPickerState();
}

class _PostCardActionPickerState extends State<PostCardActionPicker> {
  PostActionBottomSheetPage? page;

  @override
  void initState() {
    super.initState();

    BackButtonInterceptor.add(_handleBack);
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(_handleBack);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isUserLoggedIn = context.read<AuthBloc>().state.isLoggedIn;

    return SingleChildScrollView(
      child: AnimatedSize(
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              Semantics(
                label: '${widget.titles[page ?? widget.page] ?? l10n.actions}, ${(page ?? widget.page) == PostActionBottomSheetPage.general ? '' : l10n.backButton}',
                child: Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: Material(
                    borderRadius: BorderRadius.circular(50),
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(50),
                      onTap: (page ?? widget.page) == PostActionBottomSheetPage.general ? null : () => setState(() => page = PostActionBottomSheetPage.general),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12.0, 10, 16.0, 10.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Row(
                            children: [
                              if ((page ?? widget.page) != PostActionBottomSheetPage.general) ...[
                                const Icon(Icons.chevron_left, size: 30),
                                const SizedBox(width: 12),
                              ],
                              Semantics(
                                excludeSemantics: true,
                                child: Text(
                                  widget.titles[page ?? widget.page] ?? l10n.actions,
                                  style: theme.textTheme.titleLarge,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              if (widget.multiPostCardActions[page ?? widget.page]?.isNotEmpty == true)
                MultiPickerItem(
                  pickerItems: [
                    ...widget.multiPostCardActions[page ?? widget.page]!.where((a) => a.shouldShow?.call(context, widget.postViewMedia.postView) ?? true).map(
                      (a) {
                        return PickerItemData(
                          label: a.label,
                          icon: a.getOverrideIcon?.call(widget.postViewMedia.postView) ?? a.icon,
                          backgroundColor: a.getColor?.call(context),
                          foregroundColor: a.getForegroundColor?.call(context, widget.postViewMedia.postView),
                          onSelected: (a.shouldEnable?.call(isUserLoggedIn) ?? true) ? () => onSelected(a.postCardAction) : null,
                        );
                      },
                    ),
                  ],
                ),
              if (widget.postCardActions[page ?? widget.page]?.isNotEmpty == true)
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: widget.postCardActions[page ?? widget.page]!.length,
                  itemBuilder: (BuildContext itemBuilderContext, int index) {
                    return PickerItem(
                      label: widget.postCardActions[page ?? widget.page]![index].getOverrideLabel?.call(context, widget.postViewMedia.postView) ??
                          widget.postCardActions[page ?? widget.page]![index].label,
                      subtitle: widget.postCardActions[page ?? widget.page]![index].getSubtitleLabel?.call(context, widget.postViewMedia),
                      icon: widget.postCardActions[page ?? widget.page]![index].getOverrideIcon?.call(widget.postViewMedia.postView) ?? widget.postCardActions[page ?? widget.page]![index].icon,
                      trailingIcon: widget.postCardActions[page ?? widget.page]![index].trailingIcon,
                      onSelected: (widget.postCardActions[page ?? widget.page]![index].shouldEnable?.call(isUserLoggedIn) ?? true)
                          ? () => onSelected(widget.postCardActions[page ?? widget.page]![index].postCardAction)
                          : null,
                    );
                  },
                ),
              const SizedBox(height: 16.0),
            ],
          ),
        ),
      ),
    );
  }

  void onSelected(PostCardAction postCardAction) async {
    bool pop = true;
    void Function() action;

    switch (postCardAction) {
      case PostCardAction.visitCommunity:
        action = () => onTapCommunityName(widget.outerContext, widget.postViewMedia.postView.community.id);
        break;
      case PostCardAction.userActions:
        action = () => setState(() => page = PostActionBottomSheetPage.user);
        pop = false;
        break;
      case PostCardAction.visitProfile:
        action = () => navigateToFeedPage(widget.outerContext, feedType: FeedType.user, userId: widget.postViewMedia.postView.post.creatorId);
        break;
      case PostCardAction.visitInstance:
        action = () => navigateToInstancePage(widget.outerContext,
            instanceHost: fetchInstanceNameFromUrl(widget.postViewMedia.postView.community.actorId)!, instanceId: widget.postViewMedia.postView.community.instanceId);
        break;
      case PostCardAction.sharePost:
        action = () => Share.share(widget.postViewMedia.postView.post.apId);
        break;
      case PostCardAction.sharePostLocal:
        action = () => Share.share(LemmyClient.instance.generatePostUrl(widget.postViewMedia.postView.post.id));
        break;
      case PostCardAction.shareImage:
        action = () async {
          if (widget.postViewMedia.media.first.imageUrl != null) {
            try {
              // Try to get the cached image first
              var media = await DefaultCacheManager().getFileFromCache(widget.postViewMedia.media.first.imageUrl!);
              File? mediaFile = media?.file;

              if (media == null) {
                // Tell user we're downloading the image
                showSnackbar(AppLocalizations.of(widget.outerContext)!.downloadingMedia);

                // Download
                mediaFile = await DefaultCacheManager().getSingleFile(widget.postViewMedia.media.first.imageUrl!);
              }

              // Share
              await Share.shareXFiles([XFile(mediaFile!.path)]);
            } catch (e) {
              // Tell the user that the download failed
              showSnackbar(AppLocalizations.of(widget.outerContext)!.errorDownloadingMedia(e));
            }
          }
        };
        break;
      case PostCardAction.shareMedia:
        action = () => Share.share(widget.postViewMedia.media.first.mediaUrl!);
        break;
      case PostCardAction.shareLink:
        action = () {
          if (widget.postViewMedia.media.first.originalUrl != null) Share.share(widget.postViewMedia.media.first.originalUrl!);
        };
        break;
      case PostCardAction.shareAdvanced:
        action = () => showAdvancedShareSheet(widget.outerContext, widget.postViewMedia);
        break;
      case PostCardAction.instanceActions:
        action = () => setState(() => page = PostActionBottomSheetPage.instance);
        pop = false;
        break;
      case PostCardAction.blockInstance:
        action = () => widget.outerContext.read<InstanceBloc>().add(InstanceActionEvent(
              instanceAction: InstanceAction.block,
              instanceId: widget.postViewMedia.postView.community.instanceId,
              domain: fetchInstanceNameFromUrl(widget.postViewMedia.postView.community.actorId),
              value: true,
            ));
        break;
      case PostCardAction.communityActions:
        action = () => setState(() => page = PostActionBottomSheetPage.community);
        pop = false;
        break;
      case PostCardAction.blockCommunity:
        action =
            () => widget.outerContext.read<CommunityBloc>().add(CommunityActionEvent(communityAction: CommunityAction.block, communityId: widget.postViewMedia.postView.community.id, value: true));
        break;
      case PostCardAction.upvote:
        action = () => widget.outerContext
            .read<FeedBloc>()
            .add(FeedItemActionedEvent(postAction: PostAction.vote, postId: widget.postViewMedia.postView.post.id, value: widget.postViewMedia.postView.myVote == 1 ? 0 : 1));
        break;
      case PostCardAction.downvote:
        action = () => widget.outerContext
            .read<FeedBloc>()
            .add(FeedItemActionedEvent(postAction: PostAction.vote, postId: widget.postViewMedia.postView.post.id, value: widget.postViewMedia.postView.myVote == -1 ? 0 : -1));
        break;
      case PostCardAction.save:
        action = () =>
            widget.outerContext.read<FeedBloc>().add(FeedItemActionedEvent(postAction: PostAction.save, postId: widget.postViewMedia.postView.post.id, value: !widget.postViewMedia.postView.saved));
        break;
      case PostCardAction.toggleRead:
        action = () =>
            widget.outerContext.read<FeedBloc>().add(FeedItemActionedEvent(postAction: PostAction.read, postId: widget.postViewMedia.postView.post.id, value: !widget.postViewMedia.postView.read));
        break;
      case PostCardAction.share:
        pop = false;
        action = () => setState(() => page = PostActionBottomSheetPage.share);
        break;
      case PostCardAction.blockUser:
        action = () => widget.outerContext.read<UserBloc>().add(UserActionEvent(userAction: UserAction.block, userId: widget.postViewMedia.postView.creator.id, value: true));
        break;
      case PostCardAction.subscribeToCommunity:
        action =
            () => widget.outerContext.read<CommunityBloc>().add(CommunityActionEvent(communityAction: CommunityAction.follow, communityId: widget.postViewMedia.postView.community.id, value: true));
        break;
      case PostCardAction.unsubscribeFromCommunity:
        action =
            () => widget.outerContext.read<CommunityBloc>().add(CommunityActionEvent(communityAction: CommunityAction.follow, communityId: widget.postViewMedia.postView.community.id, value: false));
        break;
      case PostCardAction.delete:
        action = () => widget.outerContext
            .read<FeedBloc>()
            .add(FeedItemActionedEvent(postAction: PostAction.delete, postId: widget.postViewMedia.postView.post.id, value: !widget.postViewMedia.postView.post.deleted));
        break;
      case PostCardAction.moderatorActions:
        action = () => setState(() => page = PostActionBottomSheetPage.moderator);
        pop = false;
        break;
      case PostCardAction.moderatorLockPost:
        action = () => widget.outerContext
            .read<FeedBloc>()
            .add(FeedItemActionedEvent(postAction: PostAction.lock, postId: widget.postViewMedia.postView.post.id, value: !widget.postViewMedia.postView.post.locked));
        break;
      case PostCardAction.moderatorPinCommunity:
        action = () => widget.outerContext
            .read<FeedBloc>()
            .add(FeedItemActionedEvent(postAction: PostAction.pinCommunity, postId: widget.postViewMedia.postView.post.id, value: !widget.postViewMedia.postView.post.featuredCommunity));
        break;
      case PostCardAction.moderatorRemovePost:
        action = () => showRemovePostReasonBottomSheet(widget.outerContext, widget.postViewMedia);
        break;
    }

    if (pop) {
      Navigator.of(context).pop();
    }

    action();
  }

  FutureOr<bool> _handleBack(bool stopDefaultButtonEvent, RouteInfo routeInfo) {
    if ((page ?? widget.page) != PostActionBottomSheetPage.general) {
      setState(() => page = PostActionBottomSheetPage.general);
      return true;
    }

    return false;
  }
}

void onTapCommunityName(BuildContext context, int communityId) {
  navigateToFeedPage(context, feedType: FeedType.community, communityId: communityId);
}

void showRemovePostReasonBottomSheet(BuildContext context, PostViewMedia postViewMedia) {
  showModalBottomSheet(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (_) => ReasonBottomSheet(
      title: postViewMedia.postView.post.removed ? l10n.restorePost : l10n.removalReason,
      submitLabel: postViewMedia.postView.post.removed ? l10n.restore : l10n.remove,
      textHint: l10n.reason,
      onSubmit: (String message) {
        context.read<FeedBloc>().add(
              FeedItemActionedEvent(
                postAction: PostAction.remove,
                postId: postViewMedia.postView.post.id,
                value: {
                  'remove': !postViewMedia.postView.post.removed,
                  'reason': message,
                },
              ),
            );
        Navigator.of(context).pop();
      },
    ),
  );
}
