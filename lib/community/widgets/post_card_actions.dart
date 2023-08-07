import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:lemmy_api_client/v3.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/thunder/bloc/thunder_bloc.dart';

class PostCardActions extends StatelessWidget {
  // Callback functions
  final Function(VoteType) onVoteAction;
  final Function(bool) onSaveAction;

  final int postId;
  final bool saved;
  final VoteType voteType;

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

        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showVoteActions)
              IconButton(
                  icon: Icon(
                    Icons.arrow_upward,
                    semanticLabel: voteType == VoteType.up ? 'Upvoted' : 'Upvote',
                  ),
                  color: voteType == VoteType.up ? upVoteColor : null,
                  visualDensity: VisualDensity.compact,
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    onVoteAction(voteType == VoteType.up ? VoteType.none : VoteType.up);
                  }),
            if (showVoteActions)
              IconButton(
                icon: Icon(
                  Icons.arrow_downward,
                  semanticLabel: voteType == VoteType.down ? 'Downvoted' : 'Downvote',
                ),
                color: voteType == VoteType.down ? downVoteColor : null,
                visualDensity: VisualDensity.compact,
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  onVoteAction(voteType == VoteType.down ? VoteType.none : VoteType.down);
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
