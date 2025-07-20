import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/community/widgets/post_card_metadata.dart';
import 'package:thunder/core/enums/font_scale.dart';
import 'package:thunder/modlog/modlog.dart';
import 'package:thunder/shared/divider.dart';
import 'package:thunder/shared/text/scalable_text.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/utils/global_context.dart';

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
    final metadataFontSizeScale = context.select<ThunderBloc, FontScale>((state) => state.state.metadataFontSizeScale);
    final titleFontSizeScale = context.select<ThunderBloc, FontScale>((state) => state.state.titleFontSizeScale);
    final contentFontSizeScale = context.select<ThunderBloc, FontScale>((state) => state.state.contentFontSizeScale);

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
                  decoration: BoxDecoration(
                    color: event.getModlogEventColor().withValues(alpha: 0.2),
                    borderRadius: const BorderRadius.all(Radius.elliptical(5, 5)),
                  ),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 4.0),
                        child: Icon(
                          event.getModlogEventIcon(),
                          size: 16.0 * metadataFontSizeScale.textScaleFactor,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      ScalableText(
                        event.getModlogEventTypeName(),
                        style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                        fontScale: titleFontSizeScale,
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
                  child: ScalableText(
                    l10n.detailedReason('${event.reason}'),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    fontScale: contentFontSizeScale,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.90),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
