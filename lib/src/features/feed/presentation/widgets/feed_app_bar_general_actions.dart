import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/packages/ui/ui.dart';
import 'package:thunder/src/core/navigation/navigation_utils.dart';
import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/features/feed/feed.dart';
import 'package:thunder/src/core/config/global_context.dart';
import 'package:thunder/src/core/domain/domain.dart';
import 'package:thunder/src/shared/sort_picker.dart';

/// App bar actions shown on general listing feeds.
class FeedAppBarGeneralActions extends StatelessWidget {
  const FeedAppBarGeneralActions({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = GlobalContext.l10n;
    final feedBloc = context.read<FeedBloc>();

    return Row(
      children: [
        IconButton(
          onPressed: () {
            HapticFeedback.mediumImpact();
            triggerRefresh(context);
          },
          icon: Icon(Icons.refresh_rounded, semanticLabel: l10n.refresh),
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
        Semantics(
          label: l10n.menu,
          child: PopupMenuButton(
            onOpened: () => HapticFeedback.mediumImpact(),
            itemBuilder: (context) => [
              ThunderPopupMenuItem(
                onTap: () async {
                  HapticFeedback.mediumImpact();
                  await navigateToModlogPage(context, subtitle: context.read<ProfileBloc>().state.account.instance);
                },
                icon: Icons.shield_rounded,
                title: l10n.modlog,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
