import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:thunder/core/theme/bloc/theme_bloc.dart';

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
  final bool darkTheme = context.read<ThemeBloc>().state.useDarkTheme;

  Color? color;

  if (isBot(creator)) {
    color = Colors.purple;
  }
  if (isModerator(creator, moderators)) {
    color = Colors.orange;
  }
  if (isAdmin(creator)) {
    color = Colors.red;
  }
  if (isOwnComment) {
    color = Colors.green;
  }
  if (commentAuthorIsPostAuthor(post, comment)) {
    color = Colors.blue;
  }

  if (color != null) {
    // Blend with theme
    color = Color.alphaBlend(theme.colorScheme.primaryContainer.withOpacity(0.35), color);

    // Lighten for light mode
    if (!darkTheme) {
      color = HSLColor.fromColor(color).withLightness(0.85).toColor();
    }
  }

  return color;
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
