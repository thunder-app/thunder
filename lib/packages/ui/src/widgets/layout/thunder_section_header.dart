import 'package:flutter/material.dart';

import 'package:thunder/packages/ui/src/widgets/layout/thunder_section_divider.dart';
import 'package:thunder/packages/ui/src/widgets/layout/thunder_section_title.dart';

/// Layout variant for [ThunderSectionHeader].
enum ThunderSectionHeaderVariant {
  /// Compact sidebar header with a trailing divider.
  sidebar,

  /// Settings-style header with optional description and actions.
  settings,

  /// Sliver header with extra top padding.
  sliver,
}

/// Composable section header for sidebars, settings groups, and sliver lists.
@immutable
class ThunderSectionHeader extends StatelessWidget {
  const ThunderSectionHeader({
    super.key,
    required this.title,
    this.description,
    this.actions = const [],
    this.variant = ThunderSectionHeaderVariant.settings,
    this.padding,
  });

  /// Section title text.
  final String title;

  /// Optional description shown below [title].
  final String? description;

  /// Trailing action widgets for the sliver variant.
  final List<Widget> actions;

  /// Layout style for this header.
  final ThunderSectionHeaderVariant variant;

  /// Outer padding. Defaults vary by [variant].
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    switch (variant) {
      case ThunderSectionHeaderVariant.sidebar:
        return Padding(
          padding: padding ?? const EdgeInsets.only(top: 12.0, bottom: 8.0, left: 8.0, right: 8.0),
          child: Row(
            children: [
              Expanded(
                child: ThunderSectionTitle(title: title, description: description),
              ),
              const ThunderSectionDivider(),
            ],
          ),
        );
      case ThunderSectionHeaderVariant.settings:
        return ThunderSectionTitle(
          title: title,
          description: description,
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        );
      case ThunderSectionHeaderVariant.sliver:
        return SliverToBoxAdapter(
          child: Padding(
            padding: padding ?? const EdgeInsets.only(top: 12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: ThunderSectionTitle(
                    title: title,
                    description: description,
                  ),
                ),
                ...actions,
              ],
            ),
          ),
        );
    }
  }
}
