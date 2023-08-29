import 'package:flutter/material.dart';
import 'package:lemmy_api_client/v3.dart';

// These checks are for whether a given user falls into a given category

/// Checks whether the given [person] is an administrator in the current instance
bool isAdmin(PersonSafe? person) {
  return person?.admin == true;
}

/// Checks whether the author of the given [comment] is also the author of the given [post]
bool commentAuthorIsPostAuthor(Post? post, Comment? comment) {
  return post != null && post.creatorId == comment?.creatorId;
}

/// Checks whether the given [person] is a moderator of the given [moderators].
bool isModerator(PersonSafe? person, List<CommunityModeratorView>? moderators) {
  return person != null && moderators?.any((moderator) => moderator.moderator?.id == person.id) == true;
}

/// Checks whether the given [person] is a bot account
bool isBot(PersonSafe? person) {
  return person?.botAccount == true;
}

bool isSpecialUser(BuildContext context, bool isOwnComment, Post? post, Comment? comment, PersonSafe creator, List<CommunityModeratorView>? moderators) {
  return commentAuthorIsPostAuthor(post, comment) || isOwnComment || isAdmin(creator) || isModerator(creator, moderators) || isBot(creator);
}

// These helper methods are for building UI elements around special users

Color? fetchUsernameColor(BuildContext context, bool isOwnComment, Post? post, Comment? comment, PersonSafe creator, List<CommunityModeratorView>? moderators) {
  final theme = Theme.of(context);

  if (commentAuthorIsPostAuthor(post, comment)) return theme.colorScheme.secondaryContainer;
  if (isOwnComment) return theme.colorScheme.primaryContainer;
  if (isAdmin(creator)) return theme.colorScheme.errorContainer;
  if (isModerator(creator, moderators)) return theme.colorScheme.tertiaryContainer;
  if (isBot(creator)) return Color.alphaBlend(theme.colorScheme.primaryContainer.withOpacity(0.75), Colors.purple);

  return null;
}

String fetchUsernameDescriptor(bool isOwnComment, Post? post, Comment? comment, PersonSafe creator, List<CommunityModeratorView>? moderators) {
  String descriptor = '';

  if (commentAuthorIsPostAuthor(post, comment)) descriptor += 'original poster';
  if (isOwnComment) descriptor += '${descriptor.isNotEmpty ? ', ' : ''}me';
  if (isAdmin(creator)) descriptor += '${descriptor.isNotEmpty ? ', ' : ''}admin';
  if (isModerator(creator, moderators)) descriptor += '${descriptor.isNotEmpty ? ', ' : ''}mod';
  if (isBot(creator)) descriptor += '${descriptor.isNotEmpty ? ', ' : ''}bot';

  if (descriptor.isNotEmpty) descriptor = ' ($descriptor)';

  return descriptor;
}
