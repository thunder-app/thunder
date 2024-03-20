import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/core/enums/full_name_separator.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/feed/bloc/feed_bloc.dart';
import 'package:thunder/modlog/bloc/modlog_bloc.dart';
import 'package:thunder/modlog/widgets/modlog_filter_picker.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/utils/instance.dart';

/// The app bar for the modlog feed page
class ModlogFeedPageAppBar extends StatelessWidget {
  const ModlogFeedPageAppBar({super.key, required this.showAppBarTitle, required this.lemmyClient});

  /// Boolean which indicates whether the title on the app bar should be shown
  final bool showAppBarTitle;

  /// The current Lemmy client
  final LemmyClient lemmyClient;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = context.read<ThunderBloc>().state;

    return SliverAppBar(
      pinned: !state.hideTopBarOnScroll,
      floating: true,
      centerTitle: false,
      toolbarHeight: 70.0,
      surfaceTintColor: state.hideTopBarOnScroll ? Colors.transparent : null,
      title: ModlogFeedAppBarTitle(visible: showAppBarTitle, lemmyClient: lemmyClient),
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
          icon: Icon(
            Icons.filter_alt_rounded,
            semanticLabel: l10n.filters,
          ),
          onPressed: () {
            HapticFeedback.mediumImpact();

            showModalBottomSheet<void>(
              showDragHandle: true,
              context: context,
              isScrollControlled: true,
              builder: (builderContext) => ModlogActionTypePicker(
                title: l10n.filters,
                onSelect: (selected) => context.read<ModlogBloc>().add(ModlogFeedChangeFilterTypeEvent(modlogActionType: selected.payload)),
                previouslySelected: context.read<ModlogBloc>().state.modlogActionType,
              ),
            );
          },
        ),
      ],
    );
  }
}

class ModlogFeedAppBarTitle extends StatelessWidget {
  const ModlogFeedAppBarTitle({super.key, this.visible = true, required this.lemmyClient});

  /// Boolean which indicates whether the title on the app bar should be shown
  final bool visible;

  /// The current Lemmy client
  final LemmyClient lemmyClient;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final feedState = context.read<FeedBloc>().state;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: visible ? 1.0 : 0.0,
      child: ListTile(
        title: Text(
          l10n.modlog,
          style: theme.textTheme.titleLarge,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          feedState.fullCommunityView != null
              ? generateCommunityFullName(context, feedState.fullCommunityView!.communityView.community.name, fetchInstanceNameFromUrl(feedState.fullCommunityView!.communityView.community.actorId))
              : lemmyClient.lemmyApiV3.host,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 0),
      ),
    );
  }
}
