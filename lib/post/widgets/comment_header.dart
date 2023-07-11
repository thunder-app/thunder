import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lemmy_api_client/v3.dart';

import 'package:thunder/core/enums/font_scale.dart';
import 'package:thunder/core/models/comment_view_tree.dart';
import 'package:thunder/account/bloc/account_bloc.dart' as account_bloc;
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/utils/date_time.dart';
import 'package:thunder/utils/instance.dart';
import 'package:thunder/utils/numbers.dart';
import 'package:thunder/user/pages/user_page.dart';

import '../../core/auth/bloc/auth_bloc.dart';

class CommentHeader extends StatelessWidget {
  final CommentViewTree commentViewTree;
  final bool useDisplayNames;
  final bool isOwnComment;
  final bool isHidden;
  final int sinceCreated;

  const CommentHeader({
    super.key,
    required this.commentViewTree,
    required this.useDisplayNames,
    required this.sinceCreated,
    this.isOwnComment = false,
    this.isHidden = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ThunderState state = context.read<ThunderBloc>().state;

    bool collapseParentCommentOnGesture = state.collapseParentCommentOnGesture;

    VoteType? myVote = commentViewTree.comment?.myVote;
    bool? saved = commentViewTree.comment?.saved;
    bool? hasBeenEdited = commentViewTree.comment!.comment.updated != null ? true : false;
    //int score = commentViewTree.commentViewTree.comment?.counts.score ?? 0; maybe make combined scores an option?
    int upvotes = commentViewTree.comment?.counts.upvotes ?? 0;
    int downvotes = commentViewTree.comment?.counts.downvotes ?? 0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Tooltip(
                    message: '${commentViewTree.comment!.creator.name}@${fetchInstanceNameFromUrl(commentViewTree.comment!.creator.actorId) ?? '-'}${fetchUsernameDescriptor(isOwnComment)}',
                    preferBelow: false,
                    child: Row(children: [
                      GestureDetector(
                        onTap: () {
                          account_bloc.AccountBloc accountBloc =
                          context.read<account_bloc.AccountBloc>();
                          AuthBloc authBloc = context.read<AuthBloc>();
                          ThunderBloc thunderBloc = context.read<ThunderBloc>();

                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => MultiBlocProvider(
                                providers: [
                                  BlocProvider.value(value: accountBloc),
                                  BlocProvider.value(value: authBloc),
                                  BlocProvider.value(value: thunderBloc),
                                ],
                                child: UserPage(userId: commentViewTree.comment!.creator.id),
                              ),
                            ),
                          );
                        },
                        child: isSpecialUser(context, isOwnComment)
                          ? Container(
                            decoration: BoxDecoration(
                              color: fetchUsernameColor(context, isOwnComment) ?? theme.colorScheme.onBackground,
                              borderRadius: const BorderRadius.all(Radius.elliptical(5, 5))
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 5, right: 5),
                              child: Text(
                                commentViewTree.comment!.creator.displayName != null && useDisplayNames ? commentViewTree.comment!.creator.displayName! : commentViewTree.comment!.creator.name,
                                textScaleFactor: state.contentFontSizeScale.textScaleFactor,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white
                                ),
                              ),
                            ),
                          )
                          : Text(
                              commentViewTree.comment!.creator.displayName != null && useDisplayNames ? commentViewTree.comment!.creator.displayName! : commentViewTree.comment!.creator.name,
                              textScaleFactor: state.contentFontSizeScale.textScaleFactor,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                            ),
                          ),
                      ),
                      const SizedBox(width: 8.0),
                      Container(
                        child: isOwnComment
                          ? Row(
                            children: [
                              Icon(
                                Icons.person,
                                size: 15.0 * state.contentFontSizeScale.textScaleFactor,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 8.0),
                            ]
                          )
                          : Container(),
                      ),
                      Container(
                        child: commentViewTree.comment?.creator.admin == true
                          ? Row(
                            children: [
                              Icon(
                                Icons.shield_rounded,
                                size: 15.0 * state.contentFontSizeScale.textScaleFactor,
                                color: theme.colorScheme.tertiary,
                              ),
                              const SizedBox(width: 8.0),
                            ]
                          )
                          : Container(),
                      ),
                      Container(
                        child: commentViewTree.comment != null && commentViewTree.comment?.post.creatorId == commentViewTree.comment?.comment.creatorId
                          ? Row(
                            children: [
                              Icon(
                                Icons.mic,
                                size: 15.0 * state.contentFontSizeScale.textScaleFactor,
                                color: theme.colorScheme.secondary,
                              ),
                              const SizedBox(width: 8.0),
                            ]
                          )
                          : Container(),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.north_rounded,
                  size: 12.0 * state.contentFontSizeScale.textScaleFactor,
                  color: myVote == VoteType.up ? Colors.orange : theme.colorScheme.onBackground,
                ),
                const SizedBox(width: 2.0),
                Text(
                  formatNumberToK(upvotes),
                  textScaleFactor: state.contentFontSizeScale.textScaleFactor,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: myVote == VoteType.up ? Colors.orange : theme.colorScheme.onBackground,
                  ),
                ),
                const SizedBox(width: 10.0),
                Icon(
                  Icons.south_rounded,
                  size: 12.0 * state.contentFontSizeScale.textScaleFactor,
                  color: downvotes != 0 ? (myVote == VoteType.down ? Colors.blue : theme.colorScheme.onBackground) : Colors.transparent,
                ),
                const SizedBox(width: 2.0),
                Text(
                  formatNumberToK(downvotes),
                  textScaleFactor: state.contentFontSizeScale.textScaleFactor,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: downvotes != 0 ? (myVote == VoteType.down ? Colors.blue : theme.colorScheme.onBackground) : Colors.transparent,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: const BorderRadius.all(Radius.elliptical(5, 5))
                ),
                child: isHidden && (collapseParentCommentOnGesture || commentViewTree.replies.isNotEmpty)
                  ? Padding(
                      padding: const EdgeInsets.only(left: 5, right: 5),
                      child: Text(
                        '+${commentViewTree.replies.length}',
                        textScaleFactor: state.contentFontSizeScale.textScaleFactor,
                      ),
                    )
                  : Container(),
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
                decoration: sinceCreated < 15 ? BoxDecoration(
                    color: theme.primaryColorLight,
                    borderRadius: const BorderRadius.all(Radius.elliptical(5, 5))
                ) : null,
                child: sinceCreated < 15 ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                  child: Text(
                    'New!',
                    textScaleFactor: state.contentFontSizeScale.textScaleFactor,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.background,
                    )
                  ),
                ) : Text(
                  formatTimeToString(dateTime: hasBeenEdited ? commentViewTree.comment!.comment.updated!.toIso8601String() : commentViewTree.comment!.comment.published.toIso8601String() ),
                  textScaleFactor: state.contentFontSizeScale.textScaleFactor,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onBackground,
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
    CommentView commentView = commentViewTree.comment!;
    final theme = Theme.of(context);

    if (isOwnComment) return theme.colorScheme.primary;
    if (commentView.creator.admin == true) return theme.colorScheme.tertiary;
    if (commentView.post.creatorId == commentView.comment.creatorId) return theme.colorScheme.secondary;

    return null;
  }

  String fetchUsernameDescriptor(bool isOwnComment) {
    CommentView commentView = commentViewTree.comment!;

    String descriptor = '';

    if (isOwnComment) descriptor += 'me';
    if (commentView.creator.admin == true) descriptor += '${descriptor.isNotEmpty ? ', ' : ''}admin';
    if (commentView.post.creatorId == commentView.comment.creatorId) descriptor += '${descriptor.isNotEmpty ? ', ' : ''}original poster';

    if (descriptor.isNotEmpty) descriptor = ' ($descriptor)';

    return descriptor;
  }

  bool isSpecialUser(BuildContext context, bool isOwnComment) {
    CommentView commentView = commentViewTree.comment!;

    return 
      isOwnComment || 
      commentView.creator.admin == true || 
      commentView.post.creatorId == commentView.comment.creatorId;
  }
}
