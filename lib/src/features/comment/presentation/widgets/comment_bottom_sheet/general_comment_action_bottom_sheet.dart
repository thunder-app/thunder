import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/features/comment/comment.dart';
import 'package:thunder/src/core/enums/full_name.dart';
import 'package:thunder/src/features/post/post.dart';
import 'package:thunder/src/shared/bottom_sheet_action.dart';
import 'package:thunder/src/shared/multi_picker_item.dart';
import 'package:thunder/src/app/bloc/thunder_bloc.dart';
import 'package:thunder/src/app/utils/global_context.dart';
import 'package:thunder/src/shared/utils/instance.dart';

/// Defines the general actions that can be taken on a comment
enum GeneralCommentAction {
  general(icon: Icons.more_horiz),
  comment(icon: Icons.comment_rounded),
  user(icon: Icons.person_rounded),
  instance(icon: Icons.language_rounded),
  share(icon: Icons.share);

  String get name {
    final l10n = GlobalContext.l10n;

    return switch (this) {
      GeneralCommentAction.general => l10n.actions,
      GeneralCommentAction.comment => l10n.comment,
      GeneralCommentAction.user => l10n.user,
      GeneralCommentAction.instance => l10n.instance(1),
      GeneralCommentAction.share => l10n.share,
    };
  }

  /// The title to use for the action. This is shown when the given page is active
  String get title {
    final l10n = GlobalContext.l10n;

    return switch (this) {
      GeneralCommentAction.general => l10n.actions,
      GeneralCommentAction.comment => l10n.commentActions,
      GeneralCommentAction.user => l10n.userActions,
      GeneralCommentAction.instance => l10n.instanceActions,
      GeneralCommentAction.share => l10n.share,
    };
  }

  /// The icon to use for the action
  final IconData icon;

  const GeneralCommentAction({required this.icon});
}

enum GeneralQuickCommentAction {
  upvote(
    enabledIcon: Icons.arrow_upward_rounded,
    disabledIcon: Icons.arrow_upward_rounded,
    permissionType: PermissionType.user,
    requiresAuthentication: true,
  ),
  downvote(
    enabledIcon: Icons.arrow_downward_rounded,
    disabledIcon: Icons.arrow_downward_rounded,
    permissionType: PermissionType.user,
    requiresAuthentication: true,
  ),
  save(
    enabledIcon: Icons.star_rounded,
    disabledIcon: Icons.star_outline_rounded,
    permissionType: PermissionType.user,
    requiresAuthentication: true,
  ),
  reply(
    enabledIcon: Icons.reply_rounded,
    disabledIcon: Icons.reply_outlined,
    permissionType: PermissionType.user,
    requiresAuthentication: true,
  ),
  edit(
    enabledIcon: Icons.edit_rounded,
    disabledIcon: Icons.edit_outlined,
    permissionType: PermissionType.user,
    requiresAuthentication: true,
  );

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
class GeneralCommentActionBottomSheetPage extends StatefulWidget {
  const GeneralCommentActionBottomSheetPage({
    super.key,
    required this.context,
    required this.account,
    required this.comment,
    required this.downvotesEnabled,
    required this.onSwitchActivePage,
    required this.onAction,
  });

  /// The outer context
  final BuildContext context;

  /// The account that is performing the action
  final Account account;

  /// The comment information
  final ThunderComment comment;

  /// Whether or not the downvotes are enabled
  final bool downvotesEnabled;

  /// Called when the active page is changed
  final Function(GeneralCommentAction page) onSwitchActivePage;

  /// Called when an action is selected
  final Function(CommentAction commentAction, ThunderComment? comment) onAction;

  @override
  State<GeneralCommentActionBottomSheetPage> createState() => _GeneralCommentActionBottomSheetPageState();
}

class _GeneralCommentActionBottomSheetPageState extends State<GeneralCommentActionBottomSheetPage> {
  String? generateSubtitle(GeneralCommentAction page) {
    final comment = widget.comment;

    final userInstance = fetchInstanceNameFromUrl(comment.creator?.actorId);

    switch (page) {
      case GeneralCommentAction.user:
        return generateUserFullName(context, comment.creator?.name, comment.creator?.displayName, userInstance);
      case GeneralCommentAction.instance:
        return userInstance;
      default:
        return null;
    }
  }

  void performAction(GeneralQuickCommentAction action) async {
    final repository = CommentRepositoryImpl(account: widget.account);

    switch (action) {
      case GeneralQuickCommentAction.upvote:
        Navigator.of(context).pop();
        final comment = await repository.vote(widget.comment, widget.comment.myVote == 1 ? 0 : 1);
        widget.onAction(CommentAction.vote, comment);
        break;
      case GeneralQuickCommentAction.downvote:
        Navigator.of(context).pop();
        final comment = await repository.vote(widget.comment, widget.comment.myVote == -1 ? 0 : -1);
        widget.onAction(CommentAction.vote, comment);
        break;
      case GeneralQuickCommentAction.save:
        Navigator.of(context).pop();
        final comment = await repository.save(widget.comment, !(widget.comment.saved ?? false));
        widget.onAction(CommentAction.save, comment);
        break;
      case GeneralQuickCommentAction.reply:
        Navigator.of(context).pop();
        widget.onAction(CommentAction.reply, widget.comment);
        return;
      case GeneralQuickCommentAction.edit:
        Navigator.of(context).pop();
        widget.onAction(CommentAction.edit, widget.comment);
        return;
    }
  }

  IconData getIcon(GeneralQuickCommentAction action) {
    final comment = widget.comment;

    switch (action) {
      case GeneralQuickCommentAction.upvote:
        return comment.myVote == 1 ? GeneralQuickCommentAction.upvote.enabledIcon : GeneralQuickCommentAction.upvote.disabledIcon;
      case GeneralQuickCommentAction.downvote:
        return comment.myVote == -1 ? GeneralQuickCommentAction.downvote.enabledIcon : GeneralQuickCommentAction.downvote.disabledIcon;
      case GeneralQuickCommentAction.save:
        return comment.saved == true ? GeneralQuickCommentAction.save.enabledIcon : GeneralQuickCommentAction.save.disabledIcon;
      case GeneralQuickCommentAction.reply:
        return GeneralQuickCommentAction.reply.enabledIcon;
      case GeneralQuickCommentAction.edit:
        return GeneralQuickCommentAction.edit.enabledIcon;
    }
  }

  String getLabel(GeneralQuickCommentAction action) {
    final l10n = GlobalContext.l10n;
    final comment = widget.comment;

    switch (action) {
      case GeneralQuickCommentAction.upvote:
        return comment.myVote == 1 ? l10n.upvoted : l10n.upvote;
      case GeneralQuickCommentAction.downvote:
        return comment.myVote == -1 ? l10n.downvoted : l10n.downvote;
      case GeneralQuickCommentAction.save:
        return comment.saved == true ? l10n.saved : l10n.save;
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
    final comment = widget.comment;

    switch (action) {
      case GeneralQuickCommentAction.upvote:
        return comment.myVote == 1 ? state.upvoteColor.color : null;
      case GeneralQuickCommentAction.downvote:
        return comment.myVote == -1 ? state.downvoteColor.color : null;
      case GeneralQuickCommentAction.save:
        return comment.saved == true ? state.saveColor.color : null;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    List<GeneralQuickCommentAction> quickActions = GeneralQuickCommentAction.values.where((element) => element.permissionType == PermissionType.user).toList();

    if (widget.account.anonymous) {
      quickActions = quickActions.where((action) => action.requiresAuthentication == false).toList();
    } else {
      // Hide edit if the comment is not made by the current user
      if (widget.account.username != widget.comment.creator?.name || widget.account.instance != fetchInstanceNameFromUrl(widget.comment.creator?.actorId)) {
        quickActions = quickActions.where((action) => action != GeneralQuickCommentAction.edit).toList();
      }
    }

    // Determine the available sub-menus to display
    List<GeneralCommentAction> submenus = GeneralCommentAction.values.where((page) => page != GeneralCommentAction.general).toList();
    if (widget.account.anonymous) submenus = submenus.where((action) => action != GeneralCommentAction.comment).toList();

    return Column(
      children: [
        if (quickActions.isNotEmpty)
          MultiPickerItem(
            pickerItems: quickActions.map<PickerItemData>((quickCommentAction) {
              Function()? onSelected;

              if (quickCommentAction == GeneralQuickCommentAction.downvote && !widget.downvotesEnabled) {
                onSelected = null;
              } else {
                onSelected = widget.account.anonymous ? null : () => performAction(quickCommentAction);
              }

              return PickerItemData(
                icon: getIcon(quickCommentAction),
                label: getLabel(quickCommentAction),
                foregroundColor: getForegroundColor(quickCommentAction),
                backgroundColor: getBackgroundColor(quickCommentAction),
                onSelected: onSelected,
              );
            }).toList(),
          ),
        ...submenus.map<Widget>(
          (page) => BottomSheetAction(
            leading: Icon(page.icon),
            trailing: const Icon(Icons.chevron_right_rounded),
            title: page.name,
            subtitle: generateSubtitle(page),
            onTap: () => widget.onSwitchActivePage(page),
          ),
        ),
      ],
    );
  }
}
