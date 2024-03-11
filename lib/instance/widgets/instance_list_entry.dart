import 'package:flutter/material.dart';
import 'package:thunder/instance/utils/navigate_instance.dart';
import 'package:thunder/shared/avatars/instance_avatar.dart';
import 'package:thunder/utils/instance.dart';
import 'package:thunder/utils/numbers.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Creates a widget which can display a summary of an instance for a list.
/// Note that this is only Stateful so that it can be useful within an AnimatedContainer.
class InstanceListEntry extends StatefulWidget {
  final GetInstanceInfoResponse instance;

  const InstanceListEntry({super.key, required this.instance});

  @override
  State<InstanceListEntry> createState() => _InstanceListEntryState();
}

class _InstanceListEntryState extends State<InstanceListEntry> {
  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return ListTile(
      leading: InstanceAvatar(instance: widget.instance),
      title: Text(
        widget.instance.name ?? widget.instance.domain ?? '',
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Wrap(
        children: [
          Text(
            widget.instance.domain ?? '',
            overflow: TextOverflow.ellipsis,
          ),
          if (widget.instance.users != null)
            Text(
              ' · ${l10n.countUsers(formatLongNumber(widget.instance.users ?? 0))}',
              semanticsLabel: l10n.countUsers(widget.instance.users ?? 0),
            ),
          if (widget.instance.version?.isNotEmpty == true)
            Text(
              ' · v${widget.instance.version}',
              semanticsLabel: 'v${widget.instance.version}',
            ),
          if (!widget.instance.success) Text(' · ${l10n.unreachable}'),
        ],
      ),
      onTap: widget.instance.success
          ? () {
              navigateToInstancePage(
                context,
                instanceHost: widget.instance.domain ?? '',
                instanceId: widget.instance.id,
              );
            }
          : null,
    );
  }
}
