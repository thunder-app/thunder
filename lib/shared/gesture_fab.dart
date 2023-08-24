import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../thunder/bloc/thunder_bloc.dart';

@immutable
class GestureFab extends StatefulWidget {
  const GestureFab({
    super.key,
    this.initialOpen,
    required this.distance,
    required this.children,
    required this.icon,
    this.onSlideUp,
    this.onSlideLeft,
    this.onSlideDown,
    this.onPressed,
    this.onLongPress,
    this.centered = false,
  });

  final bool? initialOpen;
  final double distance;
  final List<Widget> children;
  final Icon icon;
  final Function? onSlideUp;
  final Function? onSlideLeft;
  final Function? onSlideDown;
  final Function? onPressed;
  final Function? onLongPress;
  final bool centered;

  @override
  State<GestureFab> createState() => _GestureFabState();
}

class _GestureFabState extends State<GestureFab> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _expandAnimation;
  late final Function(String val)? toggle;
  bool _previousIsFabOpen = false;
  bool isFabOpen = false;

  @override
  void initState() {
    super.initState();
    isFabOpen = widget.initialOpen ?? false;
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

  @override
  Widget build(BuildContext context) {
    final ThunderState state = context.watch<ThunderBloc>().state;
    if (state.isFabOpen != _previousIsFabOpen) {
      isFabOpen = state.isFabOpen;
      _previousIsFabOpen = isFabOpen;
      if (isFabOpen) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }

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
  }

  Widget _buildTapToCloseFab() {
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
              elevation: widget.centered ? 0 : 4,
              child: InkWell(
                borderRadius: BorderRadius.circular(50),
                onTap: () {
                  context.read<ThunderBloc>().add(const OnFabToggle(false));
                },
                child: Padding(
                  padding: EdgeInsets.all(widget.centered ? 12 : 8),
                  child: Icon(
                    Icons.close,
                    size: widget.centered ? 20 : 25,
                    color: Theme.of(context).primaryColor,
                    semanticLabel: AppLocalizations.of(context)!.close,
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
                context.read<ThunderBloc>().add(const OnFabToggle(true));
              }
              if (details.delta.dy > 5) {
                context.read<ThunderBloc>().add(const OnFabSummonToggle(false));
              }
            },
            onHorizontalDragStart: null,
            onLongPress: () {
              widget.onLongPress?.call();
            },
            child: widget.centered
                ? SizedBox(
                    width: 45,
                    height: 45,
                    child: Material(
                      shape: const CircleBorder(),
                      clipBehavior: Clip.antiAlias,
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(50),
                        onTap: () => widget.onPressed?.call(),
                        child: Icon(
                          widget.icon.icon,
                          size: 20,
                        ),
                      ),
                    ),
                  )
                : FloatingActionButton(
                    onPressed: () {
                      widget.onPressed?.call();
                    },
                    child: widget.icon,
                  ),
          ),
        ),
      ),
    );
  }
}

@immutable
class ActionButton extends StatelessWidget {
  const ActionButton({
    super.key,
    this.onPressed,
    this.title,
    required this.icon,
    this.centered = false,
  });

  final VoidCallback? onPressed;
  final Icon icon;
  final String? title;
  final bool centered;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return centered
        ? Material(
            color: Colors.transparent,
            elevation: 3,
            borderRadius: BorderRadius.circular(50),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Align(
                    child: SizedBox(
                      height: 35,
                      child: Material(
                        borderRadius: BorderRadius.circular(50),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(50),
                          onTap: () {
                            context.read<ThunderBloc>().add(const OnFabToggle(true));
                            onPressed?.call();
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                IgnorePointer(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 10, right: 5),
                        child: title != null ? Text(title!) : Container(),
                      ),
                      const SizedBox(
                        height: 35,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 5, right: 10),
                        child: Icon(
                          icon.icon,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
                  color: theme.colorScheme.primaryContainer,
                  elevation: 4,
                  child: InkWell(
                    onTap: () {
                      context.read<ThunderBloc>().add(const OnFabToggle(true));
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
  });

  final double maxDistance;
  final Animation<double> progress;
  final Widget child;
  final bool focus;
  final bool centered;

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
        if (widget.progress.value == 1) {
          _visible = true;
        } else if (widget.progress.value == 0) {
          _visible = false;
        }
        return Visibility(
          visible: _visible,
          child: Positioned(
            right: widget.centered ? null : 8.0 + offset.dx,
            bottom: 10.0 + offset.dy,
            child: Semantics(
              focused: widget.focus,
              child: child!,
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
