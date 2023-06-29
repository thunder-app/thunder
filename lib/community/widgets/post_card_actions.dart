import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thunder/community/bloc/community_bloc.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';

class PostCardActions extends StatelessWidget {
  final Function(VoteType) onVoteAction;
  final Function(bool) onSaveAction;

  final int postId;
  final VoteType voteType;
  final bool saved;

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
        final SharedPreferences? prefs = state.preferences;

        if (prefs == null) return Container();
        final bool showVoteActions = prefs.getBool('setting_general_show_vote_actions') ?? true;
        final bool showSaveAction = prefs.getBool('setting_general_show_save_action') ?? true;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
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

                    // context.read<CommunityBloc>().add(VotePostEvent(postId: postId, score: voteType == VoteType.up ? VoteType.none : VoteType.up));
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

                  // context.read<CommunityBloc>().add(VotePostEvent(postId: postId, score: VoteType.down ? VoteType.none : VoteType.down));
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
