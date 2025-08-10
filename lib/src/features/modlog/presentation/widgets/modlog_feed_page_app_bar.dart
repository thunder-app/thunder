import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thunder/l10n/generated/app_localizations.dart';

import 'package:thunder/src/features/modlog/modlog.dart';
import 'package:thunder/src/app/thunder.dart';
import 'package:thunder/src/shared/utils/constants.dart';

/// The app bar for the modlog feed page
class ModlogFeedPageAppBar extends StatelessWidget {
  const ModlogFeedPageAppBar({super.key, required this.subtitle});

  /// The subtitle to display below "Modlog" on the app bar
  final Widget? subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final hideTopBarOnScroll = context.select<ThunderBloc, bool>((bloc) => bloc.state.hideTopBarOnScroll);

    return SliverAppBar(
      pinned: !hideTopBarOnScroll,
      floating: true,
      centerTitle: false,
      toolbarHeight: APP_BAR_HEIGHT,
      surfaceTintColor: hideTopBarOnScroll ? Colors.transparent : null,
      title: ListTile(
        title: Text(
          l10n.modlog,
          style: theme.textTheme.titleLarge,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: subtitle,
        contentPadding: const EdgeInsets.symmetric(horizontal: 0.0),
      ),
      leading: IconButton(
        icon: (!kIsWeb && Platform.isIOS
            ? Icon(
                Icons.arrow_back_ios_new_rounded,
                semanticLabel: MaterialLocalizations.of(context).backButtonTooltip,
              )
            : Icon(Icons.arrow_back_rounded, semanticLabel: MaterialLocalizations.of(context).backButtonTooltip)),
        onPressed: () {
          HapticFeedback.mediumImpact();
          Navigator.of(context).maybePop();
        },
      ),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.filter_alt_rounded, semanticLabel: l10n.filters),
          onPressed: () {
            HapticFeedback.mediumImpact();

            showModalBottomSheet<void>(
              showDragHandle: true,
              context: context,
              isScrollControlled: true,
              builder: (builderContext) => ModlogActionTypePicker(
                title: l10n.filters,
                onSelect: (selected) async => context.read<ModlogCubit>().changeFilterType(selected.payload),
                previouslySelected: context.read<ModlogCubit>().state.modlogActionType,
              ),
            );
          },
        ),
      ],
    );
  }
}
