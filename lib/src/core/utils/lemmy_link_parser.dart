import 'package:thunder/src/core/domain/models/parsed_link.dart';

/// Pure link parsing utilities for Lemmy and PieFed URLs.
///
/// These functions extract community names, usernames, post IDs, and comment IDs
/// from platform-specific URL formats without any Flutter dependencies.
// ============================================================================
// Lemmy URL Patterns
// ============================================================================

/// Matches instance.tld/c/community@otherinstance.tld
/// Groups: 2=instance, 3=community, 4=federatedInstance
final RegExp _lemmyFullCommunityUrl = RegExp(r'^!?(https?:\/\/)?(.*)/c/(.*)@(.*)$');

/// Matches instance.tld/c/community
/// Groups: 2=instance, 3=community
final RegExp _lemmyShortCommunityUrl = RegExp(r'^!?(https?:\/\/)?(.*)/c/([^@\n]*)$');

/// Matches community@instance.tld (excludes URLs with /c/ or /u/)
/// Groups: 2=community, 3=instance
final RegExp _lemmyCommunityMention = RegExp(r'^!?(https?:\/\/)?((?:(?!\/c\/c).)*)@(.*)$');

/// Matches instance.tld/u/username@otherinstance.tld
/// Groups: 2=instance, 3=username, 4=federatedInstance
final RegExp _lemmyFullUserUrl = RegExp(r'^@?(https?:\/\/)?(.*)/u/(.*)@(.*)$');

/// Matches instance.tld/u/username
/// Groups: 2=instance, 3=username
final RegExp _lemmyShortUserUrl = RegExp(r'^@?(https?:\/\/)?(.*)/u/([^@\n]*)$');

/// Matches username@instance.tld (excludes URLs with /u/)
/// Groups: 2=username, 3=instance
final RegExp _lemmyUserMention = RegExp(r'^@?(https?:\/\/)?((?:(?!\/u\/u).)*)@(.*)$');

/// Matches instance.tld/post/123?foo=bar
/// Groups: 2=instance, 3=postId
final RegExp _lemmyPostUrl = RegExp(r'^(https?:\/\/)(.*)/post/([0-9]+)(?:\?.*)?$');

/// Matches instance.tld/comment/123
/// Groups: 2=instance, 3=commentId
final RegExp _lemmyCommentUrl = RegExp(r'^(https?:\/\/)(.*)/comment/([0-9]+).*$');

/// Matches instance.tld/post/123/456 (Lemmy new format)
/// Groups: 2=instance, 3=postId, 4=commentId
final RegExp _lemmyPostCommentUrl = RegExp(r'^(https?:\/\/)(.*)/post/([0-9]+)/([0-9]+)$');

// ============================================================================
// Lemmy Parsers
// ============================================================================

/// Parses a Lemmy community URL.
///
/// Supports formats:
/// - https://instance.tld/c/community
/// - https://instance.tld/c/community@other.tld
/// - !community@instance.tld
/// - community@instance.tld
ParsedLink? parseLemmyCommunity(String text) {
  // Skip if this looks like a user URL
  if (text.contains('/u/')) {
    return null;
  }

  // Skip if this looks like a PieFed post URL (/c/community/p/postId)
  if (text.contains('/p/')) {
    return null;
  }

  // Try full community URL: /c/community@federatedInstance
  final fullMatch = _lemmyFullCommunityUrl.firstMatch(text);
  if (fullMatch != null && fullMatch.groupCount >= 4) {
    return ParsedLink(
      value: fullMatch.group(3)!,
      instance: fullMatch.group(4)!,
    );
  }

  // Try short community URL: /c/community
  final shortMatch = _lemmyShortCommunityUrl.firstMatch(text);
  if (shortMatch != null && shortMatch.groupCount >= 3) {
    return ParsedLink(
      value: shortMatch.group(3)!,
      instance: shortMatch.group(2)!,
    );
  }

  // Try mention format: !community@instance or community@instance
  // But skip if starts with @ (user mention)
  if (text.toLowerCase().startsWith('@')) {
    return null;
  }
  final mentionMatch = _lemmyCommunityMention.firstMatch(text);
  if (mentionMatch != null && mentionMatch.groupCount >= 3) {
    return ParsedLink(
      value: mentionMatch.group(2)!,
      instance: mentionMatch.group(3)!,
    );
  }

  return null;
}

/// Parses a Lemmy user URL.
///
/// Supports formats:
/// - https://instance.tld/u/username
/// - https://instance.tld/u/username@other.tld
/// - @username@instance.tld
/// - username@instance.tld
ParsedLink? parseLemmyUser(String text) {
  // Skip if this looks like a community URL
  if (text.contains('/c/')) {
    return null;
  }

  // Try full user URL: /u/username@federatedInstance
  final fullMatch = _lemmyFullUserUrl.firstMatch(text);
  if (fullMatch != null && fullMatch.groupCount >= 4) {
    return ParsedLink(
      value: fullMatch.group(3)!,
      instance: fullMatch.group(4)!,
    );
  }

  // Try short user URL: /u/username
  final shortMatch = _lemmyShortUserUrl.firstMatch(text);
  if (shortMatch != null && shortMatch.groupCount >= 3) {
    return ParsedLink(
      value: shortMatch.group(3)!,
      instance: shortMatch.group(2)!,
    );
  }

  // Try mention format: @username@instance or username@instance
  // But skip if starts with ! (community mention)
  if (text.toLowerCase().startsWith('!')) {
    return null;
  }
  final mentionMatch = _lemmyUserMention.firstMatch(text);
  if (mentionMatch != null && mentionMatch.groupCount >= 3) {
    return ParsedLink(
      value: mentionMatch.group(2)!,
      instance: mentionMatch.group(3)!,
    );
  }

  return null;
}

/// Parses a Lemmy post URL.
///
/// Supports formats:
/// - https://instance.tld/post/123
ParsedLink? parseLemmyPostId(String text) {
  // Skip if this is a comment URL (PieFed format or Lemmy new format)
  if (text.contains('/comment/') || _lemmyPostCommentUrl.hasMatch(text)) {
    return null;
  }

  final match = _lemmyPostUrl.firstMatch(text);
  if (match != null && match.groupCount >= 3) {
    return ParsedLink(
      value: match.group(3)!,
      instance: match.group(2)!,
    );
  }

  return null;
}

/// Parses a Lemmy comment URL.
///
/// Supports formats:
/// - https://instance.tld/comment/123
/// - https://instance.tld/post/123/456
ParsedLink? parseLemmyCommentId(String text) {
  // Try legacy comment URL: /comment/123
  final commentMatch = _lemmyCommentUrl.firstMatch(text);
  if (commentMatch != null && commentMatch.groupCount >= 3) {
    return ParsedLink(
      value: commentMatch.group(3)!,
      instance: commentMatch.group(2)!,
    );
  }

  // Try new Lemmy format: /post/123/456
  final postCommentMatch = _lemmyPostCommentUrl.firstMatch(text);
  if (postCommentMatch != null && postCommentMatch.groupCount >= 4) {
    return ParsedLink(
      value: postCommentMatch.group(4)!,
      instance: postCommentMatch.group(2)!,
    );
  }

  return null;
}
