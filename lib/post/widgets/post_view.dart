import 'package:flutter/material.dart';
<<<<<<< HEAD
<<<<<<< HEAD

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

=======
=======
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a
import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thunder/account/bloc/account_bloc.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import 'package:thunder/community/pages/community_page.dart';
<<<<<<< HEAD
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a
=======
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a
import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/core/models/post_view_media.dart';
import 'package:thunder/post/bloc/post_bloc.dart';
import 'package:thunder/shared/media_view.dart';
import 'package:thunder/utils/date_time.dart';

class PostSubview extends StatelessWidget {
  final PostViewMedia postView;

  const PostSubview({super.key, required this.postView});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final bool isUserLoggedIn = context.read<AuthBloc>().state.isLoggedIn;

    return Padding(
      padding: const EdgeInsets.only(left: 12.0, right: 12.0, bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(postView.post.name, style: theme.textTheme.titleMedium),
          ),
          Row(
            children: [
<<<<<<< HEAD
<<<<<<< HEAD
              Text(
                postView.community.name,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.75),
=======
=======
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a
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
<<<<<<< HEAD
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a
=======
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a
                ),
              ),
              Text(
                ' · ${formatTimeToString(dateTime: postView.post.published)} · ',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.75),
                ),
              ),
              Text(
                postView.creator.name,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.75),
                ),
              ),
            ],
          ),
          MediaView(post: postView.post, postView: postView),
          if (postView.post.body != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: MarkdownBody(
                data: postView.post.body!,
                onTapLink: (text, url, title) => launchUrl(Uri.parse(url!)),
                styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
                  p: theme.textTheme.bodyMedium,
                  blockquoteDecoration: const BoxDecoration(
                    color: Colors.transparent,
                    border: Border(left: BorderSide(color: Colors.grey, width: 4)),
                  ),
                ),
              ),
            ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
<<<<<<< HEAD
<<<<<<< HEAD
                onPressed: isUserLoggedIn ? () => context.read<PostBloc>().add(VotePostEvent(postId: postView.post.id, score: postView.myVote == 1 ? 0 : 1)) : null,
=======
=======
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a
                onPressed: isUserLoggedIn
                    ? () {
                        HapticFeedback.mediumImpact();
                        context.read<PostBloc>().add(VotePostEvent(postId: postView.post.id, score: postView.myVote == 1 ? 0 : 1));
                      }
                    : null,
<<<<<<< HEAD
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a
=======
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a
                icon: const Icon(Icons.arrow_upward),
                color: postView.myVote == 1 ? Colors.orange : null,
              ),
              IconButton(
<<<<<<< HEAD
<<<<<<< HEAD
                onPressed: isUserLoggedIn ? () => context.read<PostBloc>().add(VotePostEvent(postId: postView.post.id, score: postView.myVote == -1 ? 0 : -1)) : null,
=======
=======
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a
                onPressed: isUserLoggedIn
                    ? () {
                        HapticFeedback.mediumImpact();
                        context.read<PostBloc>().add(VotePostEvent(postId: postView.post.id, score: postView.myVote == -1 ? 0 : -1));
                      }
                    : null,
<<<<<<< HEAD
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a
=======
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a
                icon: const Icon(Icons.arrow_downward),
                color: postView.myVote == -1 ? Colors.blue : null,
              ),
              IconButton(
<<<<<<< HEAD
<<<<<<< HEAD
                onPressed: isUserLoggedIn ? () => context.read<PostBloc>().add(SavePostEvent(postId: postView.post.id, save: !postView.saved)) : null,
=======
=======
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a
                onPressed: isUserLoggedIn
                    ? () {
                        HapticFeedback.mediumImpact();
                        context.read<PostBloc>().add(SavePostEvent(postId: postView.post.id, save: !postView.saved));
                      }
                    : null,
<<<<<<< HEAD
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a
=======
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a
                icon: Icon(postView.saved ? Icons.star_rounded : Icons.star_border_rounded),
                color: postView.saved ? Colors.purple : null,
              ),
              // IconButton(
              //   onPressed: null,
              //   icon: Icon(
              //     Icons.reply_rounded,
              //   ),
              // ),
              // IconButton(
              //   onPressed: null,
              //   icon: Icon(
              //     Icons.ios_share_rounded,
              //   ),
              // )
            ],
          )
        ],
      ),
    );
  }
}
