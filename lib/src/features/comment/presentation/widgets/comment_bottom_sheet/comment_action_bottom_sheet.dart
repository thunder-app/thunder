import 'dart:async';

import 'package:flutter/material.dart';

import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/features/comment/comment.dart';
import 'package:thunder/src/features/community/community.dart';
import 'package:thunder/src/foundation/primitives/primitives.dart';
import 'package:thunder/src/features/settings/api.dart';
import 'package:thunder/src/features/account/data/cache/profile_site_info_cache.dart';
import 'package:thunder/src/features/instance/instance.dart';
import 'package:thunder/src/shared/share/share_action_bottom_sheet.dart';
import 'package:thunder/src/features/user/user.dart';
import 'package:thunder/src/features/instance/domain/utils/instance_link_utils.dart';

/// Programatically show the comment action bottom sheet
void showCommentActionBottomModalSheet(
  BuildContext context,
  ThunderComment comment, {
  bool isShowingSource = false,
  GeneralCommentAction page = GeneralCommentAction.general,
  void Function({CommentAction? commentAction, UserAction? userAction, CommunityAction? communityAction, ThunderComment? comment})? onAction,
}) {
  showModalBottomSheet(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (_) => CommentActionBottomSheet(context: context, initialPage: page, comment: comment, onAction: onAction, isShowingSource: isShowingSource),
  );
}

class CommentActionBottomSheet extends StatefulWidget {
  const CommentActionBottomSheet({super.key, required this.context, required this.comment, this.initialPage = GeneralCommentAction.general, required this.onAction, this.isShowingSource = false});

  /// The parent context
  final BuildContext context;

  /// The comment that is being acted on
  final ThunderComment comment;

  /// Whether the source of the comment is being shown
  final bool isShowingSource;

  /// The initial page of the bottom sheet
  final GeneralCommentAction initialPage;

  /// The callback that is called when an action is performed
  final void Function({CommentAction? commentAction, UserAction? userAction, CommunityAction? communityAction, ThunderComment? comment})? onAction;

  @override
  State<CommentActionBottomSheet> createState() => _CommentActionBottomSheetState();
}

class _CommentActionBottomSheetState extends State<CommentActionBottomSheet> {
  /// The account that is performing the action
  late Account account;

  /// Whether or not the downvotes are enabled
  bool downvotesEnabled = true;

  /// List of moderated communities
  List<ThunderCommunity> moderatedCommunities = [];

  /// List of blocked users
  List<ThunderUser> blockedUsers = [];

  /// List of blocked instances
  List<ThunderInstanceBlock> blockedInstances = [];

  /// The current page of the bottom sheet
  GeneralCommentAction currentPage = GeneralCommentAction.general;

  FutureOr<bool> _handleBack(bool stopDefaultButtonEvent, RouteInfo routeInfo) {
    if (currentPage != GeneralCommentAction.general) {
      setState(() => currentPage = GeneralCommentAction.general);
      return true;
    }

    return false;
  }

  @override
  void initState() {
    super.initState();
    account = context.read<ProfileBloc>().state.account;

    currentPage = widget.initialPage;
    BackButtonInterceptor.add(_handleBack);
    WidgetsBinding.instance.addPostFrameCallback((_) => getUserInformation());
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(_handleBack);
    super.dispose();
  }

  Future<void> getUserInformation() async {
    if (account.anonymous) return;

    final siteInfo = await ProfileSiteInfoCache.instance.get(account);

    if (!mounted) return;
    setState(() {
      downvotesEnabled = siteInfo.site.enableDownvotes ?? true;
      blockedUsers = siteInfo.myUser?.personBlocks ?? [];
      blockedInstances = siteInfo.myUser?.instanceBlocks ?? [];
      moderatedCommunities = siteInfo.myUser?.moderates ?? [];
    });
  }

  String? generateSubtitle(GeneralCommentAction page) {
    final comment = widget.comment;

    String? userInstance = fetchInstanceNameFromUrl(comment.creator!.actorId);

    switch (page) {
      case GeneralCommentAction.user:
        return generateUserFullName(context, comment.creator!.name, comment.creator!.displayName, userInstance);
      case GeneralCommentAction.instance:
        return userInstance;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget actions = switch (currentPage) {
      GeneralCommentAction.general => GeneralCommentActionBottomSheetPage(
          account: account,
          context: widget.context,
          downvotesEnabled: downvotesEnabled,
          comment: widget.comment,
          onSwitchActivePage: (page) => setState(() => currentPage = page),
          onAction: (CommentAction commentAction, ThunderComment? updatedComment) {
            widget.onAction?.call(commentAction: commentAction, comment: updatedComment);
          },
        ),
      GeneralCommentAction.comment => CommentCommentActionBottomSheet(
          account: account,
          moderatedCommunities: moderatedCommunities,
          context: widget.context,
          comment: widget.comment,
          isShowingSource: widget.isShowingSource,
          onAction: (CommentAction commentAction, ThunderComment? updatedComment) {
            widget.onAction?.call(commentAction: commentAction, comment: updatedComment);
          },
        ),
      GeneralCommentAction.user => UserActionBottomSheet(
          account: account,
          context: widget.context,
          blockedUsers: blockedUsers,
          moderatedCommunities: moderatedCommunities,
          user: widget.comment.creator!,
          communityId: widget.comment.community!.id,
          isUserCommunityModerator: widget.comment.creatorIsModerator,
          isUserBannedFromCommunity: widget.comment.creatorBannedFromCommunity,
          onAction: (UserAction userAction, ThunderUser? updatedUser) {
            ProfileSiteInfoCache.instance.markDirty(account);
            widget.onAction?.call(userAction: userAction, comment: widget.comment);
          },
        ),
      GeneralCommentAction.instance => InstanceActionBottomSheet(
          account: account,
          blockedInstances: blockedInstances,
          userInstanceId: widget.comment.creator!.instanceId,
          userInstanceUrl: widget.comment.creator!.actorId,
          onAction: () {
            ProfileSiteInfoCache.instance.markDirty(account);
          },
        ),
      GeneralCommentAction.share => ShareActionBottomSheet(
          account: account,
          context: widget.context,
          comment: widget.comment,
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
                  currentPage != GeneralCommentAction.general
                      ? IconButton(onPressed: () => setState(() => currentPage = GeneralCommentAction.general), icon: const Icon(Icons.chevron_left_rounded))
                      : const SizedBox(width: 12.0),
                  Wrap(
                    direction: Axis.vertical,
                    children: [
                      Text(currentPage.title, style: theme.textTheme.titleLarge),
                      if (currentPage != GeneralCommentAction.general && currentPage != GeneralCommentAction.share && currentPage != GeneralCommentAction.comment)
                        Text(generateSubtitle(currentPage) ?? ''),
                    ],
                  ),
                ],
              ),
              if (currentPage == GeneralCommentAction.general)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                  child: LanguagePostCardMetaData(languageId: widget.comment.languageId),
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
