import 'dart:io';
import 'package:flutter/material.dart';

import 'package:share_plus/share_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import 'package:thunder/community/bloc/community_bloc.dart';
import 'package:thunder/community/enums/community_action.dart';
import 'package:thunder/core/enums/media_type.dart';
import 'package:thunder/core/models/post_view_media.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/feed/bloc/feed_bloc.dart';
import 'package:thunder/feed/utils/utils.dart';
import 'package:thunder/feed/view/feed_page.dart';
import 'package:thunder/instance/bloc/instance_bloc.dart';
import 'package:thunder/instance/enums/instance_action.dart';
import 'package:thunder/post/enums/post_action.dart';
import 'package:thunder/shared/advanced_share_sheet.dart';
import 'package:thunder/shared/picker_item.dart';
import 'package:thunder/shared/snackbar.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/user/bloc/user_bloc.dart';
import 'package:thunder/utils/instance.dart';
import 'package:thunder/utils/navigate_instance.dart';
import 'package:thunder/utils/navigate_user.dart';
import 'package:lemmy_api_client/v3.dart';

import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/shared/multi_picker_item.dart';
import 'package:thunder/utils/global_context.dart';

enum PostCardAction {
  visitProfile,
  blockUser,
  visitCommunity,
  subscribeToCommunity,
  unsubscribeFromCommunity,
  blockCommunity,
  visitInstance,
  blockInstance,
  sharePost,
  shareMedia,
  shareLink,
  upvote,
  downvote,
  save,
  toggleRead,
  share,
}

class ExtendedPostCardActions {
  const ExtendedPostCardActions({
    required this.postCardAction,
    required this.icon,
    required this.label,
    this.color,
    this.getForegroundColor,
    this.getOverrideIcon,
    this.shouldShow,
    this.shouldEnable,
  });

  final PostCardAction postCardAction;
  final IconData icon;
  final String label;
  final Color? color;
  final Color? Function(PostView postView)? getForegroundColor;
  final IconData? Function(PostView postView)? getOverrideIcon;
  final bool Function(BuildContext context, PostView commentView)? shouldShow;
  final bool Function(bool isUserLoggedIn)? shouldEnable;
}

final l10n = AppLocalizations.of(GlobalContext.context)!;

final List<ExtendedPostCardActions> postCardActionItems = [
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
  ),
  ExtendedPostCardActions(
    postCardAction: PostCardAction.shareMedia,
    icon: Icons.image_rounded,
    label: l10n.shareMedia,
  ),
  ExtendedPostCardActions(
    postCardAction: PostCardAction.shareLink,
    icon: Icons.link_rounded,
    label: l10n.shareLink,
  ),
  ExtendedPostCardActions(
    postCardAction: PostCardAction.upvote,
    label: l10n.upvote,
    icon: Icons.arrow_upward_rounded,
    color: Colors.orange,
    getForegroundColor: (postView) => postView.myVote == 1 ? Colors.orange : null,
    shouldEnable: (isUserLoggedIn) => isUserLoggedIn,
  ),
  ExtendedPostCardActions(
    postCardAction: PostCardAction.downvote,
    label: l10n.downvote,
    icon: Icons.arrow_downward_rounded,
    color: Colors.blue,
    getForegroundColor: (postView) => postView.myVote == -1 ? Colors.blue : null,
    shouldShow: (context, commentView) => context.read<AuthBloc>().state.downvotesEnabled,
    shouldEnable: (isUserLoggedIn) => isUserLoggedIn,
  ),
  ExtendedPostCardActions(
    postCardAction: PostCardAction.save,
    label: l10n.save,
    icon: Icons.star_border_rounded,
    color: Colors.purple,
    getForegroundColor: (postView) => postView.saved ? Colors.purple : null,
    getOverrideIcon: (postView) => postView.saved ? Icons.star_rounded : null,
    shouldEnable: (isUserLoggedIn) => isUserLoggedIn,
  ),
  ExtendedPostCardActions(
    postCardAction: PostCardAction.toggleRead,
    label: l10n.toggelRead,
    icon: Icons.mail_outline_outlined,
    color: Colors.teal.shade300,
    getOverrideIcon: (postView) => postView.read ? Icons.mark_email_unread_rounded : Icons.mark_email_read_outlined,
    shouldEnable: (isUserLoggedIn) => isUserLoggedIn,
  ),
  ExtendedPostCardActions(
    postCardAction: PostCardAction.share,
    icon: Icons.share_rounded,
    label: l10n.share,
  )
];

void showPostActionBottomModalSheet(
  BuildContext context,
  PostViewMedia postViewMedia, {
  List<PostCardAction>? actionsToInclude,
  List<PostCardAction>? multiActionsToInclude,
}) {
  final theme = Theme.of(context);
  final bool isUserLoggedIn = context.read<AuthBloc>().state.isLoggedIn;
  final bool useAdvancedShareSheet = context.read<ThunderBloc>().state.useAdvancedShareSheet;

  actionsToInclude ??= [];
  List<ExtendedPostCardActions> postCardActionItemsToUse = postCardActionItems.where((extendedAction) => actionsToInclude!.any((action) => extendedAction.postCardAction == action)).toList();

  if (actionsToInclude.contains(PostCardAction.blockInstance) && !LemmyClient.instance.supportsFeature(LemmyFeature.blockInstance)) {
    postCardActionItemsToUse.removeWhere((ExtendedPostCardActions postCardActionItem) => postCardActionItem.postCardAction == PostCardAction.blockInstance);
  }

  // Hide the option to block a community if the user is subscribed to it
  if (actionsToInclude.contains(PostCardAction.blockCommunity) && postViewMedia.postView.subscribed != SubscribedType.notSubscribed) {
    postCardActionItemsToUse.removeWhere((ExtendedPostCardActions postCardActionItem) => postCardActionItem.postCardAction == PostCardAction.blockCommunity);
  }

  multiActionsToInclude ??= [];
  final multiPostCardActionItemsToUse = postCardActionItems.where((extendedAction) => multiActionsToInclude!.any((action) => extendedAction.postCardAction == action)).toList();

  showModalBottomSheet<void>(
    showDragHandle: true,
    isScrollControlled: true,
    context: context,
    builder: (BuildContext bottomSheetContext) {
      return SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0, left: 26.0, right: 16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  AppLocalizations.of(context)!.actions,
                  style: theme.textTheme.titleLarge!.copyWith(),
                ),
              ),
            ),
            MultiPickerItem(
              pickerItems: [
                ...multiPostCardActionItemsToUse.where((a) => a.shouldShow?.call(context, postViewMedia.postView) ?? true).map(
                  (a) {
                    return PickerItemData(
                      label: a.label,
                      icon: a.getOverrideIcon?.call(postViewMedia.postView) ?? a.icon,
                      backgroundColor: a.color,
                      foregroundColor: a.getForegroundColor?.call(postViewMedia.postView),
                      onSelected: (a.shouldEnable?.call(isUserLoggedIn) ?? true) ? () => onSelected(context, a.postCardAction, postViewMedia, useAdvancedShareSheet) : null,
                    );
                  },
                ),
              ],
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: postCardActionItemsToUse.length,
              itemBuilder: (BuildContext itemBuilderContext, int index) {
                if (postCardActionItemsToUse[index].postCardAction == PostCardAction.shareLink &&
                    (postViewMedia.media.isEmpty || (postViewMedia.media.first.mediaType != MediaType.link && postViewMedia.media.first.mediaType != MediaType.image))) {
                  return Container();
                }

                if (postCardActionItemsToUse[index].postCardAction == PostCardAction.shareMedia && (postViewMedia.media.isEmpty || postViewMedia.media.first.mediaUrl == null)) {
                  return Container();
                }

                return PickerItem(
                  label: postCardActionItemsToUse[index].label,
                  icon: postCardActionItemsToUse[index].icon,
                  onSelected: (postCardActionItemsToUse[index].shouldEnable?.call(isUserLoggedIn) ?? true)
                      ? () => onSelected(context, postCardActionItemsToUse[index].postCardAction, postViewMedia, useAdvancedShareSheet)
                      : null,
                );
              },
            ),
            const SizedBox(height: 16.0),
          ],
        ),
      );
    },
  );
}

void onTapCommunityName(BuildContext context, int communityId) {
  navigateToFeedPage(context, feedType: FeedType.community, communityId: communityId);
}

void onSelected(BuildContext context, PostCardAction postCardAction, PostViewMedia postViewMedia, bool useAdvancedShareSheet) async {
  Navigator.of(context).pop();

  switch (postCardAction) {
    case PostCardAction.visitCommunity:
      onTapCommunityName(context, postViewMedia.postView.community.id);
      break;
    case PostCardAction.visitProfile:
      navigateToUserPage(context, userId: postViewMedia.postView.post.creatorId);
      break;
    case PostCardAction.visitInstance:
      navigateToInstancePage(context, instanceHost: fetchInstanceNameFromUrl(postViewMedia.postView.community.actorId)!, instanceId: postViewMedia.postView.community.instanceId);
      break;
    case PostCardAction.sharePost:
      Share.share(postViewMedia.postView.post.apId);
      break;
    case PostCardAction.shareMedia:
      if (postViewMedia.media.first.mediaUrl != null) {
        try {
          // Try to get the cached image first
          var media = await DefaultCacheManager().getFileFromCache(postViewMedia.media.first.mediaUrl!);
          File? mediaFile = media?.file;

          if (media == null) {
            // Tell user we're downloading the image
            showSnackbar(context, AppLocalizations.of(context)!.downloadingMedia);

            // Download
            mediaFile = await DefaultCacheManager().getSingleFile(postViewMedia.media.first.mediaUrl!);

            // Hide snackbar
            hideSnackbar(context);
          }

          // Share
          await Share.shareXFiles([XFile(mediaFile!.path)]);
        } catch (e) {
          // Tell the user that the download failed
          showSnackbar(context, AppLocalizations.of(context)!.errorDownloadingMedia(e));
        }
      }
      break;
    case PostCardAction.shareLink:
      if (postViewMedia.media.first.originalUrl != null) Share.share(postViewMedia.media.first.originalUrl!);
      break;
    case PostCardAction.blockInstance:
      context.read<InstanceBloc>().add(InstanceActionEvent(
            instanceAction: InstanceAction.block,
            instanceId: postViewMedia.postView.community.instanceId,
            domain: fetchInstanceNameFromUrl(postViewMedia.postView.community.actorId),
            value: true,
          ));
      break;
    case PostCardAction.blockCommunity:
      context.read<CommunityBloc>().add(CommunityActionEvent(communityAction: CommunityAction.block, communityId: postViewMedia.postView.community.id, value: true));
      break;
    case PostCardAction.upvote:
      context.read<FeedBloc>().add(FeedItemActionedEvent(postAction: PostAction.vote, postId: postViewMedia.postView.post.id, value: postViewMedia.postView.myVote == 1 ? 0 : 1));
      break;
    case PostCardAction.downvote:
      context.read<FeedBloc>().add(FeedItemActionedEvent(postAction: PostAction.vote, postId: postViewMedia.postView.post.id, value: postViewMedia.postView.myVote == -1 ? 0 : -1));
      break;
    case PostCardAction.save:
      context.read<FeedBloc>().add(FeedItemActionedEvent(postAction: PostAction.save, postId: postViewMedia.postView.post.id, value: !postViewMedia.postView.saved));
      break;
    case PostCardAction.toggleRead:
      context.read<FeedBloc>().add(FeedItemActionedEvent(postAction: PostAction.read, postId: postViewMedia.postView.post.id, value: !postViewMedia.postView.read));
      break;
    case PostCardAction.share:
      useAdvancedShareSheet
          ? showAdvancedShareSheet(context, postViewMedia)
          : postViewMedia.media.isEmpty
              ? Share.share(postViewMedia.postView.post.apId)
              : showPostActionBottomModalSheet(
                  context,
                  postViewMedia,
                  actionsToInclude: [PostCardAction.sharePost, PostCardAction.shareMedia, PostCardAction.shareLink],
                );
      break;
    case PostCardAction.blockUser:
      context.read<UserBloc>().add(BlockUserEvent(personId: postViewMedia.postView.creator.id, blocked: true));
      break;
    case PostCardAction.subscribeToCommunity:
      context.read<CommunityBloc>().add(CommunityActionEvent(communityAction: CommunityAction.follow, communityId: postViewMedia.postView.community.id, value: true));
      break;
    case PostCardAction.unsubscribeFromCommunity:
      context.read<CommunityBloc>().add(CommunityActionEvent(communityAction: CommunityAction.follow, communityId: postViewMedia.postView.community.id, value: false));
      break;
  }
}
