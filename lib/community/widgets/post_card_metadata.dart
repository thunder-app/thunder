import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:thunder/shared/icon_text.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/utils/date_time.dart';
import 'package:thunder/utils/numbers.dart';

class PostCardMetaData extends StatelessWidget {
  final int score;
  final VoteType voteType;
  final int comments;
  final DateTime published;
  final bool saved;

  const PostCardMetaData({
    super.key,
    required this.score,
    required this.voteType,
    required this.comments,
    required this.published,
    required this.saved,
  });

  final MaterialColor upVoteColor = Colors.orange;
  final MaterialColor downVoteColor = Colors.blue;
  final MaterialColor savedColor = Colors.purple;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<ThunderBloc, ThunderState>(
      builder: (context, state) {
        final SharedPreferences? prefs = state.preferences;

        if (prefs == null) return Container();
        final bool useCompactView = context.read<ThunderBloc>().state.preferences?.getBool('setting_general_use_compact_view') ?? false;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconText(
                  text: formatNumberToK(score),
                  icon: Icon(Icons.arrow_upward,
                      size: 18.0,
                      color: voteType == VoteType.up
                          ? upVoteColor
                          : voteType == VoteType.down
                              ? downVoteColor
                              : theme.textTheme.titleSmall?.color?.withOpacity(0.75)),
                  padding: 2.0,
                ),
                const SizedBox(width: 12.0),
                IconText(
                  icon: Icon(
                    Icons.chat,
                    size: 17.0,
                    color: theme.textTheme.titleSmall?.color?.withOpacity(0.75),
                  ),
                  text: formatNumberToK(comments),
                  padding: 5.0,
                ),
                const SizedBox(width: 10.0),
                IconText(
                  icon: Icon(
                    Icons.history_rounded,
                    size: 19.0,
                    color: theme.textTheme.titleSmall?.color?.withOpacity(0.75),
                  ),
                  text: formatTimeToString(dateTime: published.toIso8601String()),
                ),
                const SizedBox(width: 14.0),
                // if (postView.post.distinguised)
                // Icon(
                //   Icons.campaign_rounded,
                //   size: 24.0,
                //   color: Colors.green.shade800,
                // ),
              ],
            ),
            if (useCompactView)
              Icon(
                saved ? Icons.star_rounded : null,
                color: saved ? savedColor : null,
                size: 22.0,
                semanticLabel: saved ? 'Saved' : 'Save',
              ),
          ],
        );
      },
    );
  }
}
