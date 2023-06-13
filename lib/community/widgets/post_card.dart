import 'package:flutter/material.dart';

import 'package:lemmy/lemmy.dart';
import 'package:thunder/core/models/post_view_media.dart';

import 'package:thunder/post/pages/post_page.dart';
import 'package:thunder/shared/icon_text.dart';
import 'package:thunder/shared/media_view.dart';
import 'package:thunder/utils/date_time.dart';
import 'package:thunder/utils/numbers.dart';

class PostCard extends StatelessWidget {
  final PostViewMedia postView;

  const PostCard({super.key, required this.postView});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Post post = postView.post;

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
                MediaView(postView: postView),
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
                            Text(
                              postView.community.name,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontSize: theme.textTheme.titleSmall!.fontSize! * 1.05,
                                color: theme.textTheme.titleSmall?.color?.withOpacity(0.75),
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconText(
                                  text: formatNumberToK(postView.counts.upvotes),
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
                                  text: formatNumberToK(postView.counts.comments),
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
                            onPressed: () {},
                            icon: Icon(Icons.arrow_upward),
                            visualDensity: VisualDensity.compact,
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: Icon(Icons.arrow_downward),
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
