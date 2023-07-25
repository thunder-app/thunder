import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
  });

  final bool? initialOpen;
  final double distance;
  final List<Widget> children;
  final Icon icon;
  final Function? onSlideUp;
  final Function? onSlideLeft;
  final Function? onSlideDown;

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
        alignment: Alignment.bottomRight,
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
      width: 56,
      height: 56,
      child: Center(
        child: Material(
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          elevation: 4,
          child: InkWell(
            onTap: () { context.read<ThunderBloc>().add(OnFabEvent(false)); },
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Icon(
                Icons.close,
                color: Theme.of(context).primaryColor,
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
    for (var i = 0, distance = widget.distance;
    i < count;
    i++, distance += widget.distance) {
      children.add(
        _ExpandingActionButton(
          maxDistance: distance,
          progress: _expandAnimation,
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
                context.read<ThunderBloc>().add(OnFabEvent(true));
              }
              if (details.delta.dy > 5) {
                widget.onSlideDown?.call();
              }
            },
            onHorizontalDragStart: null,
            child: FloatingActionButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                context.read<ThunderBloc>().add(OnDismissPostsEvent());
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
  });

  final VoidCallback? onPressed;
  final Widget icon;
  final String? title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
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
                context.read<ThunderBloc>().add(OnFabEvent(true));
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
class _ExpandingActionButton extends StatelessWidget {
  const _ExpandingActionButton({

    required this.maxDistance,
    required this.progress,
    required this.child,
  });

  final double maxDistance;
  final Animation<double> progress;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progress,
      builder: (context, child) {
        final offset = Offset.fromDirection(
          90 * (math.pi / 180.0),
          progress.value * maxDistance,
        );
        return Positioned(
          right: 8.0 + offset.dx,
          bottom: 10.0 + offset.dy,
          child: child!,
        );
      },
      child: FadeTransition(
        opacity: progress,
        child: child,
      ),
    );
  }
}