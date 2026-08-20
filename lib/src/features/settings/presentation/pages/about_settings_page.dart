import 'package:flutter/material.dart';

import 'package:url_launcher/url_launcher.dart';

import 'package:thunder/src/core/config/config.dart';
import 'package:thunder/src/core/config/global_context.dart';
import 'package:thunder/src/features/feed/feed.dart';
import 'package:thunder/src/core/domain/domain.dart';
import 'package:thunder/src/core/services/app_version_service.dart';
import 'package:thunder/src/core/navigation/navigation_utils.dart';
import 'package:thunder/src/core/navigation/link_navigation_utils.dart';

class AboutSettingsPage extends StatelessWidget {
  final LocalSettings? settingToHighlight;

  const AboutSettingsPage({super.key, this.settingToHighlight});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = GlobalContext.l10n;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(toolbarHeight: APP_BAR_HEIGHT, pinned: true),
          SliverList.list(
            children: [
              Image.asset('assets/logo.png', width: 196.0, height: 196.0),
              const SizedBox(height: 12.0),
              Align(
                alignment: Alignment.center,
                child: Text('Thunder', style: theme.textTheme.headlineMedium),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(child: Text(l10n.versionNumber(getCurrentVersion(removeInternalBuildNumber: true)))),
              ),
              ListTile(
                title: Text('GitHub', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                subtitle: const Text('github.com/thunder-app/thunder'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  handleLink(context, url: 'https://github.com/thunder-app/thunder');
                },
              ),
              ListTile(
                title: Text('Lemmy Community', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                subtitle: const Text('lemmy.world/c/thunder_app'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  navigateToFeedPage(context, feedType: FeedType.community, communityName: 'thunder_app@lemmy.world');
                },
              ),
              ListTile(
                title: Text('Matrix Space', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                subtitle: const Text('matrix.to/#/#thunderapp:matrix.org'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  handleLink(context, url: 'https://matrix.to/#/#thunderapp:matrix.org');
                },
              ),
              ListTile(
                title: Text('Support', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                subtitle: const Text('thunderapp@proton.me'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  launchUrl(Uri.parse('mailto:thunderapp@proton.me'));
                },
              ),
              ListTile(
                title: Text('Licenses', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => showLicensePage(context: context),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
