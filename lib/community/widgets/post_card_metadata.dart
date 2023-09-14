import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lemmy_api_client/v3.dart';

import 'package:thunder/community/utils/post_card_action_helpers.dart';
import 'package:thunder/core/enums/font_scale.dart';
import 'package:thunder/shared/community_icon.dart';
import 'package:thunder/shared/icon_text.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/utils/date_time.dart';
import 'package:thunder/utils/instance.dart';
import 'package:thunder/utils/navigate_community.dart';
import 'package:thunder/utils/navigate_user.dart';
import 'package:thunder/utils/numbers.dart';

class PostCardMetaData extends StatelessWidget {
  final int score;
  final VoteType voteType;
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
    return BlocBuilder<ThunderBloc, ThunderState>(
      builder: (context, state) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Flexible(
              child: Wrap(
                alignment: WrapAlignment.start,
                runSpacing: 2,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconText(
                        textScaleFactor: MediaQuery.of(context).textScaleFactor * state.metadataFontSizeScale.textScaleFactor,
                        text: formatNumberToK(score),
                        textColor: voteType == VoteType.up
                            ? upVoteColor
                            : voteType == VoteType.down
                                ? downVoteColor
                                : readColor,
                        icon: Icon(voteType == VoteType.up ? Icons.arrow_upward : (voteType == VoteType.down ? Icons.arrow_downward : (score < 0 ? Icons.arrow_downward : Icons.arrow_upward)),
                            size: 20.0,
                            color: voteType == VoteType.up
                                ? upVoteColor
                                : voteType == VoteType.down
                                    ? downVoteColor
                                    : readColor),
                        padding: 2.0,
                      ),
                      const SizedBox(width: 10.0),
                      IconText(
                        textScaleFactor: MediaQuery.of(context).textScaleFactor * state.metadataFontSizeScale.textScaleFactor,
                        icon: Icon(
                          /*unreadComments != 0 && unreadComments != comments ? Icons.mark_unread_chat_alt_rounded  :*/ Icons.chat,
                          size: 15.0,
                          color: /*unreadComments != 0 && unreadComments != comments ? theme.primaryColor :*/
                              readColor,
                        ),
                        text: /*unreadComments != 0 && unreadComments != comments ? '+${formatNumberToK(unreadComments)}' :*/
                            formatNumberToK(comments),
                        textColor: /*unreadComments != 0 && unreadComments != comments ? theme.primaryColor :*/
                            readColor,
                        padding: 5.0,
                      ),
                      const SizedBox(width: 10.0),
                      IconText(
                        textScaleFactor: MediaQuery.of(context).textScaleFactor * state.metadataFontSizeScale.textScaleFactor,
                        icon: Icon(
                          hasBeenEdited ? Icons.edit : Icons.history_rounded,
                          size: 15.0,
                          color: readColor,
                        ),
                        text: formatTimeToString(dateTime: published.toIso8601String()),
                        textColor: readColor,
                      ),
                      const SizedBox(width: 8.0),
                    ],
                  ),
                  if (hostURL != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 2.0),
                      child: Tooltip(
                        message: hostURL,
                        preferBelow: false,
                        child: IconText(
                          textScaleFactor: MediaQuery.of(context).textScaleFactor * state.metadataFontSizeScale.textScaleFactor,
                          icon: Icon(
                            Icons.public,
                            size: 15.0,
                            color: readColor,
                          ),
                          text: Uri.parse(hostURL!).host.replaceFirst('www.', ''),
                          textColor: readColor,
                        ),
                      ),
                    ),
                ],
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                /*Container(
                  child: unreadComments != 0 && unreadComments != comments ? Row(
                    children: [
                      IconText(
                        textScaleFactor: MediaQuery.of(context).textScaleFactor * state.metadataFontSizeScale.textScaleFactor,
                        icon: Icon(
                          Icons.mark_unread_chat_alt_rounded,
                          size: 17.0,
                          color: theme.primaryColor,
                        ),
                        text: '+${formatNumberToK(unreadComments)}',
                        textColor: theme.primaryColor,
                        padding: 5.0,
                      ),
                      const SizedBox(width: 10.0),
                    ],
                  ) : null,
                ),*/
                IconText(
                  textScaleFactor: MediaQuery.of(context).textScaleFactor * state.metadataFontSizeScale.textScaleFactor,
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
                  textScaleFactor: MediaQuery.of(context).textScaleFactor * state.metadataFontSizeScale.textScaleFactor,
                  icon: Icon(
                    hasBeenEdited ? Icons.refresh_rounded : Icons.history_rounded,
                    size: 19.0,
                    color: theme.textTheme.titleSmall?.color?.withOpacity(0.75),
                  ),
                  text: formatTimeToString(dateTime: published.toIso8601String()),
                  textColor: theme.textTheme.titleSmall?.color?.withOpacity(0.9),
                ),
              ],
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
              onTap: () => navigateToCommunityPage(context, communityId: postView.community.id),
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
                            child: Text('$creatorName', textScaleFactor: MediaQuery.of(context).textScaleFactor * state.metadataFontSizeScale.textScaleFactor, style: textStyleAuthor)),
                        if (!communityMode)
                          Text(
                            ' to ',
                            textScaleFactor: MediaQuery.of(context).textScaleFactor * state.metadataFontSizeScale.textScaleFactor,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.4),
                            ),
                          ),
                      ],
                    ),
                  InkWell(
                    borderRadius: BorderRadius.circular(6),
                    onTap: (compactMode && !state.tappableAuthorCommunity) ? null : () => navigateToCommunityPage(context, communityId: postView.community.id),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!communityMode)
                          Text(
                            '${postView.community.name} · ${fetchInstanceNameFromUrl(postView.community.actorId)}',
                            textScaleFactor: MediaQuery.of(context).textScaleFactor * state.metadataFontSizeScale.textScaleFactor,
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
