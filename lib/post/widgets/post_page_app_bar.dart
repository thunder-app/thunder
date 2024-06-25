import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:thunder/core/models/post_view_media.dart';

import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/post/bloc/post_bloc.dart';
import 'package:thunder/shared/comment_sort_picker.dart';
import 'package:thunder/shared/sort_picker.dart';
import 'package:thunder/shared/thunder_popup_menu_item.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/user/widgets/user_selector.dart';

/// Holds the app bar for the post page.
class PostPageAppBar extends StatelessWidget {
  /// Whether to show the view source button
  final bool viewSource;

  /// Callback when the view source button is pressed
  final Function(bool)? onViewSource;

  /// Callback when an action is selected which requires a reset of the post page
  final Future<void> Function()? onReset;

  /// Callback when the user wants to create a cross post
  final Function()? onCreateCrossPost;

  /// Callback when the user wants to select text
  final Function()? onSelectText;

  /// Callback for when the user changes
  final void Function()? onUserChanged;

  /// Callback for when the post changes
  final void Function(PostViewMedia)? onPostChanged;

  const PostPageAppBar({
    super.key,
    this.viewSource = false,
    this.onViewSource,
    this.onReset,
    this.onCreateCrossPost,
    this.onSelectText,
    this.onUserChanged,
    this.onPostChanged,
  });

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
      actions: [
        PostAppBarActions(
          viewSource: viewSource,
          onViewSource: onViewSource,
          onReset: onReset,
          onCreateCrossPost: onCreateCrossPost,
          onSelectText: onSelectText,
          onUserChanged: onUserChanged,
          onPostChanged: onPostChanged,
        )
      ],
    );
  }
}

/// The title of the app bar. This shows the sort type of the comments
class PostAppBarTitle extends StatelessWidget {
  const PostAppBarTitle({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final (sortType, sortIcon) = getSort(context);

    return ListTile(
      title: Text(
        l10n.comments,
        style: theme.textTheme.titleLarge,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Row(
        children: [
          Icon(sortIcon, size: 13),
          const SizedBox(width: 4),
          Text(sortType),
        ],
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
    );
  }
}

/// The actions of the post page app bar
class PostAppBarActions extends StatelessWidget {
  /// Whether to show the view source button
  final bool viewSource;

  /// Callback when the view source button is pressed
  final Function(bool)? onViewSource;

  /// Callback when an action is selected which requires a reset of the post page
  final Future<void> Function()? onReset;

  /// Callback when the user wants to create a cross post
  final Function()? onCreateCrossPost;

  /// Callback when the user wants to select text
  final Function()? onSelectText;

  /// Callback for when the user changes
  final void Function()? onUserChanged;

  /// Callback for when the post changes
  final void Function(PostViewMedia)? onPostChanged;

  const PostAppBarActions({
    super.key,
    this.viewSource = false,
    this.onViewSource,
    this.onReset,
    this.onCreateCrossPost,
    this.onSelectText,
    this.onUserChanged,
    this.onPostChanged,
  });

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
            ThunderPopupMenuItem(
              onTap: onCreateCrossPost,
              icon: Icons.repeat_rounded,
              title: l10n.createNewCrossPost,
            ),
            ThunderPopupMenuItem(
              onTap: () => onViewSource?.call(!viewSource),
              icon: Icons.edit_document,
              title: viewSource ? l10n.viewOriginal : l10n.viewPostSource,
            ),
            ThunderPopupMenuItem(
              onTap: onSelectText,
              icon: Icons.select_all_rounded,
              title: l10n.selectText,
            ),
            ThunderPopupMenuItem(
              onTap: () async {
                await temporarilySwitchAccount(
                  context,
                  profileModalHeading: l10n.viewPostAsDifferentAccount,
                  onUserChanged: onUserChanged,
                  postActorId: context.read<PostBloc>().state.postView?.postView.post.apId,
                  onPostChanged: onPostChanged,
                );
              },
              icon: Icons.people_alt_rounded,
              title: l10n.viewPostAsDifferentAccount,
            ),
          ],
        ),
      ],
    );
  }
}

(String, IconData?) getSort(BuildContext context) {
  final state = context.watch<PostBloc>().state;

  if (state.status == PostStatus.initial) {
    return ('', null);
  }

  final sortTypeItemIndex = CommentSortPicker.getCommentSortTypeItems(minimumVersion: LemmyClient.instance.version).indexWhere((sortTypeItem) => sortTypeItem.payload == state.sortType);
  final sortTypeItem = sortTypeItemIndex > -1 ? allSortTypeItems[sortTypeItemIndex] : null;

  return (sortTypeItem?.label ?? '', sortTypeItem?.icon);
}
