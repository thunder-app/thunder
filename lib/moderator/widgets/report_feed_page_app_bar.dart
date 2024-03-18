import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:thunder/thunder/bloc/thunder_bloc.dart';

/// The app bar for the modlog feed page
class ReportFeedPageAppBar extends StatefulWidget {
  const ReportFeedPageAppBar({super.key, required this.showAppBarTitle, required this.onShowResolved});

  /// Boolean which indicates whether the title on the app bar should be shown
  final bool showAppBarTitle;

  /// Function that is called when the user clicks on the show all button
  final void Function(bool) onShowResolved;

  @override
  State<ReportFeedPageAppBar> createState() => _ReportFeedPageAppBarState();
}

class _ReportFeedPageAppBarState extends State<ReportFeedPageAppBar> {
  /// Boolean which indicates whether the show all button should be shown
  bool showResolved = false;

  @override
  Widget build(BuildContext context) {
    final state = context.read<ThunderBloc>().state;
    final l10n = AppLocalizations.of(context)!;

    return SliverAppBar(
      pinned: !state.hideTopBarOnScroll,
      floating: true,
      centerTitle: false,
      toolbarHeight: 70.0,
      surfaceTintColor: state.hideTopBarOnScroll ? Colors.transparent : null,
      title: ModlogFeedAppBarTitle(visible: widget.showAppBarTitle),
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
      actions: [
        FilterChip(
          shape: const StadiumBorder(),
          visualDensity: VisualDensity.compact,
          label: Text('Show Resolved'),
          selected: showResolved,
          onSelected: (bool selected) {
            HapticFeedback.mediumImpact();
            setState(() => showResolved = selected);
            widget.onShowResolved(selected);
          },
        ),
        const SizedBox(width: 10),
      ],
    );
  }
}

class ModlogFeedAppBarTitle extends StatelessWidget {
  const ModlogFeedAppBarTitle({super.key, this.visible = true});

  /// Boolean which indicates whether the title on the app bar should be shown
  final bool visible;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: visible ? 1.0 : 0.0,
      child: ListTile(
        title: Text(
          l10n.report(2),
          style: theme.textTheme.titleLarge,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 0),
      ),
    );
  }
}
