import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/packages/ui/ui.dart';
import 'package:thunder/src/core/shell/shell_chrome_cubit.dart';

/// Distinguishes feed and post FAB chrome state.
enum FabType { feed, post }

/// Thin connector over [ThunderExpandableFab] wired to [ShellChromeCubit].
class GestureFab extends StatelessWidget {
  const GestureFab({
    super.key,
    required this.distance,
    required this.children,
    required this.icon,
    this.onSlideUp,
    this.onSlideLeft,
    this.onSlideDown,
    this.onPressed,
    this.onLongPress,
    this.centered = false,
    this.heroTag,
    this.fabBackgroundColor,
    this.fabType = FabType.feed,
  });

  final double distance;
  final List<Widget> children;
  final Icon icon;
  final VoidCallback? onSlideUp;
  final VoidCallback? onSlideLeft;
  final VoidCallback? onSlideDown;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final bool centered;
  final String? heroTag;
  final Color? fabBackgroundColor;
  final FabType fabType;

  bool _isOpen(ShellChromeState state) => fabType == FabType.feed ? state.isFeedFabOpen : state.isPostFabOpen;

  void _setOpen(BuildContext context, bool isOpen) {
    final cubit = context.read<ShellChromeCubit>();
    if (fabType == FabType.feed) {
      cubit.setFeedFabOpen(isOpen);
    } else {
      cubit.setPostFabOpen(isOpen);
    }
  }

  void _setSummoned(BuildContext context, bool isSummoned) {
    final cubit = context.read<ShellChromeCubit>();
    if (fabType == FabType.feed) {
      cubit.setFeedFabSummoned(isSummoned);
    } else {
      cubit.setPostFabSummoned(isSummoned);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ShellChromeCubit, ShellChromeState>(
      builder: (context, state) {
        return ThunderExpandableFab(
          open: _isOpen(state),
          distance: distance,
          icon: icon,
          centered: centered,
          heroTag: heroTag,
          fabBackgroundColor: fabBackgroundColor,
          onOpenChanged: (open) => _setOpen(context, open),
          onSlideUp: onSlideUp,
          onSlideLeft: onSlideLeft,
          onSlideDown:
              onSlideDown ??
              () {
                if (!Navigator.of(context).canPop()) {
                  _setSummoned(context, false);
                }
              },
          onPressed: onPressed,
          onLongPress: onLongPress,
          children: children,
        );
      },
    );
  }
}

// ActionButton mutates first/last when placed inside expanding FAB stacks.
// ignore: must_be_immutable
class ActionButton extends StatelessWidget {
  ActionButton({super.key, this.onPressed, this.title, required this.icon, this.centered = false, this.backgroundColor, this.fabType = FabType.feed});

  final VoidCallback? onPressed;
  final Icon icon;
  final String? title;
  final bool centered;
  final Color? backgroundColor;
  final FabType fabType;

  bool first = false;
  bool last = false;

  void _setOpen(BuildContext context, bool isOpen) {
    final cubit = context.read<ShellChromeCubit>();
    if (fabType == FabType.feed) {
      cubit.setFeedFabOpen(isOpen);
    } else {
      cubit.setPostFabOpen(isOpen);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ThunderFabActionButton(
      onPressed: () {
        _setOpen(context, false);
        onPressed?.call();
      },
      icon: icon,
      label: title,
      backgroundColor: backgroundColor,
      compact: centered,
    );
  }
}
