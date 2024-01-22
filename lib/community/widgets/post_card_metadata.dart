import 'package:flutter/material.dart';

import 'package:lemmy_api_client/v3.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/core/enums/full_name_separator.dart';
import 'package:thunder/feed/feed.dart';
import 'package:thunder/post/enums/post_card_metadata_item.dart';
import 'package:thunder/shared/avatars/community_avatar.dart';
import 'package:thunder/shared/icon_text.dart';
import 'package:thunder/shared/text/scalable_text.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/utils/date_time.dart';
import 'package:thunder/utils/instance.dart';
import 'package:thunder/user/utils/navigate_user.dart';
import 'package:thunder/utils/numbers.dart';

const Color upVoteColor = Colors.orange;
const Color downVoteColor = Colors.blue;
Color readColor = Colors.grey.shade700;

@Deprecated("Use [PostViewMetaData] instead")
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

/// Contains metadata related to a given post. This is generally displayed as part of the post card.
///
/// This information is customizable, and can be changed by the user in the settings.
/// The order in which the items are displayed depends on the order in the [postCardMetadataItems] list
class PostCardMetadata extends StatelessWidget {
  /// The score of the post. If null, no score will be displayed.
  final int? score;

  /// The number of upvotes on the post. If null, no upvote count will be displayed.
  final int? upvoteCount;

  /// The number of downvotes on the post. If null, no downvote count will be displayed.
  final int? downvoteCount;

  /// The vote for the post. This should be either 0, 1 or -1. Defaults to 0 if not specified.
  /// When specified, this will change the color of the upvote/downvote/score icons.
  final int? voteType;

  /// The number of comments on the post. If null, no comment count will be displayed.
  final int? commentCount;

  /// The date/time the post was created or updated. This string should conform to ISO-8601 format.
  final String? dateTime;

  /// Whether or not the post has been edited. This determines the icon for the [dateTime] field.
  final bool? hasBeenEdited;

  /// Whether or not the post has been read. This is passed down to the individual [PostCardMetadataItem] widgets to determine the color.
  final bool? hasBeenRead;

  /// The URL to display in the metadata. If null, no URL will be displayed.
  final String? url;

  const PostCardMetadata({
    super.key,
    this.score,
    this.upvoteCount,
    this.downvoteCount,
    this.voteType = 0,
    this.commentCount,
    this.dateTime,
    this.hasBeenEdited = false,
    this.hasBeenRead = false,
    this.url,
  });

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AuthBloc>().state;
    final showScores = state.getSiteResponse?.myUser?.localUserView.localUser.showScores ?? true;

    List<PostCardMetadataItem> postCardMetadataItems = context.read<ThunderBloc>().state.compactPostCardMetadataItems;

    return Wrap(
      spacing: 8.0,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: postCardMetadataItems.map(
        (PostCardMetadataItem postCardMetadataItem) {
          return switch (postCardMetadataItem) {
            PostCardMetadataItem.score => showScores ? ScorePostCardMetaData(score: score, voteType: voteType, hasBeenRead: hasBeenRead ?? false) : Container(),
            PostCardMetadataItem.upvote => showScores ? UpvotePostCardMetaData(upvotes: upvoteCount, isUpvoted: voteType == 1, hasBeenRead: hasBeenRead ?? false) : Container(),
            PostCardMetadataItem.downvote => showScores ? DownvotePostCardMetaData(downvotes: downvoteCount, isDownvoted: voteType == -1, hasBeenRead: hasBeenRead ?? false) : Container(),
            PostCardMetadataItem.commentCount => CommentCountPostCardMetaData(commentCount: commentCount, hasBeenRead: hasBeenRead ?? false),
            PostCardMetadataItem.dateTime => DateTimePostCardMetaData(dateTime: dateTime!, hasBeenRead: hasBeenRead ?? false, hasBeenEdited: hasBeenEdited ?? false),
            PostCardMetadataItem.url => UrlPostCardMetaData(url: url, hasBeenRead: hasBeenRead ?? false),
          };
        },
      ).toList(),
    );
  }
}

/// Contains metadata related to the score of a given post. This is used in the [PostCardMetadata] widget.
class ScorePostCardMetaData extends StatelessWidget {
  /// The score of the post. Defaults to 0 if not specified.
  final int? score;

  /// The vote for the post. This should be either 0, 1 or -1. Defaults to 0 if not specified.
  final int? voteType;

  /// Whether or not the post has been read. This is used to determine the color.
  final bool hasBeenRead;

  const ScorePostCardMetaData({
    super.key,
    this.score = 0,
    this.voteType = 0,
    this.hasBeenRead = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final state = context.read<ThunderBloc>().state;

    final color = switch (voteType) {
      1 => upVoteColor,
      -1 => downVoteColor,
      _ => hasBeenRead ? readColor : null,
    };

    return Wrap(
      spacing: 2.0,
      crossAxisAlignment: WrapCrossAlignment.center,
      runAlignment: WrapAlignment.center,
      children: [
        Icon(Icons.arrow_upward, size: 17.0, color: color),
        ScalableText(
          formatNumberToK(score ?? 0),
          semanticsLabel: l10n.xScore(formatNumberToK(score ?? 0)),
          fontScale: state.metadataFontSizeScale,
          style: theme.textTheme.bodyMedium?.copyWith(color: color),
        ),
        Icon(Icons.arrow_downward, size: 17.0, color: color),
      ],
    );
  }
}

/// Contains metadata related to the upvotes of a given post. This is used in the [PostCardMetadata] widget.
class UpvotePostCardMetaData extends StatelessWidget {
  /// The number of upvotes on the post. Defaults to 0 if not specified.
  final int? upvotes;

  /// Whether or not the post has been upvoted. Defaults to false if not specified.
  final bool? isUpvoted;

  /// Whether or not the post has been read. This is used to determine the color.
  final bool hasBeenRead;

  const UpvotePostCardMetaData({
    super.key,
    this.upvotes = 0,
    this.isUpvoted = false,
    this.hasBeenRead = false,
  });

  @override
  Widget build(BuildContext context) {
    final state = context.read<ThunderBloc>().state;

    final color = switch (isUpvoted) {
      true => upVoteColor,
      _ => hasBeenRead ? readColor : null,
    };

    return IconText(
      fontScale: state.metadataFontSizeScale,
      text: formatNumberToK(upvotes ?? 0),
      textColor: color,
      padding: 2.0,
      icon: Icon(Icons.arrow_upward, size: 17.0, color: color),
    );
  }
}

/// Contains metadata related to the downvotes of a given post. This is used in the [PostCardMetadata] widget.
class DownvotePostCardMetaData extends StatelessWidget {
  /// The number of downvotes on the post. Defaults to 0 if not specified.
  final int? downvotes;

  /// Whether or not the post has been downvoted. Defaults to false if not specified.
  final bool? isDownvoted;

  /// Whether or not the post has been read. This is used to determine the color.
  final bool hasBeenRead;

  const DownvotePostCardMetaData({
    super.key,
    this.downvotes = 0,
    this.isDownvoted = false,
    this.hasBeenRead = false,
  });

  @override
  Widget build(BuildContext context) {
    final state = context.read<ThunderBloc>().state;

    final color = switch (isDownvoted) {
      true => downVoteColor,
      _ => hasBeenRead ? readColor : null,
    };

    return IconText(
      fontScale: state.metadataFontSizeScale,
      text: formatNumberToK(downvotes ?? 0),
      textColor: color,
      padding: 2.0,
      icon: Icon(Icons.arrow_downward, size: 17.0, color: color),
    );
  }
}

/// Contains metadata related to the number of comments for a given post. This is used in the [PostCardMetadata] widget.
class CommentCountPostCardMetaData extends StatelessWidget {
  /// The number of comments on the post. Defaults to 0 if not specified.
  final int? commentCount;

  /// Whether or not the post has been read. This is used to determine the color.
  final bool hasBeenRead;

  const CommentCountPostCardMetaData({
    super.key,
    this.commentCount = 0,
    this.hasBeenRead = false,
  });

  @override
  Widget build(BuildContext context) {
    final state = context.read<ThunderBloc>().state;

    final color = switch (hasBeenRead) {
      true => readColor,
      _ => null,
    };

    return IconText(
      fontScale: state.metadataFontSizeScale,
      text: formatNumberToK(commentCount ?? 0),
      textColor: color,
      padding: 5.0,
      icon: Icon(Icons.chat_rounded, size: 17.0, color: color),
    );
  }
}

/// Contains metadata related to the number of comments for a given post. This is used in the [PostCardMetadata] widget.
class DateTimePostCardMetaData extends StatelessWidget {
  /// The date/time the post was created or updated. This string should conform to ISO-8601 format.
  final String dateTime;

  /// Whether or not the post has been read. This is used to determine the color.
  final bool hasBeenRead;

  /// Whether or not the post has been edited. This determines the icon for the [dateTime] field.
  final bool hasBeenEdited;

  const DateTimePostCardMetaData({
    super.key,
    required this.dateTime,
    this.hasBeenRead = false,
    this.hasBeenEdited = false,
  });

  @override
  Widget build(BuildContext context) {
    final state = context.read<ThunderBloc>().state;

    final color = switch (hasBeenRead) {
      true => readColor,
      _ => null,
    };

    return IconText(
      fontScale: state.metadataFontSizeScale,
      text: formatTimeToString(dateTime: dateTime),
      textColor: color,
      padding: 2.0,
      icon: Icon(hasBeenEdited ? Icons.edit : Icons.history_rounded, size: 17.0, color: color),
    );
  }
}

/// Contains metadata related to the url/external link for a given post. This is used in the [PostCardMetadata] widget.
class UrlPostCardMetaData extends StatelessWidget {
  /// The URL to display in the metadata. If null, no URL will be displayed.
  final String? url;

  /// Whether or not the post has been read. This is used to determine the color.
  final bool hasBeenRead;

  const UrlPostCardMetaData({
    super.key,
    this.url,
    this.hasBeenRead = false,
  });

  @override
  Widget build(BuildContext context) {
    final state = context.read<ThunderBloc>().state;

    final color = switch (hasBeenRead) {
      true => readColor,
      _ => null,
    };

    if (url == null || url!.isEmpty == true) {
      return Container();
    }

    return Tooltip(
      message: url,
      preferBelow: false,
      child: IconText(
        fontScale: state.metadataFontSizeScale,
        text: Uri.parse(url ?? '').host.replaceFirst('www.', ''),
        textColor: color,
        padding: 3.0,
        icon: Icon(Icons.public, size: 17.0, color: color),
      ),
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
                child: CommunityAvatar(community: postView.community, radius: 14),
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
