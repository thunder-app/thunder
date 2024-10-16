import 'dart:io';

import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import 'package:thunder/core/enums/media_type.dart';
import 'package:thunder/core/models/post_view_media.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/instance/bloc/instance_bloc.dart';
import 'package:thunder/post/enums/post_action.dart';
import 'package:thunder/post/utils/comment_action_helpers.dart';
import 'package:thunder/shared/advanced_share_sheet.dart';
import 'package:thunder/shared/bottom_sheet_action.dart';
import 'package:thunder/shared/snackbar.dart';

/// Defines the actions that can be taken on a post when sharing
enum SharePostAction {
  sharePost(icon: Icons.share_rounded, permissionType: PermissionType.user, requiresAuthentication: false),
  sharePostLocal(icon: Icons.share_rounded, permissionType: PermissionType.user, requiresAuthentication: false),
  shareImage(icon: Icons.image_rounded, permissionType: PermissionType.user, requiresAuthentication: false),
  shareMedia(icon: Icons.personal_video_rounded, permissionType: PermissionType.user, requiresAuthentication: false),
  shareLink(icon: Icons.link_rounded, permissionType: PermissionType.user, requiresAuthentication: false),
  shareAdvanced(icon: Icons.screen_share_rounded, permissionType: PermissionType.user, requiresAuthentication: false),
  ;

  String get name => switch (this) {
        SharePostAction.sharePost => l10n.sharePost,
        SharePostAction.sharePostLocal => l10n.sharePostLocal,
        SharePostAction.shareImage => l10n.shareImage,
        SharePostAction.shareMedia => l10n.shareMediaLink,
        SharePostAction.shareLink => l10n.shareLink,
        SharePostAction.shareAdvanced => l10n.advanced,
      };

  /// The icon to use for the action
  final IconData icon;

  /// The permission type to use for the action
  final PermissionType permissionType;

  /// Whether or not the action requires user authentication
  final bool requiresAuthentication;

  const SharePostAction({required this.icon, required this.permissionType, required this.requiresAuthentication});
}

/// A bottom sheet that allows the user to perform actions on a instance.
///
/// Given a [postViewMedia] and a [onAction] callback, this widget will display a list of actions that can be taken on the instance.
class SharePostActionBottomSheet extends StatefulWidget {
  const SharePostActionBottomSheet({super.key, required this.context, required this.postViewMedia, required this.onAction});

  /// The parent context
  final BuildContext context;

  /// The post information
  final PostViewMedia postViewMedia;

  /// Called when an action is selected
  final Function() onAction;

  @override
  State<SharePostActionBottomSheet> createState() => _SharePostActionBottomSheetState();
}

class _SharePostActionBottomSheetState extends State<SharePostActionBottomSheet> {
  void retrieveMedia(String? url) async {
    if (url == null) return;

    try {
      // Try to get the cached image first
      var media = await DefaultCacheManager().getFileFromCache(url);
      File? mediaFile = media?.file;

      if (media == null) {
        showSnackbar(l10n.downloadingMedia);
        mediaFile = await DefaultCacheManager().getSingleFile(url);
      }

      await Share.shareXFiles([XFile(mediaFile!.path)]);
    } catch (e) {
      showSnackbar(l10n.errorDownloadingMedia(e));
    }
  }

  void performAction(SharePostAction action) {
    switch (action) {
      case SharePostAction.sharePost:
        Share.share(widget.postViewMedia.postView.post.apId);
        break;
      case SharePostAction.sharePostLocal:
        Share.share(LemmyClient.instance.generatePostUrl(widget.postViewMedia.postView.post.id));
        break;
      case SharePostAction.shareImage:
        retrieveMedia(widget.postViewMedia.media.first.imageUrl!);
        break;
      case SharePostAction.shareMedia:
        Share.share(widget.postViewMedia.media.first.mediaUrl!);
        break;
      case SharePostAction.shareLink:
        if (widget.postViewMedia.media.first.originalUrl != null) Share.share(widget.postViewMedia.media.first.originalUrl!);
        break;
      case SharePostAction.shareAdvanced:
        showAdvancedShareSheet(widget.context, widget.postViewMedia);
        break;
      default:
        break;
    }
  }

  String? generateSubtitle(SharePostAction action) {
    PostViewMedia postViewMedia = widget.postViewMedia;

    switch (action) {
      case SharePostAction.sharePost:
        return postViewMedia.postView.post.apId;
      case SharePostAction.sharePostLocal:
        return LemmyClient.instance.generatePostUrl(postViewMedia.postView.post.id);
      case SharePostAction.shareImage:
        return postViewMedia.media.first.imageUrl;
      case SharePostAction.shareMedia:
        return postViewMedia.media.first.mediaUrl;
      case SharePostAction.shareLink:
        return postViewMedia.media.first.originalUrl;
      case SharePostAction.shareAdvanced:
        return l10n.useAdvancedShareSheet;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    List<SharePostAction> userActions = SharePostAction.values.where((element) => element.permissionType == PermissionType.user).toList();

    // Remove the share link option if there is no link or if the media link is the same as the external link
    if (widget.postViewMedia.media.isEmpty ||
        widget.postViewMedia.media.first.mediaType == MediaType.text ||
        widget.postViewMedia.media.first.originalUrl == widget.postViewMedia.media.first.imageUrl ||
        widget.postViewMedia.media.first.originalUrl == widget.postViewMedia.media.first.mediaUrl) {
      userActions.removeWhere((action) => action == SharePostAction.shareLink);
    }

    // Remove the share image option if there is no image
    if (widget.postViewMedia.media.isEmpty || widget.postViewMedia.media.first.imageUrl?.isNotEmpty != true) {
      userActions.removeWhere((action) => action == SharePostAction.shareImage);
    }

    // Remove the share media option if there is no media
    if (widget.postViewMedia.media.isEmpty || widget.postViewMedia.media.first.mediaUrl?.isNotEmpty != true) {
      userActions.removeWhere((action) => action == SharePostAction.shareMedia);
    }

    // Remove the share local option if it is the same as the original
    if (widget.postViewMedia.postView.post.apId == LemmyClient.instance.generatePostUrl(widget.postViewMedia.postView.post.id)) {
      userActions.removeWhere((action) => action == SharePostAction.sharePostLocal);
    }

    return BlocListener<InstanceBloc, InstanceState>(
      listener: (context, state) {
        if (state.status == InstanceStatus.success) {
          context.pop();
          widget.onAction();
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...userActions
              .map(
                (sharePostAction) => BottomSheetAction(
                  leading: Icon(sharePostAction.icon),
                  trailing: sharePostAction == SharePostAction.shareAdvanced ? const Icon(Icons.chevron_right_rounded) : null,
                  subtitle: generateSubtitle(sharePostAction),
                  title: sharePostAction.name,
                  onTap: () => performAction(sharePostAction),
                ),
              )
              .toList() as List<Widget>,
        ],
      ),
    );
  }
}
