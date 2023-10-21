import 'package:flutter/material.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:thunder/instance/instance_view.dart';
import 'package:thunder/utils/instance.dart';
import 'package:thunder/utils/links.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class InstancePage extends StatefulWidget {
  final Site site;

  const InstancePage({
    super.key,
    required this.site,
  });

  @override
  State<InstancePage> createState() => _InstancePageState();
}

class _InstancePageState extends State<InstancePage> {
  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final ThemeData theme = Theme.of(context);

    return Container(
      color: theme.colorScheme.background,
      child: SafeArea(
        top: false,
        child: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              pinned: true,
              title: Text(fetchInstanceNameFromUrl(widget.site.actorId) ?? ''),
              actions: [
                IconButton(
                  tooltip: l10n.openInBrowser,
                  onPressed: () => openLink(context, url: widget.site.actorId),
                  icon: Icon(
                    Icons.open_in_browser_rounded,
                    semanticLabel: l10n.openInBrowser,
                  ),
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Material(
                  child: InstanceView(site: widget.site),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
