import 'package:material_ui/material_ui.dart';

import 'package:thunder/packages/ui/ui.dart';

/// Sliver shown while a feed is performing its initial load.
class FeedInitialLoadingSliver extends StatelessWidget {
  const FeedInitialLoadingSliver({super.key});

  @override
  Widget build(BuildContext context) {
    return const ThunderStateView.loading(sliver: true);
  }
}
