import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

import 'package:thunder/src/core/config/global_context.dart';
import 'package:thunder/src/core/domain/domain.dart';
import 'package:thunder/src/shared/markdown/common_markdown_body.dart';
import 'package:thunder/src/shared/avatars/instance_avatar.dart';
import 'package:thunder/packages/ui/ui.dart';

/// A widget that displays information about a given instance.
class InstanceInformation extends StatelessWidget {
  /// Information about the instance.
  final ThunderInstanceInfo instance;

  const InstanceInformation({super.key, required this.instance});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = GlobalContext.l10n;

    return Column(
      children: [
        Row(
          spacing: 16.0,
          children: [
            InstanceAvatar(
              radius: 24.0,
              instance: instance,
            ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    instance.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  Flexible(
                    child: Text(
                      instance.description ?? '-',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (instance.sidebar?.isNotEmpty == true) ...[
          const ThunderDivider(sliver: false, padding: false),
          const SizedBox(height: 8.0),
          Row(
            spacing: 6.0,
            children: [
              Badge(
                label: Text(instance.platform?.displayName ?? '-'),
                backgroundColor: theme.colorScheme.primary,
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              ),
              Badge(
                label: Text('v${instance.version ?? '-'}'),
                backgroundColor: theme.colorScheme.secondary,
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              ),
              Badge(
                label: Text(l10n.countUsers(NumberFormat.decimalPattern(l10n.localeName).format(instance.users ?? 0))),
                backgroundColor: theme.colorScheme.tertiary,
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          CommonMarkdownBody(body: instance.sidebar ?? '-'),
        ],
      ],
    );
  }
}
