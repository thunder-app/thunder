import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:lemmy_api_client/v3.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thunder/core/auth/bloc/auth_bloc.dart';

import 'package:thunder/thunder/bloc/thunder_bloc.dart';

class PostCardActions extends StatelessWidget {
  // Callback functions
  final Function(int) onVoteAction;
  final Function(bool) onSaveAction;

  final int postId;
  final bool saved;
  final int voteType;

  const PostCardActions({
    super.key,
    required this.postId,
    required this.voteType,
    required this.saved,
    required this.onVoteAction,
    required this.onSaveAction,
  });

  final MaterialColor upVoteColor = Colors.orange;
  final MaterialColor downVoteColor = Colors.blue;
  final MaterialColor savedColor = Colors.purple;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThunderBloc, ThunderState>(
      builder: (context, state) {
        final bool showVoteActions = state.showVoteActions;
        final bool showSaveAction = state.showSaveAction;

        final bool downvotesEnabled = context.read<AuthBloc>().state.downvotesEnabled;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showVoteActions)
              IconButton(
                  icon: Icon(
                    Icons.arrow_upward,
                    semanticLabel: voteType == 1 ? 'Upvoted' : 'Upvote',
                  ),
                  color: voteType == 1 ? upVoteColor : null,
                  visualDensity: VisualDensity.compact,
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    onVoteAction(voteType == 1 ? 0 : 1);
                  }),
            if (showVoteActions && downvotesEnabled)
              IconButton(
                icon: Icon(
                  Icons.arrow_downward,
                  semanticLabel: voteType == -1 ? 'Downvoted' : 'Downvote',
                ),
                color: voteType == -1 ? downVoteColor : null,
                visualDensity: VisualDensity.compact,
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  onVoteAction(voteType == -1 ? 0 : -1);
                },
              ),
            if (showSaveAction)
              IconButton(
                icon: Icon(
                  saved ? Icons.star_rounded : Icons.star_border_rounded,
                  semanticLabel: saved ? 'Saved' : 'Save',
                ),
                color: saved ? savedColor : null,
                visualDensity: VisualDensity.compact,
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  onSaveAction(saved ? false : true);
                },
              ),
          ],
        );
      },
    );
  }
}
