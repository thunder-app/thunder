import 'package:flutter/material.dart';

class ThunderBottomSheetHeader extends StatelessWidget {
  const ThunderBottomSheetHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleLarge),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle!, style: theme.textTheme.bodySmall),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class ThunderBottomSheetNavigator<T> extends StatefulWidget {
  const ThunderBottomSheetNavigator({
    super.key,
    required this.initialPage,
    required this.pageBuilder,
    required this.titleBuilder,
    this.canPop,
    this.onClose,
  });

  final T initialPage;
  final Widget Function(BuildContext context, T page, void Function(T nextPage) goTo, VoidCallback goBack) pageBuilder;
  final String Function(BuildContext context, T page) titleBuilder;
  final bool Function(T page)? canPop;
  final VoidCallback? onClose;

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
            leading: canPop
                ? IconButton(
                    icon: const Icon(Icons.arrow_back_rounded),
                    onPressed: _goBack,
                  )
                : null,
            trailing: IconButton(
              icon: const Icon(Icons.close_rounded),
              onPressed: () {
                Navigator.of(context).pop();
                widget.onClose?.call();
              },
            ),
          ),
          Flexible(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 150),
              child: widget.pageBuilder(context, _current, _goTo, _goBack),
            ),
          ),
        ],
      ),
    );
  }
}
