import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lemmy_api_client/v3.dart';

import 'package:thunder/comment/enums/comment_action.dart';
import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/core/enums/full_name.dart';
import 'package:thunder/post/enums/post_action.dart';
import 'package:thunder/post/widgets/post_action_bottom_sheet.dart';
import 'package:thunder/shared/bottom_sheet_action.dart';
import 'package:thunder/shared/multi_picker_item.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/utils/instance.dart';

/// Defines the general actions that can be taken on a comment
enum GeneralCommentAction {
  general(icon: Icons.more_horiz),
  comment(icon: Icons.comment_rounded),
  user(icon: Icons.person_rounded),
  instance(icon: Icons.language_rounded),
  share(icon: Icons.share);

  String get name => switch (this) {
        GeneralCommentAction.general => l10n.actions,
        GeneralCommentAction.comment => l10n.comment,
        GeneralCommentAction.user => l10n.user,
        GeneralCommentAction.instance => l10n.instance(1),
        GeneralCommentAction.share => l10n.share,
      };

  /// The title to use for the action. This is shown when the given page is active
  String get title => switch (this) {
        GeneralCommentAction.general => l10n.actions,
        GeneralCommentAction.comment => 'Comment Actions',
        GeneralCommentAction.user => l10n.userActions,
        GeneralCommentAction.instance => l10n.instanceActions,
        GeneralCommentAction.share => l10n.share,
      };

  /// The icon to use for the action
  final IconData icon;

  const GeneralCommentAction({required this.icon});
}

enum GeneralQuickCommentAction {
  upvote(enabledIcon: Icons.arrow_upward_rounded, disabledIcon: Icons.arrow_upward_rounded, permissionType: PermissionType.user, requiresAuthentication: true),
  downvote(enabledIcon: Icons.arrow_downward_rounded, disabledIcon: Icons.arrow_downward_rounded, permissionType: PermissionType.user, requiresAuthentication: true),
  save(enabledIcon: Icons.star_rounded, disabledIcon: Icons.star_outline_rounded, permissionType: PermissionType.user, requiresAuthentication: true),
  reply(enabledIcon: Icons.reply_rounded, disabledIcon: Icons.reply_outlined, permissionType: PermissionType.user, requiresAuthentication: true),
  edit(enabledIcon: Icons.edit_rounded, disabledIcon: Icons.edit_outlined, permissionType: PermissionType.user, requiresAuthentication: true),
  ;

  /// The icon to use for the action when it is enabled
  final IconData enabledIcon;

  /// The icon to use for the action when it is disabled
  final IconData disabledIcon;

  /// The permission type to use for the action
  final PermissionType permissionType;

  /// Whether or not the action requires user authentication
  final bool requiresAuthentication;

  const GeneralQuickCommentAction({required this.enabledIcon, required this.disabledIcon, required this.permissionType, required this.requiresAuthentication});
}

/// Defines the general top-level actions that can be taken on a comment.
/// Given a [commentView] and a [onSwitchActivePage] callback, this widget will display a list of actions that can be taken on the comment.
class GeneralCommentActionBottomSheetPage extends StatefulWidget {
  const GeneralCommentActionBottomSheetPage({super.key, required this.context, required this.commentView, required this.onSwitchActivePage, required this.onAction});

  /// The outer context
  final BuildContext context;

  /// The comment information
  final CommentView commentView;

  /// Called when the active page is changed
  final Function(GeneralCommentAction page) onSwitchActivePage;

  /// Called when an action is selected
  final Function(CommentAction commentAction, CommentView? commentView, dynamic value) onAction;

  @override
  State<GeneralCommentActionBottomSheetPage> createState() => _GeneralCommentActionBottomSheetPageState();
}

class _GeneralCommentActionBottomSheetPageState extends State<GeneralCommentActionBottomSheetPage> {
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

  void performAction(GeneralQuickCommentAction action) {
    final commentView = widget.commentView;

    switch (action) {
      case GeneralQuickCommentAction.upvote:
        widget.onAction(CommentAction.vote, commentView, commentView.myVote == 1 ? 0 : 1);
        break;
      case GeneralQuickCommentAction.downvote:
        widget.onAction(CommentAction.vote, commentView, commentView.myVote == -1 ? 0 : -1);
        break;
      case GeneralQuickCommentAction.save:
        widget.onAction(CommentAction.save, commentView, !commentView.saved);
        break;
      case GeneralQuickCommentAction.reply:
        Navigator.of(context).pop();
        widget.onAction(CommentAction.reply, commentView, null);
        return;
      case GeneralQuickCommentAction.edit:
        Navigator.of(context).pop();
        widget.onAction(CommentAction.edit, commentView, null);
        return;
    }

    Navigator.of(context).pop();
  }

  IconData getIcon(GeneralQuickCommentAction action) {
    final commentView = widget.commentView;

    switch (action) {
      case GeneralQuickCommentAction.upvote:
        return commentView.myVote == 1 ? GeneralQuickCommentAction.upvote.enabledIcon : GeneralQuickCommentAction.upvote.disabledIcon;
      case GeneralQuickCommentAction.downvote:
        return commentView.myVote == -1 ? GeneralQuickCommentAction.downvote.enabledIcon : GeneralQuickCommentAction.downvote.disabledIcon;
      case GeneralQuickCommentAction.save:
        return commentView.saved ? GeneralQuickCommentAction.save.enabledIcon : GeneralQuickCommentAction.save.disabledIcon;
      case GeneralQuickCommentAction.reply:
        return GeneralQuickCommentAction.reply.enabledIcon;
      case GeneralQuickCommentAction.edit:
        return GeneralQuickCommentAction.edit.enabledIcon;
    }
  }

  String getLabel(GeneralQuickCommentAction action) {
    final commentView = widget.commentView;

    switch (action) {
      case GeneralQuickCommentAction.upvote:
        return commentView.myVote == 1 ? l10n.upvoted : l10n.upvote;
      case GeneralQuickCommentAction.downvote:
        return commentView.myVote == -1 ? l10n.downvoted : l10n.downvote;
      case GeneralQuickCommentAction.save:
        return commentView.saved ? l10n.saved : l10n.save;
      case GeneralQuickCommentAction.reply:
        return l10n.reply(1);
      case GeneralQuickCommentAction.edit:
        return l10n.edit;
    }
  }

  Color? getBackgroundColor(GeneralQuickCommentAction action) {
    final state = context.read<ThunderBloc>().state;

    switch (action) {
      case GeneralQuickCommentAction.upvote:
        return state.upvoteColor.color;
      case GeneralQuickCommentAction.downvote:
        return state.downvoteColor.color;
      case GeneralQuickCommentAction.save:
        return state.saveColor.color;
      case GeneralQuickCommentAction.reply:
        return state.replyColor.color;
      case GeneralQuickCommentAction.edit:
        return state.replyColor.color;
    }
  }

  Color? getForegroundColor(GeneralQuickCommentAction action) {
    final state = context.read<ThunderBloc>().state;
    final commentView = widget.commentView;

    switch (action) {
      case GeneralQuickCommentAction.upvote:
        return commentView.myVote == 1 ? state.upvoteColor.color : null;
      case GeneralQuickCommentAction.downvote:
        return commentView.myVote == -1 ? state.downvoteColor.color : null;
      case GeneralQuickCommentAction.save:
        return commentView.saved ? state.saveColor.color : null;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final isLoggedIn = authState.isLoggedIn;

    List<GeneralQuickCommentAction> quickActions = GeneralQuickCommentAction.values.where((element) => element.permissionType == PermissionType.user).toList();

    if (!isLoggedIn) {
      quickActions = quickActions.where((action) => action.requiresAuthentication == false).toList();
    } else {
      // Hide downvoted if instance does not support it
      if (!authState.downvotesEnabled) {
        quickActions = quickActions.where((action) => action != GeneralQuickCommentAction.downvote).toList();
      }

      // Hide edit if the comment is not made by the current user
      if (widget.commentView.creator.actorId != authState.account?.actorId) {
        quickActions = quickActions.where((action) => action != GeneralQuickCommentAction.edit).toList();
      }
    }

    // Determine the available sub-menus to display
    List<GeneralCommentAction> submenus = GeneralCommentAction.values.where((page) => page != GeneralCommentAction.general).toList();

    return Column(
      children: [
        if (quickActions.isNotEmpty)
          MultiPickerItem(
            pickerItems: quickActions
                .map((generalQuickCommentAction) => PickerItemData(
                      icon: getIcon(generalQuickCommentAction),
                      label: getLabel(generalQuickCommentAction),
                      foregroundColor: getForegroundColor(generalQuickCommentAction),
                      backgroundColor: getBackgroundColor(generalQuickCommentAction),
                      onSelected: isLoggedIn ? () => performAction(generalQuickCommentAction) : null,
                    ))
                .toList(),
          ),
        ...submenus
            .map(
              (page) => BottomSheetAction(
                leading: Icon(page.icon),
                trailing: const Icon(Icons.chevron_right_rounded),
                title: page.name,
                subtitle: generateSubtitle(page),
                onTap: () => widget.onSwitchActivePage(page),
              ),
            )
            .toList() as List<Widget>,
      ],
    );
  }
}
