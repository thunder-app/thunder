// Flutter imports
import 'package:flutter/material.dart';

// Package imports
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports
import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/features/comment/comment.dart';
import 'package:thunder/src/features/post/presentation/bloc/post_bloc.dart' as post_bloc;
import 'package:thunder/src/shared/comment_reference.dart';

/// A widget that can display a single comment entry for use within a list (e.g., search page, instance explorer)
class CommentListEntry extends StatelessWidget {
  final ThunderComment comment;
  final Function(int, int)? onVoteAction;
  final Function(int, bool)? onSaveAction;

  const CommentListEntry({super.key, required this.comment, this.onVoteAction, this.onSaveAction});

  @override
  Widget build(BuildContext context) {
    assert(comment.creator != null, 'Comment must have a creator');
    final account = context.select<ProfileBloc, Account>((bloc) => bloc.state.account);

    return BlocProvider<post_bloc.PostBloc>(
      create: (BuildContext context) => post_bloc.PostBloc(account: account),
      child: CommentReference(comment: comment),
    );
  }
}
