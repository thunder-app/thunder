import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thunder/src/foundation/primitives/primitives.dart';
import 'package:thunder/l10n/generated/app_localizations.dart';

import 'package:thunder/src/features/account/data/cache/profile_site_info_cache.dart';
import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/features/feed/feed.dart';
import 'package:thunder/src/features/session/api.dart';
import 'package:thunder/src/shared/avatars/community_avatar.dart';
import 'package:thunder/src/shared/name/full_name_widgets.dart';
import 'package:thunder/packages/ui/ui.dart' show ScalableText, ThunderIconLabel;
import 'package:thunder/src/features/feed/api.dart';
import 'package:thunder/src/features/settings/api.dart';
import 'package:thunder/src/foundation/utils/utils.dart';
import 'package:thunder/src/features/instance/domain/utils/instance_link_utils.dart';
import 'package:thunder/src/app/shell/navigation/navigation_utils.dart';

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
    final postCardMetadataItems = context
        .select<FeedPreferencesCubit, List<PostCardMetadataItem>>((cubit) => postCardViewType == ViewMode.compact ? cubit.state.compactPostCardMetadataItems : cubit.state.cardPostCardMetadataItems);
    bool showScores = true;

    try {
      showScores = context.select((ProfileBloc bloc) => bloc.state.siteResponse?.myUser?.localUserView.localUser.showScores) ?? true;
    } catch (_) {
      showScores = true;
    }

    final dim = this.dim ?? false;
    final voteType = this.voteType ?? 0;
    final edited = this.edited ?? false;
    final unreadCommentCount = this.unreadCommentCount ?? 0;

    return Wrap(
      spacing: 0,
      runSpacing: 4.0,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: postCardMetadataItems.map((PostCardMetadataItem postCardMetadataItem) {
        return switch (postCardMetadataItem) {
          PostCardMetadataItem.score => ScorePostCardMetaData(
              score: score,
              voteType: voteType,
              dim: dim,
              showScores: showScores,
            ),
          PostCardMetadataItem.upvote => UpvotePostCardMetaData(
              upvotes: upvoteCount,
              upvoted: voteType == 1,
              dim: dim,
              showScores: showScores,
            ),
          PostCardMetadataItem.downvote => DownvotePostCardMetaData(
              downvotes: downvoteCount,
              downvoted: voteType == -1,
              dim: dim,
              showScores: showScores,
            ),
          PostCardMetadataItem.commentCount => CommentCountPostCardMetaData(
              commentCount: commentCount,
              unreadCommentCount: unreadCommentCount,
              dim: dim,
            ),
          PostCardMetadataItem.dateTime => DateTimePostCardMetaData(
              dateTime: dateTime!,
              dim: dim,
              edited: edited,
            ),
          PostCardMetadataItem.url => UrlPostCardMetaData(
              url: url,
              dim: dim,
            ),
          PostCardMetadataItem.language => LanguagePostCardMetaData(
              languageId: languageId,
              hasBeenRead: dim,
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

    final metadataFontScale = context.select<ThemePreferencesCubit, FontScale>((cubit) => cubit.state.metadataFontSizeScale);
    final upvoteColor = context.select<ThemePreferencesCubit, Color>((cubit) => cubit.state.upvoteColor.color);
    final downvoteColor = context.select<ThemePreferencesCubit, Color>((cubit) => cubit.state.downvoteColor.color);

    final baseTextColor = theme.textTheme.bodyMedium?.color;
    final dimColor = baseTextColor?.withValues(alpha: 0.45);

    final primaryColor = switch (voteType) {
      1 => upvoteColor,
      -1 => downvoteColor,
      _ => dim ? dimColor : baseTextColor,
    };

    final upvoteIconColor = voteType == -1 ? dimColor : primaryColor;
    final downvoteIconColor = voteType == 1 ? dimColor : primaryColor;

    final formattedScore = showScores ? formatNumberToK(score ?? 0) : '';

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
                  child: Icon(Icons.arrow_upward, size: 13.5, color: upvoteIconColor),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Icon(Icons.arrow_downward, size: 13.5, color: downvoteIconColor),
                ),
              ],
            ),
          ),
          if (showScores)
            ScalableText(
              formattedScore,
              semanticsLabel: l10n.xScore(formattedScore),
              textScaleFactor: metadataFontScale.textScaleFactor,
              style: theme.textTheme.bodyMedium?.copyWith(color: primaryColor),
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

    final metadataFontScale = context.select<ThemePreferencesCubit, FontScale>((cubit) => cubit.state.metadataFontSizeScale);
    final upvoteColor = context.select<ThemePreferencesCubit, Color>((cubit) => cubit.state.upvoteColor.color);

    final baseTextColor = theme.textTheme.bodyMedium?.color;
    final dimColor = baseTextColor?.withValues(alpha: 0.45);

    final color = upvoted == true ? upvoteColor : (dim ? dimColor : baseTextColor);

    final formattedUpvotes = showScores ? formatNumberToK(upvotes ?? 0) : null;

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ThunderIconLabel(
        icon: Icon(Icons.arrow_upward, size: 17.0, color: color),
        label: formattedUpvotes,
        labelStyle: TextStyle(color: color),
        textScaleFactor: metadataFontScale.textScaleFactor,
        gap: 2.0,
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

    final metadataFontScale = context.select<ThemePreferencesCubit, FontScale>((cubit) => cubit.state.metadataFontSizeScale);
    final downvoteColor = context.select<ThemePreferencesCubit, Color>((cubit) => cubit.state.downvoteColor.color);

    final baseTextColor = theme.textTheme.bodyMedium?.color;
    final dimColor = baseTextColor?.withValues(alpha: 0.45);

    final color = downvoted == true ? downvoteColor : (dim ? dimColor : baseTextColor);

    final formattedDownvotes = showScores ? formatNumberToK(downvotes ?? 0) : null;

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ThunderIconLabel(
        icon: Icon(Icons.arrow_downward, size: 17.0, color: color),
        label: formattedDownvotes,
        labelStyle: TextStyle(color: color),
        textScaleFactor: metadataFontScale.textScaleFactor,
        gap: 2.0,
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

    final fontScale = context.select<ThemePreferencesCubit, FontScale>((cubit) => cubit.state.metadataFontSizeScale);

    final baseTextColor = theme.textTheme.bodyMedium?.color;
    final primaryColor = theme.primaryColor;
    final dimColor = baseTextColor?.withValues(alpha: 0.45);

    final hasUnread = unreadCommentCount > 0 && unreadCommentCount != commentCount;

    final color = hasUnread ? primaryColor : (dim ? dimColor : baseTextColor);
    final commentCountText = hasUnread ? '+${formatNumberToK(unreadCommentCount)}' : formatNumberToK(commentCount ?? 0);
    final icon = hasUnread ? Icons.mark_unread_chat_alt_rounded : Icons.chat;

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ThunderIconLabel(
        icon: Icon(icon, size: 17.0, color: color),
        label: commentCountText,
        labelStyle: TextStyle(color: color),
        textScaleFactor: fontScale.textScaleFactor,
        gap: 4.0,
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

    final showFullPostDate = context.select<FeedPreferencesCubit, bool>((cubit) => cubit.state.showFullPostDate);
    final dateFormat = context.select<FeedPreferencesCubit, DateFormat?>((cubit) => cubit.state.dateFormat);
    final fontScale = context.select<ThemePreferencesCubit, FontScale>((cubit) => cubit.state.metadataFontSizeScale);

    String formattedDate;

    try {
      formattedDate = showFullPostDate && dateFormat != null ? dateFormat.format(DateTime.parse(dateTime).toLocal()) : formatTimeToString(dateTime: dateTime);
    } catch (e) {
      formattedDate = dateTime; // Fallback for malformed dates
    }

    final baseColor = theme.textTheme.bodyMedium?.color;
    final dimColor = baseColor?.withValues(alpha: 0.45);
    final fullDateColor = baseColor?.withValues(alpha: 0.75);
    final color = dim ? dimColor : (showFullPostDate ? fullDateColor : baseColor);
    final icon = edited ? Icons.edit : Icons.history_rounded;

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ThunderIconLabel(
        icon: Icon(icon, size: 17.0, color: color),
        label: formattedDate,
        labelStyle: TextStyle(color: color),
        textScaleFactor: fontScale.textScaleFactor,
        gap: 2.0,
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
    final fontScale = context.select<ThemePreferencesCubit, FontScale>((cubit) => cubit.state.metadataFontSizeScale);

    String? host;

    if (url?.isNotEmpty == true) {
      try {
        host = Uri.parse(url!).host.replaceFirst('www.', '');
      } catch (e) {
        host = url; // Fallback for malformed URLs
      }
    }

    final textStyle = theme.textTheme.bodyMedium;
    final dimColor = textStyle?.color?.withValues(alpha: 0.45);
    final textColor = dim ? dimColor : textStyle?.color;

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Tooltip(
        message: url!,
        preferBelow: false,
        child: ThunderIconLabel(
          icon: Icon(Icons.public, size: 17.0, color: textColor),
          label: host ?? url!,
          labelStyle: TextStyle(color: textColor),
          textScaleFactor: fontScale.textScaleFactor,
          gap: 3.0,
        ),
      ),
    );
  }
}

/// Contains metadata related to the language of a given post. This is used in the [PostCardMetadata] widget.
class LanguagePostCardMetaData extends StatefulWidget {
  /// The language to display in the metadata. If null, no language will be displayed.
  /// Pass `-1` to indicate that this widget is for demonstration purposes, and `English` will be displayed.
  final int? languageId;

  /// Whether or not the post has been read. This is used to determine the color.
  final bool hasBeenRead;

  /// Optional explicit account used to resolve languages in overlays.
  final Account? account;

  const LanguagePostCardMetaData({
    super.key,
    this.languageId,
    this.hasBeenRead = false,
    this.account,
  });

  @override
  State<LanguagePostCardMetaData> createState() => _LanguagePostCardMetaDataState();
}

class _LanguagePostCardMetaDataState extends State<LanguagePostCardMetaData> {
  List<ThunderLanguage> _languages = const <ThunderLanguage>[];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadLanguagesIfNeeded();
  }

  Future<void> _loadLanguagesIfNeeded() async {
    if (widget.languageId == null || widget.languageId == -1) return;

    if (widget.account == null) {
      try {
        final languages = context.read<ProfileBloc>().state.siteResponse?.allLanguages ?? const <ThunderLanguage>[];
        if (!mounted || languages.isEmpty && _languages.isEmpty) return;

        if (_languages != languages) {
          setState(() => _languages = languages);
        }
        return;
      } catch (_) {
        // Fall back to account-scoped site info when no ProfileBloc is available.
      }
    }

    final account = widget.account ?? resolveEffectiveAccount(context);
    if (account.anonymous) return;

    final siteInfo = await ProfileSiteInfoCache.instance.get(account);
    if (!mounted) return;

    setState(() => _languages = siteInfo.allLanguages ?? const <ThunderLanguage>[]);
  }

  @override
  Widget build(BuildContext context) {
    String? languageName;

    if (widget.languageId == -1) {
      languageName = 'English';
    } else if (widget.languageId != null) {
      List<ThunderLanguage> languages = _languages;

      if (widget.account == null) {
        try {
          languages = context.select((ProfileBloc bloc) => bloc.state.siteResponse?.allLanguages ?? <ThunderLanguage>[]);
        } catch (_) {
          languages = _languages;
        }
      }

      final language = languages.firstWhereOrNull((language) => language.id == widget.languageId);
      languageName = language?.name;
    }

    if (languageName == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final fontScale = context.select<ThemePreferencesCubit, FontScale>((cubit) => cubit.state.metadataFontSizeScale);

    final readColor = theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.45);
    final color = widget.hasBeenRead ? readColor : theme.textTheme.bodyMedium?.color;

    return Container(
      margin: const EdgeInsets.only(right: 8.0),
      child: Tooltip(
        message: languageName,
        preferBelow: false,
        child: ThunderIconLabel(
          icon: Icon(Icons.map_rounded, size: 17.0, color: color),
          label: languageName,
          labelStyle: TextStyle(color: color),
          textScaleFactor: fontScale.textScaleFactor,
          gap: 3.0,
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
        ScorePostCardMetaData(score: post.score, voteType: post.myVote, dim: true),
        CommentCountPostCardMetaData(commentCount: post.comments, unreadCommentCount: post.unreadComments ?? 0, dim: true),
        DateTimePostCardMetaData(dateTime: post.published.toIso8601String(), edited: post.updated != null, dim: true),
      ],
    );
  }
}

class PostCommunityAndAuthor extends StatelessWidget {
  const PostCommunityAndAuthor({super.key, required this.user, required this.community, this.dim, this.feedType, this.feedListType});

  /// The user to display in the metadata
  final ThunderUser user;

  /// The community to display in the metadata
  final ThunderCommunity community;

  /// Whether or not to dim the color of the text and icons. This is usually used to indicate that the post has been read.
  final bool? dim;

  /// Optional feed type override for contexts without a FeedBloc.
  final FeedType? feedType;

  /// Optional feed list type override for contexts without a FeedBloc.
  final FeedListType? feedListType;

  @override
  Widget build(BuildContext context) {
    final showPostAuthor = context.select<FeedPreferencesCubit, bool>((cubit) => cubit.state.showPostAuthor);
    final showCommunityIcons = context.select<FeedPreferencesCubit, bool>((cubit) => cubit.state.showCommunityIcons);

    final hasFeedBloc = context.findAncestorWidgetOfExactType<BlocProvider<FeedBloc>>() != null;
    final resolvedFeedType = feedType ?? (hasFeedBloc ? context.select<FeedBloc, FeedType?>((bloc) => bloc.state.feedType) : null);
    final showUsername = (showPostAuthor || resolvedFeedType == FeedType.community) && resolvedFeedType != FeedType.user;
    final showCommunityName = resolvedFeedType != FeedType.community;

    final dim = this.dim ?? false;

    return Row(
      spacing: 6.0,
      children: [
        if (showCommunityIcons && resolvedFeedType != FeedType.community)
          GestureDetector(
            child: CommunityAvatar(community: community, radius: showUsername && showCommunityName ? 14 : 7, thumbnailSize: 50, format: 'png'),
            onTap: () => navigateToFeedPage(context, communityId: community.id, feedType: FeedType.community),
          ),
        if (showCommunityName && showUsername)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CommunityPostCardMetadata(
                communityName: community.name,
                displayName: community.title,
                actorId: community.actorId,
                subscribed: community.subscribed != SubscriptionStatus.notSubscribed,
                dim: dim,
                feedListType: feedListType,
              ),
              UserPostCardMetadata(
                username: user.name,
                displayName: user.displayName,
                actorId: user.actorId,
                dim: dim,
              ),
            ],
          )
        else if (showCommunityName)
          CommunityPostCardMetadata(
            communityName: community.name,
            displayName: community.title,
            actorId: community.actorId,
            subscribed: community.subscribed != SubscriptionStatus.notSubscribed,
            dim: dim,
            feedListType: feedListType,
          )
        else if (showUsername)
          UserPostCardMetadata(
            username: user.name,
            displayName: user.displayName,
            actorId: user.actorId,
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
    this.feedListType,
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

  /// Optional feed list type override for contexts without a FeedBloc.
  final FeedListType? feedListType;

  Color? _transformColor(Color? color) => dim ? color?.withValues(alpha: 0.45) : color?.withValues(alpha: 0.75);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final fontScale = context.select<ThemePreferencesCubit, FontScale>((cubit) => cubit.state.metadataFontSizeScale);
    final hasFeedBloc = context.findAncestorWidgetOfExactType<BlocProvider<FeedBloc>>() != null;
    final resolvedFeedListType = feedListType ?? (hasFeedBloc ? context.select<FeedBloc, FeedListType?>((bloc) => bloc.state.feedListType) : null);

    final instanceName = actorId != null ? fetchInstanceNameFromUrl(actorId) : null;
    final showCommunitySubscription = (resolvedFeedListType == FeedListType.all || resolvedFeedListType == FeedListType.local) && subscribed;

    Widget child = CommunityFullNameWidget(name: communityName, displayName: displayName, instance: instanceName, fontScale: fontScale, transformColor: _transformColor);

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
    final postShowUserInstance = context.select<FeedPreferencesCubit, bool>((cubit) => cubit.state.postShowUserInstance);
    final metadataFontSizeScale = context.select<ThemePreferencesCubit, FontScale>((cubit) => cubit.state.metadataFontSizeScale);

    final instanceName = actorId != null ? fetchInstanceNameFromUrl(actorId) : null;

    return UserFullNameWidget(
        name: username, displayName: displayName, instance: instanceName, includeInstance: postShowUserInstance, fontScale: metadataFontSizeScale, transformColor: _transformColor);
  }
}
