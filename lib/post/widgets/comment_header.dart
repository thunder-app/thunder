import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';

import 'package:thunder/core/enums/font_scale.dart';
import 'package:thunder/core/models/comment_view_tree.dart';
import 'package:thunder/account/bloc/account_bloc.dart' as account_bloc;
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/thunder/thunder_icons.dart';
import 'package:thunder/user/utils/special_user_checks.dart';
import 'package:thunder/utils/instance.dart';
import 'package:thunder/utils/numbers.dart';
import 'package:thunder/user/pages/user_page.dart';
import 'package:thunder/utils/swipe.dart';

import '../../core/auth/bloc/auth_bloc.dart';

class CommentHeader extends StatelessWidget {
  final CommentViewTree commentViewTree;
  final bool useDisplayNames;
  final bool isOwnComment;
  final bool isHidden;
  final bool isCommentNew;
  final int moddingCommentId;
  final List<CommunityModeratorView>? moderators;

  const CommentHeader({
    super.key,
    required this.commentViewTree,
    required this.useDisplayNames,
    this.isCommentNew = false,
    this.isOwnComment = false,
    this.isHidden = false,
    this.moddingCommentId = -1,
    required this.moderators,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ThunderState state = context.read<ThunderBloc>().state;

    bool collapseParentCommentOnGesture = state.collapseParentCommentOnGesture;

    VoteType? myVote = commentViewTree.commentView?.myVote;
    bool? saved = commentViewTree.commentView?.saved;
    bool? hasBeenEdited = commentViewTree.commentView!.comment.updated != null ? true : false;
    //int score = commentViewTree.commentViewTree.comment?.counts.score ?? 0; maybe make combined scores an option?
    int upvotes = commentViewTree.commentView?.counts.upvotes ?? 0;
    int downvotes = commentViewTree.commentView?.counts.downvotes ?? 0;

    return Padding(
      padding: EdgeInsets.fromLTRB(isSpecialUser(context, isOwnComment) ? 8.0 : 3.0, 10.0, 8.0, 10.0),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Tooltip(
                  excludeFromSemantics: true,
                  message: '${commentViewTree.commentView!.creator.name}@${fetchInstanceNameFromUrl(commentViewTree.commentView!.creator.actorId) ?? '-'}${fetchUsernameDescriptor(isOwnComment)}',
                  preferBelow: false,
                  child: Row(
                    children: [
                      Material(
                        color: isSpecialUser(context, isOwnComment) ? fetchUsernameColor(context, isOwnComment) ?? theme.colorScheme.onBackground : Colors.transparent,
                        borderRadius: isSpecialUser(context, isOwnComment) ? const BorderRadius.all(Radius.elliptical(5, 5)) : null,
                        child: InkWell(
                          borderRadius: const BorderRadius.all(Radius.elliptical(5, 5)),
                          onTap: () {
                            account_bloc.AccountBloc accountBloc = context.read<account_bloc.AccountBloc>();
                            AuthBloc authBloc = context.read<AuthBloc>();
                            ThunderBloc thunderBloc = context.read<ThunderBloc>();

                            Navigator.of(context).push(
                              SwipeablePageRoute(
                                canOnlySwipeFromEdge: disableFullPageSwipe(isUserLoggedIn: authBloc.state.isLoggedIn, state: thunderBloc.state, isFeedPage: true),
                                builder: (context) => MultiBlocProvider(
                                  providers: [
                                    BlocProvider.value(value: accountBloc),
                                    BlocProvider.value(value: authBloc),
                                    BlocProvider.value(value: thunderBloc),
                                  ],
                                  child: UserPage(userId: commentViewTree.commentView!.creator.id),
                                ),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(left: 5, right: 5),
                            child: isSpecialUser(context, isOwnComment)
                                ? Row(
                                    children: [
                                      Text(
                                        commentViewTree.commentView!.creator.displayName != null && useDisplayNames
                                            ? commentViewTree.commentView!.creator.displayName!
                                            : commentViewTree.commentView!.creator.name,
                                        textScaleFactor: MediaQuery.of(context).textScaleFactor * state.metadataFontSizeScale.textScaleFactor,
                                        style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500, color: theme.colorScheme.onBackground),
                                      ),
                                      const SizedBox(width: 2.0),
                                      Container(
                                        child: commentAuthorIsPostAuthor(commentViewTree.commentView?.post, commentViewTree.commentView?.comment)
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
                                                padding: EdgeInsets.only(left: 1),
                                                child: Icon(
                                                  Icons.person,
                                                  size: 15.0 * state.metadataFontSizeScale.textScaleFactor,
                                                  color: theme.colorScheme.onBackground,
                                                ))
                                            : Container(),
                                      ),
                                      Container(
                                        child: isAdmin(commentViewTree.commentView?.creator)
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
                                        child: isModerator(commentViewTree.commentView?.creator, moderators)
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
                                    ],
                                  )
                                : Text(
                                    commentViewTree.commentView!.creator.displayName != null && useDisplayNames
                                        ? commentViewTree.commentView!.creator.displayName!
                                        : commentViewTree.commentView!.creator.name,
                                    textScaleFactor: MediaQuery.of(context).textScaleFactor * state.metadataFontSizeScale.textScaleFactor,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8.0),
                    ],
                  ),
                ),
                Icon(
                  Icons.north_rounded,
                  size: 12.0 * state.metadataFontSizeScale.textScaleFactor,
                  color: myVote == VoteType.up ? Colors.orange : theme.colorScheme.onBackground,
                ),
                const SizedBox(width: 2.0),
                Text(
                  formatNumberToK(upvotes),
                  semanticsLabel: '${formatNumberToK(upvotes)} upvotes',
                  textScaleFactor: MediaQuery.of(context).textScaleFactor * state.metadataFontSizeScale.textScaleFactor,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: myVote == VoteType.up ? Colors.orange : theme.colorScheme.onBackground,
                  ),
                ),
                const SizedBox(width: 10.0),
                Icon(
                  Icons.south_rounded,
                  size: 12.0 * state.metadataFontSizeScale.textScaleFactor,
                  color: downvotes != 0 ? (myVote == VoteType.down ? Colors.blue : theme.colorScheme.onBackground) : Colors.transparent,
                ),
                const SizedBox(width: 2.0),
                if (downvotes != 0)
                  Text(
                    formatNumberToK(downvotes),
                    textScaleFactor: MediaQuery.of(context).textScaleFactor * state.metadataFontSizeScale.textScaleFactor,
                    semanticsLabel: '${formatNumberToK(downvotes)} downvotes',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: downvotes != 0 ? (myVote == VoteType.down ? Colors.blue : theme.colorScheme.onBackground) : Colors.transparent,
                    ),
                  ),
              ],
            ),
          ),
          Row(
            children: [
              AnimatedOpacity(
                opacity: (isHidden && (collapseParentCommentOnGesture || (commentViewTree.commentView?.counts.childCount ?? 0) > 0)) ? 1 : 0,
                // Matches the collapse animation
                duration: const Duration(milliseconds: 130),
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: const BorderRadius.all(Radius.elliptical(5, 5)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 5, right: 5),
                    child: Text(
                      '+${commentViewTree.commentView!.counts.childCount}',
                      textScaleFactor: MediaQuery.of(context).textScaleFactor * state.metadataFontSizeScale.textScaleFactor,
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
                      if (commentViewTree.commentView!.comment.id == moddingCommentId) ...[
                        Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: SizedBox(
                                width: state.metadataFontSizeScale.textScaleFactor * 15,
                                height: state.metadataFontSizeScale.textScaleFactor * 15,
                                child: CircularProgressIndicator(
                                  color: theme.colorScheme.primary,
                                )))
                      ] else
                        Text(
                          commentViewTree.datePostedOrEdited,
                          textScaleFactor: MediaQuery.of(context).textScaleFactor * state.metadataFontSizeScale.textScaleFactor,
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

  Color? fetchUsernameColor(BuildContext context, bool isOwnComment) {
    CommentView commentView = commentViewTree.commentView!;
    final theme = Theme.of(context);

    if (commentAuthorIsPostAuthor(commentView.post, commentView.comment)) return theme.colorScheme.secondaryContainer;
    if (isOwnComment) return theme.colorScheme.primaryContainer;
    if (isAdmin(commentView.creator)) return theme.colorScheme.errorContainer;
    if (isModerator(commentView.creator, moderators)) return theme.colorScheme.tertiaryContainer;

    return null;
  }

  String fetchUsernameDescriptor(bool isOwnComment) {
    CommentView commentView = commentViewTree.commentView!;

    String descriptor = '';

    if (commentAuthorIsPostAuthor(commentView.post, commentView.comment)) descriptor += 'original poster';
    if (isOwnComment) descriptor += '${descriptor.isNotEmpty ? ', ' : ''}me';
    if (isAdmin(commentView.creator)) descriptor += '${descriptor.isNotEmpty ? ', ' : ''}admin';
    if (isModerator(commentView.creator, moderators)) descriptor += '${descriptor.isNotEmpty ? ', ' : ''}mod';

    if (descriptor.isNotEmpty) descriptor = ' ($descriptor)';

    return descriptor;
  }

  bool isSpecialUser(BuildContext context, bool isOwnComment) {
    CommentView commentView = commentViewTree.commentView!;

    return commentAuthorIsPostAuthor(commentView.post, commentView.comment) || isOwnComment || isAdmin(commentView.creator) || isModerator(commentView.creator, moderators);
  }
}
