import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/src/app/utils/global_context.dart';
import 'package:thunder/src/app/utils/navigation.dart';
import 'package:thunder/src/core/enums/search_sort_type.dart';
import 'package:thunder/src/core/enums/threadiverse_platform.dart';
import 'package:thunder/src/core/models/models.dart';
import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/features/instance/instance.dart';
import 'package:thunder/src/shared/snackbar.dart';
import 'package:thunder/src/shared/sort_picker.dart';
import 'package:thunder/src/shared/utils/constants.dart';
import 'package:thunder/src/shared/utils/links.dart';
import 'package:thunder/src/shared/widgets/thunder_popup_menu_item.dart';

class InstancePageAppBar extends StatefulWidget {
  /// The instance being displayed.
  final ThunderInstanceInfo instance;

  /// The sort type for the instance's data.
  final SearchSortType searchSortType;

  /// The account being used.
  final Account account;

  /// Callback for when the sort type is changed.
  final Function(SearchSortType sortType) onSortSelected;

  /// Widget to be displayed at the bottom of the app bar.
  final PreferredSizeWidget? bottom;

  /// Callback for when the query is changed.
  final Function(String query) onQueryChanged;

  const InstancePageAppBar({
    super.key,
    required this.instance,
    required this.searchSortType,
    required this.account,
    required this.onSortSelected,
    required this.onQueryChanged,
    this.bottom,
  });

  @override
  State<InstancePageAppBar> createState() => _InstancePageAppBarState();
}

class _InstancePageAppBarState extends State<InstancePageAppBar> {
  /// The timer for debouncing the search bar.
  Timer? _debounceTimer;

  /// The controller for the search bar.
  TextEditingController queryController = TextEditingController();

  @override
  void dispose() {
    _debounceTimer?.cancel();
    queryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = GlobalContext.l10n;
    final account = context.read<ProfileBloc>().state.account;

    final instanceHost = Uri.parse(widget.instance.domain).host;

    final blockedInstances = context.watch<ProfileBloc>().state.siteResponse?.myUser?.instanceBlocks;
    final blocked = blockedInstances?.any((i) => instanceHost.contains(i.instance['domain'])) ?? false;

    return SliverAppBar(
      pinned: true,
      toolbarHeight: APP_BAR_HEIGHT,
      bottom: widget.bottom,
      automaticallyImplyLeading: false,
      title: SearchBar(
        controller: queryController,
        hintText: l10n.searchInstance(instanceHost),
        elevation: WidgetStateProperty.all(0),
        onChanged: (query) {
          if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
          _debounceTimer = Timer(const Duration(milliseconds: 500), () {
            widget.onQueryChanged(query);
          });
        },
        leading: IconButton(
          icon: Icon(Icons.arrow_back, semanticLabel: l10n.back),
          onPressed: () {
            HapticFeedback.mediumImpact();
            Navigator.pop(context);
          },
        ),
        trailing: [
          IconButton(
            icon: Icon(Icons.sort, semanticLabel: l10n.sortBy),
            onPressed: () {
              HapticFeedback.mediumImpact();

              showModalBottomSheet<void>(
                showDragHandle: true,
                context: context,
                isScrollControlled: true,
                builder: (builderContext) => SortPicker<SearchSortType>(
                  account: account,
                  title: l10n.sortOptions,
                  onSelect: (selected) async {
                    widget.onSortSelected(selected.payload);
                  },
                  previouslySelected: widget.searchSortType,
                ),
              );
            },
          ),
          Semantics(
            label: l10n.menu,
            child: PopupMenuButton(
              itemBuilder: (context) => [
                if (widget.instance.id != null && !widget.account.anonymous && !instanceHost.contains(account.instance))
                  ThunderPopupMenuItem(
                    title: blocked ? l10n.unblockInstance : l10n.blockInstance,
                    icon: blocked ? Icons.undo_rounded : Icons.block,
                    onTap: () async {
                      final repository = InstanceRepositoryImpl(account: widget.account);
                      final success = await repository.block(widget.instance.id!, !blocked);

                      // Update the profile bloc state.
                      context.read<ProfileBloc>().add(FetchProfileSettings());

                      if (context.mounted) {
                        if (success) {
                          showSnackbar(l10n.successfullyBlockedCommunity(widget.instance.name));
                        } else {
                          showSnackbar(l10n.successfullyUnblockedCommunity(widget.instance.name));
                        }
                      }
                    },
                  ),
                if (widget.instance.platform == ThreadiversePlatform.lemmy)
                  ThunderPopupMenuItem(
                    title: l10n.modlog,
                    icon: Icons.shield_rounded,
                    onTap: () async {
                      HapticFeedback.mediumImpact();
                      navigateToModlogPage(context, subtitle: widget.instance.name);
                    },
                  ),
                ThunderPopupMenuItem(
                  title: l10n.openInBrowser,
                  icon: Icons.open_in_browser_rounded,
                  onTap: () => handleLink(context, url: widget.instance.domain),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
