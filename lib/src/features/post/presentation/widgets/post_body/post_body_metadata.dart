import 'package:flutter/material.dart';

import 'package:thunder/src/features/community/community.dart';

/// Contains metadata related to a given post, usually displayed at the bottom of the post body.
///
/// This includes the total number of comments and the date/time the post was created or updated.
class PostBodyMetadata extends StatelessWidget {
  /// The language of the post. If null, no language will be displayed.
  final int? languageId;

  /// The number of comments on the post. If null, no comment count will be displayed.
  final int? commentCount;

  /// The number of unread comments on the post. If null, no unread comment count will be displayed.
  final int? unreadCommentCount;

  /// The date/time the post was created or updated. This string should conform to ISO-8601 format.
  final String? dateTime;

  /// Whether or not the post has been edited. This determines the icon for the [dateTime] field.
  final bool? hasBeenEdited;

  /// The URL to the post-related content.
  final String? url;

  const PostBodyMetadata({super.key, this.languageId, this.commentCount, this.unreadCommentCount, this.dateTime, this.hasBeenEdited = false, this.url});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0).copyWith(top: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          UrlPostCardMetaData(url: url, dim: false),
          Row(
            children: [
              if (languageId != null && languageId != 0) LanguagePostCardMetaData(languageId: languageId, hasBeenRead: false),
              CommentCountPostCardMetaData(commentCount: commentCount, unreadCommentCount: unreadCommentCount ?? 0, dim: false),
              DateTimePostCardMetaData(dateTime: dateTime!, dim: false, edited: hasBeenEdited ?? false),
            ],
          ),
        ],
      ),
    );
  }
}
