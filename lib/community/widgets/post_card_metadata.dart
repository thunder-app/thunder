import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import 'package:lemmy_api_client/v3.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/core/enums/view_mode.dart';
import 'package:thunder/feed/feed.dart';
import 'package:thunder/post/enums/post_card_metadata_item.dart';
import 'package:thunder/shared/avatars/community_avatar.dart';
import 'package:thunder/shared/full_name_widgets.dart';
import 'package:thunder/shared/icon_text.dart';
import 'package:thunder/shared/text/scalable_text.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/utils/date_time.dart';
import 'package:thunder/utils/instance.dart';
import 'package:thunder/utils/numbers.dart';

/// Contains metadata related to a given post. This is generally displayed as part of the post card.
///
/// This information is customizable, and can be changed by the user in the settings.
/// The order in which the items are displayed depends on the order in the [postCardMetadataItems] list
class PostCardMetadata extends StatelessWidget {
  /// The type of view the post card is in. This is used to determine the appropriate setting to read from.
  final ViewMode postCardViewType;

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

  /// The number of unread comments on the post. If null, no unread comment count will be displayed.
  final int? unreadCommentCount;

  /// The date/time the post was created or updated. This string should conform to ISO-8601 format.
  final String? dateTime;

  /// Whether or not the post has been edited. This determines the icon for the [dateTime] field.
  final bool? hasBeenEdited;

  /// Whether or not the post has been read. This is passed down to the individual [PostCardMetadataItem] widgets to determine the color.
  final bool? hasBeenRead;

  /// The URL to display in the metadata. If null, no URL will be displayed.
  final String? url;

  /// The language to display in the metadata. If null, no language will be displayed.
  final int? languageId;

  const PostCardMetadata({
    super.key,
    required this.postCardViewType,
    this.score,
    this.upvoteCount,
    this.downvoteCount,
    this.voteType = 0,
    this.commentCount,
    this.unreadCommentCount,
    this.dateTime,
    this.hasBeenEdited = false,
    this.hasBeenRead = false,
    this.url,
    this.languageId,
  });

  @override
  Widget build(BuildContext context) {
    final showScores = context.watch<AuthBloc>().state.getSiteResponse?.myUser?.localUserView.localUser.showScores ?? true;

    List<PostCardMetadataItem> postCardMetadataItems = switch (postCardViewType) {
      ViewMode.compact => context.read<ThunderBloc>().state.compactPostCardMetadataItems,
      ViewMode.comfortable => context.read<ThunderBloc>().state.cardPostCardMetadataItems,
    };

    return Wrap(
      spacing: 0,
      runSpacing: 4.0,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: postCardMetadataItems.map(
        (PostCardMetadataItem postCardMetadataItem) {
          return switch (postCardMetadataItem) {
            PostCardMetadataItem.score => ScorePostCardMetaData(score: score, voteType: voteType, hasBeenRead: hasBeenRead ?? false, showScores: showScores),
            PostCardMetadataItem.upvote => UpvotePostCardMetaData(upvotes: upvoteCount, isUpvoted: voteType == 1, hasBeenRead: hasBeenRead ?? false, showScores: showScores),
            PostCardMetadataItem.downvote => DownvotePostCardMetaData(downvotes: downvoteCount, isDownvoted: voteType == -1, hasBeenRead: hasBeenRead ?? false, showScores: showScores),
            PostCardMetadataItem.commentCount => CommentCountPostCardMetaData(commentCount: commentCount, unreadCommentCount: unreadCommentCount ?? 0, hasBeenRead: hasBeenRead ?? false),
            PostCardMetadataItem.dateTime => DateTimePostCardMetaData(dateTime: dateTime!, hasBeenRead: hasBeenRead ?? false, hasBeenEdited: hasBeenEdited ?? false),
            PostCardMetadataItem.url => UrlPostCardMetaData(url: url, hasBeenRead: hasBeenRead ?? false),
            PostCardMetadataItem.language => LanguagePostCardMetaData(languageId: languageId, hasBeenRead: hasBeenRead ?? false),
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

  /// Whether or not the scores should be displayed. Defaults to true.
  final bool showScores;

  const ScorePostCardMetaData({
    super.key,
    this.score = 0,
    this.voteType = 0,
    this.hasBeenRead = false,
    this.showScores = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final state = context.read<ThunderBloc>().state;

    final readColor = theme.textTheme.bodyMedium?.color?.withOpacity(0.45);

    final color = switch (voteType) {
      1 => context.read<ThunderBloc>().state.upvoteColor.color,
      -1 => context.read<ThunderBloc>().state.downvoteColor.color,
      _ => hasBeenRead ? readColor : theme.textTheme.bodyMedium?.color,
    };

    if (!showScores && voteType == 0) {
      return const SizedBox();
    }

    return Container(
      margin: const EdgeInsets.only(right: 8.0),
      child: Wrap(
        spacing: 2.0,
        crossAxisAlignment: WrapCrossAlignment.center,
        runAlignment: WrapAlignment.center,
        children: [
          SizedBox(
            width: 21,
            height: 17,
            child: Stack(
              children: [
                Align(alignment: Alignment.topLeft, child: Icon(Icons.arrow_upward, size: 13.5, color: voteType == -1 ? readColor : color)),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Icon(Icons.arrow_downward, size: 13.5, color: voteType == 1 ? readColor : color),
                ),
              ],
            ),
          ),
          if (showScores)
            ScalableText(
              formatNumberToK(score ?? 0),
              semanticsLabel: l10n.xScore(formatNumberToK(score ?? 0)),
              fontScale: state.metadataFontSizeScale,
              style: theme.textTheme.bodyMedium?.copyWith(color: color),
            ),
        ],
      ),
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

  /// Whether or not the scores should be displayed. Defaults to true.
  final bool showScores;

  const UpvotePostCardMetaData({
    super.key,
    this.upvotes = 0,
    this.isUpvoted = false,
    this.hasBeenRead = false,
    this.showScores = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = context.read<ThunderBloc>().state;
    final readColor = theme.textTheme.bodyMedium?.color?.withOpacity(0.45);

    final color = switch (isUpvoted) {
      true => context.read<ThunderBloc>().state.upvoteColor.color,
      _ => hasBeenRead ? readColor : theme.textTheme.bodyMedium?.color,
    };

    if (!showScores && isUpvoted == false) {
      return const SizedBox();
    }

    return Container(
      margin: const EdgeInsets.only(right: 8.0),
      child: IconText(
        fontScale: state.metadataFontSizeScale,
        text: showScores ? formatNumberToK(upvotes ?? 0) : null,
        textColor: color,
        padding: 2.0,
        icon: Icon(Icons.arrow_upward, size: 17.0, color: color),
      ),
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

  /// Whether or not the scores should be displayed. Defaults to true.
  final bool showScores;

  const DownvotePostCardMetaData({
    super.key,
    this.downvotes = 0,
    this.isDownvoted = false,
    this.hasBeenRead = false,
    this.showScores = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = context.read<ThunderBloc>().state;
    final readColor = theme.textTheme.bodyMedium?.color?.withOpacity(0.45);

    final color = switch (isDownvoted) {
      true => context.read<ThunderBloc>().state.downvoteColor.color,
      _ => hasBeenRead ? readColor : theme.textTheme.bodyMedium?.color,
    };

    if (!showScores && isDownvoted == false) {
      return const SizedBox();
    }

    return Container(
      margin: const EdgeInsets.only(right: 8.0),
      child: IconText(
        fontScale: state.metadataFontSizeScale,
        text: showScores ? formatNumberToK(downvotes ?? 0) : null,
        textColor: color,
        padding: 2.0,
        icon: Icon(Icons.arrow_downward, size: 17.0, color: color),
      ),
    );
  }
}

/// Contains metadata related to the number of comments for a given post. This is used in the [PostCardMetadata] widget.
class CommentCountPostCardMetaData extends StatelessWidget {
  /// The number of comments on the post. Defaults to 0 if not specified.
  final int? commentCount;

  /// The number of unread comments on the post. Defaults to 0 if not specified.
  final int unreadCommentCount;

  /// Whether or not the post has been read. This is used to determine the color.
  final bool hasBeenRead;

  const CommentCountPostCardMetaData({
    super.key,
    this.commentCount = 0,
    this.unreadCommentCount = 0,
    this.hasBeenRead = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = context.read<ThunderBloc>().state;
    final readColor = theme.textTheme.bodyMedium?.color?.withOpacity(0.45);

    final color = switch (hasBeenRead) {
      true => (unreadCommentCount > 0 && unreadCommentCount != commentCount) ? theme.primaryColor : readColor,
      _ => (unreadCommentCount > 0 && unreadCommentCount != commentCount) ? theme.primaryColor : theme.textTheme.bodyMedium?.color,
    };

    return Container(
      margin: const EdgeInsets.only(right: 8.0),
      child: IconText(
        fontScale: state.metadataFontSizeScale,
        text: (unreadCommentCount > 0 && unreadCommentCount != commentCount) ? '+${formatNumberToK(unreadCommentCount)}' : formatNumberToK(commentCount ?? 0),
        textColor: color,
        padding: 4.0,
        icon: Icon(unreadCommentCount > 0 && unreadCommentCount != commentCount ? Icons.mark_unread_chat_alt_rounded : Icons.chat, size: 17.0, color: color),
      ),
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
    final theme = Theme.of(context);
    final state = context.read<ThunderBloc>().state;
    final readColor = theme.textTheme.bodyMedium?.color?.withOpacity(0.45);

    final color = switch (hasBeenRead) {
      true => readColor,
      _ => state.showFullPostDate ? theme.textTheme.bodyMedium?.color?.withOpacity(0.75) : theme.textTheme.bodyMedium?.color,
    };

    return Container(
      margin: const EdgeInsets.only(right: 8.0),
      child: IconText(
        fontScale: state.metadataFontSizeScale,
        text: state.showFullPostDate ? state.dateFormat?.format(DateTime.parse(dateTime)) : formatTimeToString(dateTime: dateTime),
        textColor: color,
        padding: 2.0,
        icon: Icon(hasBeenEdited ? Icons.edit : Icons.history_rounded, size: 17.0, color: color),
      ),
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
    final theme = Theme.of(context);
    final state = context.read<ThunderBloc>().state;
    final readColor = theme.textTheme.bodyMedium?.color?.withOpacity(0.45);

    final color = switch (hasBeenRead) {
      true => readColor,
      _ => theme.textTheme.bodyMedium?.color,
    };

    if (url == null || url!.isEmpty == true) {
      return Container();
    }

    return Container(
      margin: const EdgeInsets.only(right: 8.0),
      child: Tooltip(
        message: url,
        preferBelow: false,
        child: IconText(
          fontScale: state.metadataFontSizeScale,
          text: Uri.parse(url ?? '').host.replaceFirst('www.', ''),
          textColor: color,
          padding: 3.0,
          icon: Icon(Icons.public, size: 17.0, color: color),
        ),
      ),
    );
  }
}

/// Contains metadata related to the language of a given post. This is used in the [PostCardMetadata] widget.
class LanguagePostCardMetaData extends StatelessWidget {
  /// The language to display in the metadata. If null, no language will be displayed.
  /// Pass `-1` to indicate that this widget is for demonstration purposes, and `English` will be displayed.
  final int? languageId;

  /// Whether or not the post has been read. This is used to determine the color.
  final bool hasBeenRead;

  const LanguagePostCardMetaData({
    super.key,
    this.languageId,
    this.hasBeenRead = false,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ThunderState state = context.read<ThunderBloc>().state;
    final Color? readColor = theme.textTheme.bodyMedium?.color?.withOpacity(0.45);

    final color = switch (hasBeenRead) {
      true => readColor,
      _ => theme.textTheme.bodyMedium?.color,
    };

    List<Language> languages = context.read<AuthBloc>().state.getSiteResponse?.allLanguages ?? [];
    Language? language = languages.firstWhereOrNull((Language language) => language.id == languageId);

    if ((language?.name.isNotEmpty != true || language?.id == 0) && languageId != -1) {
      return Container();
    }

    return Container(
      margin: const EdgeInsets.only(right: 8.0),
      child: Tooltip(
        message: languageId == -1 ? 'English' : language!.name,
        preferBelow: false,
        child: IconText(
          fontScale: state.metadataFontSizeScale,
          text: languageId == -1 ? 'English' : language!.name,
          textColor: color,
          padding: 3.0,
          icon: Icon(Icons.map_rounded, size: 17.0, color: color),
        ),
      ),
    );
  }
}

/// Display metadata for a cross-post, used in the expanded cross-posts view
class CrossPostMetaData extends StatelessWidget {
  /// Accepts the PostView of a cross-post
  final PostView crossPost;

  const CrossPostMetaData({
    super.key,
    required this.crossPost,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThunderBloc, ThunderState>(
      builder: (context, state) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ScorePostCardMetaData(
              score: crossPost.counts.score,
              voteType: crossPost.myVote,
              hasBeenRead: true,
            ),
            const SizedBox(width: 10.0),
            CommentCountPostCardMetaData(
              commentCount: crossPost.counts.comments,
              unreadCommentCount: crossPost.unreadComments,
              hasBeenRead: true,
            ),
            const SizedBox(width: 10.0),
            DateTimePostCardMetaData(
              dateTime: crossPost.post.published.toIso8601String(),
              hasBeenEdited: crossPost.post.updated != null ? true : false,
              hasBeenRead: true,
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
    required this.feedType,
    this.authorColorTransformation,
    this.communityColorTransformation,
    required this.compactMode,
    required this.showCommunitySubscription,
  });

  final bool showCommunityIcons;
  final FeedType? feedType;
  final bool compactMode;
  final PostView postView;
  final Color? Function(Color?)? authorColorTransformation;
  final Color? Function(Color?)? communityColorTransformation;
  final bool showCommunitySubscription;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<ThunderBloc, ThunderState>(builder: (context, state) {
      final bool showUsername = (state.showPostAuthor || feedType == FeedType.community) && feedType != FeedType.user;
      final bool showCommunityName = feedType != FeedType.community;

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
                  if (showUsername)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          borderRadius: BorderRadius.circular(6),
                          onTap: (compactMode && !state.tappableAuthorCommunity) ? null : () => navigateToFeedPage(context, feedType: FeedType.user, userId: postView.creator.id),
                          child: UserFullNameWidget(
                            context,
                            postView.creator.name,
                            postView.creator.displayName,
                            fetchInstanceNameFromUrl(postView.creator.actorId),
                            includeInstance: state.postShowUserInstance,
                            fontScale: state.metadataFontSizeScale,
                            transformColor: authorColorTransformation,
                          ),
                        ),
                        if (showUsername && showCommunityName)
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
                        if (showCommunityName)
                          CommunityFullNameWidget(
                            context,
                            postView.community.name,
                            postView.community.title,
                            fetchInstanceNameFromUrl(postView.community.actorId),
                            fontScale: state.metadataFontSizeScale,
                            transformColor: communityColorTransformation,
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
                              color: communityColorTransformation?.call(theme.textTheme.bodyMedium?.color),
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
