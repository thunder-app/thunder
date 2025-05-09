import 'package:flutter/material.dart';

import 'package:thunder/community/widgets/post_card_metadata.dart';

/// Contains metadata related to a given post, usually displayed at the bottom of the post body.
///
/// This includes the total number of comments and the date/time the post was created or updated.
class PostBodyMetadata extends StatelessWidget {
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

  const PostBodyMetadata({
    super.key,
    this.commentCount,
    this.unreadCommentCount,
    this.dateTime,
    this.hasBeenEdited = false,
    this.url,
  });

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
              CommentCountPostCardMetaData(commentCount: commentCount, unreadCommentCount: unreadCommentCount ?? 0, dim: false),
              DateTimePostCardMetaData(dateTime: dateTime!, dim: false, edited: hasBeenEdited ?? false),
            ],
          )
        ],
      ),
    );
  }
}
