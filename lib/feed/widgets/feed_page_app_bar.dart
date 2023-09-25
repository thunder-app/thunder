import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:thunder/feed/bloc/feed_bloc.dart';
import 'package:thunder/feed/utils/utils.dart';
import 'package:thunder/shared/sort_picker.dart';

class FeedPageAppBar extends StatelessWidget {
  const FeedPageAppBar({super.key, this.showAppBarTitle = true});

  final bool showAppBarTitle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final FeedBloc feedBloc = context.read<FeedBloc>();

    final bool showBackAction = Navigator.of(context).canPop() && (feedBloc.state.communityId != null || feedBloc.state.communityName != null);

    return SliverAppBar(
      pinned: true,
      floating: true,
      centerTitle: false,
      toolbarHeight: 70.0,
      title: FeedAppBarTitle(visible: showAppBarTitle),
      leading: IconButton(
        icon: showBackAction ? (Platform.isAndroid ? const Icon(Icons.arrow_back_rounded) : const Icon(Icons.arrow_back_ios_new_rounded)) : const Icon(Icons.menu),
        onPressed: () => showBackAction ? Navigator.of(context).pop() : Scaffold.of(context).openDrawer(),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 8.0),
          child: IconButton(
            icon: Icon(Icons.sort, semanticLabel: l10n.sortBy),
            onPressed: () {
              showModalBottomSheet<void>(
                showDragHandle: true,
                context: context,
                builder: (builderContext) => SortPicker(
                  title: l10n.sortOptions,
                  onSelect: (selected) => feedBloc.add(FeedChangeSortTypeEvent(selected.payload)),
                  previouslySelected: feedBloc.state.sortType,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class FeedAppBarTitle extends StatelessWidget {
  const FeedAppBarTitle({super.key, this.visible = true});

  final bool visible;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final FeedBloc feedBloc = context.watch<FeedBloc>();

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: visible ? 1.0 : 0.0,
      child: ListTile(
        title: Text(
          getCommunityName(feedBloc.state),
          style: theme.textTheme.titleLarge,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Row(
          children: [
            Icon(getSortIcon(feedBloc.state), size: 13),
            const SizedBox(width: 4),
            Text(getSortName(feedBloc.state)),
          ],
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 0),
      ),
    );
  }
}
