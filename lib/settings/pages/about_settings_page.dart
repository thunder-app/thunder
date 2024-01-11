import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thunder/feed/utils/utils.dart';
import 'package:thunder/feed/view/feed_page.dart';

import 'package:thunder/utils/links.dart';
import 'package:thunder/core/update/check_github_update.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';

class AboutSettingsPage extends StatelessWidget {
  const AboutSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    final ThunderState state = context.read<ThunderBloc>().state;

    return Scaffold(
      appBar: AppBar(centerTitle: false),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.asset('assets/logo.png', width: 196.0, height: 196.0),
            const SizedBox(height: 12.0),
            Text('Thunder', style: theme.textTheme.headlineMedium),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: FutureBuilder(
                future: getCurrentVersion(removeInternalBuildNumber: true),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Center(child: Text('Version ${snapshot.data ?? 'N/A'}'));
                  }
                  return Container();
                },
              ),
            ),
            ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                ListTile(
                  title: Text(
                    'GitHub',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text('github.com/thunder-app/thunder'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    handleLink(context, url: 'https://github.com/thunder-app/thunder');
                  },
                ),
                ListTile(
                  title: Text(
                    'Lemmy Community',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text('lemmy.world/c/thunder_app'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    navigateToFeedPage(context, feedType: FeedType.community, communityName: 'thunder_app@lemmy.world');
                  },
                ),
                ListTile(
                  title: Text(
                    'Matrix Space',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text('matrix.to/#/#thunderapp:matrix.org'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    handleLink(context, url: 'https://matrix.to/#/#thunderapp:matrix.org');
                  },
                ),
                ListTile(
                  title: Text(
                    'Licenses',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => showLicensePage(context: context),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
