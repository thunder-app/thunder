import 'package:flutter/material.dart';

import 'package:thunder/community/widgets/post_card_metadata.dart';
import 'package:thunder/post/enums/post_card_metadata_item.dart';

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
                PostCardMetadataItem.commentCount =>
                  CommentCountPostCardMetaData(
                      commentCount: commentCount,
                      unreadCommentCount: unreadCommentCount ?? 0,
                      hasBeenRead: false),
                PostCardMetadataItem.dateTime => DateTimePostCardMetaData(
                    dateTime: dateTime!,
                    hasBeenRead: false,
                    hasBeenEdited: hasBeenEdited ?? false),
                PostCardMetadataItem.url =>
                  UrlPostCardMetaData(url: url, hasBeenRead: false),
                _ => Container(),
              };
            },
          ).toList(),
        ),
      ],
    );
  }
}
