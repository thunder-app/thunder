import 'dart:async';

import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:lemmy_api_client/v3.dart';

import 'package:thunder/core/enums/full_name.dart';
import 'package:thunder/core/models/post_view_media.dart';
import 'package:thunder/post/enums/post_action.dart';
import 'package:thunder/post/widgets/community_post_action_bottom_sheet.dart';
import 'package:thunder/post/widgets/general_post_action_bottom_sheet.dart';
import 'package:thunder/post/widgets/instance_post_action_bottom_sheet.dart';
import 'package:thunder/post/widgets/post_post_action_bottom_sheet.dart';
import 'package:thunder/post/widgets/share_post_action_bottom_sheet.dart';
import 'package:thunder/post/widgets/user_post_action_bottom_sheet.dart';
import 'package:thunder/utils/instance.dart';
import 'package:thunder/utils/global_context.dart';

final l10n = AppLocalizations.of(GlobalContext.context)!;

/// Programatically show the post action bottom sheet
void showPostActionBottomModalSheet(
  BuildContext context,
  PostViewMedia postViewMedia, {
  GeneralPostAction page = GeneralPostAction.general,
  void Function({PostAction? action})? onAction,
}) {
  showModalBottomSheet(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (_) => PostActionBottomSheet(context: context, postViewMedia: postViewMedia),
  );
}

class PostActionBottomSheet extends StatefulWidget {
  const PostActionBottomSheet({super.key, required this.context, required this.postViewMedia, this.initialPage = GeneralPostAction.general});

  /// The parent context
  final BuildContext context;

  /// The post that is being acted on
  final PostViewMedia postViewMedia;

  /// The initial page of the bottom sheet
  final GeneralPostAction initialPage;

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
      GeneralPostAction.post => PostPostActionBottomSheet(
          context: widget.context,
          postViewMedia: widget.postViewMedia,
          onAction: () {},
        ),
      GeneralPostAction.general => GeneralPostActionBottomSheetPage(
          context: widget.context,
          postViewMedia: widget.postViewMedia,
          onSwitchActivePage: (page) => setState(() => currentPage = page),
        ),
      GeneralPostAction.user => UserPostActionBottomSheet(
          postViewMedia: widget.postViewMedia,
          onAction: (PersonView? updatedPersonView) {},
        ),
      GeneralPostAction.community => CommunityPostActionBottomSheet(
          postViewMedia: widget.postViewMedia,
          onAction: (CommunityView? updatedCommunityView) {},
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
              const SizedBox(height: 16.0),
              actions,
            ],
          ),
        ),
      ),
    );
  }
}


// final List<PostActionBottomSheet> postCardActionItems = [
//   PostActionBottomSheet(
//     postCardAction: PostCardAction.delete,
//     icon: Icons.delete_rounded,
//     label: l10n.delete,
//     getOverrideIcon: (postView) => postView.post.deleted ? Icons.restore_from_trash_rounded : Icons.delete_rounded,
//     getOverrideLabel: (context, postView) => postView.post.deleted ? l10n.restore : l10n.delete,
//   ),
//   PostActionBottomSheet(
//     postCardAction: PostCardAction.moderatorLockPost,
//     icon: Icons.lock,
//     label: l10n.lockPost,
//     getOverrideIcon: (postView) => postView.post.locked ? Icons.lock_open_rounded : Icons.lock,
//     getOverrideLabel: (context, postView) => postView.post.locked ? l10n.unlockPost : l10n.lockPost,
//   ),
//   PostActionBottomSheet(
//     postCardAction: PostCardAction.moderatorPinCommunity,
//     icon: Icons.push_pin_rounded,
//     label: l10n.pinToCommunity,
//     getOverrideIcon: (postView) => postView.post.featuredCommunity ? Icons.push_pin_rounded : Icons.push_pin_outlined,
//     getOverrideLabel: (context, postView) => postView.post.featuredCommunity ? l10n.unpinFromCommunity : l10n.pinToCommunity,
//   ),
//   PostActionBottomSheet(
//     postCardAction: PostCardAction.moderatorRemovePost,
//     icon: Icons.delete_forever_rounded,
//     label: l10n.removePost,
//     getOverrideIcon: (postView) => postView.post.removed ? Icons.restore_from_trash_rounded : Icons.delete_forever_rounded,
//     getOverrideLabel: (context, postView) => postView.post.removed ? l10n.restorePost : l10n.removePost,
//   )
// ];


// void showPostActionBottomModalSheet(
//   BuildContext context,
//   PostViewMedia postViewMedia, {
//   PostActionBottomSheetPage page = PostActionBottomSheetPage.general,
//   void Function(int userId)? onBlockedUser,
//   void Function(int userId)? onBlockedCommunity,
//   void Function(int postId)? onPostHidden,
// }) {

//   // Add the moderator actions submenu
//   if (isModerator) {
//     defaultPostCardActions.add(postCardActionItems.firstWhere((PostActionBottomSheet extendedPostCardActions) => extendedPostCardActions.postCardAction == PostCardAction.moderatorActions));
//   }


//   // Generate the list of moderator actions
//   final List<PostActionBottomSheet> moderatorPostCardActions = postCardActionItems
//       .where((extendedAction) => [
//             PostCardAction.moderatorLockPost,
//             PostCardAction.moderatorPinCommunity,
//             PostCardAction.moderatorRemovePost,
//           ].contains(extendedAction.postCardAction))
//       .toList();


//   // Generate the list of community actions
//   final List<PostActionBottomSheet> communityActions = postCardActionItems
//       .where((extendedAction) => [
//             PostCardAction.visitCommunity,
//             postViewMedia.postView.subscribed == SubscribedType.notSubscribed ? PostCardAction.subscribeToCommunity : PostCardAction.unsubscribeFromCommunity,
//             PostCardAction.blockCommunity,
//           ].contains(extendedAction.postCardAction))
//       .toList();

//   // Hide the option to block a community if the user is subscribed to it
//   if (communityActions.any((extendedAction) => extendedAction.postCardAction == PostCardAction.blockCommunity) && postViewMedia.postView.subscribed != SubscribedType.notSubscribed) {
//     communityActions.removeWhere((PostActionBottomSheet postCardActionItem) => postCardActionItem.postCardAction == PostCardAction.blockCommunity);
//   }

//   // Generate the list of instance actions
//   final List<PostActionBottomSheet> instanceActions = postCardActionItems
//       .where((extendedAction) => [
//             PostCardAction.visitCommunityInstance,
//             PostCardAction.blockCommunityInstance,
//             PostCardAction.visitUserInstance,
//             PostCardAction.blockUserInstance,
//           ].contains(extendedAction.postCardAction))
//       .toList();

//   // Remove block if unsupported
//   if (instanceActions.any((extendedAction) => extendedAction.postCardAction == PostCardAction.blockCommunityInstance) && !LemmyClient.instance.supportsFeature(LemmyFeature.blockInstance)) {
//     instanceActions.removeWhere((PostActionBottomSheet postCardActionItem) => postCardActionItem.postCardAction == PostCardAction.blockCommunityInstance);
//   }
//   if (instanceActions.any((extendedAction) => extendedAction.postCardAction == PostCardAction.blockUserInstance) && !LemmyClient.instance.supportsFeature(LemmyFeature.blockInstance)) {
//     instanceActions.removeWhere((PostActionBottomSheet postCardActionItem) => postCardActionItem.postCardAction == PostCardAction.blockUserInstance);
//   }

//   // Hide user block if user's instance is the same as the community' sinstance
//   bool areSameInstance = areCommunityAndUserOnSameInstance(postViewMedia.postView);
//   if (instanceActions.any((extendedAction) => extendedAction.postCardAction == PostCardAction.visitUserInstance) && areSameInstance) {
//     instanceActions.removeWhere((PostActionBottomSheet postCardActionItem) => postCardActionItem.postCardAction == PostCardAction.visitUserInstance);
//   }
//   if (instanceActions.any((extendedAction) => extendedAction.postCardAction == PostCardAction.blockUserInstance) && areSameInstance) {
//     instanceActions.removeWhere((PostActionBottomSheet postCardActionItem) => postCardActionItem.postCardAction == PostCardAction.blockUserInstance);
//   }

//   showModalBottomSheet<void>(
//     showDragHandle: true,
//     isScrollControlled: true,
//     context: context,
//     builder: (builderContext) => PostCardActionPicker(
//       postViewMedia: postViewMedia,
//       page: page,
//       postCardActions: {
//         PostActionBottomSheetPage.general: defaultPostCardActions,
//         PostActionBottomSheetPage.moderator: moderatorPostCardActions,
//         PostActionBottomSheetPage.share: sharePostCardActions,
//         PostActionBottomSheetPage.user: userActions,
//         PostActionBottomSheetPage.community: communityActions,
//         PostActionBottomSheetPage.instance: instanceActions,
//       },
//       multiPostCardActions: {PostActionBottomSheetPage.general: defaultMultiPostCardActions},
//       titles: {
//         PostActionBottomSheetPage.general: l10n.actions,
//         PostActionBottomSheetPage.moderator: l10n.moderatorActions,
//         PostActionBottomSheetPage.share: l10n.share,
//         PostActionBottomSheetPage.user: l10n.userActions,
//         PostActionBottomSheetPage.community: l10n.communityActions,
//         PostActionBottomSheetPage.instance: l10n.instanceActions,
//       },
//       outerContext: context,
//       onBlockedUser: onBlockedUser,
//       onBlockedCommunity: onBlockedCommunity,
//       onPostHidden: onPostHidden,
//     ),
//   );
// }


// class _PostCardActionPickerState extends State<PostCardActionPicker> {
//   PostActionBottomSheetPage? page;

//   @override
//   Widget build(BuildContext context) {
//     final ThemeData theme = Theme.of(context);
//     final bool isUserLoggedIn = context.read<AuthBloc>().state.isLoggedIn;

//     return SingleChildScrollView(
//       child: AnimatedSize(
//         duration: const Duration(milliseconds: 100),
//         curve: Curves.easeInOut,
//         child: SingleChildScrollView(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.start,
//             mainAxisSize: MainAxisSize.max,
//             children: [
//               // Post metadata chips
//               if ((page ?? PostActionBottomSheetPage.general) == PostActionBottomSheetPage.general)
//                 Row(
//                   children: [
//                     const SizedBox(width: 20),
//                     LanguagePostCardMetaData(languageId: widget.postViewMedia.postView.post.languageId),
//                   ],
//                 ),
//               if (widget.multiPostCardActions[page ?? widget.page]?.isNotEmpty == true)
//                 MultiPickerItem(
//                   pickerItems: [
//                     ...widget.multiPostCardActions[page ?? widget.page]!.where((a) => a.shouldShow?.call(context, widget.postViewMedia.postView) ?? true).map(
//                       (a) {
//                         return PickerItemData(
//                           label: a.getOverrideLabel?.call(context, widget.postViewMedia.postView) ?? a.label,
//                           icon: a.getOverrideIcon?.call(widget.postViewMedia.postView) ?? a.icon,
//                           backgroundColor: a.getColor?.call(context),
//                           foregroundColor: a.getForegroundColor?.call(context, widget.postViewMedia.postView),
//                           onSelected: (a.shouldEnable?.call(isUserLoggedIn) ?? true) ? () => onSelected(a.postCardAction) : null,
//                         );
//                       },
//                     ),
//                   ],
//                 ),

//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   void onSelected(PostCardAction postCardAction) async {
//     switch (postCardAction) {
//       case PostCardAction.upvote:
//         action = () => widget.outerContext
//             .read<FeedBloc>()
//             .add(FeedItemActionedEvent(postAction: PostAction.vote, postId: widget.postViewMedia.postView.post.id, value: widget.postViewMedia.postView.myVote == 1 ? 0 : 1));
//         break;
//       case PostCardAction.downvote:
//         action = () => widget.outerContext
//             .read<FeedBloc>()
//             .add(FeedItemActionedEvent(postAction: PostAction.vote, postId: widget.postViewMedia.postView.post.id, value: widget.postViewMedia.postView.myVote == -1 ? 0 : -1));
//         break;
//       case PostCardAction.save:
//         action = () =>
//             widget.outerContext.read<FeedBloc>().add(FeedItemActionedEvent(postAction: PostAction.save, postId: widget.postViewMedia.postView.post.id, value: !widget.postViewMedia.postView.saved));
//         break;
//       case PostCardAction.toggleRead:
//         action = () =>
//             widget.outerContext.read<FeedBloc>().add(FeedItemActionedEvent(postAction: PostAction.read, postId: widget.postViewMedia.postView.post.id, value: !widget.postViewMedia.postView.read));
//         break;
//       case PostCardAction.hide:
//         action = () => widget.outerContext
//             .read<FeedBloc>()
//             .add(FeedItemActionedEvent(postAction: PostAction.hide, postId: widget.postViewMedia.postView.post.id, value: !(widget.postViewMedia.postView.hidden ?? false)));
//         widget.onPostHidden?.call(widget.postViewMedia.postView.post.id);
//         break;
//       case PostCardAction.delete:
//         action = () => widget.outerContext
//             .read<FeedBloc>()
//             .add(FeedItemActionedEvent(postAction: PostAction.delete, postId: widget.postViewMedia.postView.post.id, value: !widget.postViewMedia.postView.post.deleted));
//         break;
//       case PostCardAction.moderatorActions:
//         action = () => setState(() => page = PostActionBottomSheetPage.moderator);
//         pop = false;
//         break;
//       case PostCardAction.moderatorLockPost:
//         action = () => widget.outerContext
//             .read<FeedBloc>()
//             .add(FeedItemActionedEvent(postAction: PostAction.lock, postId: widget.postViewMedia.postView.post.id, value: !widget.postViewMedia.postView.post.locked));
//         break;
//       case PostCardAction.moderatorPinCommunity:
//         action = () => widget.outerContext
//             .read<FeedBloc>()
//             .add(FeedItemActionedEvent(postAction: PostAction.pinCommunity, postId: widget.postViewMedia.postView.post.id, value: !widget.postViewMedia.postView.post.featuredCommunity));
//         break;
//       case PostCardAction.moderatorRemovePost:
//         action = () => showRemovePostReasonBottomSheet(widget.outerContext, widget.postViewMedia);
//         break;
//     }
//   }
// }

