import 'package:flutter/material.dart';

import 'package:lemmy_api_client/v3.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/core/enums/font_scale.dart';
import 'package:thunder/core/enums/full_name_separator.dart';
import 'package:thunder/shared/text/scalable_text.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/thunder/thunder_icons.dart';
import 'package:thunder/user/utils/special_user_checks.dart';
import 'package:thunder/utils/instance.dart';
import 'package:thunder/utils/navigate_user.dart';
import 'package:thunder/utils/numbers.dart';

import '../utils/date_time.dart';

class CommentHeader extends StatelessWidget {
  final CommentView comment;
  final bool isOwnComment;
  final bool isHidden;
  final int moddingCommentId;
  final DateTime now;
  final List<CommunityModeratorView>? moderators;

  const CommentHeader({
    super.key,
    required this.comment,
    required this.now,
    this.isOwnComment = false,
    required this.isHidden,
    this.moddingCommentId = -1,
    required this.moderators,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ThunderState state = context.read<ThunderBloc>().state;

    bool collapseParentCommentOnGesture = state.collapseParentCommentOnGesture;
    bool commentShowUserInstance = state.commentShowUserInstance;

    bool? saved = comment.saved;
    bool? hasBeenEdited = comment.comment.updated != null ? true : false;
    bool? isCommentNew = now.difference(comment.comment.published).inMinutes < 15;

    return Padding(
      padding: EdgeInsets.fromLTRB(isSpecialUser(context, isOwnComment, comment.post, comment.comment, comment.creator, moderators) ? 8.0 : 3.0, 10.0, 8.0, 10.0),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Tooltip(
                  excludeFromSemantics: true,
                  message:
                      '${generateUserFullName(context, comment.creator.name, fetchInstanceNameFromUrl(comment.creator.actorId) ?? '-')}${fetchUsernameDescriptor(isOwnComment, comment.post, comment.comment, comment.creator, moderators)}',
                  preferBelow: false,
                  child: Row(
                    children: [
                      Material(
                        color: isSpecialUser(context, isOwnComment, comment.post, comment.comment, comment.creator, moderators)
                            ? fetchUsernameColor(context, isOwnComment, comment.post, comment.comment, comment.creator, moderators) ?? theme.colorScheme.onBackground
                            : Colors.transparent,
                        borderRadius: isSpecialUser(context, isOwnComment, comment.post, comment.comment, comment.creator, moderators) ? const BorderRadius.all(Radius.elliptical(5, 5)) : null,
                        child: InkWell(
                          borderRadius: const BorderRadius.all(Radius.elliptical(5, 5)),
                          onTap: isHidden && collapseParentCommentOnGesture
                              ? null
                              : () {
                                  navigateToUserPage(context, userId: comment.creator.id);
                                },
                          child: Padding(
                              padding: const EdgeInsets.only(left: 5, right: 5),
                              child: isSpecialUser(context, isOwnComment, comment.post, comment.comment, comment.creator, moderators)
                                  ? Row(
                                      children: [
                                        ScalableText(
                                          comment.creator.displayName != null && state.useDisplayNames ? comment.creator.displayName! : comment.creator.name,
                                          fontScale: state.metadataFontSizeScale,
                                          style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500, color: theme.colorScheme.onBackground),
                                        ),
                                        if (commentShowUserInstance)
                                          ScalableText(
                                            generateUserFullNameSuffix(context, fetchInstanceNameFromUrl(comment.creator.actorId)),
                                            fontScale: state.metadataFontSizeScale,
                                            style: theme.textTheme.bodyMedium?.copyWith(
                                              fontWeight: FontWeight.w300,
                                            ),
                                          ),
                                        const SizedBox(width: 2.0),
                                        Container(
                                          child: commentAuthorIsPostAuthor(comment.post, comment.comment)
                                              ? Padding(
                                                  padding: const EdgeInsets.only(left: 1),
                                                  child: Icon(
                                                    Thunder.microphone_variant,
                                                    size: 15.0 * state.metadataFontSizeScale.textScaleFactor,
                                                    color: theme.colorScheme.onBackground,
                                                  ),
                                                )
                                              : Container(),
                                        ),
                                        Container(
                                          child: isOwnComment
                                              ? Padding(
                                                  padding: const EdgeInsets.only(left: 1),
                                                  child: Icon(
                                                    Icons.person,
                                                    size: 15.0 * state.metadataFontSizeScale.textScaleFactor,
                                                    color: theme.colorScheme.onBackground,
                                                  ))
                                              : Container(),
                                        ),
                                        Container(
                                          child: isAdmin(comment.creator)
                                              ? Padding(
                                                  padding: const EdgeInsets.only(left: 1),
                                                  child: Icon(
                                                    Thunder.shield_crown,
                                                    size: 14.0 * state.metadataFontSizeScale.textScaleFactor,
                                                    color: theme.colorScheme.onBackground,
                                                  ),
                                                )
                                              : Container(),
                                        ),
                                        Container(
                                          child: isModerator(comment.creator, moderators)
                                              ? Padding(
                                                  padding: const EdgeInsets.only(left: 1),
                                                  child: Icon(
                                                    Thunder.shield,
                                                    size: 14.0 * state.metadataFontSizeScale.textScaleFactor,
                                                    color: theme.colorScheme.onBackground,
                                                  ),
                                                )
                                              : Container(),
                                        ),
                                        Container(
                                          child: isBot(comment.creator)
                                              ? Padding(
                                                  padding: const EdgeInsets.only(left: 1, right: 2),
                                                  child: Icon(
                                                    Thunder.robot,
                                                    size: 13.0 * state.metadataFontSizeScale.textScaleFactor,
                                                    color: theme.colorScheme.onBackground,
                                                  ),
                                                )
                                              : Container(),
                                        ),
                                      ],
                                    )
                                  : Text.rich(
                                      TextSpan(
                                          style: theme.textTheme.bodyMedium?.copyWith(
                                            fontWeight: FontWeight.w500,
                                            fontSize: MediaQuery.textScalerOf(context).scale(theme.textTheme.bodyMedium!.fontSize! * state.titleFontSizeScale.textScaleFactor),
                                          ),
                                          text: comment.creator.displayName != null && state.useDisplayNames ? comment.creator.displayName! : comment.creator.name,
                                          children: [
                                            if (commentShowUserInstance)
                                              TextSpan(
                                                text: generateUserFullNameSuffix(context, fetchInstanceNameFromUrl(comment.creator.actorId)),
                                                style: theme.textTheme.bodyMedium?.copyWith(
                                                  fontWeight: FontWeight.w300,
                                                  fontSize: MediaQuery.textScalerOf(context).scale(theme.textTheme.bodyMedium!.fontSize! * state.titleFontSizeScale.textScaleFactor),
                                                ),
                                              )
                                          ]),
                                      textScaler: TextScaler.noScaling,
                                    )),
                        ),
                      ),
                      const SizedBox(width: 8.0),
                    ],
                  ),
                ),
                CommentHeaderScore(comment: comment),
              ],
            ),
          ),
          Row(
            children: [
              AnimatedOpacity(
                opacity: (isHidden && (collapseParentCommentOnGesture || comment.counts.childCount > 0)) ? 1 : 0,
                // Matches the collapse animation
                duration: const Duration(milliseconds: 130),
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: const BorderRadius.all(Radius.elliptical(5, 5)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 5, right: 5),
                    child: ScalableText(
                      '+${comment.counts.childCount}',
                      fontScale: state.metadataFontSizeScale,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8.0),
              Icon(
                saved == true ? Icons.star_rounded : null,
                color: saved == true ? Colors.purple : null,
                size: saved == true ? 18.0 : 0,
              ),
              SizedBox(
                width: hasBeenEdited ? 32.0 : 8,
                child: Icon(
                  hasBeenEdited ? Icons.create_rounded : null,
                  color: theme.colorScheme.onBackground.withOpacity(0.75),
                  size: 16.0,
                ),
              ),
              Container(
                decoration: isCommentNew ? BoxDecoration(color: theme.splashColor, borderRadius: const BorderRadius.all(Radius.elliptical(5, 5))) : null,
                child: Padding(
                  padding: const EdgeInsets.only(left: 5, right: 5),
                  child: Row(
                    children: [
                      isCommentNew
                          ? const Row(children: [
                              Icon(
                                Icons.auto_awesome_rounded,
                                size: 16.0,
                              ),
                              SizedBox(width: 5)
                            ])
                          : Container(),
                      if (comment.comment.id == moddingCommentId) ...[
                        Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: SizedBox(
                                width: state.metadataFontSizeScale.textScaleFactor * 15,
                                height: state.metadataFontSizeScale.textScaleFactor * 15,
                                child: CircularProgressIndicator(
                                  color: theme.colorScheme.primary,
                                )))
                      ] else
                        ScalableText(
                          formatTimeToString(dateTime: (comment.comment.updated ?? comment.comment.published).toIso8601String()),
                          fontScale: state.metadataFontSizeScale,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onBackground,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class CommentHeaderScore extends StatelessWidget {
  final CommentView comment;

  const CommentHeaderScore({super.key, required this.comment});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final ThunderState state = context.read<ThunderBloc>().state;
    final AuthState authState = context.watch<AuthBloc>().state;

    bool showScores = authState.getSiteResponse?.myUser?.localUserView.localUser.showScores ?? true;
    bool combineCommentScores = state.combineCommentScores;

    int? myVote = comment.myVote;

    int score = comment.counts.score;
    int upvotes = comment.counts.upvotes;
    int downvotes = comment.counts.downvotes;

    if (!showScores) {
      if (myVote == null || myVote == 0) return Container();

      return Icon(
        myVote == 1 ? Icons.north_rounded : Icons.south_rounded,
        size: 12.0 * state.metadataFontSizeScale.textScaleFactor,
        color: myVote == 1 ? Colors.orange : Colors.blue,
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Icon(
          Icons.north_rounded,
          size: 12.0 * state.metadataFontSizeScale.textScaleFactor,
          color: myVote == 1 ? Colors.orange : theme.colorScheme.onBackground,
        ),
        const SizedBox(width: 2.0),
        ScalableText(
          combineCommentScores ? formatNumberToK(score) : formatNumberToK(upvotes),
          semanticsLabel: combineCommentScores ? l10n.xScore(formatNumberToK(score)) : l10n.xUpvotes(formatNumberToK(upvotes)),
          fontScale: state.metadataFontSizeScale,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: myVote == 1 ? Colors.orange : (myVote == -1 && combineCommentScores ? Colors.blue : theme.colorScheme.onBackground),
          ),
        ),
        SizedBox(width: combineCommentScores ? 2.0 : 10.0),
        Icon(
          Icons.south_rounded,
          size: 12.0 * state.metadataFontSizeScale.textScaleFactor,
          color: (downvotes != 0 || combineCommentScores) ? (myVote == -1 ? Colors.blue : theme.colorScheme.onBackground) : Colors.transparent,
        ),
        if (!combineCommentScores) ...[
          const SizedBox(width: 2.0),
          if (downvotes != 0)
            ScalableText(
              formatNumberToK(downvotes),
              fontScale: state.metadataFontSizeScale,
              semanticsLabel: l10n.xDownvotes(formatNumberToK(downvotes)),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: downvotes != 0 ? (myVote == -1 ? Colors.blue : theme.colorScheme.onBackground) : Colors.transparent,
              ),
            ),
        ],
      ],
    );
  }
}
