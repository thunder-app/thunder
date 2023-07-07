import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lemmy_api_client/v3.dart';

import 'package:thunder/core/enums/font_scale.dart';
import 'package:thunder/shared/icon_text.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/utils/date_time.dart';
import 'package:thunder/utils/numbers.dart';

class PostCardMetaData extends StatelessWidget {
  final int score;
  final VoteType voteType;
  final int comments;
  final int unreadComments;
  final bool hasBeenEdited;
  final DateTime published;
  final bool saved;
  final bool distinguised;

  const PostCardMetaData({
    super.key,
    required this.score,
    required this.voteType,
    required this.unreadComments,
    required this.comments,
    required this.hasBeenEdited,
    required this.published,
    required this.saved,
    required this.distinguised,
  });

  final MaterialColor upVoteColor = Colors.orange;
  final MaterialColor downVoteColor = Colors.blue;
  final MaterialColor savedColor = Colors.purple;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<ThunderBloc, ThunderState>(
      builder: (context, state) {
        final bool useCompactView = state.useCompactView;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconText(
                  textScaleFactor: state.contentFontSizeScale.textScaleFactor,
                  text: formatNumberToK(score),
                  textColor: voteType == VoteType.up
                    ? upVoteColor
                    : voteType == VoteType.down
                      ? downVoteColor
                      : theme.textTheme.titleSmall?.color?.withOpacity(0.9),
                  icon: Icon( voteType == VoteType.down ? Icons.arrow_downward : Icons.arrow_upward,
                      size: 18.0,
                      color: voteType == VoteType.up
                          ? upVoteColor
                          : voteType == VoteType.down
                              ? downVoteColor
                              : theme.textTheme.titleSmall?.color?.withOpacity(0.75)
                  ),
                  padding: 2.0,
                ),
                const SizedBox(width: 12.0),
                IconText(
                  textScaleFactor: state.contentFontSizeScale.textScaleFactor,
                  icon: Icon(
                    Icons.chat,
                    size: 17.0,
                    color: theme.textTheme.titleSmall?.color?.withOpacity(0.75),
                  ),
                  text: formatNumberToK(comments),
                  textColor: theme.textTheme.titleSmall?.color?.withOpacity(0.9),
                  padding: 5.0,
                ),
                const SizedBox(width: 10.0),
                IconText(
                  textScaleFactor: state.contentFontSizeScale.textScaleFactor,
                  icon: Icon(
                    hasBeenEdited ? Icons.create_rounded : Icons.history_rounded,
                    size: 19.0,
                    color: theme.textTheme.titleSmall?.color?.withOpacity(0.75),
                  ),
                  text: formatTimeToString(dateTime: published.toIso8601String()),
                  textColor: theme.textTheme.titleSmall?.color?.withOpacity(0.9),
                ),
                const SizedBox(width: 14.0),
                if (distinguised)
                  Icon(
                    Icons.push_pin_rounded,
                    size: 24.0,
                    color: Colors.green.shade800,
                  ),
              ],
            ),
            if (useCompactView)
              Icon(
                saved ? Icons.star_rounded : null,
                color: saved ? savedColor : null,
                size: 22.0,
                semanticLabel: saved ? 'Saved' : '',
              ),
          ],
        );
      },
    );
  }
}

class PostViewMetaData extends StatelessWidget {
  final int comments;
  final DateTime published;
  final bool saved;

  const PostViewMetaData({
    super.key,
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
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconText(
                  textScaleFactor: state.contentFontSizeScale.textScaleFactor,
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
                  textScaleFactor: state.contentFontSizeScale.textScaleFactor,
                  icon: Icon(
                    Icons.history_rounded,
                    size: 19.0,
                    color: theme.textTheme.titleSmall?.color?.withOpacity(0.75),
                  ),
                  text: formatTimeToString(dateTime: published.toIso8601String()),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
