import 'package:thunder/src/core/domain/models/parsed_link.dart';
import 'package:thunder/src/core/utils/lemmy_link_parser.dart';
import 'package:thunder/src/core/utils/piefed_link_parser.dart';

// ============================================================================
// Unified Parsers
// ============================================================================

/// Parses a community URL from any supported platform.
///
/// Tries Lemmy and PieFed formats.
ParsedLink? parseCommunity(String text) {
  // Both Lemmy and PieFed use the same community URL format
  return parseLemmyCommunity(text);
}

/// Parses a user URL from any supported platform.
///
/// Tries Lemmy and PieFed formats.
ParsedLink? parseUser(String text) {
  // Both Lemmy and PieFed use the same user URL format
  return parseLemmyUser(text);
}

/// Parses a post URL from any supported platform.
///
/// Tries PieFed first (to exclude comment URLs), then Lemmy.
ParsedLink? parsePostId(String text) {
  // Check for PieFed comment format first to exclude it
  if (parsePiefedCommentId(text) != null) {
    return null;
  }

  // Try PieFed format first (includes /c/community/p/123/slug format)
  final piefedResult = parsePiefedPostId(text);
  if (piefedResult != null) {
    return piefedResult;
  }

  // Try Lemmy format
  return parseLemmyPostId(text);
}

/// Parses a comment URL from any supported platform.
///
/// Tries PieFed format first, then Lemmy formats.
ParsedLink? parseCommentId(String text) {
  // Try PieFed format first: /post/123/comment/456
  final piefedResult = parsePiefedCommentId(text);
  if (piefedResult != null) {
    return piefedResult;
  }

  // Try Lemmy formats: /comment/123 or /post/123/456
  return parseLemmyCommentId(text);
}
