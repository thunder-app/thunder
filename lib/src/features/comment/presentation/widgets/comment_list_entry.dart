import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/features/comment/comment.dart';
import 'package:thunder/src/features/post/post.dart';
import 'package:thunder/src/shared/comment_reference.dart';

/// A widget that can display a single comment entry for use within a list (e.g., search page, instance explorer)
class CommentListEntry extends StatelessWidget {
  /// The comment to display
  final ThunderComment comment;

  const CommentListEntry({super.key, required this.comment});

  @override
  Widget build(BuildContext context) {
    final account = context.select<ProfileBloc, Account>((bloc) => bloc.state.account);

    return BlocProvider<PostBloc>(
      create: (BuildContext context) => PostBloc(account: account),
      child: CommentReference(comment: comment),
    );
  }
}
