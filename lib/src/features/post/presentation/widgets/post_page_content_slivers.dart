import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:super_sliver_list/super_sliver_list.dart';

import 'package:thunder/packages/ui/ui.dart';
import 'package:thunder/src/features/post/post.dart';
import 'package:thunder/src/features/post/presentation/widgets/post_body_sliver.dart';
import 'package:thunder/src/features/post/presentation/widgets/post_bottom_sliver.dart';
import 'package:thunder/src/features/post/presentation/widgets/post_comments_sliver.dart';
import 'package:thunder/src/foundation/config/global_context.dart';

/// Selects the post-page content branch and delegates each branch to slivers.
class PostPageContentSlivers extends StatelessWidget {
  const PostPageContentSlivers({
    super.key,
    required this.initialPost,
    required this.listController,
    required this.appBarKey,
    required this.viewSource,
    required this.showCompactPostBody,
    required this.onRetry,
  });

  /// Post shown before the full post response arrives.
  final ThunderPost initialPost;

  /// Controller shared with the comment list.
  final ListController listController;

  /// Key for measuring the app bar when building the footer spacer.
  final GlobalKey appBarKey;

  /// Whether the post body should render source text.
  final bool viewSource;

  /// Whether the post body should use compact highlighted-comment layout.
  final bool showCompactPostBody;

  /// Called when the user retries a failed post load.
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PostBloc, PostState>(
      buildWhen: (previous, current) =>
          previous.status != current.status || previous.post != current.post || previous.crossPosts != current.crossPosts || previous.errorMessage != current.errorMessage,
      builder: (context, state) {
        if (state.status == PostPageStatus.initial || state.status == PostPageStatus.loading) {
          return const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (state.status == PostPageStatus.failure) {
          final l10n = GlobalContext.l10n;
          return SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: ThunderStateView(
                title: l10n.unableToLoadPost,
                message: l10n.internetOrInstanceIssues,
                actions: [
                  ThunderStateAction(
                    label: l10n.retry,
                    onPressed: onRetry,
                    primary: true,
                  ),
                ],
              ),
            ),
          );
        }

        final post = state.post ?? initialPost;
        return SliverMainAxisGroup(
          slivers: [
            PostBodySliver(
              post: post,
              crossPosts: state.crossPosts,
              viewSource: viewSource,
              showCompactPostBody: showCompactPostBody,
            ),
            PostCommentsSliver(listController: listController),
            PostBottomSliver(
              appBarKey: appBarKey,
              postKey: initialPost.apId,
            ),
          ],
        );
      },
    );
  }
}
