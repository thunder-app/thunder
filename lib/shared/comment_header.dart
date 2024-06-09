import 'package:flutter/material.dart';

import 'package:lemmy_api_client/v3.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:thunder/account/bloc/account_bloc.dart';

import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/core/enums/font_scale.dart';
import 'package:thunder/core/enums/user_type.dart';
import 'package:thunder/shared/avatars/user_avatar.dart';
import 'package:thunder/shared/chips/user_chip.dart';
import 'package:thunder/shared/text/scalable_text.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/utils/numbers.dart';

import '../utils/date_time.dart';

class CommentHeader extends StatelessWidget {
  final CommentView comment;
  final bool isOwnComment;
  final bool isHidden;
  final int moddingCommentId;

  const CommentHeader({
    super.key,
    required this.comment,
    this.isOwnComment = false,
    required this.isHidden,
    this.moddingCommentId = -1,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ThunderState state = context.read<ThunderBloc>().state;
    final AccountState accountState = context.read<AccountBloc>().state;

    bool collapseParentCommentOnGesture = state.collapseParentCommentOnGesture;

    bool? saved = comment.saved;
    bool? hasBeenEdited = comment.comment.updated != null ? true : false;
    bool? isCommentNew = DateTime.now().toUtc().difference(comment.comment.published).inMinutes < 15;

    List<UserType> userGroups = [];

    if (comment.creator.botAccount) userGroups.add(UserType.bot);
    if (comment.creatorIsModerator ?? false) userGroups.add(UserType.moderator);
    if (comment.creatorIsAdmin ?? false) userGroups.add(UserType.admin);
    if (comment.post.creatorId == comment.creator.id) userGroups.add(UserType.op);
    if (comment.creator.id == accountState.personView?.person.id) userGroups.add(UserType.self);
    if (comment.creator.published.month == DateTime.now().month && comment.creator.published.day == DateTime.now().day) userGroups.add(UserType.birthday);

    return Padding(
      padding: EdgeInsets.fromLTRB(userGroups.isNotEmpty ? 8.0 : 8.0, 10.0, 8.0, 10.0),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                UserChip(
                  person: comment.creator,
                  personAvatar: UserAvatar(person: comment.creator, radius: 10, thumbnailSize: 20, format: 'png'),
                  userGroups: userGroups,
                  includeInstance: state.commentShowUserInstance,
                  ignorePointerEvents: isHidden && collapseParentCommentOnGesture,
                  opacity: 1.0,
                ),
                const SizedBox(width: 8.0),
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
                color: saved == true ? context.read<ThunderBloc>().state.saveColor.color : null,
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
        color: myVote == 1 ? context.read<ThunderBloc>().state.upvoteColor.color : context.read<ThunderBloc>().state.downvoteColor.color,
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Icon(
          Icons.north_rounded,
          size: 12.0 * state.metadataFontSizeScale.textScaleFactor,
          color: myVote == 1 ? context.read<ThunderBloc>().state.upvoteColor.color : theme.colorScheme.onBackground,
        ),
        const SizedBox(width: 2.0),
        ScalableText(
          combineCommentScores ? formatNumberToK(score) : formatNumberToK(upvotes),
          semanticsLabel: combineCommentScores ? l10n.xScore(formatNumberToK(score)) : l10n.xUpvotes(formatNumberToK(upvotes)),
          fontScale: state.metadataFontSizeScale,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: myVote == 1
                ? context.read<ThunderBloc>().state.upvoteColor.color
                : (myVote == -1 && combineCommentScores ? context.read<ThunderBloc>().state.downvoteColor.color : theme.colorScheme.onBackground),
          ),
        ),
        SizedBox(width: combineCommentScores ? 2.0 : 10.0),
        Icon(
          Icons.south_rounded,
          size: 12.0 * state.metadataFontSizeScale.textScaleFactor,
          color: (downvotes != 0 || combineCommentScores) ? (myVote == -1 ? context.read<ThunderBloc>().state.downvoteColor.color : theme.colorScheme.onBackground) : Colors.transparent,
        ),
        if (!combineCommentScores) ...[
          const SizedBox(width: 2.0),
          if (downvotes != 0)
            ScalableText(
              formatNumberToK(downvotes),
              fontScale: state.metadataFontSizeScale,
              semanticsLabel: l10n.xDownvotes(formatNumberToK(downvotes)),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: downvotes != 0 ? (myVote == -1 ? context.read<ThunderBloc>().state.downvoteColor.color : theme.colorScheme.onBackground) : Colors.transparent,
              ),
            ),
        ],
      ],
    );
  }
}
