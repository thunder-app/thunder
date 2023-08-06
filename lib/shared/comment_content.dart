import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:thunder/core/enums/font_scale.dart';
import 'package:thunder/shared/common_markdown_body.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/utils/date_time.dart';

import '../../utils/numbers.dart';

class CommentContent extends StatelessWidget {
  final CommentView comment;

  const CommentContent({super.key, required this.comment});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    int upvotes = comment.counts.upvotes ?? 0;
    int downvotes = comment.counts.downvotes ?? 0;

    final ThunderState state = context.read<ThunderBloc>().state;

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                comment.creator.name,
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(width: 8.0),
              Icon(
                Icons.north_rounded,
                size: 12.0 * state.contentFontSizeScale.textScaleFactor,
                color: comment.myVote == VoteType.up ? Colors.orange : theme.colorScheme.onBackground,
              ),
              const SizedBox(width: 2.0),
              Text(
                formatNumberToK(upvotes),
                semanticsLabel: '${formatNumberToK(upvotes)} upvotes',
                textScaleFactor: state.contentFontSizeScale.textScaleFactor,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: comment.myVote == VoteType.up ? Colors.orange : theme.colorScheme.onBackground,
                ),
              ),
              const SizedBox(width: 10.0),
              Icon(
                Icons.south_rounded,
                size: 12.0 * state.contentFontSizeScale.textScaleFactor,
                color: downvotes != 0 ? theme.colorScheme.onBackground : Colors.transparent,
              ),
              const SizedBox(width: 2.0),
              if (downvotes != 0)
                Text(
                  formatNumberToK(downvotes),
                  semanticsLabel: '${formatNumberToK(upvotes)} downvotes',
                  textScaleFactor: state.contentFontSizeScale.textScaleFactor,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: downvotes != 0 ? theme.colorScheme.onBackground : Colors.transparent,
                  ),
                ),
              const Spacer(),
              Text(formatTimeToString(dateTime: comment.comment.published.toIso8601String())),
            ],
          ),
          const SizedBox(height: 10),
          CommonMarkdownBody(body: comment.comment.content),
        ],
      ),
    );
  }
}
