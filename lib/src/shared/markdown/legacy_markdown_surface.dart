import 'package:flutter/material.dart' as legacy; // ignore: deprecated_member_use, migrate_design_widgets
import 'package:flutter/widgets.dart';

/// Provides a legacy Material ancestor for flutter_markdown widgets.
class LegacyMarkdownSurface extends StatelessWidget {
  const LegacyMarkdownSurface({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => legacy.Material(type: legacy.MaterialType.transparency, child: child);
}
