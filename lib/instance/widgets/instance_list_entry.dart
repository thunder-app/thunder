import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:thunder/core/models/models.dart';

import 'package:thunder/utils/navigation.dart';
import 'package:thunder/shared/avatars/instance_avatar.dart';
import 'package:thunder/utils/numbers.dart';

/// Creates a widget which can display a summary of an instance for a list.
/// Note that this is only Stateful so that it can be useful within an AnimatedContainer.
class InstanceListEntry extends StatefulWidget {
  final ThunderInstanceInfo instanceInfo;

  const InstanceListEntry({super.key, required this.instanceInfo});

  @override
  State<InstanceListEntry> createState() => _InstanceListEntryState();
}

class _InstanceListEntryState extends State<InstanceListEntry> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final instanceInfo = widget.instanceInfo;

    final name = instanceInfo.name;
    final domain = instanceInfo.domain ?? '';
    final users = instanceInfo.users ?? 0;
    final version = instanceInfo.version;

    if (!instanceInfo.success) {
      return ListTile(
        leading: InstanceAvatar(instance: instanceInfo),
        title: Text(name ?? domain, overflow: TextOverflow.ellipsis),
        subtitle: Wrap(children: [
          Text(domain, overflow: TextOverflow.ellipsis),
          Text(' · ${l10n.unreachable}'),
        ]),
        onTap: null,
      );
    }

    return ListTile(
      leading: InstanceAvatar(instance: instanceInfo),
      title: Text(name ?? domain, overflow: TextOverflow.ellipsis),
      subtitle: Wrap(
        children: [
          Text(domain, overflow: TextOverflow.ellipsis),
          if (instanceInfo.users != null) Text(' · ${l10n.countUsers(formatLongNumber(users))}', semanticsLabel: l10n.countUsers(users)),
          if (version?.isNotEmpty == true) Text(' · v$version', semanticsLabel: 'v$version'),
        ],
      ),
      onTap: () => navigateToInstancePage(context, instanceHost: domain, instanceId: instanceInfo.id),
    );
  }
}
