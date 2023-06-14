import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:lemmy/lemmy.dart';
import 'package:thunder/community/bloc/community_bloc.dart';
import 'package:thunder/community/community.dart';
import 'package:thunder/core/models/post_view_media.dart';

import 'package:thunder/post/pages/post_page.dart';
import 'package:thunder/shared/icon_text.dart';
import 'package:thunder/shared/media_view.dart';
import 'package:thunder/utils/date_time.dart';
import 'package:thunder/utils/numbers.dart';

class PostCard extends StatefulWidget {
  final PostViewMedia postView;

  const PostCard({super.key, required this.postView});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Post post = widget.postView.post;

    int? myVote = widget.postView.myVote;

    return Column(
      children: [
        Divider(
          height: 1.0,
          thickness: 2.0,
          color: theme.textTheme.bodyMedium?.color?.withOpacity(0.20),
        ),
        InkWell(
          onLongPress: () {},
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MediaView(postView: widget.postView),
                Text(
                  post.name,
                  style: theme.textTheme.titleMedium,
                  softWrap: true,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 6.0, bottom: 4.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              child: Text(
                                widget.postView.community.name,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontSize: theme.textTheme.titleSmall!.fontSize! * 1.05,
                                  color: theme.textTheme.titleSmall?.color?.withOpacity(0.75),
                                ),
                              ),
                              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) => CommunityPage(communityId: widget.postView.community.id),
                              )),
                            ),
                            const SizedBox(height: 8.0),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconText(
                                  text: formatNumberToK(widget.postView.counts.upvotes),
                                  icon: Icon(
                                    Icons.arrow_upward,
                                    size: 18.0,
                                    color: theme.textTheme.titleSmall?.color?.withOpacity(0.75),
                                  ),
                                  padding: 2.0,
                                ),
                                const SizedBox(width: 12.0),
                                IconText(
                                  icon: Icon(
                                    Icons.chat,
                                    size: 17.0,
                                    color: theme.textTheme.titleSmall?.color?.withOpacity(0.75),
                                  ),
                                  text: formatNumberToK(widget.postView.counts.comments),
                                  padding: 5.0,
                                ),
                                const SizedBox(width: 10.0),
                                IconText(
                                  icon: Icon(
                                    Icons.history_rounded,
                                    size: 19.0,
                                    color: theme.textTheme.titleSmall?.color?.withOpacity(0.75),
                                  ),
                                  text: formatTimeToString(dateTime: post.published),
                                ),
                                const SizedBox(width: 14.0),
                                if (post.featuredCommunity == true || post.featuredLocal == true)
                                  Icon(
                                    Icons.campaign_rounded,
                                    size: 24.0,
                                    color: Colors.green.shade800,
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          IconButton(
                            onPressed: () {
                              context.read<CommunityBloc>().add(VotePostEvent(postId: post.id, score: myVote == 1 ? 0 : 1));
                            },
                            icon: Icon(Icons.arrow_upward),
                            color: myVote == 1 ? Colors.orange : null,
                            visualDensity: VisualDensity.compact,
                          ),
                          IconButton(
                            onPressed: () {
                              context.read<CommunityBloc>().add(VotePostEvent(postId: post.id, score: myVote == -1 ? 0 : -1));
                            },
                            icon: Icon(Icons.arrow_downward),
                            color: myVote == -1 ? Colors.blue : null,
                            visualDensity: VisualDensity.compact,
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: Icon(Icons.star_border_rounded),
                            visualDensity: VisualDensity.compact,
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => PostPage(postId: post.id)));
          },
        ),
      ],
    );
  }
}
