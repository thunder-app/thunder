import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:thunder/account/bloc/account_bloc.dart';
import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/core/enums/font_scale.dart';
import 'package:thunder/post/bloc/post_bloc.dart';
import 'package:thunder/post/pages/post_page.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/utils/instance.dart';

import 'comment_content.dart';

class CommentReference extends StatelessWidget {
  final CommentView comment;
  final PersonMentionView? mention;

  const CommentReference({super.key, required this.comment});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final ThunderState state = context.read<ThunderBloc>().state;

    return InkWell(
      onTap: () async {
        AccountBloc accountBloc = context.read<AccountBloc>();
        AuthBloc authBloc = context.read<AuthBloc>();
        ThunderBloc thunderBloc = context.read<ThunderBloc>();

        // To to specific post for now, in the future, will be best to scroll to the position of the comment
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => MultiBlocProvider(
              providers: [
                BlocProvider.value(value: accountBloc),
                BlocProvider.value(value: authBloc),
                BlocProvider.value(value: thunderBloc),
                BlocProvider(create: (context) => PostBloc()),
              ],
              child: PostPage(postId: comment.post.id, selectedCommentPath: comment.comment.path, selectedCommentId: comment.comment.id, onPostUpdated: () => {}),
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          comment.post.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            /*const Divider(height: 1),*/
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0.0),
                ),
                child: CommentContent(comment: comment)
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10),
              child: Row(
                children: [
                  Text(
                    'in ',
                    textScaleFactor: state.contentFontSizeScale.textScaleFactor,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.4),
                    ),
                  ),
                  Text(
                    '${comment.community.name}${' · ${fetchInstanceNameFromUrl(comment.community.actorId)}'}',
                    textScaleFactor: state.contentFontSizeScale.textScaleFactor,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.75),
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
