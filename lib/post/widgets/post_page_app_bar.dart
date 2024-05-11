import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/post/bloc/post_bloc.dart';
import 'package:thunder/shared/comment_sort_picker.dart';
import 'package:thunder/shared/sort_picker.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';

/// Holds the app bar for the post page.
class PostPageAppBar extends StatelessWidget {
  /// Callback when an action is selected which requires a reset of the post page
  final Future<void> Function()? onReset;

  const PostPageAppBar({super.key, this.onReset});

  @override
  Widget build(BuildContext context) {
    final state = context.read<ThunderBloc>().state;

    return SliverAppBar(
      pinned: !state.hideTopBarOnScroll,
      floating: true,
      centerTitle: false,
      toolbarHeight: 70.0,
      surfaceTintColor: state.hideTopBarOnScroll ? Colors.transparent : null,
      title: const PostAppBarTitle(),
      actions: [PostAppBarActions(onReset: onReset)],
    );
  }
}

/// The title of the app bar. This shows the title (feed type, community, user) and the sort type
class PostAppBarTitle extends StatelessWidget {
  const PostAppBarTitle({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return ListTile(
      title: Text(
        l10n.comments,
        style: theme.textTheme.titleLarge,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Row(
        children: [
          Icon(getSortIcon(context), size: 13),
          const SizedBox(width: 4),
          Text(getSortName(context)),
        ],
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
    );
  }
}

/// The actions of the post page app bar
class PostAppBarActions extends StatelessWidget {
  /// Callback when an action is selected which requires a reset of the post page
  final Future<void> Function()? onReset;

  const PostAppBarActions({super.key, this.onReset});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = context.watch<PostBloc>().state;

    return Row(
      children: [
        IconButton(
          icon: Icon(Icons.refresh, semanticLabel: l10n.refresh),
          onPressed: () async {
            HapticFeedback.mediumImpact();
            await onReset?.call();
            if (context.mounted) context.read<PostBloc>().add(GetPostEvent(postView: state.postView));
          },
        ),
        IconButton(
          icon: Icon(Icons.sort, semanticLabel: l10n.sortBy),
          onPressed: () {
            HapticFeedback.mediumImpact();

            showModalBottomSheet<void>(
              showDragHandle: true,
              context: context,
              builder: (builderContext) => CommentSortPicker(
                title: l10n.sortOptions,
                onSelect: (selected) async {
                  await onReset?.call();
                  if (context.mounted) context.read<PostBloc>().add(GetPostCommentsEvent(sortType: selected.payload, reset: true));
                },
                previouslySelected: state.sortType,
                minimumVersion: LemmyClient.instance.version,
              ),
            );
          },
        ),
        PopupMenuButton(
          itemBuilder: (context) => [
            //     if (feedBloc.state.fullCommunityView?.communityView.community.actorId != null)
            //       ThunderPopupMenuItem(
            //         onTap: () => showCommunityShareSheet(context, feedBloc.state.fullCommunityView!.communityView),
            //         icon: Icons.share_rounded,
            //         title: l10n.share,
            //       ),
            //     if (feedBloc.state.fullCommunityView?.communityView != null)
            //       ThunderPopupMenuItem(
            //         onTap: () async {
            //           final ThunderState state = context.read<ThunderBloc>().state;
            //           final bool reduceAnimations = state.reduceAnimations;
            //           final SearchBloc searchBloc = SearchBloc();

            //           await Navigator.of(context).push(
            //             SwipeablePageRoute(
            //               transitionDuration: reduceAnimations ? const Duration(milliseconds: 100) : null,
            //               backGestureDetectionWidth: 45,
            //               canOnlySwipeFromEdge: true,
            //               builder: (context) => MultiBlocProvider(
            //                 providers: [
            //                   // Create a new SearchBloc so it doesn't conflict with the main one
            //                   BlocProvider.value(value: searchBloc),
            //                   BlocProvider.value(value: thunderBloc),
            //                 ],
            //                 child: SearchPage(communityToSearch: feedBloc.state.fullCommunityView!.communityView, isInitiallyFocused: true),
            //               ),
            //             ),
            //           );
            //         },
            //         icon: Icons.search_rounded,
            //         title: l10n.search,
            //       ),
            //     ThunderPopupMenuItem(
            //       onTap: () async {
            //         await navigateToModlogPage(
            //           context,
            //           feedBloc: feedBloc,
            //           communityId: feedBloc.state.fullCommunityView!.communityView.community.id,
            //         );
            //       },
            //       icon: Icons.shield_rounded,
            //       title: l10n.modlog,
            //     ),
          ],
        ),
      ],
    );
  }
}

String getSortName(BuildContext context) {
  final state = context.watch<PostBloc>().state;

  if (state.status == PostStatus.initial) {
    return '';
  }

  final sortTypeItemIndex = CommentSortPicker.getCommentSortTypeItems(minimumVersion: LemmyClient.instance.version).indexWhere((sortTypeItem) => sortTypeItem.payload == state.sortType);
  final sortTypeItem = sortTypeItemIndex > -1 ? allSortTypeItems[sortTypeItemIndex] : null;

  return sortTypeItem?.label ?? '';
}

IconData? getSortIcon(BuildContext context) {
  final state = context.watch<PostBloc>().state;

  if (state.status == PostStatus.initial) {
    return null;
  }

  final sortTypeItemIndex = CommentSortPicker.getCommentSortTypeItems(minimumVersion: LemmyClient.instance.version).indexWhere((sortTypeItem) => sortTypeItem.payload == state.sortType);
  final sortTypeItem = sortTypeItemIndex > -1 ? allSortTypeItems[sortTypeItemIndex] : null;

  return sortTypeItem?.icon;
}
