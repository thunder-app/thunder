import 'package:flutter/material.dart';

class SearchActionChip extends StatelessWidget {
  final List<Widget> children;
  final void Function()? onPressed;
  final Color? backgroundColor;

  const SearchActionChip({super.key, required this.children, this.onPressed, this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return ActionChip(
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      side: BorderSide(color: theme.dividerColor),
      backgroundColor: backgroundColor,
      label: SizedBox(
        height: 20,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: children,
        ),
      ),
      onPressed: onPressed,
    );
  }
}
