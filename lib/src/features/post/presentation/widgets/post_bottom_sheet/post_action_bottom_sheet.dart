import 'dart:async';

import 'package:flutter/material.dart';

import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/features/community/community.dart';
import 'package:thunder/src/core/models/thunder_my_user.dart';
import 'package:thunder/src/core/enums/full_name.dart';
import 'package:thunder/src/features/post/post.dart';
import 'package:thunder/src/features/instance/instance.dart';
import 'package:thunder/src/shared/share/share_action_bottom_sheet.dart';
import 'package:thunder/src/features/user/user.dart';
import 'package:thunder/src/shared/utils/instance.dart';
import 'package:thunder/src/shared/profile_site_info_cache.dart';

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
  final void Function({PostAction? postAction, UserAction? userAction, CommunityAction? communityAction, ThunderPost? post})? onAction;

  @override
  State<PostActionBottomSheet> createState() => _PostActionBottomSheetState();
}

class _PostActionBottomSheetState extends State<PostActionBottomSheet> {
  /// The account that is performing the action
  late Account account;

  /// Whether or not the downvotes are enabled
  bool downvotesEnabled = true;

  /// List of subscribed communities
  List<ThunderCommunity> subscribedCommunities = [];

  /// List of blocked communities
  List<ThunderCommunity> blockedCommunities = [];

  /// List of moderated communities
  List<ThunderCommunity> moderatedCommunities = [];

  /// List of blocked users
  List<ThunderUser> blockedUsers = [];

  /// List of blocked instances
  List<ThunderInstanceBlock> blockedInstances = [];

  /// The current page of the bottom sheet
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
      blockedCommunities = siteInfo.myUser?.communityBlocks ?? [];
      subscribedCommunities = siteInfo.myUser?.follows ?? [];
    });
  }

  String? generateSubtitle(GeneralPostAction page) {
    ThunderPost post = widget.post;

    String? communityInstance = fetchInstanceNameFromUrl(post.community?.actorId);
    String? userInstance = fetchInstanceNameFromUrl(post.creator?.actorId);

    switch (page) {
      case GeneralPostAction.user:
        return generateUserFullName(context, post.creator?.name, post.creator?.displayName, fetchInstanceNameFromUrl(post.creator?.actorId));
      case GeneralPostAction.community:
        return generateCommunityFullName(context, post.community?.name, post.community?.title, fetchInstanceNameFromUrl(post.community?.actorId));
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
          account: account,
          context: widget.context,
          downvotesEnabled: downvotesEnabled,
          post: widget.post,
          onSwitchActivePage: (page) => setState(() => currentPage = page),
          onAction: (PostAction postAction, ThunderPost? post) {
            widget.onAction?.call(postAction: postAction, post: post);
          },
        ),
      GeneralPostAction.post => PostPostActionBottomSheet(
          account: account,
          context: widget.context,
          moderatedCommunities: moderatedCommunities,
          post: widget.post,
          onAction: (PostAction postAction, ThunderPost? post) {
            widget.onAction?.call(postAction: postAction, post: post);
          },
        ),
      GeneralPostAction.user => UserActionBottomSheet(
          account: account,
          context: widget.context,
          blockedUsers: blockedUsers,
          moderatedCommunities: moderatedCommunities,
          user: widget.post.creator!,
          communityId: widget.post.community?.id,
          isUserCommunityModerator: widget.post.creatorIsModerator,
          isUserBannedFromCommunity: widget.post.creatorBannedFromCommunity,
          onAction: (UserAction userAction, ThunderUser? updatedUser) {
            ProfileSiteInfoCache.instance.markDirty(account);
            widget.onAction?.call(userAction: userAction, post: widget.post);
          },
        ),
      GeneralPostAction.community => CommunityPostActionBottomSheet(
          account: account,
          post: widget.post,
          moderatedCommunities: moderatedCommunities,
          blockedCommunities: blockedCommunities,
          subscribedCommunities: subscribedCommunities,
          onAction: (CommunityAction communityAction, ThunderCommunity? updatedCommunity) {
            ProfileSiteInfoCache.instance.markDirty(account);
            widget.onAction?.call(
              communityAction: communityAction,
              post: widget.post.copyWith(
                community: updatedCommunity,
                subscribed: updatedCommunity?.subscribed,
              ),
            );
          },
        ),
      GeneralPostAction.instance => InstanceActionBottomSheet(
          account: account,
          blockedInstances: blockedInstances,
          userInstanceId: widget.post.creator?.instanceId,
          userInstanceUrl: widget.post.creator?.actorId,
          communityInstanceId: widget.post.community?.instanceId,
          communityInstanceUrl: widget.post.community?.actorId,
          onAction: () {
            ProfileSiteInfoCache.instance.markDirty(account);
          },
        ),
      GeneralPostAction.share => ShareActionBottomSheet(
          account: account,
          context: widget.context,
          post: widget.post,
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
