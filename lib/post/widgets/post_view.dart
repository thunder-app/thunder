import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:share_plus/share_plus.dart';

import 'package:thunder/account/bloc/account_bloc.dart' as account_bloc;
import 'package:thunder/community/widgets/post_card_metadata.dart';
import 'package:thunder/core/enums/font_scale.dart';
import 'package:thunder/post/widgets/create_comment_modal.dart';
import 'package:thunder/shared/common_markdown_body.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/community/pages/community_page.dart';
import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/core/models/post_view_media.dart';
import 'package:thunder/post/bloc/post_bloc.dart';
import 'package:thunder/shared/media_view.dart';
import 'package:thunder/user/pages/user_page.dart';
import 'package:thunder/utils/numbers.dart';

import '../../utils/date_time.dart';

class PostSubview extends StatelessWidget {
  final PostViewMedia postViewMedia;

  const PostSubview({super.key, required this.postViewMedia});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final PostView postView = postViewMedia.postView;
    final Post post = postView.post;

    final bool isUserLoggedIn = context.read<AuthBloc>().state.isLoggedIn;

    final ThunderState thunderState = context.read<ThunderBloc>().state;

    final bool hideNsfwPreviews = thunderState.hideNsfwPreviews;

    return Padding(
      padding: const EdgeInsets.only(left: 12.0, right: 12.0, bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),

            child: Text(
              post.name,
              textScaleFactor: thunderState.titleFontSizeScale.textScaleFactor,
              style: theme.textTheme.titleMedium,
            ),
          ),
          MediaView(
            post: post,
            postView: postViewMedia,
            hideNsfwPreviews: hideNsfwPreviews,
          ),
          if (postViewMedia.postView.post.body != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: CommonMarkdownBody(
                body: post.body ?? '',
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 16.0),
            child: Row(
              // Row for post view: author, community, comment count and post time
              children: [

                GestureDetector(
                  onTap: () {
                    account_bloc.AccountBloc accountBloc =
                        context.read<account_bloc.AccountBloc>();
                    AuthBloc authBloc = context.read<AuthBloc>();
                    ThunderBloc thunderBloc = context.read<ThunderBloc>();

                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => MultiBlocProvider(
                          providers: [
                            BlocProvider.value(value: accountBloc),
                            BlocProvider.value(value: authBloc),
                            BlocProvider.value(value: thunderBloc),
                          ],
                          child: UserPage(userId: postView.creator.id),
                        ),
                      ),
                    );
                  },
                  child: Text(
                    postView.creator.name,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.75),
                    ),
                  ),
                ),
                Text(
                  ' to ',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.4),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    account_bloc.AccountBloc accountBloc =
                        context.read<account_bloc.AccountBloc>();
                    AuthBloc authBloc = context.read<AuthBloc>();
                    ThunderBloc thunderBloc = context.read<ThunderBloc>();

                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => MultiBlocProvider(
                          providers: [
                            BlocProvider.value(value: accountBloc),
                            BlocProvider.value(value: authBloc),
                            BlocProvider.value(value: thunderBloc),
                          ],
                          child:
                              CommunityPage(communityId: postView.community.id),
                        ),
                      ),
                    );
                  },
                  child: Text(
                    postView.community.name,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.75),
                    ),
                  ),
                ),
                const Spacer(), // use Spacer
                Padding(
                  padding: const EdgeInsets.only(right: 0.0),
                  child: PostViewMetaData(
                    comments: postView.counts.comments,
                    published: post.published,
                    saved: postView.saved,
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                flex: 1,
                child: TextButton(
                  onPressed: isUserLoggedIn
                      ? () {
                          HapticFeedback.mediumImpact();
                          context.read<PostBloc>().add(VotePostEvent(
                              postId: post.id,
                              score: postView.myVote == VoteType.up
                                  ? VoteType.none
                                  : VoteType.up));
                        }
                      : null,
                  style: TextButton.styleFrom(
                    fixedSize: const Size.fromHeight(40),
                    foregroundColor: postView.myVote == VoteType.up ? theme.textTheme.bodyMedium?.color : Colors.orange,
                    padding: EdgeInsets.zero,
                  ),
                  child: Row(
                    children: [
                      const Spacer(),
                      Icon(
                        Icons.arrow_upward,
                        semanticLabel:
                        postView.myVote == VoteType.up ? 'Upvoted' : 'Upvote',
                        color: isUserLoggedIn ? (postView.myVote == VoteType.up ? Colors.orange : theme.textTheme.bodyMedium?.color) : null,
                      ),
                      const SizedBox(width: 4.0),
                      Text(
                        formatNumberToK(postViewMedia.postView.counts.upvotes),
                        style: TextStyle(
                          color: isUserLoggedIn ? (postView.myVote == VoteType.up ? Colors.orange : theme.textTheme.bodyMedium?.color) : null,
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: TextButton(
                  onPressed: isUserLoggedIn
                      ? () {
                          HapticFeedback.mediumImpact();

                          context.read<PostBloc>().add(VotePostEvent(
                              postId: post.id,
                              score: postView.myVote == VoteType.down
                                  ? VoteType.none
                                  : VoteType.down));
                        }
                      : null,
                  style: TextButton.styleFrom(
                    fixedSize: const Size.fromHeight(40),
                    foregroundColor: postView.myVote == VoteType.down ? theme.textTheme.bodyMedium?.color : Colors.blue,
                    padding: EdgeInsets.zero,
                  ),

                  child: Row(
                    children: [
                      const Spacer(),
                      Icon(
                        Icons.arrow_downward,
                        semanticLabel:
                        postView.myVote == VoteType.up ? 'Downvoted' : 'Downvote',
                        color: isUserLoggedIn ? (postView.myVote == VoteType.down ? Colors.blue : theme.textTheme.bodyMedium?.color) : null,
                      ),
                      const SizedBox(width: 4.0),
                      Text(
                        formatNumberToK(postViewMedia.postView.counts.downvotes),
                        style: TextStyle(
                          color: isUserLoggedIn ? (postView.myVote == VoteType.down ? Colors.blue : theme.textTheme.bodyMedium?.color) : null,
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: IconButton(
                  onPressed: isUserLoggedIn
                      ? () {
                          HapticFeedback.mediumImpact();
                          context.read<PostBloc>().add(SavePostEvent(
                              postId: post.id, save: !postView.saved));
                        }
                      : null,
                  icon: Icon(
                    postView.saved
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                    semanticLabel: postView.saved ? 'Saved' : 'Save',
                    color: isUserLoggedIn ? (postView.saved ? Colors.purple : theme.textTheme.bodyMedium?.color) : null,
                  ),
                  style: IconButton.styleFrom(
                    foregroundColor: postView.saved ? null : Colors.purple,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: IconButton(
                  onPressed: isUserLoggedIn
                      ? () {
                          PostBloc postBloc = context.read<PostBloc>();

                          showModalBottomSheet(
                            isScrollControlled: true,
                            context: context,
                            showDragHandle: true,
                            builder: (context) {
                              return Padding(
                                padding: EdgeInsets.only(
                                    bottom:
                                        MediaQuery.of(context).viewInsets.bottom +
                                            40),
                                child: FractionallySizedBox(
                                  heightFactor: 0.8,
                                  child: BlocProvider<PostBloc>.value(
                                    value: postBloc,
                                    child: CreateCommentModal(postView: postView),
                                  ),
                                ),
                              );
                            },
                          );
                        }
                      : null,
                  icon: const Icon(Icons.reply_rounded, semanticLabel: 'Reply'),
                ),
              ),
              Expanded(
                flex: 1,
                child: IconButton(
                  icon: const Icon(Icons.share_rounded, semanticLabel: 'Share'),
                  onPressed: () => Share.share(post.apId),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
