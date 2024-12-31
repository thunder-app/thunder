import 'dart:async';

import 'package:flutter/material.dart';

import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:lemmy_api_client/v3.dart';

import 'package:thunder/comment/enums/comment_action.dart';
import 'package:thunder/comment/widgets/general_comment_action_bottom_sheet.dart';
import 'package:thunder/community/enums/community_action.dart';
import 'package:thunder/community/widgets/post_card_metadata.dart';
import 'package:thunder/core/enums/full_name.dart';
import 'package:thunder/instance/widgets/instance_action_bottom_sheet.dart';
import 'package:thunder/user/enums/user_action.dart';
import 'package:thunder/user/widgets/user_action_bottom_sheet.dart';
import 'package:thunder/utils/instance.dart';

/// Programatically show the comment action bottom sheet
void showCommentActionBottomModalSheet(
  BuildContext context,
  CommentView commentView, {
  GeneralCommentAction page = GeneralCommentAction.general,
  void Function({CommentAction? commentAction, UserAction? userAction, CommunityAction? communityAction, required CommentView commentView, dynamic value})? onAction,
}) {
  showModalBottomSheet(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (_) => CommentActionBottomSheet(context: context, initialPage: page, commentView: commentView, onAction: onAction),
  );
}

class CommentActionBottomSheet extends StatefulWidget {
  const CommentActionBottomSheet({super.key, required this.context, required this.commentView, this.initialPage = GeneralCommentAction.general, required this.onAction});

  /// The parent context
  final BuildContext context;

  /// The comment that is being acted on
  final CommentView commentView;

  /// The initial page of the bottom sheet
  final GeneralCommentAction initialPage;

  /// The callback that is called when an action is performed
  final void Function({CommentAction? commentAction, UserAction? userAction, CommunityAction? communityAction, required CommentView commentView, dynamic value})? onAction;

  @override
  State<CommentActionBottomSheet> createState() => _CommentActionBottomSheetState();
}

class _CommentActionBottomSheetState extends State<CommentActionBottomSheet> {
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
    currentPage = widget.initialPage;
    BackButtonInterceptor.add(_handleBack);
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(_handleBack);
    super.dispose();
  }

  String? generateSubtitle(GeneralCommentAction page) {
    CommentView commentView = widget.commentView;

    String? communityInstance = fetchInstanceNameFromUrl(commentView.community.actorId);
    String? userInstance = fetchInstanceNameFromUrl(commentView.creator.actorId);

    switch (page) {
      case GeneralCommentAction.user:
        return generateUserFullName(context, commentView.creator.name, commentView.creator.displayName, fetchInstanceNameFromUrl(commentView.creator.actorId));
      case GeneralCommentAction.instance:
        return (communityInstance == userInstance) ? '$communityInstance' : '$communityInstance • $userInstance';
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget actions = switch (currentPage) {
      GeneralCommentAction.general => GeneralCommentActionBottomSheetPage(
          context: widget.context,
          commentView: widget.commentView,
          onSwitchActivePage: (page) => setState(() => currentPage = page),
          onAction: (CommentAction commentAction, CommentView? updatedCommentView, dynamic value) {
            widget.onAction?.call(commentAction: commentAction, commentView: widget.commentView, value: value);
          },
        ),
      GeneralCommentAction.user => UserActionBottomSheet(
          context: widget.context,
          user: widget.commentView.creator,
          communityId: widget.commentView.community.id,
          isUserCommunityModerator: widget.commentView.creatorIsModerator,
          isUserBannedFromCommunity: widget.commentView.creatorBannedFromCommunity,
          onAction: (UserAction userAction, PersonView? updatedPersonView) {
            widget.onAction?.call(userAction: userAction, commentView: widget.commentView);
          },
        ),
      GeneralCommentAction.instance => InstanceActionBottomSheet(
          userInstanceId: widget.commentView.creator.instanceId,
          userInstanceUrl: widget.commentView.creator.actorId,
          onAction: () {},
        ),
      _ => SizedBox(),

      // GeneralCommentAction.post => PostPostActionBottomSheet(
      //     context: widget.context,
      //     postViewMedia: widget.commentView,
      //     onAction: (PostAction postAction, PostViewMedia? updatedPostViewMedia) {
      //       widget.onAction?.call(postAction: postAction, postViewMedia: widget.commentView);
      //     },
      //   ),

      // GeneralCommentAction.share => SharePostActionBottomSheet(
      //     context: widget.context,
      //     postViewMedia: widget.commentView,
      //     onAction: () {},
      //   ),
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
                  child: LanguagePostCardMetaData(languageId: widget.commentView.comment.languageId),
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
