import 'package:flutter/material.dart';
<<<<<<< HEAD
<<<<<<< HEAD
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:lemmy/lemmy.dart';
=======
=======
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:lemmy/lemmy.dart';
import 'package:thunder/account/bloc/account_bloc.dart';
<<<<<<< HEAD
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a
=======
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a

import 'package:thunder/community/bloc/community_bloc.dart';
import 'package:thunder/community/community.dart';
import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/core/models/post_view_media.dart';
import 'package:thunder/post/pages/post_page.dart';
import 'package:thunder/shared/icon_text.dart';
import 'package:thunder/shared/media_view.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/utils/date_time.dart';
import 'package:thunder/utils/numbers.dart';

class PostCard extends StatelessWidget {
  final PostViewMedia postView;

  const PostCard({super.key, required this.postView});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Post post = postView.post;

    final bool showFullHeightImages = context.read<ThunderBloc>().state.preferences?.getBool('setting_general_show_full_height_images') ?? false;
    final bool showVoteActions = context.read<ThunderBloc>().state.preferences?.getBool('setting_general_show_vote_actions') ?? true;
    final bool showSaveAction = context.read<ThunderBloc>().state.preferences?.getBool('setting_general_show_save_action') ?? true;

    final bool isUserLoggedIn = context.read<AuthBloc>().state.isLoggedIn;

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
                MediaView(postView: postView, showFullHeightImages: showFullHeightImages),
                Text(post.name, style: theme.textTheme.titleMedium, softWrap: true),
                Padding(
                  padding: const EdgeInsets.only(top: 6.0, bottom: 4.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
<<<<<<< HEAD
<<<<<<< HEAD
                              child: Text(
                                postView.community.name,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontSize: theme.textTheme.titleSmall!.fontSize! * 1.05,
                                  color: theme.textTheme.titleSmall?.color?.withOpacity(0.75),
                                ),
                              ),
                              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) => CommunityPage(communityId: postView.community.id),
                              )),
                            ),
=======
=======
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a
                                child: Text(
                                  postView.community.name,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontSize: theme.textTheme.titleSmall!.fontSize! * 1.05,
                                    color: theme.textTheme.titleSmall?.color?.withOpacity(0.75),
                                  ),
                                ),
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
                                }),
<<<<<<< HEAD
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a
=======
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a
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
<<<<<<< HEAD
<<<<<<< HEAD
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (showVoteActions)
                            IconButton(
                              icon: const Icon(Icons.arrow_upward),
                              color: postView.myVote == 1 ? Colors.orange : null,
                              visualDensity: VisualDensity.compact,
                              onPressed: isUserLoggedIn ? () => context.read<CommunityBloc>().add(VotePostEvent(postId: post.id, score: postView.myVote == 1 ? 0 : 1)) : null,
                            ),
                          if (showVoteActions)
                            IconButton(
                              icon: const Icon(Icons.arrow_downward),
                              color: postView.myVote == -1 ? Colors.blue : null,
                              visualDensity: VisualDensity.compact,
                              onPressed: isUserLoggedIn ? () => context.read<CommunityBloc>().add(VotePostEvent(postId: post.id, score: postView.myVote == -1 ? 0 : -1)) : null,
                            ),
                          if (showSaveAction)
                            IconButton(
                              icon: Icon(postView.saved ? Icons.star_rounded : Icons.star_border_rounded),
                              color: postView.saved ? Colors.purple : null,
                              visualDensity: VisualDensity.compact,
                              onPressed: isUserLoggedIn ? () => context.read<CommunityBloc>().add(SavePostEvent(postId: post.id, save: postView.saved ? false : true)) : null,
                            ),
                        ],
                      ),
=======
=======
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a
                      if (isUserLoggedIn)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (showVoteActions)
                              IconButton(
                                icon: const Icon(Icons.arrow_upward),
                                color: postView.myVote == 1 ? Colors.orange : null,
                                visualDensity: VisualDensity.compact,
                                onPressed: isUserLoggedIn
                                    ? () {
                                        HapticFeedback.mediumImpact();
                                        context.read<CommunityBloc>().add(VotePostEvent(postId: post.id, score: postView.myVote == 1 ? 0 : 1));
                                      }
                                    : null,
                              ),
                            if (showVoteActions)
                              IconButton(
                                icon: const Icon(Icons.arrow_downward),
                                color: postView.myVote == -1 ? Colors.blue : null,
                                visualDensity: VisualDensity.compact,
                                onPressed: isUserLoggedIn
                                    ? () {
                                        HapticFeedback.mediumImpact();
                                        context.read<CommunityBloc>().add(VotePostEvent(postId: post.id, score: postView.myVote == -1 ? 0 : -1));
                                      }
                                    : null,
                              ),
                            if (showSaveAction)
                              IconButton(
                                icon: Icon(postView.saved ? Icons.star_rounded : Icons.star_border_rounded),
                                color: postView.saved ? Colors.purple : null,
                                visualDensity: VisualDensity.compact,
                                onPressed: isUserLoggedIn
                                    ? () {
                                        HapticFeedback.mediumImpact();
                                        context.read<CommunityBloc>().add(SavePostEvent(postId: post.id, save: postView.saved ? false : true));
                                      }
                                    : null,
                              ),
                          ],
                        ),
<<<<<<< HEAD
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a
=======
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a
                    ],
                  ),
                )
              ],
            ),
          ),
          onTap: () async {
<<<<<<< HEAD
<<<<<<< HEAD
            CommunityBloc bloc = BlocProvider.of<CommunityBloc>(context);
            AuthBloc authBloc = BlocProvider.of<AuthBloc>(context);
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return BlocProvider.value(
                    value: bloc,
                    child: BlocProvider.value(
                      value: authBloc,
                      child: PostPage(postView: postView),
                    ),
                  );
                },
=======
=======
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a
            AccountBloc accountBloc = context.read<AccountBloc>();
            AuthBloc authBloc = context.read<AuthBloc>();
            ThunderBloc thunderBloc = context.read<ThunderBloc>();
            CommunityBloc communityBloc = BlocProvider.of<CommunityBloc>(context);

            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => MultiBlocProvider(
                  providers: [
                    BlocProvider.value(value: accountBloc),
                    BlocProvider.value(value: authBloc),
                    BlocProvider.value(value: thunderBloc),
                    BlocProvider.value(value: communityBloc),
                  ],
                  child: PostPage(postView: postView),
                ),
<<<<<<< HEAD
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a
=======
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a
              ),
            );
            if (context.mounted) context.read<CommunityBloc>().add(ForceRefreshEvent());
          },
        ),
      ],
    );
  }
}
