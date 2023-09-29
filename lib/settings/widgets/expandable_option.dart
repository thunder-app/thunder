import 'package:flutter/material.dart';

/// This widget creates an option which can be expanded to see the full contents
class ExpandableOption extends StatefulWidget {
  final IconData? icon;
  final String description;
  final Widget child;

  const ExpandableOption({
    super.key,
    this.icon,
    required this.description,
    required this.child,
  });

  @override
  State<ExpandableOption> createState() => _ExpandableOptionState();
}

class _ExpandableOptionState extends State<ExpandableOption> with SingleTickerProviderStateMixin {
  bool isExpanded = false;

  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: 100),
    vsync: this,
  );

  // Animation for settings collapse
  late final Animation<Offset> _offsetAnimation = Tween<Offset>(
    begin: Offset.zero,
    end: const Offset(1.5, 0.0),
  ).animate(CurvedAnimation(
    parent: _controller,
    curve: Curves.fastOutSlowIn,
  ));

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Column(
      children: [
        InkWell(
          borderRadius: const BorderRadius.all(Radius.circular(50)),
          onTap: () => setState(() => isExpanded = !isExpanded),
          child: Padding(
            padding: const EdgeInsets.only(left: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(widget.icon),
                    const SizedBox(width: 8.0),
                    Text(widget.description, style: theme.textTheme.bodyMedium),
                  ],
                ),
                const SizedBox(
                  height: 40,
                ),
                Icon(isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded),
              ],
            ),
          ),
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          switchInCurve: Curves.easeInOut,
          switchOutCurve: Curves.easeInOut,
          transitionBuilder: (Widget child, Animation<double> animation) {
            return SizeTransition(
              sizeFactor: animation,
              child: SlideTransition(position: _offsetAnimation, child: child),
            );
          },
          child: isExpanded
              ? Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: widget.child,
                )
              : Container(),
        ),
      ],
    );
  }
}
