import 'package:flutter/material.dart';

class ExtendedDismissible extends StatefulWidget {
  final Widget child;
  final VoidCallback? onDismissed;
  final VoidCallback? onCancel;
  final Function(DismissUpdateDetails)? onUpdate;
  Widget? background;

  ExtendedDismissible({
    Key? key,
    required this.child,
    this.onUpdate,
    this.onDismissed,
    this.onCancel,
    this.background,
  }) : super(key: key);

  @override
  _ExtendedDismissibleState createState() => _ExtendedDismissibleState();
}

class _ExtendedDismissibleState extends State<ExtendedDismissible> {
  bool _isInteracting = false;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) {
        setState(() {
          _isInteracting = true;
        });
      },
      onPointerUp: (_) {
        if (_isInteracting) {
          setState(() {
            _isInteracting = false;
          });
          widget.onCancel?.call();
        }
      },
      child: Draggable(
        hitTestBehavior: HitTestBehavior.opaque,
        onDragCompleted: () => setState(() {
          _isInteracting = false;
        }),
        onDragEnd: (_) {
          if (_isInteracting) {
            setState(() {
              _isInteracting = false;
            });
          }
        },
        feedback: Container(), // Replace with your draggable feedback widget
        child: Dismissible(
          key: widget.key!,
          direction: DismissDirection.horizontal,
          onDismissed: (direction) {
            widget.onDismissed?.call();
          },
          dismissThresholds: const {DismissDirection.endToStart: 0.9, DismissDirection.startToEnd: 0.9},
          confirmDismiss: (DismissDirection direction) async {
            return false;
          },
          onUpdate: (details) => widget.onUpdate?.call(details),
          child: widget.child,
          background: widget.background,
        ),
      ),
    );

    return GestureDetector(
      onVerticalDragStart: (details) => setState(() {
        _isInteracting = true;
      }),
      onVerticalDragEnd: (details) => setState(() {
        _isInteracting = false;
      }),
      onVerticalDragCancel: () {
        setState(() {
          _isInteracting = false;
        });
      },
      onHorizontalDragStart: (details) => setState(() {
        _isInteracting = true;
      }),
      onHorizontalDragEnd: (details) => setState(() {
        _isInteracting = false;
      }),
      onHorizontalDragCancel: () {
        setState(() {
          _isInteracting = false;
        });
      },
      onTapDown: (_) {
        setState(() {
          _isInteracting = true;
        });
      },
      onTapUp: (_) {
        setState(() {
          _isInteracting = false;
        });
      },
      onTapCancel: () {
        setState(() {
          _isInteracting = false;
        });
        widget.onCancel?.call();
      },
      child: Dismissible(
        key: widget.key!,
        direction: DismissDirection.horizontal,
        onDismissed: (direction) {
          widget.onDismissed?.call();
        },
        dismissThresholds: const {DismissDirection.endToStart: 0.9, DismissDirection.startToEnd: 0.9},
        confirmDismiss: (DismissDirection direction) async {
          return false;
        },
        onUpdate: (details) => widget.onUpdate?.call(details),
        child: widget.child,
        background: widget.background,
      ),
    );
  }
}
