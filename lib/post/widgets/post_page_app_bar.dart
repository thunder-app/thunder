import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thunder/localizations/app_localizations.dart';
import 'package:lemmy_api_client/src/v3/enums/comment_sort_type.dart';
import 'package:thunder/core/enums/media_type.dart';
import 'package:thunder/core/models/models.dart';

import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/post/bloc/post_bloc.dart';
import 'package:thunder/shared/comment_sort_picker.dart';
import 'package:thunder/shared/thunder_popup_menu_item.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/user/widgets/user_selector.dart';
import 'package:thunder/utils/bottom_sheet_list_picker.dart';
import 'package:thunder/utils/constants.dart';
import 'package:thunder/utils/links.dart';

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
  final void Function(ThunderPost post)? onPostChanged;

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
      toolbarHeight: APP_BAR_HEIGHT,
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
class PostAppBarTitle extends StatefulWidget {
  const PostAppBarTitle({super.key});

  @override
  State<PostAppBarTitle> createState() => _PostAppBarTitleState();
}

class _PostAppBarTitleState extends State<PostAppBarTitle> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final (sortType, sortIcon) = getSort(context);
    final hasSubtitle = sortType.isNotEmpty && sortIcon != null;

    return SizedBox(
      height: 56,
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            top: hasSubtitle ? 2 : 16,
            left: 0,
            child: Text(
              l10n.comments,
              style: theme.textTheme.titleLarge,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (hasSubtitle)
            Positioned(
              left: 0,
              bottom: 6,
              child: Row(
                children: [
                  Icon(sortIcon, size: 13),
                  const SizedBox(width: 4),
                  Text(sortType, style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
        ],
      ),
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
  final void Function(ThunderPost post)? onPostChanged;

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
            if (context.mounted) context.read<PostBloc>().add(GetPostEvent(post: state.post));
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
        Semantics(
          label: l10n.menu,
          child: PopupMenuButton(
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
                    postActorId: context.read<PostBloc>().state.post?.url,
                    onPostChanged: onPostChanged,
                  );
                },
                icon: Icons.people_alt_rounded,
                title: l10n.viewPostAsDifferentAccount,
              ),
              if (state.post?.media.first.mediaType == MediaType.link && state.post!.media.first.originalUrl?.isNotEmpty == true)
                ThunderPopupMenuItem(
                  onTap: () {
                    handleLinkLongPress(
                      context,
                      state.post!.media.first.originalUrl!,
                      state.post!.media.first.originalUrl!,
                      initialPage: LinkBottomSheetPage.alternateLinks,
                    );
                  },
                  icon: Icons.link_rounded,
                  title: l10n.alternateSources,
                ),
            ],
          ),
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

  ListPickerItem<CommentSortType>? sortTypeItem =
      CommentSortPicker.getCommentSortTypeItems(minimumVersion: LemmyClient.instance.version).firstWhereOrNull((sortTypeItem) => sortTypeItem.payload == state.sortType);

  return (sortTypeItem?.label ?? '', sortTypeItem?.icon);
}
