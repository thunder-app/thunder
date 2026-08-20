import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:super_sliver_list/super_sliver_list.dart';

import 'package:thunder/src/features/post/post.dart';
import 'package:thunder/src/features/post/presentation/widgets/cross_posts.dart';
import 'package:thunder/src/features/post/presentation/widgets/post_page_content_slivers.dart';
import 'package:thunder/src/shared/text/selectable_text_modal.dart';

/// Scrollable sliver body for the post page.
class PostPageScrollBody extends StatelessWidget {
  const PostPageScrollBody({
    super.key,
    required this.scrollController,
    required this.listController,
    required this.appBarKey,
    required this.initialPost,
    required this.viewSource,
    required this.onViewSource,
    required this.onReset,
    required this.onRetry,
    this.highlightedCommentId,
    this.commentPath,
  });

  /// Scroll controller shared by refresh, app bar reset, and FAB actions.
  final ScrollController scrollController;

  /// Controller shared by the comment list and comment navigator.
  final ListController listController;

  /// Key used by the footer to measure the app bar height.
  final GlobalKey appBarKey;

  /// Post shown while the bloc resolves the full post payload.
  final ThunderPost initialPost;

  /// Whether to show post source text.
  final bool viewSource;

  /// Called when the user toggles post-source mode.
  final ValueChanged<bool> onViewSource;

  /// Scrolls the page to the top before refresh or sort actions.
  final Future<void> Function() onReset;

  /// Called when the post error state retries loading.
  final VoidCallback onRetry;

  /// Initially highlighted comment id.
  final int? highlightedCommentId;

  /// Initially highlighted comment path.
  final String? commentPath;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: scrollController,
      scrollCacheExtent: ScrollCacheExtent.pixels(1000),
      slivers: [
        PostPageAppBar(
          key: appBarKey,
          viewSource: viewSource,
          onViewSource: onViewSource,
          onReset: onReset,
          onCreateCrossPost: () {
            final post = context.read<PostBloc>().state.post ?? initialPost;
            createCrossPost(context, title: post.name, url: post.url, text: post.body, postUrl: post.apId);
          },
          onSelectText: () {
            final post = context.read<PostBloc>().state.post ?? initialPost;
            showSelectableTextModal(context, title: post.name, text: post.body ?? '');
          },
          onPostChanged: (post) => context.read<PostBloc>().add(GetPostEvent(post: post)),
          highlightedCommentId: highlightedCommentId,
          commentPath: commentPath,
        ),
        PostPageContentSlivers(
          initialPost: initialPost,
          listController: listController,
          appBarKey: appBarKey,
          viewSource: viewSource,
          showCompactPostBody: highlightedCommentId != null,
          onRetry: onRetry,
        ),
      ],
    );
  }
}
