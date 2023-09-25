import 'dart:io';
import 'package:flutter/material.dart';

import 'package:share_plus/share_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import 'package:thunder/community/bloc/community_bloc.dart';
import 'package:thunder/core/enums/media_type.dart';
import 'package:thunder/core/models/post_view_media.dart';
import 'package:thunder/feed/utils/utils.dart';
import 'package:thunder/feed/view/feed_page.dart';
import 'package:thunder/shared/picker_item.dart';
import 'package:thunder/shared/snackbar.dart';
import 'package:thunder/utils/navigate_user.dart';

enum PostCardAction { visitProfile, visitCommunity, sharePost, shareMedia, shareLink, blockCommunity }

class ExtendedPostCardActions {
  const ExtendedPostCardActions({required this.postCardAction, required this.icon, required this.label});

  final PostCardAction postCardAction;
  final IconData icon;
  final String label;
}

const postCardActionItems = [
  ExtendedPostCardActions(
    postCardAction: PostCardAction.visitCommunity,
    icon: Icons.home_work_rounded,
    label: 'Visit Community',
  ),
  ExtendedPostCardActions(
    postCardAction: PostCardAction.blockCommunity,
    icon: Icons.block_rounded,
    label: 'Block Community',
  ),
  ExtendedPostCardActions(
    postCardAction: PostCardAction.visitProfile,
    icon: Icons.person_search_rounded,
    label: 'Visit User Profile',
  ),
  ExtendedPostCardActions(
    postCardAction: PostCardAction.sharePost,
    icon: Icons.share_rounded,
    label: 'Share Post',
  ),
  ExtendedPostCardActions(
    postCardAction: PostCardAction.shareMedia,
    icon: Icons.image_rounded,
    label: 'Share Media',
  ),
  ExtendedPostCardActions(
    postCardAction: PostCardAction.shareLink,
    icon: Icons.link_rounded,
    label: 'Share Link',
  ),
];

void showPostActionBottomModalSheet(BuildContext context, PostViewMedia postViewMedia, {List<PostCardAction>? actionsToInclude}) {
  final theme = Theme.of(context);
  actionsToInclude ??= [];
  final postCardActionItemsToUse = postCardActionItems.where((extendedAction) => actionsToInclude!.any((action) => extendedAction.postCardAction == action)).toList();

  showModalBottomSheet<void>(
    showDragHandle: true,
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
                  onSelected: () async {
                    Navigator.of(context).pop();

                    PostCardAction postCardAction = postCardActionItemsToUse[index].postCardAction;

                    switch (postCardAction) {
                      case PostCardAction.visitCommunity:
                        onTapCommunityName(context, postViewMedia.postView.community.id);
                        break;
                      case PostCardAction.visitProfile:
                        navigateToUserPage(context, userId: postViewMedia.postView.post.creatorId);
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
                      case PostCardAction.blockCommunity:
                        context.read<CommunityBloc>().add(BlockCommunityEvent(communityId: postViewMedia.postView.community.id, block: true));
                        break;
                    }
                  },
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

void onTapUserName(BuildContext context, int userId) {
  navigateToUserPage(context, userId: userId);
}
