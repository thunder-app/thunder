import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:html_unescape/html_unescape_small.dart';
import 'package:thunder/l10n/generated/app_localizations.dart';

import 'package:thunder/src/foundation/primitives/primitives.dart';
import 'package:thunder/src/features/feed/feed.dart';
import 'package:thunder/src/features/modlog/modlog.dart';
import 'package:thunder/src/app/shell/navigation/navigation_utils.dart';
import 'package:thunder/src/shared/identity/widgets/avatars/community_avatar.dart';
import 'package:thunder/src/shared/identity/widgets/avatars/user_avatar.dart';
import 'package:thunder/src/shared/content/widgets/markdown/common_markdown_body.dart';
import 'package:thunder/src/shared/identity/widgets/full_name_widgets.dart';

import 'package:thunder/packages/ui/ui.dart' show ScalableText;
import 'package:thunder/src/features/settings/api.dart';
import 'package:thunder/src/features/instance/domain/utils/instance_link_utils.dart';
import 'package:thunder/packages/ui/ui.dart' show showSnackbar;

/// Provides some additional context for a [ModlogEventItem]
class ModlogItemContextCard extends StatelessWidget {
  const ModlogItemContextCard({
    super.key,
    required this.type,
    this.post,
    this.comment,
    this.community,
    this.user,
  });

  /// The type of event
  final ModlogActionType type;

  /// The post related to the event
  final ThunderPost? post;

  /// The comment related to the event
  final ThunderComment? comment;

  /// The community related to the event
  final ThunderCommunity? community;

  /// The user related to the event
  final ThunderUser? user;

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case ModlogActionType.modLockPost:
      case ModlogActionType.modRemovePost:
      case ModlogActionType.modFeaturePost:
      case ModlogActionType.adminPurgePost:
        return post != null ? ModlogPostItemContextCard(post: post!, community: community) : Container();
      case ModlogActionType.modRemoveComment:
      case ModlogActionType.adminPurgeComment:
        return comment != null ? ModlogCommentItemContextCard(comment: comment!, user: user, post: post, community: community) : Container();
      case ModlogActionType.modHideCommunity:
      case ModlogActionType.adminPurgeCommunity:
      case ModlogActionType.modRemoveCommunity:
      case ModlogActionType.modTransferCommunity:
        return community != null ? ModlogCommunityItemContextCard(community: community) : Container();
      case ModlogActionType.modAdd:
      case ModlogActionType.modBan:
      case ModlogActionType.adminPurgePerson:
      case ModlogActionType.modAddCommunity:
      case ModlogActionType.modBanFromCommunity:
        return user != null ? ModlogUserItemContextCard(user: user) : Container();
      default:
        return Container();
    }
  }
}

/// Provides some additional context for a [Post] related modlog event
///
/// Displays the title and community of the post. If the post is not removed, tapping on the card will navigate to the post
class ModlogPostItemContextCard extends StatelessWidget {
  const ModlogPostItemContextCard({
    super.key,
    required this.post,
    this.community,
  });

  /// The post related to the event
  final ThunderPost post;

  /// The community related to the event
  final ThunderCommunity? community;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final titleFontSizeScale = context.select<ThemePreferencesCubit, FontScale>((cubit) => cubit.state.titleFontSizeScale);
    final metadataFontSizeScale = context.select<ThemePreferencesCubit, FontScale>((cubit) => cubit.state.metadataFontSizeScale);

    return InkWell(
      onTap: () {
        if (!post.removed) {
          navigateToPost(context, postId: post.id);
        } else {
          showSnackbar(l10n.unableToFindPost);
        }
      },
      child: Container(
        padding: const EdgeInsets.only(bottom: 8.0, top: 6, left: 8.0, right: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ScalableText(
                    HtmlUnescape().convert(post.name),
                    style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                    textScaleFactor: titleFontSizeScale.textScaleFactor,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 6.0, top: 6.0),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(6),
                      onTap: () => navigateToFeedPage(context, feedType: FeedType.community, communityId: community?.id),
                      child: CommunityFullNameWidget(
                          name: community?.name,
                          displayName: community?.title,
                          instance: fetchInstanceNameFromUrl(community?.actorId),
                          fontScale: metadataFontSizeScale,
                          transformColor: (color) => color?.withValues(alpha: 0.75)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Provides some additional context for a [Comment] related modlog event
///
/// Displays the comment information, including post, user, and community.
/// Hidden by default due to possibility of sensitive content.
class ModlogCommentItemContextCard extends StatefulWidget {
  const ModlogCommentItemContextCard({
    super.key,
    required this.comment,
    this.post,
    this.user,
    this.community,
  });

  /// The comment related to the event
  final ThunderComment comment;

  /// The post related to the event
  final ThunderPost? post;

  /// The user related to the event
  final ThunderUser? user;

  /// The community related to the event
  final ThunderCommunity? community;

  @override
  State<ModlogCommentItemContextCard> createState() => _ModlogCommentItemContextCardState();
}

class _ModlogCommentItemContextCardState extends State<ModlogCommentItemContextCard> {
  /// Whether to show the sensitive content
  bool showSensitiveContent = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final titleFontSizeScale = context.select<ThemePreferencesCubit, FontScale>((cubit) => cubit.state.titleFontSizeScale);
    final metadataFontSizeScale = context.select<ThemePreferencesCubit, FontScale>((cubit) => cubit.state.metadataFontSizeScale);

    Color? textStyleCommunityAndAuthor(Color? color) => color?.withValues(alpha: 0.75);

    return InkWell(
      onTap: () {
        try {
          if (widget.post == null) {
            return showSnackbar(l10n.unableToFindPost);
          }
          navigateToPost(context, postId: widget.post!.id, highlightedCommentId: widget.comment.id);
        } catch (e) {
          showSnackbar(l10n.unableToFindPost);
        }
      },
      child: Container(
        padding: const EdgeInsets.only(bottom: 8.0, top: 6, left: 8.0, right: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(
                    TextSpan(
                      children: [
                        WidgetSpan(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 4.0),
                            child: Icon(
                              Icons.article_rounded,
                              size: MediaQuery.textScalerOf(context).scale(18 * titleFontSizeScale.textScaleFactor),
                            ),
                          ),
                        ),
                        TextSpan(
                          text: HtmlUnescape().convert(widget.post!.name),
                        )
                      ],
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: MediaQuery.textScalerOf(context).scale(theme.textTheme.bodyMedium!.fontSize! * titleFontSizeScale.textScaleFactor),
                      ),
                    ),
                    textScaler: TextScaler.noScaling,
                  ),
                  Divider(thickness: 1.0, color: theme.dividerColor.withValues(alpha: 0.3)),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 100),
                    child: showSensitiveContent
                        ? CommonMarkdownBody(body: widget.comment.content, isComment: true)
                        : InkWell(
                            borderRadius: const BorderRadius.all(Radius.elliptical(5, 5)),
                            onTap: () => setState(() {
                              showSensitiveContent = !showSensitiveContent;
                            }),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: ScalableText(
                                l10n.sensitiveContentWarning,
                                style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500, color: theme.colorScheme.secondary),
                                textScaleFactor: metadataFontSizeScale.textScaleFactor,
                              ),
                            ),
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 6.0, top: 8.0),
                    child: Wrap(
                      direction: Axis.horizontal,
                      alignment: WrapAlignment.start,
                      crossAxisAlignment: WrapCrossAlignment.end,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            InkWell(
                              borderRadius: BorderRadius.circular(6),
                              onTap: () => navigateToFeedPage(context, feedType: FeedType.user, userId: widget.user?.id),
                              child: ScalableText(
                                '${widget.user?.displayName ?? widget.user?.displayNameOrName}',
                                textScaleFactor: metadataFontSizeScale.textScaleFactor,
                                style: theme.textTheme.bodyMedium?.copyWith(color: textStyleCommunityAndAuthor(theme.textTheme.bodyMedium?.color)),
                              ),
                            ),
                            ScalableText(
                              ' in ',
                              textScaleFactor: metadataFontSizeScale.textScaleFactor,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.4),
                              ),
                            ),
                          ],
                        ),
                        InkWell(
                          borderRadius: BorderRadius.circular(6),
                          onTap: () => navigateToFeedPage(context, feedType: FeedType.community, communityId: widget.community?.id),
                          child: CommunityFullNameWidget(
                              name: widget.community?.name,
                              displayName: widget.community?.title,
                              instance: fetchInstanceNameFromUrl(widget.community?.actorId),
                              fontScale: metadataFontSizeScale,
                              transformColor: textStyleCommunityAndAuthor),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Provides some additional context for a [Person] related modlog event
class ModlogUserItemContextCard extends StatelessWidget {
  const ModlogUserItemContextCard({super.key, this.user});

  /// The user related to the event
  final ThunderUser? user;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final titleFontSizeScale = context.select<ThemePreferencesCubit, FontScale>((cubit) => cubit.state.titleFontSizeScale);

    return InkWell(
      onTap: () {
        if (user != null) {
          navigateToFeedPage(context, feedType: FeedType.user, userId: user!.id);
        } else {
          showSnackbar(l10n.unableToFindUser);
        }
      },
      child: Container(
        padding: const EdgeInsets.only(bottom: 8.0, top: 8.0, left: 8.0, right: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Wrap(
              spacing: 8.0,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                if (user != null) UserAvatar(user: user!),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ScalableText(
                      HtmlUnescape().convert(user?.displayName ?? user?.displayNameOrName ?? l10n.user),
                      style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                      textScaleFactor: titleFontSizeScale.textScaleFactor,
                    ),
                    UserFullNameWidget(
                        name: user?.displayNameOrName, displayName: user?.displayName, instance: fetchInstanceNameFromUrl(user?.actorId), transformColor: (color) => color?.withValues(alpha: 0.75)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Provides some additional context for a [Community] related modlog event
class ModlogCommunityItemContextCard extends StatelessWidget {
  const ModlogCommunityItemContextCard({super.key, this.community});

  /// The community related to the event
  final ThunderCommunity? community;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final titleFontSizeScale = context.select<ThemePreferencesCubit, FontScale>((cubit) => cubit.state.titleFontSizeScale);
    final metadataFontSizeScale = context.select<ThemePreferencesCubit, FontScale>((cubit) => cubit.state.metadataFontSizeScale);

    return InkWell(
      onTap: () {
        if (community != null && !community!.removed) {
          navigateToFeedPage(context, feedType: FeedType.community, communityId: community!.id);
        } else {
          showSnackbar(l10n.unableToFindCommunity);
        }
      },
      child: Container(
        padding: const EdgeInsets.only(bottom: 8.0, top: 8.0, left: 8.0, right: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Wrap(
              spacing: 8.0,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                if (community != null) CommunityAvatar(community: community!),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ScalableText(
                      HtmlUnescape().convert(community?.title ?? community?.name ?? l10n.community),
                      style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                      textScaleFactor: titleFontSizeScale.textScaleFactor,
                    ),
                    CommunityFullNameWidget(
                        name: community?.name,
                        displayName: community?.title,
                        instance: fetchInstanceNameFromUrl(community?.actorId),
                        fontScale: metadataFontSizeScale,
                        transformColor: (color) => color?.withValues(alpha: 0.75)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
