import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/src/foundation/config/global_context.dart';
import 'package:thunder/src/foundation/primitives/primitives.dart';
import 'package:thunder/src/features/account/api.dart';
import 'package:thunder/src/features/comment/api.dart';
import 'package:thunder/src/features/session/api.dart';
import 'package:thunder/src/shared/name/full_name_widgets.dart';

import 'package:thunder/packages/ui/ui.dart' show ScalableText;
import 'package:thunder/src/features/settings/api.dart';
import 'package:thunder/src/foundation/utils/utils.dart';
import 'package:thunder/src/features/instance/domain/utils/instance_link_utils.dart';
import 'package:thunder/src/app/shell/navigation/navigation_utils.dart';
import 'package:thunder/packages/ui/ui.dart' show showSnackbar;

/// A widget that displays a reference to a comment with additional post and community information.
///
/// This widget is usually used outside the context of the [PostPage]. Can optionally provide a [child] that is displayed in the header.
class CommentReference extends StatelessWidget {
  /// The comment to display information for
  final ThunderComment comment;

  /// The child to display in the header
  final Widget? child;

  const CommentReference({
    super.key,
    required this.comment,
    this.child,
  });

  /// Handles the tap event for the comment reference
  void _onTap(BuildContext context, Account account) {
    final l10n = GlobalContext.l10n;

    if (comment.post?.deleted == true && comment.post?.creatorId != account.userId) {
      return showSnackbar(l10n.unableToLoadPost);
    }

    navigateToComment(context, comment);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = GlobalContext.l10n;
    final account = resolveEffectiveAccount(context);

    assert(comment.creator != null && comment.community != null && comment.post != null, 'Comment must have creator, community, and post fields');

    return Semantics(
      label: """${l10n.inReplyTo(comment.community!.name, comment.post!.name)}\n
          ${fetchInstanceNameFromUrl(comment.community!.actorId)}\n
          ${comment.creator!.name}\n
          ${comment.upvotes == 0 ? '' : l10n.xUpvotes(formatNumberToK(comment.upvotes!))}\n
          ${comment.downvotes == 0 ? '' : l10n.xDownvotes(formatNumberToK(comment.downvotes!))}\n
          ${formatTimeToString(dateTime: (comment.updated ?? comment.published).toIso8601String())}\n
          ${cleanCommentContent(comment)}""",
      child: InkWell(
        onTap: () => _onTap(context, account),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CommentReferenceHeader(comment: comment, child: child),
              CommentCard(
                account: account,
                comment: comment,
                hideReplyCount: true,
                onCollapse: (_, __) => _onTap(context, account),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A widget that displays the header of a comment reference.
///
/// This widget is usually used within a [CommentReference]. Can optionally provide a [child] that is displayed in the header.
class _CommentReferenceHeader extends StatelessWidget {
  /// The comment to display information for
  final ThunderComment comment;

  /// The child to display
  final Widget? child;

  const _CommentReferenceHeader({required this.comment, this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = GlobalContext.l10n;

    final contentFontSizeScale = context.select<ThemePreferencesCubit, FontScale>((cubit) => cubit.state.contentFontSizeScale);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  spacing: 5.0,
                  children: [
                    if (comment.post?.deleted ?? false) const Icon(Icons.delete_rounded, size: 15.0, color: Colors.red),
                    Flexible(
                      child: ExcludeSemantics(
                        child: Text(
                          comment.post?.name ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  spacing: 5.0,
                  children: [
                    ExcludeSemantics(
                      child: ScalableText(
                        l10n.in_,
                        textScaleFactor: contentFontSizeScale.textScaleFactor,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.4),
                        ),
                      ),
                    ),
                    ExcludeSemantics(
                      child: CommunityFullNameWidget(
                          name: comment.community?.name,
                          displayName: comment.community?.title,
                          instance: fetchInstanceNameFromUrl(comment.community?.actorId),
                          fontScale: contentFontSizeScale,
                          transformColor: (color) => color?.withValues(alpha: 0.75)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (child != null) child!,
        ],
      ),
    );
  }
}
