import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thunder/account/bloc/account_bloc.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import 'package:thunder/community/pages/community_page.dart';
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
    final bool hideNsfwPreviews = context.read<ThunderBloc>().state.preferences?.getBool('setting_general_hide_nsfw_previews') ?? true;

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
          MediaView(post: postView.post, postView: postView, hideNsfwPreviews: hideNsfwPreviews,),
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
                onPressed: isUserLoggedIn
                    ? () {
                        HapticFeedback.mediumImpact();
                        context.read<PostBloc>().add(VotePostEvent(postId: postView.post.id, score: postView.myVote == 1 ? 0 : 1));
                      }
                    : null,
                icon: const Icon(Icons.arrow_upward),
                color: postView.myVote == 1 ? Colors.orange : null,
              ),
              IconButton(
                onPressed: isUserLoggedIn
                    ? () {
                        HapticFeedback.mediumImpact();
                        context.read<PostBloc>().add(VotePostEvent(postId: postView.post.id, score: postView.myVote == -1 ? 0 : -1));
                      }
                    : null,
                icon: const Icon(Icons.arrow_downward),
                color: postView.myVote == -1 ? Colors.blue : null,
              ),
              IconButton(
                onPressed: isUserLoggedIn
                    ? () {
                        HapticFeedback.mediumImpact();
                        context.read<PostBloc>().add(SavePostEvent(postId: postView.post.id, save: !postView.saved));
                      }
                    : null,
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
