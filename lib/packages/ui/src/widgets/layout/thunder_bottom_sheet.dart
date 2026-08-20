import 'package:flutter/material.dart';

/// Title row for Thunder bottom sheets with optional leading and trailing slots.
@immutable
class ThunderBottomSheetHeader extends StatelessWidget {
  const ThunderBottomSheetHeader({super.key, required this.title, this.subtitle, this.leading, this.trailing});

  /// Primary heading text.
  final String title;

  /// Optional secondary text shown below [title].
  final String? subtitle;

  /// Widget shown before the title column, such as a back button.
  final Widget? leading;

  /// Widget shown after the title column, such as a close button.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (leading != null) ...[leading!, const SizedBox(width: 12.0)],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleLarge),
                if (subtitle != null) ...[const SizedBox(height: 2.0), Text(subtitle!, style: theme.textTheme.bodySmall)],
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// Multi-page bottom sheet navigator with a shared header and back/close controls.
class ThunderBottomSheetNavigator<T> extends StatefulWidget {
  const ThunderBottomSheetNavigator({super.key, required this.initialPage, required this.pageBuilder, required this.titleBuilder, this.canPop, this.onClose});

  /// The first page pushed onto the internal navigation stack.
  final T initialPage;

  /// Builds the body for [page] and exposes [goTo] and [goBack] navigation callbacks.
  final Widget Function(BuildContext context, T page, void Function(T nextPage) goTo, void Function() goBack) pageBuilder;

  /// Returns the header title for [page].
  final String Function(BuildContext context, T page) titleBuilder;

  /// When provided, controls whether the back action is allowed for [page].
  final bool Function(T page)? canPop;

  /// Called when the sheet is closed via the close button or a pop from the root page.
  final void Function()? onClose;

  @override
  State<ThunderBottomSheetNavigator<T>> createState() => _ThunderBottomSheetNavigatorState<T>();
}

class _ThunderBottomSheetNavigatorState<T> extends State<ThunderBottomSheetNavigator<T>> {
  late final List<T> _history = [widget.initialPage];

  T get _current => _history.last;

  void _goTo(T page) => setState(() => _history.add(page));

  void _goBack() {
    final allowed = widget.canPop?.call(_current) ?? _history.length > 1;
    if (!allowed) return;

    setState(() {
      if (_history.length > 1) {
        _history.removeLast();
      } else {
        Navigator.of(context).pop();
        widget.onClose?.call();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final canPop = _history.length > 1;

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ThunderBottomSheetHeader(
            title: widget.titleBuilder(context, _current),
            leading: canPop ? IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: _goBack) : null,
            trailing: IconButton(
              icon: const Icon(Icons.close_rounded),
              onPressed: () {
                Navigator.of(context).pop();
                widget.onClose?.call();
              },
            ),
          ),
          Flexible(
            child: AnimatedSwitcher(duration: const Duration(milliseconds: 150), child: widget.pageBuilder(context, _current, _goTo, _goBack)),
          ),
        ],
      ),
    );
  }
}
