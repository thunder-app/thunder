import 'dart:async';

import 'package:flutter/material.dart';

import 'package:back_button_interceptor/back_button_interceptor.dart';

import 'package:thunder/comment/comment.dart';
import 'package:thunder/community/enums/community_action.dart';
import 'package:thunder/community/widgets/post_card_metadata.dart';
import 'package:thunder/core/enums/full_name.dart';
import 'package:thunder/core/models/models.dart';
import 'package:thunder/instance/widgets/instance_action_bottom_sheet.dart';
import 'package:thunder/shared/share/share_action_bottom_sheet.dart';
import 'package:thunder/user/enums/user_action.dart';
import 'package:thunder/user/widgets/user_action_bottom_sheet.dart';
import 'package:thunder/utils/instance.dart';

/// Programatically show the comment action bottom sheet
void showCommentActionBottomModalSheet(
  BuildContext context,
  ThunderComment comment, {
  bool isShowingSource = false,
  GeneralCommentAction page = GeneralCommentAction.general,
  void Function({CommentAction? commentAction, UserAction? userAction, CommunityAction? communityAction, required ThunderComment comment, dynamic value})? onAction,
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
  final void Function({CommentAction? commentAction, UserAction? userAction, CommunityAction? communityAction, required ThunderComment comment, dynamic value})? onAction;

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
    final comment = widget.comment;

    assert(comment.creator != null, 'Comment must have a creator');

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

    assert(widget.comment.creator != null && widget.comment.community != null, 'Comment must have a creator and community');

    Widget actions = switch (currentPage) {
      GeneralCommentAction.general => GeneralCommentActionBottomSheetPage(
          context: widget.context,
          comment: widget.comment,
          onSwitchActivePage: (page) => setState(() => currentPage = page),
          onAction: (CommentAction commentAction, ThunderComment? updatedComment, dynamic value) {
            widget.onAction?.call(commentAction: commentAction, comment: widget.comment, value: value);
          },
        ),
      GeneralCommentAction.comment => CommentCommentActionBottomSheet(
          context: widget.context,
          comment: widget.comment,
          isShowingSource: widget.isShowingSource,
          onAction: (CommentAction commentAction, ThunderComment? updatedComment, dynamic value) {
            widget.onAction?.call(commentAction: commentAction, comment: widget.comment, value: value);
          },
        ),
      GeneralCommentAction.user => UserActionBottomSheet(
          context: widget.context,
          user: ThunderUser(widget.comment.creator!),
          communityId: widget.comment.community!.id,
          isUserCommunityModerator: widget.comment.creatorIsModerator,
          isUserBannedFromCommunity: widget.comment.creatorBannedFromCommunity,
          onAction: (UserAction userAction, ThunderUser? updatedUser) {
            widget.onAction?.call(userAction: userAction, comment: widget.comment);
          },
        ),
      GeneralCommentAction.instance => InstanceActionBottomSheet(
          userInstanceId: widget.comment.creator!.instanceId,
          userInstanceUrl: widget.comment.creator!.actorId,
          onAction: () {},
        ),
      GeneralCommentAction.share => ShareActionBottomSheet(
          context: widget.context,
          comment: widget.comment,
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
