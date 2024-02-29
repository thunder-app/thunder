import 'package:flutter/material.dart';

import 'package:lemmy_api_client/v3.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:thunder/feed/utils/utils.dart';
import 'package:thunder/feed/view/feed_page.dart';
import 'package:thunder/post/utils/navigate_post.dart';
import 'package:thunder/shared/common_markdown_body.dart';
import 'package:thunder/shared/snackbar.dart';
import 'package:thunder/user/utils/navigate_user.dart';

/// Provides some additional context for a [ModlogEventItem]
class ModlogItemContextCard extends StatefulWidget {
  const ModlogItemContextCard({super.key, required this.title, this.post, this.comment, this.community, this.user});

  /// The title of the context card
  final String title;

  /// The post related to the event
  final Post? post;

  /// The comment related to the event
  final Comment? comment;

  /// The community related to the event
  final Community? community;

  /// The user related to the event
  final Person? user;

  @override
  State<ModlogItemContextCard> createState() => _ModlogItemContextCardState();
}

class _ModlogItemContextCardState extends State<ModlogItemContextCard> {
  /// Whether to show the sensitive content
  bool showSensitiveContent = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    IconData icon;

    if (widget.post != null) {
      icon = Icons.article_rounded;
    } else if (widget.comment != null) {
      icon = Icons.comment_rounded;
    } else if (widget.community != null) {
      icon = Icons.people_rounded;
    } else if (widget.user != null) {
      icon = Icons.person_rounded;
    } else {
      icon = Icons.link;
    }

    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12.0)),
      child: Stack(
        alignment: Alignment.bottomRight,
        fit: StackFit.passthrough,
        children: [
          Container(
            color: ElevationOverlay.applySurfaceTint(
              theme.colorScheme.surface.withOpacity(0.8),
              theme.colorScheme.surfaceTint,
              10,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Icon(
                    icon,
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                ),
                Expanded(
                  child: AnimatedSize(
                    duration: const Duration(milliseconds: 100),
                    child: (widget.comment != null && !showSensitiveContent)
                        ? Text(
                            l10n.sensitiveContentWarning,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.secondary,
                            ),
                          )
                        : widget.comment != null
                            ? CommonMarkdownBody(body: widget.comment!.content, isComment: true) // Use markdown for comments
                            : Text(widget.title),
                  ),
                ),
              ],
            ),
          ),
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                splashColor: theme.colorScheme.primary.withOpacity(0.4),
                onTap: (!showSensitiveContent && widget.comment != null)
                    ? () {
                        setState(() {
                          showSensitiveContent = !showSensitiveContent;
                        });
                      }
                    : () {
                        if (widget.post != null) {
                          if (widget.post!.removed) {
                            showSnackbar(l10n.unableToFindPost);
                          } else {
                            navigateToPost(context, postId: widget.post!.id);
                          }
                        } else if (widget.community != null) {
                          if (widget.community!.removed) {
                            showSnackbar(l10n.unableToFindCommunity);
                          } else {
                            navigateToFeedPage(context, feedType: FeedType.community, communityId: widget.community!.id);
                          }
                        } else if (widget.user != null) {
                          navigateToUserPage(context, userId: widget.user!.id);
                        }
                      },
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
