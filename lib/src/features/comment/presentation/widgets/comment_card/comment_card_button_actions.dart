import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/src/features/account/data/cache/profile_site_info_cache.dart';
import 'package:thunder/src/features/settings/api.dart';
import 'package:thunder/src/core/domain/domain.dart';
import 'package:thunder/src/core/config/global_context.dart';

/// Displays a row of actions that can be performed on a comment.
///
/// This is only shown when comment button actions are enabled.
class CommentCardButtonActions extends StatefulWidget {
  final Account account;

  /// The comment to perform actions on
  final ThunderComment comment;

  /// Whether the comment is owned by the current user
  final bool isOwnComment;

  /// The function to call when an action is performed. Simulate a swipe action on the comment card
  final void Function(SwipeAction action) onAction;

  /// The function to call when opening the bottom sheet
  final void Function() onBottomSheetOpen;

  const CommentCardButtonActions({
    super.key,
    required this.account,
    required this.comment,
    required this.isOwnComment,
    required this.onAction,
    required this.onBottomSheetOpen,
  });

  @override
  State<CommentCardButtonActions> createState() => _CommentCardButtonActionsState();
}

class _CommentCardButtonActionsState extends State<CommentCardButtonActions> {
  bool _downvotesEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSiteInfo();
  }

  @override
  void didUpdateWidget(covariant CommentCardButtonActions oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.account.id != widget.account.id || oldWidget.account.instance != widget.account.instance || oldWidget.account.anonymous != widget.account.anonymous) {
      _loadSiteInfo();
    }
  }

  Future<void> _loadSiteInfo() async {
    if (widget.account.anonymous) {
      if (!mounted) return;
      setState(() => _downvotesEnabled = true);
      return;
    }

    final siteInfo = await ProfileSiteInfoCache.instance.get(widget.account);
    if (!mounted) return;
    setState(() => _downvotesEnabled = siteInfo.site.enableDownvotes ?? true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = GlobalContext.l10n;

    final voteType = widget.comment.context.vote.score;
    final upvoteColor = context.select<ThemePreferencesCubit, Color>((cubit) => cubit.state.upvoteColor.color);
    final downvoteColor = context.select<ThemePreferencesCubit, Color>((cubit) => cubit.state.downvoteColor.color);

    final widgets = [
      _CommentCardButtonAction(
        icon: Icons.more_horiz_rounded,
        label: l10n.actions,
        onAction: widget.onBottomSheetOpen,
      )
    ];

    if (widget.isOwnComment) {
      widgets.add(
        _CommentCardButtonAction(
          icon: Icons.edit_rounded,
          label: l10n.edit,
          onAction: () => widget.onAction(SwipeAction.edit),
        ),
      );
    } else {
      widgets.add(
        _CommentCardButtonAction(
          icon: Icons.reply_rounded,
          label: l10n.reply(1),
          onAction: () => widget.onAction(SwipeAction.reply),
        ),
      );
    }

    widgets.add(
      _CommentCardButtonAction(
        icon: Icons.arrow_upward,
        label: voteType == 1 ? l10n.upvoted : l10n.upvote,
        color: voteType == 1 ? upvoteColor : null,
        onAction: () => widget.onAction(SwipeAction.upvote),
      ),
    );

    if (_downvotesEnabled) {
      widgets.add(
        _CommentCardButtonAction(
          icon: Icons.arrow_downward,
          label: voteType == -1 ? l10n.downvoted : l10n.downvote,
          color: voteType == -1 ? downvoteColor : null,
          onAction: () => widget.onAction(SwipeAction.downvote),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: widgets,
    );
  }
}

class _CommentCardButtonAction extends StatelessWidget {
  /// The icon to display
  final IconData icon;

  /// The semantic label for the icon
  final String label;

  /// The color of the icon
  final Color? color;

  /// The action to perform when the icon is pressed
  final void Function() onAction;

  const _CommentCardButtonAction({
    required this.icon,
    required this.label,
    this.color,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 28.0,
      width: 44.0,
      child: IconButton(
        icon: Icon(icon, semanticLabel: label, size: 22.0),
        color: color,
        visualDensity: VisualDensity.compact,
        onPressed: () => onAction(),
      ),
    );
  }
}
