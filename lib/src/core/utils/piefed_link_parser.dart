import 'package:thunder/src/core/domain/models/parsed_link.dart';
import 'package:thunder/src/core/utils/lemmy_link_parser.dart';

// ============================================================================
// PieFed URL Patterns
// ============================================================================

/// Matches instance.tld/post/123/comment/456 (PieFed format)
/// Groups: 2=instance, 3=postId, 4=commentId
final RegExp _piefedCommentUrl = RegExp(r'^(https?:\/\/)(.*)/post/([0-9]+)/comment/([0-9]+).*$');

/// Matches instance.tld/c/community/p/123/slug (PieFed community post format)
/// Groups: 2=instance, 3=community, 4=postId
final RegExp _piefedCommunityPostUrl = RegExp(r'^(https?:\/\/)([^/]+)/c/([^/]+)/p/([0-9]+)');

/// Matches instance.tld/post/123
/// Groups: 2=instance, 3=postId
final RegExp _piefedPostUrl = RegExp(r'^(https?:\/\/)(.*)/post/([0-9]+)$');

// ============================================================================
// PieFed Parsers
// ============================================================================

/// Parses a PieFed community URL.
/// PieFed uses the same format as Lemmy for communities.
ParsedLink? parsePiefedCommunity(String text) => parseLemmyCommunity(text);

/// Parses a PieFed user URL.
/// PieFed uses the same format as Lemmy for users.
ParsedLink? parsePiefedUser(String text) => parseLemmyUser(text);

/// Parses a PieFed post URL.
///
/// Supports formats:
/// - https://instance.tld/post/123
/// - https://instance.tld/c/community/p/123/slug
ParsedLink? parsePiefedPostId(String text) {
  // Skip if this is a comment URL
  if (text.contains('/comment/')) {
    return null;
  }

  // Try PieFed community post format: /c/community/p/123/slug
  final communityPostMatch = _piefedCommunityPostUrl.firstMatch(text);
  if (communityPostMatch != null && communityPostMatch.groupCount >= 4) {
    return ParsedLink(value: communityPostMatch.group(4)!, instance: communityPostMatch.group(2)!);
  }

  // Try standard post format: /post/123
  final match = _piefedPostUrl.firstMatch(text);
  if (match != null && match.groupCount >= 3) {
    return ParsedLink(value: match.group(3)!, instance: match.group(2)!);
  }

  return null;
}

/// Parses a PieFed comment URL.
///
/// Supports formats:
/// - https://instance.tld/post/123/comment/456
ParsedLink? parsePiefedCommentId(String text) {
  final match = _piefedCommentUrl.firstMatch(text);
  if (match != null && match.groupCount >= 4) {
    return ParsedLink(value: match.group(4)!, instance: match.group(2)!);
  }

  return null;
}
