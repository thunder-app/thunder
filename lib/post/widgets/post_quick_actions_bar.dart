import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/shared/snackbar.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/utils/numbers.dart';

/// A widget that displays the quick actions bar for a post
class PostQuickActionsBar extends StatelessWidget {
  const PostQuickActionsBar({
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<AuthBloc, AuthState>(
      buildWhen: (previous, current) => previous.isLoggedIn != current.isLoggedIn,
      builder: (context, state) {
        bool isUserLoggedIn = state.isLoggedIn;
        bool downvotesEnabled = state.downvotesEnabled;
        bool showScores = state.getSiteResponse?.myUser?.localUserView.localUser.showScores ?? true;

        return Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: TextButton(
                onPressed: isUserLoggedIn ? () => onVote?.call(vote == 1 ? 0 : 1) : null,
                style: TextButton.styleFrom(
                  fixedSize: const Size.fromHeight(40),
                  foregroundColor: vote == 1 ? theme.textTheme.bodyMedium?.color : context.read<ThunderBloc>().state.upvoteColor.color,
                  padding: EdgeInsets.zero,
                ),
                child: Wrap(
                  spacing: 4.0,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Icon(
                      Icons.arrow_upward_rounded,
                      semanticLabel: vote == 1 ? l10n.upvoted : l10n.upvote,
                      color: isUserLoggedIn ? (vote == 1 ? context.read<ThunderBloc>().state.upvoteColor.color : theme.textTheme.bodyMedium?.color) : null,
                    ),
                    if (showScores)
                      Text(
                        formatNumberToK(upvotes ?? 0),
                        style: TextStyle(
                          color: isUserLoggedIn ? (vote == 1 ? context.read<ThunderBloc>().state.upvoteColor.color : theme.textTheme.bodyMedium?.color) : null,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            if (downvotesEnabled)
              Expanded(
                child: TextButton(
                  onPressed: isUserLoggedIn ? () => onVote?.call(vote == -1 ? 0 : -1) : null,
                  style: TextButton.styleFrom(
                    fixedSize: const Size.fromHeight(40),
                    foregroundColor: vote == -1 ? theme.textTheme.bodyMedium?.color : context.read<ThunderBloc>().state.downvoteColor.color,
                    padding: EdgeInsets.zero,
                  ),
                  child: Wrap(
                    spacing: 4.0,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Icon(
                        Icons.arrow_downward_rounded,
                        semanticLabel: vote == -1 ? l10n.downvoted : l10n.downvote,
                        color: isUserLoggedIn ? (vote == -1 ? context.read<ThunderBloc>().state.downvoteColor.color : theme.textTheme.bodyMedium?.color) : null,
                      ),
                      if (showScores)
                        Text(
                          formatNumberToK(downvotes ?? 0),
                          style: TextStyle(
                            color: isUserLoggedIn ? (vote == -1 ? context.read<ThunderBloc>().state.downvoteColor.color : theme.textTheme.bodyMedium?.color) : null,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            Expanded(
              child: IconButton(
                onPressed: isUserLoggedIn ? () => onSave?.call(!saved) : null,
                style: IconButton.styleFrom(foregroundColor: saved ? null : context.read<ThunderBloc>().state.saveColor.color),
                icon: Icon(
                  saved ? Icons.star_rounded : Icons.star_border_rounded,
                  semanticLabel: saved ? l10n.saved : l10n.save,
                  color: isUserLoggedIn ? (saved ? context.read<ThunderBloc>().state.saveColor.color : theme.textTheme.bodyMedium?.color) : null,
                ),
              ),
            ),
            if (locked)
              Expanded(
                child: IconButton(
                  onPressed: () => showSnackbar(l10n.postLocked),
                  icon: Icon(Icons.lock, semanticLabel: l10n.postLocked, color: theme.colorScheme.error),
                ),
              ),
            if (!locked && isOwnPost)
              Expanded(
                child: IconButton(
                  onPressed: isUserLoggedIn ? () => onEdit?.call() : null,
                  icon: Icon(Icons.edit_rounded, semanticLabel: l10n.edit),
                ),
              ),
            if (!locked && !isOwnPost)
              Expanded(
                child: IconButton(
                  onPressed: isUserLoggedIn ? () => onReply?.call() : null,
                  icon: Icon(Icons.reply_rounded, semanticLabel: l10n.reply(0)),
                ),
              ),
            Expanded(
              child: IconButton(
                onPressed: () => onShare?.call(),
                icon: Icon(Icons.share_rounded, semanticLabel: l10n.share),
              ),
            ),
          ],
        );
      },
    );
  }
}
