import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import 'package:lemmy_api_client/v3.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:thunder/account/account.dart';
import 'package:thunder/core/enums/enums.dart';
import 'package:thunder/core/enums/view_mode.dart';
import 'package:thunder/core/models/models.dart';
import 'package:thunder/feed/feed.dart';
import 'package:thunder/post/enums/post_card_metadata_item.dart';
import 'package:thunder/shared/avatars/community_avatar.dart';
import 'package:thunder/shared/full_name_widgets.dart';
import 'package:thunder/shared/icon_text.dart';
import 'package:thunder/shared/text/scalable_text.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/utils/date_time.dart';
import 'package:thunder/utils/instance.dart';
import 'package:thunder/utils/navigation.dart';
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
  final bool? edited;

  /// Whether or not to dim the metadata widgets. This is passed down to the individual [PostCardMetadataItem] widgets to determine the color.
  final bool? dim;

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
    this.edited = false,
    this.dim = false,
    this.url,
    this.languageId,
  });

  @override
  Widget build(BuildContext context) {
    final showScores = context.select((ProfileBloc bloc) => bloc.state.getSiteResponse?.myUser?.localUserView.localUser.showScores) ?? true;

    final List<PostCardMetadataItem> postCardMetadataItems = postCardViewType == ViewMode.compact
        ? context.select((ThunderBloc bloc) => bloc.state.compactPostCardMetadataItems)
        : context.select((ThunderBloc bloc) => bloc.state.cardPostCardMetadataItems);

    return Wrap(
      spacing: 0,
      runSpacing: 4.0,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: postCardMetadataItems.map((PostCardMetadataItem postCardMetadataItem) {
        return switch (postCardMetadataItem) {
          PostCardMetadataItem.score => ScorePostCardMetaData(
              score: score,
              voteType: voteType,
              dim: dim ?? false,
              showScores: showScores,
            ),
          PostCardMetadataItem.upvote => UpvotePostCardMetaData(
              upvotes: upvoteCount,
              upvoted: voteType == 1,
              dim: dim ?? false,
              showScores: showScores,
            ),
          PostCardMetadataItem.downvote => DownvotePostCardMetaData(
              downvotes: downvoteCount,
              downvoted: voteType == -1,
              dim: dim ?? false,
              showScores: showScores,
            ),
          PostCardMetadataItem.commentCount => CommentCountPostCardMetaData(
              commentCount: commentCount,
              unreadCommentCount: unreadCommentCount ?? 0,
              dim: dim ?? false,
            ),
          PostCardMetadataItem.dateTime => DateTimePostCardMetaData(
              dateTime: dateTime!,
              dim: dim ?? false,
              edited: edited ?? false,
            ),
          PostCardMetadataItem.url => UrlPostCardMetaData(
              url: url,
              dim: dim ?? false,
            ),
          PostCardMetadataItem.language => LanguagePostCardMetaData(
              languageId: languageId,
              hasBeenRead: dim ?? false,
            ),
        };
      }).toList(),
    );
  }
}

/// Contains metadata related to the score of a given post. This is used in the [PostCardMetadata] widget.
class ScorePostCardMetaData extends StatelessWidget {
  /// The score of the post. Defaults to 0 if not specified.
  final int? score;

  /// The vote for the post. This should be either 0, 1 or -1. Defaults to 0 if not specified.
  final int? voteType;

  /// Whether or not to dim the color of the text and icons. This is usually used to indicate that the post has been read.
  final bool dim;

  /// Whether or not the scores should be displayed. Defaults to true.
  final bool showScores;

  const ScorePostCardMetaData({
    super.key,
    this.score = 0,
    this.voteType = 0,
    this.dim = false,
    this.showScores = true,
  });

  @override
  Widget build(BuildContext context) {
    // If scores should not be shown and voteType is 0, return an empty widget.
    if (!showScores && voteType == 0) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final metadataFontScale = context.select((ThunderBloc bloc) => bloc.state.metadataFontSizeScale);
    final upvoteColor = context.select((ThunderBloc bloc) => bloc.state.upvoteColor.color);
    final downvoteColor = context.select((ThunderBloc bloc) => bloc.state.downvoteColor.color);

    final dimColor = theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.45);

    // Compute the color based on the vote type.
    final color = switch (voteType) {
      1 => upvoteColor,
      -1 => downvoteColor,
      _ => dim ? dimColor : theme.textTheme.bodyMedium?.color,
    };

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
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
                Align(
                  alignment: Alignment.topLeft,
                  child: Icon(
                    Icons.arrow_upward,
                    size: 13.5,
                    color: voteType == -1 ? dimColor : color,
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Icon(
                    Icons.arrow_downward,
                    size: 13.5,
                    color: voteType == 1 ? dimColor : color,
                  ),
                ),
              ],
            ),
          ),
          if (showScores)
            ScalableText(
              formatNumberToK(score ?? 0),
              semanticsLabel: l10n.xScore(formatNumberToK(score ?? 0)),
              fontScale: metadataFontScale,
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
  final bool? upvoted;

  /// Whether or not to dim the color of the text and icons. This is usually used to indicate that the post has been read.
  final bool dim;

  /// Whether or not the scores should be displayed. Defaults to true.
  final bool showScores;

  const UpvotePostCardMetaData({
    super.key,
    this.upvotes = 0,
    this.upvoted = false,
    this.dim = false,
    this.showScores = true,
  });

  @override
  Widget build(BuildContext context) {
    // If scores should not be shown and the post is not upvoted, return an empty widget.
    if (!showScores && upvoted == false) return const SizedBox.shrink();

    final theme = Theme.of(context);

    final metadataFontScale = context.select((ThunderBloc bloc) => bloc.state.metadataFontSizeScale);
    final upvoteColor = context.select((ThunderBloc bloc) => bloc.state.upvoteColor.color);

    final dimColor = theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.45);

    // Compute the final color based on the upvote status and read status.
    final color = upvoted == true ? upvoteColor : (dim ? dimColor : theme.textTheme.bodyMedium?.color);

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: IconText(
        fontScale: metadataFontScale,
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
  final bool? downvoted;

  /// Whether or not to dim the color of the text and icons. This is usually used to indicate that the post has been read.
  final bool dim;

  /// Whether or not the scores should be displayed. Defaults to true.
  final bool showScores;

  const DownvotePostCardMetaData({
    super.key,
    this.downvotes = 0,
    this.downvoted = false,
    this.dim = false,
    this.showScores = true,
  });

  @override
  Widget build(BuildContext context) {
    // If scores should not be shown and the post is not downvoted, return an empty widget.
    if (!showScores && downvoted == false) return const SizedBox.shrink();

    final theme = Theme.of(context);

    final metadataFontScale = context.select((ThunderBloc bloc) => bloc.state.metadataFontSizeScale);
    final downvoteColor = context.select((ThunderBloc bloc) => bloc.state.downvoteColor.color);

    final dimColor = theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.45);

    // Determine the final color based on the downvote status and read status.
    final color = downvoted == true ? downvoteColor : (dim ? dimColor : theme.textTheme.bodyMedium?.color);

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: IconText(
        fontScale: metadataFontScale,
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

  /// Whether or not to dim the color of the text and icons. This is usually used to indicate that the post has been read.
  final bool dim;

  const CommentCountPostCardMetaData({
    super.key,
    this.commentCount = 0,
    this.unreadCommentCount = 0,
    this.dim = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final fontScale = context.select((ThunderBloc bloc) => bloc.state.metadataFontSizeScale);
    final dimColor = theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.45);

    final bool hasUnread = unreadCommentCount > 0 && unreadCommentCount != commentCount;

    final color = switch (dim) {
      true => hasUnread ? theme.primaryColor : dimColor,
      _ => hasUnread ? theme.primaryColor : theme.textTheme.bodyMedium?.color,
    };

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: IconText(
        fontScale: fontScale,
        text: hasUnread ? '+${formatNumberToK(unreadCommentCount)}' : formatNumberToK(commentCount ?? 0),
        textColor: color,
        padding: 4.0,
        icon: Icon(
          hasUnread ? Icons.mark_unread_chat_alt_rounded : Icons.chat,
          size: 17.0,
          color: color,
        ),
      ),
    );
  }
}

/// Contains metadata related to the number of comments for a given post. This is used in the [PostCardMetadata] widget.
class DateTimePostCardMetaData extends StatelessWidget {
  /// The date/time the post was created or updated. This string should conform to ISO-8601 format.
  final String dateTime;

  /// Whether or not to dim the color of the text and icons. This is usually used to indicate that the post has been read.
  final bool dim;

  /// Whether or not the post has been edited. This determines the icon for the [dateTime] field.
  final bool edited;

  const DateTimePostCardMetaData({super.key, required this.dateTime, this.dim = false, this.edited = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final fontScale = context.select((ThunderBloc bloc) => bloc.state.metadataFontSizeScale);
    final showFullPostDate = context.select((ThunderBloc bloc) => bloc.state.showFullPostDate);
    final dateFormat = context.select((ThunderBloc bloc) => bloc.state.dateFormat);

    final baseColor = theme.textTheme.bodyMedium?.color;
    final dimColor = baseColor?.withValues(alpha: 0.45);
    final fullDateColor = baseColor?.withValues(alpha: 0.75);
    final color = dim ? dimColor : (showFullPostDate ? fullDateColor : baseColor);

    final parsedDateTime = DateTime.parse(dateTime);
    final formattedDate = showFullPostDate && dateFormat != null ? dateFormat.format(parsedDateTime.toLocal()) : formatTimeToString(dateTime: dateTime);

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: IconText(
        fontScale: fontScale,
        text: formattedDate,
        textColor: color,
        padding: 2.0,
        icon: Icon(
          edited ? Icons.edit : Icons.history_rounded,
          size: 17.0,
          color: color,
        ),
      ),
    );
  }
}

/// Contains metadata related to the url/external link for a given post. This is used in the [PostCardMetadata] widget.
class UrlPostCardMetaData extends StatelessWidget {
  /// The URL to display in the metadata. If null, no URL will be displayed.
  final String? url;

  /// Whether or not to dim the color of the text and icons. This is usually used to indicate that the post has been read.
  final bool dim;

  const UrlPostCardMetaData({super.key, this.url, this.dim = false});

  @override
  Widget build(BuildContext context) {
    if (url?.isEmpty ?? true) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final fontScale = context.select((ThunderBloc bloc) => bloc.state.metadataFontSizeScale);

    final textStyle = theme.textTheme.bodyMedium;
    final dimColor = textStyle?.color?.withValues(alpha: 0.45);
    final textColor = dim ? dimColor : textStyle?.color;

    final host = Uri.parse(url!).host.replaceFirst('www.', '');

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Tooltip(
        message: url!,
        preferBelow: false,
        child: IconText(
          fontScale: fontScale,
          text: host,
          textColor: textColor,
          padding: 3.0,
          icon: Icon(Icons.public, size: 17.0, color: textColor),
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
    final Color? readColor = theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.45);

    final color = switch (hasBeenRead) {
      true => readColor,
      _ => theme.textTheme.bodyMedium?.color,
    };

    List<Language> languages = context.read<ProfileBloc>().state.getSiteResponse?.allLanguages ?? [];
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
  /// The post to display metadata for
  final ThunderPost post;

  const CrossPostMetaData({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 6.0,
      mainAxisSize: MainAxisSize.min,
      children: [
        ScorePostCardMetaData(score: post.score, voteType: post.voteType, dim: true),
        CommentCountPostCardMetaData(commentCount: post.comments, unreadCommentCount: post.unreadComments ?? 0, dim: true),
        DateTimePostCardMetaData(dateTime: post.created.toIso8601String(), edited: post.updated != null, dim: true),
      ],
    );
  }
}

class PostCommunityAndAuthor extends StatelessWidget {
  const PostCommunityAndAuthor({super.key, required this.user, required this.community, this.dim});

  /// The user to display in the metadata
  final ThunderUser user;

  /// The community to display in the metadata
  final ThunderCommunity community;

  /// Whether or not to dim the color of the text and icons. This is usually used to indicate that the post has been read.
  final bool? dim;

  @override
  Widget build(BuildContext context) {
    final state = context.select((ThunderBloc bloc) => (bloc.state.showPostAuthor, bloc.state.showCommunityIcons));
    final showPostAuthor = state.$1;
    final showCommunityIcons = state.$2;

    final feedType = context.select((FeedBloc bloc) => bloc.state.feedType);
    final showUsername = (showPostAuthor || feedType == FeedType.community) && feedType != FeedType.user;
    final showCommunityName = feedType != FeedType.community;

    final dim = this.dim ?? false;

    return Row(
      spacing: 6.0,
      children: [
        if (showCommunityIcons && feedType != FeedType.community)
          GestureDetector(
            child: CommunityAvatar(community: community, radius: showUsername && showCommunityName ? 14 : 7, thumbnailSize: 50, format: 'png'),
            onTap: () => navigateToFeedPage(context, communityId: community.id, feedType: FeedType.community),
          ),
        if (showCommunityName && showUsername)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CommunityPostCardMetadata(
                communityName: community.communityName,
                displayName: community.title,
                actorId: community.url,
                subscribed: community.subscribed != SubscribedType.notSubscribed,
                dim: dim,
              ),
              UserPostCardMetadata(
                username: user.username,
                displayName: user.displayName,
                actorId: user.url,
                dim: dim,
              ),
            ],
          )
        else if (showCommunityName)
          CommunityPostCardMetadata(
            communityName: community.communityName,
            displayName: community.title,
            actorId: community.url,
            subscribed: community.subscribed != SubscribedType.notSubscribed,
            dim: dim,
          )
        else if (showUsername)
          UserPostCardMetadata(
            username: user.username,
            displayName: user.displayName,
            actorId: user.url,
            dim: dim,
          ),
      ],
    );
  }
}

class CommunityPostCardMetadata extends StatelessWidget {
  const CommunityPostCardMetadata({
    super.key,
    this.communityName,
    this.displayName,
    this.actorId,
    required this.dim,
    required this.subscribed,
  });

  /// The name of the community
  final String? communityName;

  /// The display name of the community
  final String? displayName;

  /// The actor ID of the community (e.g., community URL)
  final String? actorId;

  /// Whether or not to dim the color of the text and icons. This is usually used to indicate that the post has been read.
  final bool dim;

  /// Whether the user is subscribed to the community
  final bool subscribed;

  Color? _transformColor(Color? color) => dim ? color?.withValues(alpha: 0.45) : color?.withValues(alpha: 0.75);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final thunderState = context.select((ThunderBloc bloc) => bloc.state.metadataFontSizeScale);
    final feedListType = context.select((FeedBloc bloc) => bloc.state.feedListType);
    final instanceName = actorId != null ? fetchInstanceNameFromUrl(actorId) : null;

    final showCommunitySubscription = (feedListType == FeedListType.all || feedListType == FeedListType.local) && subscribed == true;

    Widget child = CommunityFullNameWidget(
      context,
      communityName,
      displayName,
      instanceName,
      fontScale: thunderState,
      transformColor: _transformColor,
    );

    if (!showCommunitySubscription) return child;

    return Row(
      spacing: 4.0,
      children: [
        child,
        Icon(Icons.playlist_add_check_rounded, size: 16.0, color: _transformColor(theme.textTheme.bodyMedium?.color)),
      ],
    );
  }
}

class UserPostCardMetadata extends StatelessWidget {
  const UserPostCardMetadata({
    super.key,
    this.username,
    this.displayName,
    this.actorId,
    required this.dim,
  });

  /// The username of the user
  final String? username;

  /// The display name of the user
  final String? displayName;

  /// The actor ID of the user (e.g., user URL)
  final String? actorId;

  /// Whether or not to dim the color of the text and icons. This is usually used to indicate that the post has been read.
  final bool dim;

  Color? _transformColor(Color? color) => dim ? color?.withValues(alpha: 0.45) : color?.withValues(alpha: 0.75);

  @override
  Widget build(BuildContext context) {
    final state = context.select((ThunderBloc bloc) => (bloc.state.postShowUserInstance, bloc.state.metadataFontSizeScale));

    final postShowUserInstance = state.$1;
    final metadataFontSizeScale = state.$2;
    final instanceName = actorId != null ? fetchInstanceNameFromUrl(actorId) : null;

    return UserFullNameWidget(
      context,
      username,
      displayName,
      instanceName,
      includeInstance: postShowUserInstance,
      fontScale: metadataFontSizeScale,
      transformColor: _transformColor,
    );
  }
}
