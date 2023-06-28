import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lemmy_api_client/v3.dart';

import 'package:thunder/account/bloc/account_bloc.dart';
import 'package:thunder/community/pages/community_page.dart';
import 'package:thunder/community/widgets/post_card_actions.dart';
import 'package:thunder/community/widgets/post_card_metadata.dart';
import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/core/models/post_view_media.dart';
import 'package:thunder/shared/media_view.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/utils/instance.dart';

class PostCardViewComfortable extends StatelessWidget {
  final PostViewMedia postViewMedia;
  final bool showThumbnailPreviewOnRight;
  final bool hideNsfwPreviews;
  final bool showInstanceName;
  final bool showFullHeightImages;
  final bool showVoteActions;
  final bool showSaveAction;
  final bool isUserLoggedIn;

  const PostCardViewComfortable({
    super.key,
    required this.postViewMedia,
    required this.showThumbnailPreviewOnRight,
    required this.hideNsfwPreviews,
    required this.showInstanceName,
    required this.showFullHeightImages,
    required this.showVoteActions,
    required this.showSaveAction,
    required this.isUserLoggedIn,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MediaView(
            postView: postViewMedia,
            showFullHeightImages: showFullHeightImages,
            hideNsfwPreviews: hideNsfwPreviews,
          ),
          Text(postViewMedia.postView.post.name, style: theme.textTheme.titleMedium, softWrap: true),
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
                          '${postViewMedia.postView.community.name}${showInstanceName ? ' · ${fetchInstanceNameFromUrl(postViewMedia.postView.community.actorId)}' : ''}',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontSize: theme.textTheme.titleSmall!.fontSize! * 1.05,
                            color: theme.textTheme.titleSmall?.color?.withOpacity(0.75),
                          ),
                        ),
                        onTap: () => onTapCommunityName(context),
                      ),
                      const SizedBox(height: 8.0),
                      PostCardMetaData(
                        score: postViewMedia.postView.counts.score,
                        voteType: postViewMedia.postView.myVote ?? VoteType.none,
                        comments: postViewMedia.postView.counts.comments,
                        published: postViewMedia.postView.post.published,
                        saved: postViewMedia.postView.saved,
                      )
                    ],
                  ),
                ),
                if (isUserLoggedIn)
                  PostCardActions(
                    postId: postViewMedia.postView.post.id,
                    voteType: postViewMedia.postView.myVote ?? VoteType.none,
                    saved: postViewMedia.postView.saved,
                  ),
              ],
            ),
          )
        ],
      ),
    );
  }

  void onTapCommunityName(BuildContext context) {
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
          child: CommunityPage(communityId: postViewMedia.postView.community.id),
        ),
      ),
    );
  }
}
