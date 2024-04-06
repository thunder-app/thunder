import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/community/widgets/post_card_metadata.dart';
import 'package:thunder/core/enums/font_scale.dart';
import 'package:thunder/core/enums/full_name.dart';
import 'package:thunder/core/enums/user_type.dart';
import 'package:thunder/feed/utils/utils.dart';
import 'package:thunder/feed/view/feed_page.dart';
import 'package:thunder/post/enums/post_card_metadata_item.dart';
import 'package:thunder/shared/full_name_widgets.dart';
import 'package:thunder/shared/text/scalable_text.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/thunder/thunder_icons.dart';
import 'package:thunder/user/utils/special_user_checks.dart';
import 'package:thunder/utils/instance.dart';

/// Contains metadata related to a given post. This is generally displayed as part of the post view.
///
/// The order in which the items are displayed depends on the order in the [postCardMetadataItems] list
class PostMetadata extends StatelessWidget {
  /// The number of comments on the post. If null, no comment count will be displayed.
  final int? commentCount;

  /// The number of unread comments on the post. If null, no unread comment count will be displayed.
  final int? unreadCommentCount;

  /// The date/time the post was created or updated. This string should conform to ISO-8601 format.
  final String? dateTime;

  /// Whether or not the post has been edited. This determines the icon for the [dateTime] field.
  final bool? hasBeenEdited;

  /// The URL to display in the metadata. If null, no URL will be displayed.
  final String? url;

  const PostMetadata({
    super.key,
    this.commentCount,
    this.unreadCommentCount,
    this.dateTime,
    this.hasBeenEdited = false,
    this.url,
  });

  @override
  Widget build(BuildContext context) {
    List<PostCardMetadataItem> postCardMetadataItems = [
      PostCardMetadataItem.commentCount,
      PostCardMetadataItem.dateTime,
    ];

    return Column(
      children: [
        Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: postCardMetadataItems.map(
            (PostCardMetadataItem postCardMetadataItem) {
              return switch (postCardMetadataItem) {
                PostCardMetadataItem.commentCount => CommentCountPostCardMetaData(commentCount: commentCount, unreadCommentCount: unreadCommentCount ?? 0, hasBeenRead: false),
                PostCardMetadataItem.dateTime => DateTimePostCardMetaData(dateTime: dateTime!, hasBeenRead: false, hasBeenEdited: hasBeenEdited ?? false),
                PostCardMetadataItem.url => UrlPostCardMetaData(url: url, hasBeenRead: false),
                _ => Container(),
              };
            },
          ).toList(),
        ),
      ],
    );
  }
}

class PostPersonCommunityMetadata extends StatelessWidget {
  const PostPersonCommunityMetadata({
    super.key,
    required this.personId,
    required this.personName,
    required this.personDisplayName,
    required this.personUrl,
    required this.communityId,
    required this.communityName,
    required this.communityUrl,
    required this.userGroups,
  });

  final int personId;
  final String personName;
  final String personDisplayName;
  final String personUrl;
  final int communityId;
  final String communityName;
  final String communityUrl;
  final List<UserType> userGroups;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = context.read<ThunderBloc>().state;

    return Wrap(
      spacing: 6.0,
      children: [
        PersonPostMetadata(
          personId: personId,
          personName: personName,
          personDisplayName: personDisplayName,
          personUrl: personUrl,
          userGroups: userGroups,
        ),
        ScalableText(
          'to',
          fontScale: state.metadataFontSizeScale,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.textTheme.bodyMedium?.color?.withOpacity(0.4),
          ),
        ),
        CommunityPostMetadata(
          communityId: communityId,
          communityName: communityName,
          communityUrl: communityUrl,
        ),
      ],
    );
  }
}

class PersonPostMetadata extends StatelessWidget {
  const PersonPostMetadata({
    super.key,
    this.personId,
    this.personName,
    this.personDisplayName,
    this.personUrl,
    this.userGroups = const [],
    this.disableTap = false,
  });

  /// The ID of the user
  final int? personId;

  /// The username of the user
  final String? personName;

  /// The display name of the user
  final String? personDisplayName;

  /// The URL of the user's profile
  final String? personUrl;

  /// The groups that the user belongs to (e.g., self, moderator, admin)
  /// This determines special badge colors and icons
  final List<UserType> userGroups;

  /// Whether or not to disable the tap behavior
  final bool disableTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = context.read<ThunderBloc>().state;

    return Tooltip(
      excludeFromSemantics: true,
      message: '${generateUserFullName(context, personName, fetchInstanceNameFromUrl(personUrl) ?? '-')}${fetchUsernameDescriptor(userGroups)}',
      preferBelow: false,
      child: Material(
        color: userGroups.isNotEmpty ? fetchUsernameColor(context, userGroups) ?? theme.colorScheme.onBackground : Colors.transparent,
        borderRadius: userGroups.isNotEmpty ? const BorderRadius.all(Radius.elliptical(5, 5)) : null,
        child: InkWell(
          borderRadius: BorderRadius.circular(5),
          onTap: disableTap
              ? null
              : () {
                  navigateToFeedPage(context, feedType: FeedType.user, userId: personId);
                },
          child: Padding(
            padding: userGroups.isNotEmpty ? const EdgeInsets.symmetric(horizontal: 5.0) : EdgeInsets.zero,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                UserFullNameWidget(
                  context,
                  personDisplayName != null && state.useDisplayNames ? personDisplayName! : personName,
                  fetchInstanceNameFromUrl(personUrl),
                  includeInstance: state.postBodyShowUserInstance,
                  fontScale: state.metadataFontSizeScale,
                  transformColor: (color) => color?.withOpacity(0.75),
                ),
                if (userGroups.isNotEmpty) const SizedBox(width: 2.0),
                if (userGroups.contains(UserType.self))
                  Padding(
                    padding: const EdgeInsets.only(left: 1),
                    child: Icon(
                      Icons.person,
                      size: 15.0 * state.metadataFontSizeScale.textScaleFactor,
                      color: theme.colorScheme.onBackground,
                    ),
                  ),
                if (userGroups.contains(UserType.admin))
                  Padding(
                    padding: const EdgeInsets.only(left: 1),
                    child: Icon(
                      Thunder.shield_crown,
                      size: 14.0 * state.metadataFontSizeScale.textScaleFactor,
                      color: theme.colorScheme.onBackground,
                    ),
                  ),
                if (userGroups.contains(UserType.moderator))
                  Padding(
                    padding: const EdgeInsets.only(left: 1),
                    child: Icon(
                      Thunder.shield,
                      size: 14.0 * state.metadataFontSizeScale.textScaleFactor,
                      color: theme.colorScheme.onBackground,
                    ),
                  ),
                if (userGroups.contains(UserType.bot))
                  Padding(
                    padding: const EdgeInsets.only(left: 1, right: 2),
                    child: Icon(
                      Thunder.robot,
                      size: 13.0 * state.metadataFontSizeScale.textScaleFactor,
                      color: theme.colorScheme.onBackground,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CommunityPostMetadata extends StatelessWidget {
  const CommunityPostMetadata({
    super.key,
    this.communityId,
    this.communityName,
    this.communityUrl,
  });

  /// The ID of the community.
  final int? communityId;

  /// The name of the community.
  final String? communityName;

  /// The URL of the community.
  final String? communityUrl;

  @override
  Widget build(BuildContext context) {
    final state = context.read<ThunderBloc>().state;

    return InkWell(
      borderRadius: BorderRadius.circular(5),
      onTap: () => navigateToFeedPage(context, feedType: FeedType.community, communityId: communityId),
      child: Tooltip(
        excludeFromSemantics: true,
        message: generateCommunityFullName(context, communityName, fetchInstanceNameFromUrl(communityUrl) ?? '-'),
        preferBelow: false,
        child: CommunityFullNameWidget(
          context,
          communityName,
          fetchInstanceNameFromUrl(communityUrl),
          includeInstance: state.postBodyShowCommunityInstance,
          fontScale: state.metadataFontSizeScale,
          transformColor: (color) => color?.withOpacity(0.75),
        ),
      ),
    );
  }
}
