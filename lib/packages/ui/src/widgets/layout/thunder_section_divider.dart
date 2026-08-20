import 'package:flutter/material.dart';

import 'package:thunder/packages/ui/src/theme/thunder_theme.dart';

/// Trailing divider used in sidebar-style section headers.
@immutable
class ThunderSectionDivider extends StatelessWidget {
  const ThunderSectionDivider({super.key, this.indent, this.height = 5.0, this.thickness = 2.0});

  /// Leading indent. Defaults to the theme sidebar indent.
  final double? indent;

  /// Divider height.
  final double height;

  /// Divider line thickness.
  final double thickness;

  @override
  Widget build(BuildContext context) {
    final thunderTheme = ThunderTheme.of(context);

    return Expanded(
      child: Divider(height: height, thickness: thickness, indent: indent ?? thunderTheme.sidebarDividerIndent),
    );
  }
}
