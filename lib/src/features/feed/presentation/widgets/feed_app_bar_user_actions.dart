import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/src/features/feed/feed.dart';
import 'package:thunder/src/core/config/global_context.dart';
import 'package:thunder/src/core/domain/domain.dart';
import 'package:thunder/src/shared/sort_picker.dart';

/// App bar actions shown on user feeds.
class FeedAppBarUserActions extends StatelessWidget {
  const FeedAppBarUserActions({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = GlobalContext.l10n;
    final feedBloc = context.read<FeedBloc>();

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, semanticLabel: l10n.refresh),
            onPressed: () {
              HapticFeedback.mediumImpact();
              triggerRefresh(context);
            },
          ),
          IconButton(
            icon: Icon(Icons.sort, semanticLabel: l10n.sortBy),
            onPressed: () {
              HapticFeedback.mediumImpact();
              showModalBottomSheet<void>(
                showDragHandle: true,
                context: context,
                isScrollControlled: true,
                builder: (builderContext) => SortPicker<PostSortType>(
                  account: feedBloc.account,
                  title: l10n.sortOptions,
                  onSelect: (selected) async => feedBloc.add(FeedChangePostSortTypeEvent(selected.payload)),
                  previouslySelected: feedBloc.state.postSortType,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
