import 'package:flutter/material.dart';

class ThunderExpandableOption extends StatefulWidget {
  const ThunderExpandableOption({
    super.key,
    this.icon,
    required this.title,
    required this.child,
    this.initiallyExpanded = false,
  });

  final Widget? icon;
  final String title;
  final Widget child;
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
    final theme = Theme.of(context);

    return Column(
      children: [
        InkWell(
          borderRadius: const BorderRadius.all(Radius.circular(50)),
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          child: Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      if (widget.icon != null) ...[
                        widget.icon!,
                        const SizedBox(width: 8),
                      ],
                      Expanded(child: Text(widget.title, style: theme.textTheme.bodyMedium)),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                Icon(_isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded),
              ],
            ),
          ),
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
                  padding: const EdgeInsets.all(6),
                  child: widget.child,
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
