import 'dart:io';

import 'package:flutter/material.dart';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:share_plus/share_plus.dart';

import 'package:thunder/src/features/account/api.dart';
import 'package:thunder/src/foundation/networking/instance_uri.dart';
import 'package:thunder/src/foundation/primitives/primitives.dart';
import 'package:thunder/src/features/post/api.dart';
import 'package:thunder/src/shared/share/advanced_share_sheet/advanced_share_sheet.dart';
import 'package:thunder/src/foundation/config/global_context.dart';
import 'package:thunder/packages/ui/ui.dart';

/// Defines the actions that can be taken on a post when sharing
enum ShareBottomSheetAction {
  shareComment(
    icon: Icons.comment_rounded,
    permissionType: PermissionType.all,
    requiresAuthentication: false,
  ),
  shareCommentLocal(
    icon: Icons.comment_rounded,
    permissionType: PermissionType.all,
    requiresAuthentication: false,
  ),
  sharePost(
    icon: Icons.share_rounded,
    permissionType: PermissionType.all,
    requiresAuthentication: false,
  ),
  sharePostLocal(
    icon: Icons.share_rounded,
    permissionType: PermissionType.all,
    requiresAuthentication: false,
  ),
  shareImage(
    icon: Icons.image_rounded,
    permissionType: PermissionType.all,
    requiresAuthentication: false,
  ),
  shareMedia(
    icon: Icons.personal_video_rounded,
    permissionType: PermissionType.all,
    requiresAuthentication: false,
  ),
  shareLink(
    icon: Icons.link_rounded,
    permissionType: PermissionType.all,
    requiresAuthentication: false,
  ),
  shareAdvanced(
    icon: Icons.screen_share_rounded,
    permissionType: PermissionType.all,
    requiresAuthentication: false,
  );

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
class ShareActionBottomSheet extends StatefulWidget {
  const ShareActionBottomSheet({super.key, required this.context, required this.account, this.post, this.comment});

  /// The parent context
  final BuildContext context;

  /// The account to use for the share actions
  final Account account;

  /// The post information
  final ThunderPost? post;

  /// The comment information
  final ThunderComment? comment;

  @override
  State<ShareActionBottomSheet> createState() => _ShareActionBottomSheetState();
}

class _ShareActionBottomSheetState extends State<ShareActionBottomSheet> {
  String generateCommentUrl(int commentId) {
    final account = widget.account;
    return buildInstanceUrl(account.instance, '/comment/$commentId');
  }

  String generatePostUrl(int postId) {
    final account = widget.account;
    return buildInstanceUrl(account.instance, '/post/$postId');
  }

  void retrieveMedia(String? url) async {
    final l10n = GlobalContext.l10n;

    if (url == null) return;

    try {
      // Try to get the cached image first
      final media = await DefaultCacheManager().getFileFromCache(url);
      File? mediaFile = media?.file;

      if (media == null) {
        showThunderSnackbar(l10n.downloadingMedia);
        mediaFile = await DefaultCacheManager().getSingleFile(url);
      }

      await SharePlus.instance.share(ShareParams(
        files: [XFile(mediaFile!.path)],
        sharePositionOrigin: Rect.fromLTWH(0, 0, 1, 1),
      ));
    } catch (e) {
      showThunderSnackbar(l10n.errorDownloadingMedia(e));
    }
  }

  void performAction(ShareBottomSheetAction action) {
    final post = widget.post;
    final comment = widget.comment;

    switch (action) {
      case ShareBottomSheetAction.shareComment:
        SharePlus.instance.share(ShareParams(
          uri: Uri.parse(comment!.apId),
          sharePositionOrigin: Rect.fromLTWH(0, 0, 1, 1),
        ));
        break;
      case ShareBottomSheetAction.shareCommentLocal:
        SharePlus.instance.share(ShareParams(
          uri: Uri.parse(generateCommentUrl(comment!.id)),
          sharePositionOrigin: Rect.fromLTWH(0, 0, 1, 1),
        ));
        break;
      case ShareBottomSheetAction.sharePost:
        SharePlus.instance.share(ShareParams(
          uri: Uri.parse(post!.apId),
          sharePositionOrigin: Rect.fromLTWH(0, 0, 1, 1),
        ));
        break;
      case ShareBottomSheetAction.sharePostLocal:
        SharePlus.instance.share(ShareParams(
          uri: Uri.parse(generatePostUrl(post!.id)),
          sharePositionOrigin: Rect.fromLTWH(0, 0, 1, 1),
        ));
        break;
      case ShareBottomSheetAction.shareImage:
        retrieveMedia(post!.media.first.imageUrl!);
        break;
      case ShareBottomSheetAction.shareMedia:
        SharePlus.instance.share(ShareParams(
          uri: Uri.parse(post!.media.first.mediaUrl!),
          sharePositionOrigin: Rect.fromLTWH(0, 0, 1, 1),
        ));
        break;
      case ShareBottomSheetAction.shareLink:
        if (post!.media.first.originalUrl != null) {
          SharePlus.instance.share(ShareParams(
            uri: Uri.parse(post.media.first.originalUrl!),
            sharePositionOrigin: Rect.fromLTWH(0, 0, 1, 1),
          ));
        }
        break;
      case ShareBottomSheetAction.shareAdvanced:
        showAdvancedShareSheet(widget.context, post!);
        break;
    }
  }

  String? generateSubtitle(ShareBottomSheetAction action) {
    final l10n = GlobalContext.l10n;
    final post = widget.post;
    final comment = widget.comment;

    switch (action) {
      case ShareBottomSheetAction.shareComment:
        return comment!.apId;
      case ShareBottomSheetAction.shareCommentLocal:
        return generateCommentUrl(comment!.id);
      case ShareBottomSheetAction.sharePost:
        return post!.apId;
      case ShareBottomSheetAction.sharePostLocal:
        return generatePostUrl(post!.id);
      case ShareBottomSheetAction.shareImage:
        return post!.media.first.imageUrl;
      case ShareBottomSheetAction.shareMedia:
        return post!.media.first.mediaUrl;
      case ShareBottomSheetAction.shareLink:
        return post!.media.first.originalUrl;
      case ShareBottomSheetAction.shareAdvanced:
        return l10n.useAdvancedShareSheet;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check to see if we are sharing a post or a comment.
    List<ShareBottomSheetAction> userActions = [];

    if (widget.comment != null) {
      userActions = [ShareBottomSheetAction.shareComment, ShareBottomSheetAction.shareCommentLocal];

      // Remove the share local option if it is the same as the original
      if (widget.comment!.apId == generateCommentUrl(widget.comment!.id)) {
        userActions.removeWhere((action) => action == ShareBottomSheetAction.shareCommentLocal);
      }
    } else if (widget.post != null) {
      userActions = ShareBottomSheetAction.values.where((element) => element != ShareBottomSheetAction.shareComment && element != ShareBottomSheetAction.shareCommentLocal).toList();

      // Remove the share link option if there is no link or if the media link is the same as the external link
      if (widget.post!.media.isEmpty ||
          widget.post!.media.first.mediaType == MediaType.text ||
          widget.post!.media.first.originalUrl == widget.post!.media.first.imageUrl ||
          widget.post!.media.first.originalUrl == widget.post!.media.first.mediaUrl) {
        userActions.removeWhere((action) => action == ShareBottomSheetAction.shareLink);
      }

      // Remove the share image option if there is no image
      if (widget.post!.media.isEmpty || widget.post!.media.first.imageUrl?.isNotEmpty != true) {
        userActions.removeWhere((action) => action == ShareBottomSheetAction.shareImage);
      }

      // Remove the share media option if there is no media
      if (widget.post!.media.isEmpty || widget.post!.media.first.mediaUrl?.isNotEmpty != true) {
        userActions.removeWhere((action) => action == ShareBottomSheetAction.shareMedia);
      }

      // Remove the share local option if it is the same as the original
      if (widget.post!.apId == generatePostUrl(widget.post!.id)) {
        userActions.removeWhere((action) => action == ShareBottomSheetAction.sharePostLocal);
      }
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...userActions.map<Widget>(
          (sharePostAction) => ThunderBottomSheetAction(
            title: sharePostAction.name,
            subtitle: generateSubtitle(sharePostAction),
            leading: Icon(sharePostAction.icon),
            trailing: sharePostAction == ShareBottomSheetAction.shareAdvanced ? const Icon(Icons.chevron_right_rounded) : null,
            onTap: () => performAction(sharePostAction),
          ),
        ),
      ],
    );
  }
}
