import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:super_sliver_list/super_sliver_list.dart';

import 'package:thunder/src/features/comment/comment.dart';
import 'package:thunder/src/features/post/post.dart';

/// Selects only the post and comments required by the post page FAB.
class PostPageFloatingActionButton extends StatelessWidget {
  const PostPageFloatingActionButton({super.key, required this.initialPost, required this.scrollController, required this.listController});

  /// Fallback post displayed before the bloc receives the loaded post.
  final ThunderPost initialPost;

  /// Scroll controller used by FAB actions.
  final ScrollController scrollController;

  /// Comment-list controller used by comment navigation actions.
  final ListController listController;

  @override
  Widget build(BuildContext context) {
    final fabData = context.select<PostBloc, ({ThunderPost? post, List<CommentNode> comments})>((bloc) => (post: bloc.state.post, comments: bloc.state.comments));

    return PostPageFAB(post: fabData.post ?? initialPost, comments: fabData.comments, scrollController: scrollController, listController: listController);
  }
}
