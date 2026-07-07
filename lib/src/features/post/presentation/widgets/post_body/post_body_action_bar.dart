import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/src/features/account/data/cache/profile_site_info_cache.dart';
import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/features/session/api.dart';

import 'package:thunder/src/features/settings/api.dart';
import 'package:thunder/src/foundation/primitives/primitives.dart';
import 'package:thunder/src/foundation/config/global_context.dart';
import 'package:thunder/src/foundation/utils/utils.dart';
import 'package:thunder/packages/ui/ui.dart';

/// A widget that displays the quick actions bar for a post
class PostBodyActionsBar extends StatefulWidget {
  const PostBodyActionsBar({
    super.key,
    this.vote,
    this.upvotes,
    this.downvotes,
    this.saved = false,
    this.locked = false,
    this.isOwnPost = false,
    this.onVote,
    this.onSave,
    this.onShare,
    this.onReply,
    this.onEdit,
  });

  /// The number of upvotes the post has
  final int? upvotes;

  /// The number of downvotes the post has
  final int? downvotes;

  /// The vote of the user for the given post. If 1, the user has voted up. If -1, the user has voted down.
  final int? vote;

  /// Whether the user has saved the post
  final bool saved;

  /// Whether the post is locked
  final bool locked;

  /// Whether the user is the creator of the post
  final bool isOwnPost;

  /// Called when the user wants to vote on the post
  final Function(int score)? onVote;

  /// Called when the user wants to save the post
  final Function(bool save)? onSave;

  /// Called when the user wants to share the post
  final Function()? onShare;

  /// Called when the user wants to reply to the post
  final Function()? onReply;

  /// Called when the user wants to edit the post
  final Function()? onEdit;

  @override
  State<PostBodyActionsBar> createState() => _PostBodyActionsBarState();
}

class _PostBodyActionsBarState extends State<PostBodyActionsBar> {
  Account? _account;
  bool _downvotesEnabled = true;
  bool _showScores = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final account = resolveEffectiveAccount(context);
    if (_account?.id == account.id && _account?.instance == account.instance && _account?.anonymous == account.anonymous) {
      return;
    }

    _account = account;
    _loadAccountDisplayPreferences(account);
  }

  Future<void> _loadAccountDisplayPreferences(Account account) async {
    if (account.anonymous) {
      if (!mounted) return;
      setState(() {
        _downvotesEnabled = true;
        _showScores = true;
      });
      return;
    }

    final siteInfo = await ProfileSiteInfoCache.instance.get(account);
    if (!mounted || _account?.id != account.id) return;

    setState(() {
      _downvotesEnabled = siteInfo.site.enableDownvotes ?? true;
      _showScores = siteInfo.myUser?.localUserView.localUser.showScores ?? true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final account = _account ?? resolveEffectiveAccount(context);
    final upvoteColor = context.select<ThemePreferencesCubit, ActionColor>((cubit) => cubit.state.upvoteColor);
    final downvoteColor = context.select<ThemePreferencesCubit, ActionColor>((cubit) => cubit.state.downvoteColor);
    final saveColor = context.select<ThemePreferencesCubit, ActionColor>((cubit) => cubit.state.saveColor);
    final theme = Theme.of(context);
    final l10n = GlobalContext.l10n;
    final isUserLoggedIn = !account.anonymous;
    final downvotesEnabled = _downvotesEnabled;
    final showScores = _showScores;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: TextButton(
              onPressed: isUserLoggedIn ? () => widget.onVote?.call(widget.vote == 1 ? 0 : 1) : null,
              style: TextButton.styleFrom(
                fixedSize: const Size.fromHeight(40),
                foregroundColor: widget.vote == 1 ? theme.textTheme.bodyMedium?.color : context.read<ThemePreferencesCubit>().state.upvoteColor.color,
                padding: EdgeInsets.zero,
              ),
              child: Wrap(
                spacing: 4.0,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Icon(
                    Icons.arrow_upward_rounded,
                    semanticLabel: widget.vote == 1 ? l10n.upvoted : l10n.upvote,
                    color: isUserLoggedIn ? (widget.vote == 1 ? upvoteColor.color : theme.textTheme.bodyMedium?.color) : null,
                    size: 24.0,
                  ),
                  if (showScores)
                    Text(
                      formatNumberToK(widget.upvotes ?? 0),
                      style: TextStyle(
                        color: isUserLoggedIn ? (widget.vote == 1 ? upvoteColor.color : theme.textTheme.bodyMedium?.color) : null,
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (downvotesEnabled)
            Expanded(
              child: TextButton(
                onPressed: isUserLoggedIn ? () => widget.onVote?.call(widget.vote == -1 ? 0 : -1) : null,
                style: TextButton.styleFrom(
                  fixedSize: const Size.fromHeight(40),
                  foregroundColor: widget.vote == -1 ? theme.textTheme.bodyMedium?.color : downvoteColor.color,
                  padding: EdgeInsets.zero,
                ),
                child: Wrap(
                  spacing: 4.0,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Icon(
                      Icons.arrow_downward_rounded,
                      semanticLabel: widget.vote == -1 ? l10n.downvoted : l10n.downvote,
                      color: isUserLoggedIn ? (widget.vote == -1 ? downvoteColor.color : theme.textTheme.bodyMedium?.color) : null,
                      size: 24.0,
                    ),
                    if (showScores)
                      Text(
                        formatNumberToK(widget.downvotes ?? 0),
                        style: TextStyle(
                          color: isUserLoggedIn ? (widget.vote == -1 ? downvoteColor.color : theme.textTheme.bodyMedium?.color) : null,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          Expanded(
            child: IconButton(
              onPressed: isUserLoggedIn ? () => widget.onSave?.call(!widget.saved) : null,
              style: IconButton.styleFrom(foregroundColor: widget.saved ? null : saveColor.color),
              icon: Icon(
                widget.saved ? Icons.star_rounded : Icons.star_border_rounded,
                semanticLabel: widget.saved ? l10n.saved : l10n.save,
                color: isUserLoggedIn ? (widget.saved ? saveColor.color : theme.textTheme.bodyMedium?.color) : null,
              ),
            ),
          ),
          if (widget.locked)
            Expanded(
              child: IconButton(
                onPressed: () => showThunderSnackbar(l10n.postLocked),
                icon: Icon(Icons.lock, semanticLabel: l10n.postLocked, color: theme.colorScheme.error),
              ),
            ),
          if (!widget.locked && widget.isOwnPost)
            Expanded(
              child: IconButton(
                onPressed: isUserLoggedIn ? () => widget.onEdit?.call() : null,
                icon: Icon(Icons.edit_rounded, semanticLabel: l10n.edit),
              ),
            ),
          if (!widget.locked && !widget.isOwnPost)
            Expanded(
              child: IconButton(
                onPressed: isUserLoggedIn ? () => widget.onReply?.call() : null,
                icon: Icon(Icons.reply_rounded, semanticLabel: l10n.reply(0)),
              ),
            ),
          Expanded(
            child: IconButton(
              onPressed: () => widget.onShare?.call(),
              icon: Icon(Icons.share_rounded, semanticLabel: l10n.share),
            ),
          ),
        ],
      ),
    );
  }
}
