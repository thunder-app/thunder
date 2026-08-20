import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/src/features/community/community.dart';
import 'package:thunder/src/core/domain/domain.dart';
import 'package:thunder/src/features/modlog/modlog.dart';
import 'package:thunder/src/features/settings/api.dart';
import 'package:thunder/src/core/config/global_context.dart';
import 'package:thunder/packages/ui/ui.dart';

/// Widget to display a single modlog event item
class ModlogItemCard extends StatelessWidget {
  /// The modlog event item to display
  final ModlogEventItem event;

  const ModlogItemCard({super.key, required this.event});

  /// Returns the name of the moderator or admin of the modlog event if it exists
  String getModeratorName(ModlogEventItem modlogEventItem) {
    final l10n = GlobalContext.l10n;

    if (modlogEventItem.moderator != null) {
      return l10n.performedBy(modlogEventItem.moderator!.displayNameOrName);
    }

    if (modlogEventItem.admin != null) {
      return l10n.performedBy(modlogEventItem.admin!.displayNameOrName);
    }

    switch (modlogEventItem.type) {
      case ModlogActionType.adminPurgeComment:
      case ModlogActionType.adminPurgePost:
      case ModlogActionType.adminPurgeCommunity:
      case ModlogActionType.adminPurgePerson:
        return l10n.performedBy(l10n.admin);
      default:
        return l10n.performedBy(l10n.moderator(1));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = GlobalContext.l10n;

    final modName = getModeratorName(event);
    final metadataFontSizeScale = context.select<ThemePreferencesCubit, FontScale>((cubit) => cubit.state.metadataFontSizeScale);
    final titleFontSizeScale = context.select<ThemePreferencesCubit, FontScale>((cubit) => cubit.state.titleFontSizeScale);
    final contentFontSizeScale = context.select<ThemePreferencesCubit, FontScale>((cubit) => cubit.state.contentFontSizeScale);

    return Column(
      children: [
        ThunderDivider(sliver: false, padding: false),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Tooltip(
                message: modName,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                  decoration: BoxDecoration(color: event.getModlogEventColor().withValues(alpha: 0.2), borderRadius: const BorderRadius.all(Radius.elliptical(5, 5))),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 4.0),
                        child: Icon(event.getModlogEventIcon(), size: 16.0 * metadataFontSizeScale.textScaleFactor, color: theme.colorScheme.onSurface),
                      ),
                      ThunderScalableText(
                        event.getModlogEventTypeName(),
                        style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                        textScaleFactor: titleFontSizeScale.textScaleFactor,
                      ),
                    ],
                  ),
                ),
              ),
              DateTimePostCardMetaData(dateTime: event.dateTime),
            ],
          ),
        ),
        ModlogItemContextCard(type: event.type, post: event.post, comment: event.comment, community: event.community, user: event.user),
        if (event.reason != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Divider(thickness: 1.0, color: theme.dividerColor.withValues(alpha: 0.3)),
                Padding(
                  padding: const EdgeInsets.only(bottom: 6.0),
                  child: ThunderScalableText(
                    l10n.detailedReason('${event.reason}'),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    textScaleFactor: contentFontSizeScale.textScaleFactor,
                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.90)),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
