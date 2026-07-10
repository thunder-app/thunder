import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/src/core/config/global_context.dart';
import 'package:thunder/src/features/post/post.dart';

/// Banner that exits a highlighted comment thread and reloads all comments.
class PostViewAllCommentsBanner extends StatelessWidget {
  const PostViewAllCommentsBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final highlightedCommentId = context.select<PostNavigationCubit, int?>((cubit) => cubit.state.highlightedCommentId);
    if (highlightedCommentId == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final l10n = GlobalContext.l10n;

    return InkWell(
      onTap: () {
        context.read<PostBloc>().add(const GetPostCommentsEvent(reset: true, commentParentId: null));
        context.read<PostNavigationCubit>().setHighlightedCommentId(null);
      },
      child: Container(
        height: 60.0,
        decoration: BoxDecoration(border: Border(top: BorderSide(color: theme.dividerColor))),
        child: Row(
          spacing: 4.0,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(l10n.viewAllComments, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
            const Icon(Icons.arrow_right_alt_rounded),
          ],
        ),
      ),
    );
  }
}
