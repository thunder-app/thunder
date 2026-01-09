import 'package:flutter/material.dart';

import 'package:thunder/src/app/utils/global_context.dart';
import 'package:thunder/src/core/models/models.dart';
import 'package:thunder/src/app/utils/navigation.dart';
import 'package:thunder/src/shared/widgets/avatars/instance_avatar.dart';
import 'package:thunder/src/shared/utils/numbers.dart';

/// Creates a widget which can display a summary of an instance for a list.
class InstanceListEntry extends StatefulWidget {
  /// The instance to display.
  final ThunderInstanceInfo instance;

  const InstanceListEntry({super.key, required this.instance});

  @override
  State<InstanceListEntry> createState() => _InstanceListEntryState();
}

class _InstanceListEntryState extends State<InstanceListEntry> {
  @override
  Widget build(BuildContext context) {
    final l10n = GlobalContext.l10n;

    final name = widget.instance.name;
    final domain = widget.instance.domain;
    final users = widget.instance.users ?? 0;
    final version = widget.instance.version;

    if (!widget.instance.success) {
      return ListTile(
        leading: InstanceAvatar(instance: widget.instance),
        title: Text(name.isNotEmpty ? name : domain, overflow: TextOverflow.ellipsis),
        subtitle: Wrap(
          children: [
            Text(domain, overflow: TextOverflow.ellipsis),
            Text(' · ${l10n.unreachable}'),
          ],
        ),
        onTap: null,
      );
    }

    return ListTile(
      leading: InstanceAvatar(instance: widget.instance),
      title: Text(name.isNotEmpty ? name : domain, overflow: TextOverflow.ellipsis),
      subtitle: Wrap(
        children: [
          Text(domain, overflow: TextOverflow.ellipsis),
          if (widget.instance.users != null) Text(' · ${l10n.countUsers(formatLongNumber(users))}', semanticsLabel: l10n.countUsers(users)),
          if (version?.isNotEmpty == true) Text(' · v$version', semanticsLabel: 'v$version'),
        ],
      ),
      onTap: () => navigateToInstancePage(context, instanceHost: domain, instanceId: widget.instance.id),
    );
  }
}
