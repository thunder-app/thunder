import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lemmy_api_client/v3.dart';

import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/core/enums/full_name_separator.dart';
import 'package:thunder/feed/feed.dart';
import 'package:thunder/shared/community_icon.dart';
import 'package:thunder/shared/icon_text.dart';
import 'package:thunder/shared/text/scalable_text.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/utils/date_time.dart';
import 'package:thunder/utils/instance.dart';
import 'package:thunder/utils/navigate_user.dart';
import 'package:thunder/utils/numbers.dart';

class PostCardMetaData extends StatelessWidget {
  final int score;
  final int voteType;
  final int unreadComments;
  final int comments;
  final bool hasBeenEdited;
  final DateTime published;
  final String? hostURL;
  final Color? readColor;

  const PostCardMetaData({
    super.key,
    required this.score,
    required this.voteType,
    required this.unreadComments,
    required this.comments,
    required this.hasBeenEdited,
    required this.published,
    this.hostURL,
    this.readColor,
  });

  final MaterialColor upVoteColor = Colors.orange;
  final MaterialColor downVoteColor = Colors.blue;

  @override
  Widget build(BuildContext context) {
    final AuthState authState = context.watch<AuthBloc>().state;
    final showScores = authState.getSiteResponse?.myUser?.localUserView.localUser.showScores ?? true;

    return BlocBuilder<ThunderBloc, ThunderState>(
      builder: (context, state) {
        return Wrap(
          children: [
            IconText(
              fontScale: state.metadataFontSizeScale,
              text: showScores ? formatNumberToK(score) : null,
              textColor: voteType == 1
                  ? upVoteColor
                  : voteType == -1
                      ? downVoteColor
                      : readColor,
              icon: Icon(voteType == 1 ? Icons.arrow_upward : (voteType == -1 ? Icons.arrow_downward : (score < 0 ? Icons.arrow_downward : Icons.arrow_upward)),
                  size: 20.0,
                  color: voteType == 1
                      ? upVoteColor
                      : voteType == -1
                          ? downVoteColor
                          : readColor),
              padding: 2.0,
            ),
            const SizedBox(width: 8.0),
            IconText(
              fontScale: state.metadataFontSizeScale,
              icon: Icon(
                Icons.chat,
                size: 18.0,
                color: readColor,
              ),
              text: formatNumberToK(comments),
              textColor: readColor,
              padding: 5.0,
            ),
            const SizedBox(width: 8.0),
            IconText(
              fontScale: state.metadataFontSizeScale,
              icon: Icon(
                hasBeenEdited ? Icons.edit : Icons.history_rounded,
                size: 18.0,
                color: readColor,
              ),
              text: formatTimeToString(dateTime: published.toIso8601String()),
              textColor: readColor,
            ),
            const SizedBox(width: 8.0),
            if (hostURL != null)
              Tooltip(
                message: hostURL,
                preferBelow: false,
                child: IconText(
                  fontScale: state.metadataFontSizeScale,
                  icon: Icon(
                    Icons.public,
                    size: 17.0,
                    color: readColor,
                  ),
                  text: Uri.parse(hostURL!).host.replaceFirst('www.', ''),
                  textColor: readColor,
                ),
              ),
          ],
        );
      },
    );
  }
}

class PostViewMetaData extends StatelessWidget {
  final int unreadComments;
  final int comments;
  final bool hasBeenEdited;
  final DateTime published;
  final bool saved;

  const PostViewMetaData({
    super.key,
    required this.unreadComments,
    required this.comments,
    required this.hasBeenEdited,
    required this.published,
    required this.saved,
  });

  final MaterialColor upVoteColor = Colors.orange;
  final MaterialColor downVoteColor = Colors.blue;
  final MaterialColor savedColor = Colors.purple;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<ThunderBloc, ThunderState>(
      builder: (context, state) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconText(
              fontScale: state.metadataFontSizeScale,
              icon: Icon(
                Icons.chat,
                size: 17.0,
                color: theme.textTheme.titleSmall?.color?.withOpacity(0.75),
              ),
              text: formatNumberToK(comments),
              textColor: theme.textTheme.titleSmall?.color?.withOpacity(0.9),
              padding: 5.0,
            ),
            const SizedBox(width: 10.0),
            IconText(
              fontScale: state.metadataFontSizeScale,
              icon: Icon(
                hasBeenEdited ? Icons.refresh_rounded : Icons.history_rounded,
                size: 19.0,
                color: theme.textTheme.titleSmall?.color?.withOpacity(0.75),
              ),
              text: formatTimeToString(dateTime: published.toIso8601String()),
              textColor: theme.textTheme.titleSmall?.color?.withOpacity(0.9),
            ),
          ],
        );
      },
    );
  }
}

class PostCommunityAndAuthor extends StatelessWidget {
  const PostCommunityAndAuthor({
    super.key,
    required this.postView,
    required this.showCommunityIcons,
    required this.communityMode,
    this.textStyleAuthor,
    this.textStyleCommunity,
    required this.compactMode,
    required this.showCommunitySubscription,
  });

  final bool showCommunityIcons;
  final bool communityMode;
  final bool compactMode;
  final PostView postView;
  final TextStyle? textStyleAuthor;
  final TextStyle? textStyleCommunity;
  final bool showCommunitySubscription;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<ThunderBloc, ThunderState>(builder: (context, state) {
      final String? creatorName = postView.creator.displayName != null && state.useDisplayNames ? postView.creator.displayName : postView.creator.name;

      return Row(
        children: [
          if (showCommunityIcons)
            GestureDetector(
              child: Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: CommunityIcon(community: postView.community, radius: 14),
              ),
              onTap: () => navigateToFeedPage(context, communityId: postView.community.id, feedType: FeedType.community),
            ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 6.0),
              child: Wrap(
                direction: Axis.horizontal,
                alignment: WrapAlignment.start,
                crossAxisAlignment: WrapCrossAlignment.end,
                children: [
                  if (state.showPostAuthor || communityMode)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                            borderRadius: BorderRadius.circular(6),
                            onTap: (compactMode && !state.tappableAuthorCommunity) ? null : () => navigateToUserPage(context, userId: postView.creator.id),
                            child: ScalableText(
                              '$creatorName',
                              fontScale: state.metadataFontSizeScale,
                              style: textStyleAuthor,
                            )),
                        if (!communityMode)
                          ScalableText(
                            ' to ',
                            fontScale: state.metadataFontSizeScale,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.4),
                            ),
                          ),
                      ],
                    ),
                  InkWell(
                    borderRadius: BorderRadius.circular(6),
                    onTap: (compactMode && !state.tappableAuthorCommunity) ? null : () => navigateToFeedPage(context, feedType: FeedType.community, communityId: postView.community.id),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!communityMode)
                          ScalableText(
                            generateCommunityFullName(context, postView.community.name, fetchInstanceNameFromUrl(postView.community.actorId)),
                            fontScale: state.metadataFontSizeScale,
                            style: textStyleCommunity,
                          ),
                        if (showCommunitySubscription)
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 3,
                              left: 4,
                            ),
                            child: Icon(
                              Icons.playlist_add_check_rounded,
                              size: 16.0,
                              color: textStyleCommunity?.color,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }
}
