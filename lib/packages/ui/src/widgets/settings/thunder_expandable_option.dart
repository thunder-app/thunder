import 'package:flutter/material.dart';

import 'package:thunder/packages/ui/src/widgets/settings/thunder_settings_tile.dart';
import 'package:thunder/packages/ui/src/widgets/settings/thunder_settings_trailing.dart';

/// Expandable settings section with a chevron header and animated child content.
class ThunderExpandableOption extends StatefulWidget {
  const ThunderExpandableOption({
    super.key,
    this.leading,
    required this.title,
    required this.child,
    this.initiallyExpanded = false,
  });

  /// Optional leading widget shown in the header tile.
  final Widget? leading;

  /// Header title text.
  final String title;

  /// Content revealed when the section is expanded.
  final Widget child;

  /// Whether the section starts expanded.
  final bool initiallyExpanded;

  @override
  State<ThunderExpandableOption> createState() => _ThunderExpandableOptionState();
}

class _ThunderExpandableOptionState extends State<ThunderExpandableOption> with SingleTickerProviderStateMixin {
  late bool _isExpanded;

  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: 120),
    vsync: this,
  );

  late final Animation<Offset> _offsetAnimation = Tween<Offset>(
    begin: Offset.zero,
    end: const Offset(1.5, 0),
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.fastOutSlowIn));

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ThunderSettingsTile(
          title: widget.title,
          leading: widget.leading,
          trailing: ThunderSettingsExpandTrailing(expanded: _isExpanded),
          onTap: () => setState(() => _isExpanded = !_isExpanded),
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          switchInCurve: Curves.easeInOut,
          switchOutCurve: Curves.easeInOut,
          transitionBuilder: (child, animation) {
            return SizeTransition(
              sizeFactor: animation,
              child: SlideTransition(position: _offsetAnimation, child: child),
            );
          },
          child: _isExpanded
              ? Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: widget.child,
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
