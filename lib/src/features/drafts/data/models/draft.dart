import 'package:thunder/src/foundation/primitives/enums/draft_type.dart';

class Draft {
  /// The database identifier for this object
  final String id;

  /// The type of draft
  final DraftType draftType;

  /// Existing id, if we're editing
  final int? existingId;

  /// The community/post/comment we're replying to
  final int? replyId;

  /// Whether this draft is currently considered active for draft resume.
  final bool active;

  /// The account currently selected for publishing this draft.
  final String? accountId;

  /// The title of the post
  final String? title;

  /// The URL of the post
  final String? url;

  /// The custom thumbnail of the post
  final String? customThumbnail;

  /// Alternative text for the image
  final String? altText;

  /// Whether the post is marked as NSFW.
  final bool nsfw;

  /// The selected language for the post/comment.
  final int? languageId;

  /// The body of the post/comment
  final String? body;

  const Draft({
    required this.id,
    required this.draftType,
    this.existingId,
    this.replyId,
    this.active = false,
    this.accountId,
    this.title,
    this.url,
    this.customThumbnail,
    this.altText,
    this.nsfw = false,
    this.languageId,
    this.body,
  });

  Draft copyWith({
    String? id,
    DraftType? draftType,
    int? existingId,
    int? replyId,
    bool? active,
    String? accountId,
    String? title,
    String? url,
    String? customThumbnail,
    String? altText,
    bool? nsfw,
    int? languageId,
    String? body,
  }) =>
      Draft(
        id: id ?? this.id,
        draftType: draftType ?? this.draftType,
        existingId: existingId ?? this.existingId,
        replyId: replyId ?? this.replyId,
        active: active ?? this.active,
        accountId: accountId ?? this.accountId,
        title: title ?? this.title,
        url: url ?? this.url,
        customThumbnail: customThumbnail ?? this.customThumbnail,
        altText: altText ?? this.altText,
        nsfw: nsfw ?? this.nsfw,
        languageId: languageId ?? this.languageId,
        body: body ?? this.body,
      );

  /// See whether this draft contains enough info to save for a post
  bool get isPostNotEmpty =>
      title?.isNotEmpty == true || url?.isNotEmpty == true || customThumbnail?.isNotEmpty == true || altText?.isNotEmpty == true || body?.isNotEmpty == true || nsfw || languageId != null;

  /// See whether this draft contains enough info to save for a comment
  bool get isCommentNotEmpty => body?.isNotEmpty == true || languageId != null;

  /// See whether this draft contains enough information to attempt a draft restore on startup.
  bool get hasRestorableContent => isPostNotEmpty || isCommentNotEmpty;
}
