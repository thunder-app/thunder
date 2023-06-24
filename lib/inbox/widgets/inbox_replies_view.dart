import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:lemmy/lemmy.dart';

import 'package:thunder/inbox/bloc/inbox_bloc.dart';
import 'package:thunder/utils/date_time.dart';

class InboxRepliesView extends StatelessWidget {
  const InboxRepliesView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    List<CommentReplyView> replies = context.read<InboxBloc>().state.replies;

    if (replies.isEmpty) {
      return const Center(child: Text('No replies'));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: replies.length,
      itemBuilder: (context, index) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          replies[index].creator.name,
                          style: theme.textTheme.titleSmall?.copyWith(color: Colors.greenAccent),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Icon(Icons.arrow_forward_rounded, size: 14),
                        ),
                        Text(
                          replies[index].recipient.name,
                          style: theme.textTheme.titleSmall?.copyWith(color: Colors.greenAccent),
                        ),
                      ],
                    ),
                    Text(formatTimeToString(dateTime: replies[index].comment.published))
                  ],
                ),
                const SizedBox(height: 10),
                Text(replies[index].comment.content),
              ],
            ),
          ),
        );
      },
    );
  }
}
