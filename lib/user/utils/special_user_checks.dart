import 'package:lemmy_api_client/v3.dart';

/// Checks whether the given [person] is an administrator in the current instance
bool isAdmin(PersonSafe? person) {
  return person?.admin == true;
}

/// Checks whether the author of the given [comment] is also the author of the given [post]
bool commentAuthorIsPostAuthor(Post? post, Comment? comment) {
  return post != null && post.creatorId == comment?.creatorId;
}

/// Checks whether the given [person] is a moderator of the given [community].
bool isModerator(PersonSafe? person, FullCommunityView? community) {
  return person != null && community?.moderators.any((moderator) => moderator.moderator?.id == person.id) == true;
}
