import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/src/app/shell/state/shell_chrome_cubit.dart';
import 'package:thunder/src/features/settings/api.dart';
import 'package:thunder/src/foundation/config/global_context.dart';

/// Enum to distinguish between feed and post FABs
enum FabType { feed, post }

/// A FAB that allows the user to expand and collapse a list of actions.
class GestureFab extends StatefulWidget {
  /// The distance between the FAB and the actions
  final double distance;

  /// The list of actions to display
  final List<Widget> children;

  /// The icon to display on the FAB
  final Icon icon;

  /// The function to call when the FAB is slid up
  final Function? onSlideUp;

  /// The function to call when the FAB is slid left
  final Function? onSlideLeft;

  /// The function to call when the FAB is slid down
  final Function? onSlideDown;

  /// The function to call when the FAB is pressed
  final Function? onPressed;

  /// The function to call when the FAB is long pressed
  final Function? onLongPress;

  /// Whether the FAB is centered
  final bool centered;

  /// The hero tag to use for the FAB
  final String? heroTag;

  /// The background color of the FAB
  final Color? fabBackgroundColor;

  /// The type of FAB (feed or post) - determines which state to use
  final FabType fabType;

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

  @override
  State<GestureFab> createState() => _GestureFabState();
}

class _GestureFabState extends State<GestureFab> with SingleTickerProviderStateMixin {
  /// The controller for the animation
  late final AnimationController _controller;

  /// The animation for the expansion of the FAB
  late final Animation<double> _expandAnimation;

  /// The function to call when the FAB is toggled
  late final Function(String val)? toggle;

  /// Whether the FAB is open
  bool isFabOpen = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      value: isFabOpen ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );

    _expandAnimation = CurvedAnimation(
      curve: Curves.fastOutSlowIn,
      reverseCurve: Curves.easeOutQuad,
      parent: _controller,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Gets the current isFabOpen state based on the fabType
  bool _getIsFabOpen(ShellChromeState state) {
    return widget.fabType == FabType.feed ? state.isFeedFabOpen : state.isPostFabOpen;
  }

  /// Sets the FAB open state based on the fabType
  void _setFabOpen(BuildContext context, bool isOpen) {
    final cubit = context.read<ShellChromeCubit>();

    if (widget.fabType == FabType.feed) {
      cubit.setFeedFabOpen(isOpen);
    } else {
      cubit.setPostFabOpen(isOpen);
    }
  }

  /// Sets the FAB summoned state based on the fabType
  void _setFabSummoned(BuildContext context, bool isSummoned) {
    final cubit = context.read<ShellChromeCubit>();

    if (widget.fabType == FabType.feed) {
      cubit.setFeedFabSummoned(isSummoned);
    } else {
      cubit.setPostFabSummoned(isSummoned);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ShellChromeCubit, ShellChromeState>(
      listenWhen: (previous, current) => _getIsFabOpen(previous) != _getIsFabOpen(current),
      listener: (context, state) {
        final isOpen = _getIsFabOpen(state);

        if (isOpen) {
          _controller.forward();
        } else {
          _controller.reverse();
        }

        if (isFabOpen != isOpen) {
          setState(() => isFabOpen = isOpen);
        }
      },
      builder: (context, state) {
        return SizedBox.expand(
          child: Stack(
            alignment: widget.centered ? Alignment.bottomCenter : Alignment.bottomRight,
            clipBehavior: Clip.none,
            children: [
              _buildTapToCloseFab(),
              ..._buildExpandingActionButtons(),
              _buildTapToOpenFab(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTapToCloseFab() {
    final theme = Theme.of(context);
    final l10n = GlobalContext.l10n;

    return SizedBox(
      width: widget.centered ? 45 : 56,
      height: widget.centered ? 45 : 56,
      child: AnimatedBuilder(
        animation: _expandAnimation,
        builder: (context, child) => child!,
        child: FadeTransition(
          opacity: _expandAnimation,
          child: Center(
            child: Material(
              shape: widget.centered ? null : const CircleBorder(),
              clipBehavior: widget.centered ? Clip.none : Clip.antiAlias,
              color: widget.centered ? Colors.transparent : null,
              elevation: widget.centered ? 0 : 4,
              child: InkWell(
                borderRadius: BorderRadius.circular(50),
                onTap: () {
                  _setFabOpen(context, false);
                },
                child: Padding(
                  padding: EdgeInsets.all(widget.centered ? 12 : 8),
                  child: Icon(
                    Icons.close,
                    size: widget.centered ? 20 : 25,
                    color: theme.textTheme.bodyMedium?.color,
                    semanticLabel: l10n.close,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildExpandingActionButtons() {
    final children = <Widget>[];
    final count = widget.children.length;

    for (var i = 0, distance = widget.distance; i < count; i++, distance += widget.distance) {
      children.add(
        _ExpandingActionButton(
          maxDistance: distance,
          progress: _expandAnimation,
          focus: isFabOpen && i == count - 1,
          centered: widget.centered,
          first: i == count - 1,
          last: i == 0,
          child: widget.children[i],
        ),
      );
    }

    return children;
  }

  Widget _buildTapToOpenFab() {
    return IgnorePointer(
      ignoring: isFabOpen,
      child: AnimatedContainer(
        transformAlignment: Alignment.center,
        transform: Matrix4.diagonal3Values(
          isFabOpen ? 0.7 : 1.0,
          isFabOpen ? 0.7 : 1.0,
          1.0,
        ),
        duration: const Duration(milliseconds: 250),
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
        child: AnimatedOpacity(
          opacity: isFabOpen ? 0.0 : 1.0,
          curve: const Interval(0.25, 1.0, curve: Curves.easeInOut),
          duration: const Duration(milliseconds: 250),
          child: GestureDetector(
            onVerticalDragUpdate: (details) {
              if (details.delta.dy < -5) {
                _setFabOpen(context, true);
              }
              if (details.delta.dy > 5) {
                // Only allow hiding fab when on the main feed, and not when opening a community on a new page
                if (Navigator.of(context).canPop() == false) _setFabSummoned(context, false);
              }
            },
            onHorizontalDragStart: null,
            onLongPress: () {
              HapticFeedback.heavyImpact();
              widget.onLongPress?.call();
            },
            onTapDown: (details) => HapticFeedback.mediumImpact(),
            child: widget.centered
                ? SizedBox(
                    width: 45,
                    height: 45,
                    child: Material(
                      shape: widget.centered ? null : const CircleBorder(),
                      clipBehavior: Clip.antiAlias,
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(50),
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          widget.onPressed?.call();
                        },
                        child: Icon(
                          widget.icon.icon,
                          size: 20,
                          semanticLabel: widget.icon.semanticLabel,
                        ),
                      ),
                    ),
                  )
                : FloatingActionButton(
                    heroTag: widget.heroTag,
                    backgroundColor: widget.fabBackgroundColor,
                    onPressed: () => widget.onPressed?.call(),
                    child: widget.icon,
                  ),
          ),
        ),
      ),
    );
  }
}

// ActionButton mutates first/last when placed inside expanding FAB stacks.
// ignore: must_be_immutable
class ActionButton extends StatelessWidget {
  ActionButton({
    super.key,
    this.onPressed,
    this.title,
    required this.icon,
    this.centered = false,
    this.backgroundColor,
    this.fabType = FabType.feed,
  });

  final VoidCallback? onPressed;
  final Icon icon;
  final String? title;
  final bool centered;
  final Color? backgroundColor;
  final FabType fabType;

  bool? first;
  bool? last;

  /// Sets the FAB open state based on the fabType
  void _setFabOpen(BuildContext context, bool isOpen) {
    final cubit = context.read<ShellChromeCubit>();
    if (fabType == FabType.feed) {
      cubit.setFeedFabOpen(isOpen);
    } else {
      cubit.setPostFabOpen(isOpen);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool darkTheme = context.read<ThemePreferencesCubit>().state.useDarkTheme;

    return centered
        ? SizedBox(
            width: 160,
            child: Material(
              color: Colors.transparent,
              elevation: 3,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(first == true ? 20 : 0),
                topRight: Radius.circular(first == true ? 20 : 0),
                bottomLeft: Radius.circular(last == true ? 20 : 0),
                bottomRight: Radius.circular(last == true ? 20 : 0),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Align(
                      child: SizedBox(
                        height: 40,
                        child: Material(
                          color: darkTheme ? theme.colorScheme.primaryContainer : null,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(first == true ? 20 : 0),
                            topRight: Radius.circular(first == true ? 20 : 0),
                            bottomLeft: Radius.circular(last == true ? 20 : 0),
                            bottomRight: Radius.circular(last == true ? 20 : 0),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(first == true ? 20 : 0),
                              topRight: Radius.circular(first == true ? 20 : 0),
                              bottomLeft: Radius.circular(last == true ? 20 : 0),
                              bottomRight: Radius.circular(last == true ? 20 : 0),
                            ),
                            onTap: () {
                              _setFabOpen(context, false);
                              onPressed?.call();
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 5, right: 5),
                    child: IgnorePointer(
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 10, right: 5),
                            child: Icon(
                              icon.icon,
                              size: 20,
                            ),
                          ),
                          const SizedBox(
                            height: 40,
                          ),
                          Flexible(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 10, right: 5),
                              child: title != null
                                  ? Text(
                                      title!,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    )
                                  : Container(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        : Row(
            children: [
              title != null ? Text(title!) : Container(),
              const SizedBox(width: 16),
              SizedBox(
                height: 40,
                width: 40,
                child: Material(
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                  clipBehavior: Clip.antiAlias,
                  color: backgroundColor ?? theme.colorScheme.primaryContainer,
                  elevation: 4,
                  child: InkWell(
                    onTap: () {
                      _setFabOpen(context, false);
                      onPressed?.call();
                    },
                    child: icon,
                  ),
                ),
              ),
            ],
          );
  }
}

@immutable
class _ExpandingActionButton extends StatefulWidget {
  const _ExpandingActionButton({
    required this.maxDistance,
    required this.progress,
    required this.child,
    required this.focus,
    this.centered = false,
    required this.first,
    required this.last,
  });

  final double maxDistance;
  final Animation<double> progress;
  final Widget child;
  final bool focus;
  final bool centered;

  final bool first;
  final bool last;

  @override
  State<_ExpandingActionButton> createState() => _ExpandingActionButtonState();
}

class _ExpandingActionButtonState extends State<_ExpandingActionButton> {
  bool _visible = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.progress,
      builder: (context, child) {
        final offset = Offset.fromDirection(
          90 * (math.pi / 180.0),
          widget.progress.value * widget.maxDistance,
        );
        _visible = !widget.progress.isDismissed;
        return Visibility(
          visible: _visible,
          child: Positioned(
            right: widget.centered ? null : 8.0 + offset.dx,
            bottom: (widget.centered ? 15.0 : 10.0) + offset.dy,
            child: Semantics(
              focused: widget.focus,
              child: child is FadeTransition && child.child is ActionButton
                  ? () {
                      (child.child as ActionButton).first = widget.first;
                      (child.child as ActionButton).last = widget.last;
                      return child;
                    }()
                  : child!,
            ),
          ),
        );
      },
      child: FadeTransition(
        opacity: widget.progress,
        child: widget.child,
      ),
    );
  }
}
