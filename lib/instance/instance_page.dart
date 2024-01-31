import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/instance/bloc/instance_bloc.dart';
import 'package:thunder/instance/enums/instance_action.dart';
import 'package:thunder/instance/instance_view.dart';
import 'package:thunder/shared/snackbar.dart';
import 'package:thunder/utils/instance.dart';
import 'package:thunder/utils/links.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:thunder/utils/numbers.dart';

class InstancePage extends StatefulWidget {
  final GetSiteResponse getSiteResponse;
  final bool? isBlocked;

  // This is needed (in addition to Site) specifically for blocking.
  // Since site is requested directly from the target instance, its ID is only right on its own server
  // But it's wrong on the server we're connected to.
  final int? instanceId;

  const InstancePage({
    super.key,
    required this.getSiteResponse,
    required this.isBlocked,
    required this.instanceId,
  });

  @override
  State<InstancePage> createState() => _InstancePageState();
}

class _InstancePageState extends State<InstancePage> {
  final GlobalKey<ScaffoldMessengerState> _key = GlobalKey<ScaffoldMessengerState>();
  bool? isBlocked;
  bool currentlyTogglingBlock = false;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final ThemeData theme = Theme.of(context);

    isBlocked ??= widget.isBlocked ?? false;

    return BlocListener<InstanceBloc, InstanceState>(
      listener: (context, state) {
        if (state.message != null) {
          showSnackbar(context, state.message!);
        }

        if (state.status == InstanceStatus.success && currentlyTogglingBlock) {
          currentlyTogglingBlock = false;
          setState(() {
            isBlocked = !isBlocked!;
          });
        }
      },
      child: ScaffoldMessenger(
        key: _key,
        child: Scaffold(
          body: Container(
            color: theme.colorScheme.background,
            child: SafeArea(
              top: false,
              child: CustomScrollView(
                slivers: <Widget>[
                  SliverAppBar(
                    pinned: true,
                    title: ListTile(
                      title: Text(
                        fetchInstanceNameFromUrl(widget.getSiteResponse.siteView.site.actorId) ?? '',
                        style: theme.textTheme.titleLarge,
                      ),
                      subtitle: Text("v${widget.getSiteResponse.version} · ${l10n.countUsers(formatLongNumber(widget.getSiteResponse.siteView.counts.users))}"),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                    ),
                    actions: [
                      if (LemmyClient.instance.supportsFeature(LemmyFeature.blockInstance) && widget.instanceId != null)
                        IconButton(
                          tooltip: isBlocked! ? l10n.unblockInstance : l10n.blockInstance,
                          onPressed: () {
                            currentlyTogglingBlock = true;
                            context.read<InstanceBloc>().add(InstanceActionEvent(
                                  instanceAction: InstanceAction.block,
                                  instanceId: widget.instanceId!,
                                  domain: fetchInstanceNameFromUrl(widget.getSiteResponse.siteView.site.actorId),
                                  value: !isBlocked!,
                                ));
                          },
                          icon: Icon(
                            isBlocked! ? Icons.undo_rounded : Icons.block,
                            semanticLabel: isBlocked! ? l10n.unblockInstance : l10n.blockInstance,
                          ),
                        ),
                      IconButton(
                        tooltip: l10n.openInBrowser,
                        onPressed: () => handleLink(context, url: widget.getSiteResponse.siteView.site.actorId),
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
                        child: InstanceView(site: widget.getSiteResponse.siteView.site),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
