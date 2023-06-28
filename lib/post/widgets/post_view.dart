import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:share_plus/share_plus.dart';

import 'package:thunder/account/bloc/account_bloc.dart';
import 'package:thunder/post/widgets/create_comment_modal.dart';
import 'package:thunder/shared/common_markdown_body.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/community/pages/community_page.dart';
import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/core/models/post_view_media.dart';
import 'package:thunder/post/bloc/post_bloc.dart';
import 'package:thunder/shared/media_view.dart';
import 'package:thunder/user/pages/user_page.dart';
import 'package:thunder/utils/date_time.dart';

class PostSubview extends StatelessWidget {
  final PostViewMedia postViewMedia;

  const PostSubview({super.key, required this.postViewMedia});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final PostView postView = postViewMedia.postView;
    final Post post = postView.post;

    final bool isUserLoggedIn = context.read<AuthBloc>().state.isLoggedIn;
    final bool hideNsfwPreviews = context.read<ThunderBloc>().state.preferences?.getBool('setting_general_hide_nsfw_previews') ?? true;

    return Padding(
      padding: const EdgeInsets.only(left: 12.0, right: 12.0, bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(post.name, style: theme.textTheme.titleMedium),
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  AccountBloc accountBloc = context.read<AccountBloc>();
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
                        child: CommunityPage(communityId: postView.community.id),
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
              Text(
                ' · ${formatTimeToString(dateTime: post.published.toIso8601String())} · ',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.75),
                ),
              ),
              GestureDetector(
                onTap: () {
                  AccountBloc accountBloc = context.read<AccountBloc>();
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
            ],
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
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                onPressed: isUserLoggedIn
                    ? () {
                        HapticFeedback.mediumImpact();
                        context.read<PostBloc>().add(VotePostEvent(postId: post.id, score: postView.myVote == VoteType.up ? VoteType.none : VoteType.up));
                      }
                    : null,
                icon: Icon(
                  Icons.arrow_upward,
                  semanticLabel: postView.myVote == VoteType.up ? 'Upvoted' : 'Upvote',
                ),
                color: postView.myVote == VoteType.up ? Colors.orange : null,
              ),
              IconButton(
                onPressed: isUserLoggedIn
                    ? () {
                        HapticFeedback.mediumImpact();
                        context.read<PostBloc>().add(VotePostEvent(postId: post.id, score: postView.myVote == VoteType.down ? VoteType.none : VoteType.down));
                      }
                    : null,
                icon: Icon(
                  Icons.arrow_downward,
                  semanticLabel: postView.myVote == VoteType.down ? 'Downvoted' : 'Downvote',
                ),
                color: postView.myVote == VoteType.down ? Colors.blue : null,
              ),
              IconButton(
                onPressed: isUserLoggedIn
                    ? () {
                        HapticFeedback.mediumImpact();
                        context.read<PostBloc>().add(SavePostEvent(postId: post.id, save: !postView.saved));
                      }
                    : null,
                icon: Icon(
                  postView.saved ? Icons.star_rounded : Icons.star_border_rounded,
                  semanticLabel: postView.saved ? 'Saved' : 'Save',
                ),
                color: postView.saved ? Colors.purple : null,
              ),
              IconButton(
                onPressed: isUserLoggedIn
                    ? () {
                        PostBloc postBloc = context.read<PostBloc>();

                        showModalBottomSheet(
                          isScrollControlled: true,
                          context: context,
                          showDragHandle: true,
                          builder: (context) {
                            return Padding(
                              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 40),
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
              IconButton(
                icon: const Icon(Icons.share_rounded, semanticLabel: 'Share'),
                onPressed: () => Share.share(post.apId),
              )
            ],
          )
        ],
      ),
    );
  }
}
