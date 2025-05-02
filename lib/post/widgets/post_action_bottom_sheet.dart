import 'dart:async';

import 'package:flutter/material.dart';

import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:thunder/community/enums/community_action.dart';
import 'package:thunder/community/widgets/post_card_metadata.dart';
import 'package:thunder/core/enums/full_name.dart';
import 'package:thunder/core/models/models.dart';
import 'package:thunder/post/enums/post_action.dart';
import 'package:thunder/post/widgets/community_post_action_bottom_sheet.dart';
import 'package:thunder/post/widgets/general_post_action_bottom_sheet.dart';
import 'package:thunder/instance/widgets/instance_action_bottom_sheet.dart';
import 'package:thunder/post/widgets/post_post_action_bottom_sheet.dart';
import 'package:thunder/shared/share/share_action_bottom_sheet.dart';
import 'package:thunder/user/widgets/user_action_bottom_sheet.dart';
import 'package:thunder/user/enums/user_action.dart';
import 'package:thunder/utils/instance.dart';
import 'package:thunder/utils/global_context.dart';

final l10n = AppLocalizations.of(GlobalContext.context)!;

/// Programatically show the post action bottom sheet
void showPostActionBottomModalSheet(
  BuildContext context,
  ThunderPost post, {
  GeneralPostAction page = GeneralPostAction.general,
  void Function({PostAction? postAction, UserAction? userAction, CommunityAction? communityAction, ThunderPost? post})? onAction,
}) {
  showModalBottomSheet(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (_) => PostActionBottomSheet(context: context, initialPage: page, post: post, onAction: onAction),
  );
}

class PostActionBottomSheet extends StatefulWidget {
  const PostActionBottomSheet({super.key, required this.context, required this.post, this.initialPage = GeneralPostAction.general, required this.onAction});

  /// The parent context
  final BuildContext context;

  /// The post that is being acted on
  final ThunderPost post;

  /// The initial page of the bottom sheet
  final GeneralPostAction initialPage;

  /// The callback that is called when an action is performed
  final void Function({PostAction? postAction, UserAction? userAction, CommunityAction? communityAction, required ThunderPost? post})? onAction;

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
    ThunderPost post = widget.post;

    String? communityInstance = fetchInstanceNameFromUrl(post.community?.url);
    String? userInstance = fetchInstanceNameFromUrl(post.creator?.url);

    switch (page) {
      case GeneralPostAction.user:
        return generateUserFullName(context, post.creator?.name, post.creator?.displayName, fetchInstanceNameFromUrl(post.creator?.url));
      case GeneralPostAction.community:
        return generateCommunityFullName(context, post.community?.name, post.community?.title, fetchInstanceNameFromUrl(post.community?.url));
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
          post: widget.post,
          onSwitchActivePage: (page) => setState(() => currentPage = page),
          onAction: (PostAction postAction, ThunderPost? post) {
            widget.onAction?.call(postAction: postAction, post: widget.post);
          },
        ),
      GeneralPostAction.post => PostPostActionBottomSheet(
          context: widget.context,
          post: widget.post,
          onAction: (PostAction postAction, ThunderPost? post) {
            widget.onAction?.call(postAction: postAction, post: widget.post);
          },
        ),
      GeneralPostAction.user => UserActionBottomSheet(
          context: widget.context,
          user: widget.post.creator!,
          communityId: widget.post.community?.id,
          isUserCommunityModerator: widget.post.creatorIsModerator,
          isUserBannedFromCommunity: widget.post.creatorBannedFromCommunity,
          onAction: (UserAction userAction, ThunderUser? updatedUser) {
            widget.onAction?.call(userAction: userAction, post: widget.post);
          },
        ),
      GeneralPostAction.community => CommunityPostActionBottomSheet(
          post: widget.post,
          onAction: (CommunityAction communityAction, ThunderCommunity? updatedCommunity) {
            widget.onAction?.call(communityAction: communityAction, post: widget.post);
          },
        ),
      GeneralPostAction.instance => InstanceActionBottomSheet(
          userInstanceId: widget.post.creator?.instanceId,
          userInstanceUrl: widget.post.creator?.url,
          communityInstanceId: widget.post.community?.instanceId,
          communityInstanceUrl: widget.post.community?.url,
          onAction: () {},
        ),
      GeneralPostAction.share => ShareActionBottomSheet(
          context: widget.context,
          post: widget.post,
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
                  child: LanguagePostCardMetaData(languageId: widget.post.languageId),
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
