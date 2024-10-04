import 'dart:async';

import 'package:flutter/material.dart';

import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:lemmy_api_client/v3.dart';

import 'package:thunder/community/enums/community_action.dart';
import 'package:thunder/community/widgets/post_card_metadata.dart';
import 'package:thunder/core/enums/full_name.dart';
import 'package:thunder/core/models/post_view_media.dart';
import 'package:thunder/post/enums/post_action.dart';
import 'package:thunder/post/widgets/community_post_action_bottom_sheet.dart';
import 'package:thunder/post/widgets/general_post_action_bottom_sheet.dart';
import 'package:thunder/post/widgets/instance_post_action_bottom_sheet.dart';
import 'package:thunder/post/widgets/post_post_action_bottom_sheet.dart';
import 'package:thunder/post/widgets/share_post_action_bottom_sheet.dart';
import 'package:thunder/post/widgets/user_post_action_bottom_sheet.dart';
import 'package:thunder/user/enums/user_action.dart';
import 'package:thunder/utils/instance.dart';
import 'package:thunder/utils/global_context.dart';

final l10n = AppLocalizations.of(GlobalContext.context)!;

/// Programatically show the post action bottom sheet
void showPostActionBottomModalSheet(
  BuildContext context,
  PostViewMedia postViewMedia, {
  GeneralPostAction page = GeneralPostAction.general,
  void Function({PostAction? postAction, UserAction? userAction, CommunityAction? communityAction, required PostViewMedia postViewMedia})? onAction,
}) {
  showModalBottomSheet(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (_) => PostActionBottomSheet(context: context, postViewMedia: postViewMedia, onAction: onAction),
  );
}

class PostActionBottomSheet extends StatefulWidget {
  const PostActionBottomSheet({super.key, required this.context, required this.postViewMedia, this.initialPage = GeneralPostAction.general, required this.onAction});

  /// The parent context
  final BuildContext context;

  /// The post that is being acted on
  final PostViewMedia postViewMedia;

  /// The initial page of the bottom sheet
  final GeneralPostAction initialPage;

  /// The callback that is called when an action is performed
  final void Function({PostAction? postAction, UserAction? userAction, CommunityAction? communityAction, required PostViewMedia postViewMedia})? onAction;

  @override
  State<PostActionBottomSheet> createState() => _PostActionBottomSheetState();
}

class _PostActionBottomSheetState extends State<PostActionBottomSheet> {
  GeneralPostAction currentPage = GeneralPostAction.general;

  FutureOr<bool> _handleBack(bool stopDefaultButtonEvent, RouteInfo routeInfo) {
    if (currentPage != GeneralPostAction.general) {
      setState(() => currentPage = GeneralPostAction.general);
      return true;
    }

    return false;
  }

  @override
  void initState() {
    super.initState();
    currentPage = widget.initialPage;
    BackButtonInterceptor.add(_handleBack);
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(_handleBack);
    super.dispose();
  }

  String? generateSubtitle(GeneralPostAction page) {
    PostViewMedia postViewMedia = widget.postViewMedia;

    String? communityInstance = fetchInstanceNameFromUrl(postViewMedia.postView.community.actorId);
    String? userInstance = fetchInstanceNameFromUrl(postViewMedia.postView.creator.actorId);

    switch (page) {
      case GeneralPostAction.user:
        return generateUserFullName(context, postViewMedia.postView.creator.name, postViewMedia.postView.creator.displayName, fetchInstanceNameFromUrl(postViewMedia.postView.creator.actorId));
      case GeneralPostAction.community:
        return generateCommunityFullName(context, postViewMedia.postView.community.name, postViewMedia.postView.community.title, fetchInstanceNameFromUrl(postViewMedia.postView.community.actorId));
      case GeneralPostAction.instance:
        return (communityInstance == userInstance) ? '$communityInstance' : '$communityInstance • $userInstance';
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget actions = switch (currentPage) {
      GeneralPostAction.general => GeneralPostActionBottomSheetPage(
          context: widget.context,
          postViewMedia: widget.postViewMedia,
          onSwitchActivePage: (page) => setState(() => currentPage = page),
          onAction: (PostAction postAction, PostViewMedia? updatedPostViewMedia) {
            widget.onAction?.call(postAction: postAction, postViewMedia: widget.postViewMedia);
          },
        ),
      GeneralPostAction.post => PostPostActionBottomSheet(
          context: widget.context,
          postViewMedia: widget.postViewMedia,
          onAction: (PostAction postAction, PostViewMedia? updatedPostViewMedia) {
            widget.onAction?.call(postAction: postAction, postViewMedia: widget.postViewMedia);
          },
        ),
      GeneralPostAction.user => UserPostActionBottomSheet(
          postViewMedia: widget.postViewMedia,
          onAction: (UserAction userAction, PersonView? updatedPersonView) {
            widget.onAction?.call(userAction: userAction, postViewMedia: widget.postViewMedia);
          },
        ),
      GeneralPostAction.community => CommunityPostActionBottomSheet(
          postViewMedia: widget.postViewMedia,
          onAction: (CommunityAction communityAction, CommunityView? updatedCommunityView) {
            widget.onAction?.call(communityAction: communityAction, postViewMedia: widget.postViewMedia);
          },
        ),
      GeneralPostAction.instance => InstancePostActionBottomSheet(
          postViewMedia: widget.postViewMedia,
          onAction: () {},
        ),
      GeneralPostAction.share => SharePostActionBottomSheet(
          context: widget.context,
          postViewMedia: widget.postViewMedia,
          onAction: () {},
        ),
    };

    return SafeArea(
      child: AnimatedSize(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubicEmphasized,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  currentPage != GeneralPostAction.general
                      ? IconButton(onPressed: () => setState(() => currentPage = GeneralPostAction.general), icon: const Icon(Icons.chevron_left_rounded))
                      : const SizedBox(width: 12.0),
                  Wrap(
                    direction: Axis.vertical,
                    children: [
                      Text(currentPage.title, style: theme.textTheme.titleLarge),
                      if (currentPage != GeneralPostAction.general && currentPage != GeneralPostAction.share && currentPage != GeneralPostAction.post) Text(generateSubtitle(currentPage) ?? ''),
                    ],
                  ),
                ],
              ),
              if (currentPage == GeneralPostAction.general)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                  child: LanguagePostCardMetaData(languageId: widget.postViewMedia.postView.post.languageId),
                ),
              const SizedBox(height: 16.0),
              actions,
            ],
          ),
        ),
      ),
    );
  }
}
