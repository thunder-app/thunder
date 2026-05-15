import 'package:flutter/material.dart';

/// Sliver shown while a feed is performing its initial load.
class FeedInitialLoadingSliver extends StatelessWidget {
  const FeedInitialLoadingSliver({super.key});

  @override
  Widget build(BuildContext context) {
    return const SliverFillRemaining(
      hasScrollBody: false,
      child: Center(child: CircularProgressIndicator()),
    );
  }
}
