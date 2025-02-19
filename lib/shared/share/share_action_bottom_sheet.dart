import 'dart:io';

import 'package:flutter/material.dart';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:share_plus/share_plus.dart';

import 'package:thunder/core/enums/media_type.dart';
import 'package:thunder/core/models/post_view_media.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/post/enums/post_action.dart';
import 'package:thunder/shared/share/advanced_share_sheet.dart';
import 'package:thunder/shared/bottom_sheet_action.dart';
import 'package:thunder/shared/snackbar.dart';
import 'package:thunder/utils/global_context.dart';

/// Defines the actions that can be taken on a post when sharing
enum ShareBottomSheetAction {
  shareComment(icon: Icons.comment_rounded, permissionType: PermissionType.user, requiresAuthentication: false),
  shareCommentLocal(icon: Icons.comment_rounded, permissionType: PermissionType.user, requiresAuthentication: false),
  sharePost(icon: Icons.share_rounded, permissionType: PermissionType.user, requiresAuthentication: false),
  sharePostLocal(icon: Icons.share_rounded, permissionType: PermissionType.user, requiresAuthentication: false),
  shareImage(icon: Icons.image_rounded, permissionType: PermissionType.user, requiresAuthentication: false),
  shareMedia(icon: Icons.personal_video_rounded, permissionType: PermissionType.user, requiresAuthentication: false),
  shareLink(icon: Icons.link_rounded, permissionType: PermissionType.user, requiresAuthentication: false),
  shareAdvanced(icon: Icons.screen_share_rounded, permissionType: PermissionType.user, requiresAuthentication: false),
  ;

  String get name => switch (this) {
        ShareBottomSheetAction.shareComment => GlobalContext.l10n.shareComment,
        ShareBottomSheetAction.shareCommentLocal => GlobalContext.l10n.shareCommentLocal,
        ShareBottomSheetAction.sharePost => GlobalContext.l10n.sharePost,
        ShareBottomSheetAction.sharePostLocal => GlobalContext.l10n.sharePostLocal,
        ShareBottomSheetAction.shareImage => GlobalContext.l10n.shareImage,
        ShareBottomSheetAction.shareMedia => GlobalContext.l10n.shareMediaLink,
        ShareBottomSheetAction.shareLink => GlobalContext.l10n.shareLink,
        ShareBottomSheetAction.shareAdvanced => GlobalContext.l10n.advanced,
      };

  /// The icon to use for the action
  final IconData icon;

  /// The permission type to use for the action
  final PermissionType permissionType;

  /// Whether or not the action requires user authentication
  final bool requiresAuthentication;

  const ShareBottomSheetAction({required this.icon, required this.permissionType, required this.requiresAuthentication});
}

/// A bottom sheet that allows the user to perform share actions.
///
/// Given a [postViewMedia] or a [commentView], and a [onAction] callback, this widget will display a list of share actions that can be taken.
class ShareActionBottomSheet extends StatefulWidget {
  const ShareActionBottomSheet({super.key, required this.context, this.postViewMedia, this.commentView, required this.onAction});

  /// The parent context
  final BuildContext context;

  /// The post information
  final PostViewMedia? postViewMedia;

  /// The comment information
  final CommentView? commentView;

  /// Called when an action is selected
  final Function() onAction;

  @override
  State<ShareActionBottomSheet> createState() => _ShareActionBottomSheetState();
}

class _ShareActionBottomSheetState extends State<ShareActionBottomSheet> {
  void retrieveMedia(String? url) async {
    if (url == null) return;

    try {
      // Try to get the cached image first
      var media = await DefaultCacheManager().getFileFromCache(url);
      File? mediaFile = media?.file;

      if (media == null) {
        showSnackbar(GlobalContext.l10n.downloadingMedia);
        mediaFile = await DefaultCacheManager().getSingleFile(url);
      }

      await Share.shareXFiles([XFile(mediaFile!.path)]);
    } catch (e) {
      showSnackbar(GlobalContext.l10n.errorDownloadingMedia(e));
    }
  }

  void performAction(ShareBottomSheetAction action) {
    PostViewMedia? postViewMedia = widget.postViewMedia;
    CommentView? commentView = widget.commentView;

    switch (action) {
      case ShareBottomSheetAction.shareComment:
        Share.share(commentView!.comment.apId);
        break;
      case ShareBottomSheetAction.shareCommentLocal:
        Share.share(LemmyClient.instance.generateCommentUrl(commentView!.comment.id));
        break;
      case ShareBottomSheetAction.sharePost:
        Share.share(postViewMedia!.postView.post.apId);
        break;
      case ShareBottomSheetAction.sharePostLocal:
        Share.share(LemmyClient.instance.generatePostUrl(postViewMedia!.postView.post.id));
        break;
      case ShareBottomSheetAction.shareImage:
        retrieveMedia(postViewMedia!.media.first.imageUrl!);
        break;
      case ShareBottomSheetAction.shareMedia:
        Share.share(postViewMedia!.media.first.mediaUrl!);
        break;
      case ShareBottomSheetAction.shareLink:
        if (postViewMedia!.media.first.originalUrl != null) Share.share(postViewMedia.media.first.originalUrl!);
        break;
      case ShareBottomSheetAction.shareAdvanced:
        showAdvancedShareSheet(widget.context, postViewMedia!);
        break;
    }
  }

  String? generateSubtitle(ShareBottomSheetAction action) {
    PostViewMedia? postViewMedia = widget.postViewMedia;
    CommentView? commentView = widget.commentView;

    switch (action) {
      case ShareBottomSheetAction.shareComment:
        return commentView!.comment.apId;
      case ShareBottomSheetAction.shareCommentLocal:
        return LemmyClient.instance.generateCommentUrl(commentView!.comment.id);
      case ShareBottomSheetAction.sharePost:
        return postViewMedia!.postView.post.apId;
      case ShareBottomSheetAction.sharePostLocal:
        return LemmyClient.instance.generatePostUrl(postViewMedia!.postView.post.id);
      case ShareBottomSheetAction.shareImage:
        return postViewMedia!.media.first.imageUrl;
      case ShareBottomSheetAction.shareMedia:
        return postViewMedia!.media.first.mediaUrl;
      case ShareBottomSheetAction.shareLink:
        return postViewMedia!.media.first.originalUrl;
      case ShareBottomSheetAction.shareAdvanced:
        return GlobalContext.l10n.useAdvancedShareSheet;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check to see if we are sharing a post or a comment.
    List<ShareBottomSheetAction> userActions = [];

    if (widget.commentView != null) {
      userActions = [ShareBottomSheetAction.shareComment, ShareBottomSheetAction.shareCommentLocal];

      // Remove the share local option if it is the same as the original
      if (widget.commentView!.comment.apId == LemmyClient.instance.generateCommentUrl(widget.commentView!.comment.id)) {
        userActions.removeWhere((action) => action == ShareBottomSheetAction.shareCommentLocal);
      }
    } else if (widget.postViewMedia != null) {
      userActions = ShareBottomSheetAction.values.where((element) => element != ShareBottomSheetAction.shareComment && element != ShareBottomSheetAction.shareCommentLocal).toList();

      // Remove the share link option if there is no link or if the media link is the same as the external link
      if (widget.postViewMedia!.media.isEmpty ||
          widget.postViewMedia!.media.first.mediaType == MediaType.text ||
          widget.postViewMedia!.media.first.originalUrl == widget.postViewMedia!.media.first.imageUrl ||
          widget.postViewMedia!.media.first.originalUrl == widget.postViewMedia!.media.first.mediaUrl) {
        userActions.removeWhere((action) => action == ShareBottomSheetAction.shareLink);
      }

      // Remove the share image option if there is no image
      if (widget.postViewMedia!.media.isEmpty || widget.postViewMedia!.media.first.imageUrl?.isNotEmpty != true) {
        userActions.removeWhere((action) => action == ShareBottomSheetAction.shareImage);
      }

      // Remove the share media option if there is no media
      if (widget.postViewMedia!.media.isEmpty || widget.postViewMedia!.media.first.mediaUrl?.isNotEmpty != true) {
        userActions.removeWhere((action) => action == ShareBottomSheetAction.shareMedia);
      }

      // Remove the share local option if it is the same as the original
      if (widget.postViewMedia!.postView.post.apId == LemmyClient.instance.generatePostUrl(widget.postViewMedia!.postView.post.id)) {
        userActions.removeWhere((action) => action == ShareBottomSheetAction.sharePostLocal);
      }
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...userActions
            .map(
              (sharePostAction) => BottomSheetAction(
                leading: Icon(sharePostAction.icon),
                trailing: sharePostAction == ShareBottomSheetAction.shareAdvanced ? const Icon(Icons.chevron_right_rounded) : null,
                subtitle: generateSubtitle(sharePostAction),
                title: sharePostAction.name,
                onTap: () => performAction(sharePostAction),
              ),
            )
            .toList() as List<Widget>,
      ],
    );
  }
}
