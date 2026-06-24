import 'package:flutter/material.dart';

/// Displays a transparent sliver header for a profile-modal section.
class ProfileSectionHeader extends StatelessWidget {
  const ProfileSectionHeader({
    super.key,
    required this.title,
    required this.actions,
  });

  /// Text displayed as the section heading.
  final String title;

  /// Actions displayed at the trailing edge of the header.
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      title: Text(title),
      centerTitle: false,
      scrolledUnderElevation: 0,
      pinned: false,
      forceMaterialTransparency: true,
      actions: actions,
    );
  }
}
