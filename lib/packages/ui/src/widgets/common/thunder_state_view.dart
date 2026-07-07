import 'package:flutter/material.dart';

import 'package:thunder/packages/ui/src/widgets/common/thunder_state_action.dart';
import 'package:thunder/packages/ui/src/widgets/common/thunder_state_actions.dart';
import 'package:thunder/packages/ui/src/widgets/common/thunder_state_icon.dart';
import 'package:thunder/packages/ui/src/widgets/common/thunder_state_text.dart';
import 'package:thunder/packages/ui/src/widgets/layout/thunder_sliver_adapter.dart';

/// Presentation mode for [ThunderStateView].
enum ThunderStateViewMode {
  /// Shows a centered progress indicator.
  loading,

  /// Shows an error icon, title, message, and optional actions.
  error,

  /// Shows italicized empty-state text.
  empty,

  /// Shows a custom [ThunderStateView.child] widget.
  custom,
}

/// Composable loading, error, empty, or custom state presentation.
@immutable
class ThunderStateView extends StatelessWidget {
  const ThunderStateView({
    super.key,
    this.mode = ThunderStateViewMode.error,
    this.title,
    this.message,
    this.actions = const [],
    this.icon,
    this.compact = false,
    this.sliver = false,
    this.fillRemaining = true,
    this.hasScrollBody = false,
    this.padding = const EdgeInsets.all(12.0),
    this.child,
    this.semanticsLabel,
  });

  /// Loading state with a centered progress indicator.
  ///
  /// Omits error/empty-specific fields such as [title], [message], [actions],
  /// [icon], [compact], and [child].
  const ThunderStateView.loading({
    super.key,
    this.sliver = false,
    this.fillRemaining = true,
    this.hasScrollBody = false,
    this.padding = const EdgeInsets.all(12.0),
    this.semanticsLabel,
  })  : mode = ThunderStateViewMode.loading,
        title = null,
        message = null,
        actions = const [],
        icon = null,
        compact = false,
        child = null;

  /// Presentation mode for this state view.
  final ThunderStateViewMode mode;

  /// Optional title text for error and empty modes.
  final String? title;

  /// Optional message text shown below [title].
  final String? message;

  /// Action buttons shown in error mode.
  final List<ThunderStateAction> actions;

  /// Custom icon for error mode. Defaults to a warning icon.
  final IconData? icon;

  /// When true, uses tighter spacing in error mode.
  final bool compact;

  /// When true, wraps content in a sliver adapter.
  final bool sliver;

  /// When [sliver] is true, uses [SliverFillRemaining].
  final bool fillRemaining;

  /// Passed to [SliverFillRemaining] when [fillRemaining] is true.
  final bool hasScrollBody;

  /// Outer padding around the state content.
  final EdgeInsetsGeometry padding;

  /// Custom content shown in custom mode.
  final Widget? child;

  /// Accessibility label for loading mode.
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: padding,
      child: Center(
        child: _ThunderStateViewBody(
          mode: mode,
          title: title,
          message: message,
          actions: actions,
          icon: icon,
          compact: compact,
          semanticsLabel: semanticsLabel,
          child: child,
        ),
      ),
    );

    return ThunderSliverAdapter(
      sliver: sliver,
      fillRemaining: fillRemaining,
      hasScrollBody: hasScrollBody,
      child: content,
    );
  }
}

/// Inner content builder for [ThunderStateView] modes.
class _ThunderStateViewBody extends StatelessWidget {
  const _ThunderStateViewBody({
    required this.mode,
    this.title,
    this.message,
    required this.actions,
    this.icon,
    required this.compact,
    this.child,
    this.semanticsLabel,
  });

  /// The presentation mode for this state view.
  final ThunderStateViewMode mode;

  /// Optional title text for error and empty modes.
  final String? title;

  /// Optional message text shown below [title].
  final String? message;

  /// Action buttons shown in error mode.
  final List<ThunderStateAction> actions;

  /// Custom icon for error mode.
  final IconData? icon;

  /// When true, uses tighter spacing in error mode.
  final bool compact;

  /// Custom content shown in custom mode.
  final Widget? child;

  /// Accessibility label for loading mode.
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    switch (mode) {
      case ThunderStateViewMode.loading:
        return Semantics(
          label: semanticsLabel,
          child: const CircularProgressIndicator(),
        );
      case ThunderStateViewMode.custom:
        return child ?? const SizedBox.shrink();
      case ThunderStateViewMode.empty:
        return ThunderStateText(
          title: title,
          message: message,
          italic: true,
        );
      case ThunderStateViewMode.error:
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ThunderStateIcon(
              icon: icon ?? Icons.warning_rounded,
              compact: compact,
            ),
            SizedBox(height: compact ? 16.0 : 32.0),
            ThunderStateText(
              title: title,
              message: message,
            ),
            if (actions.isNotEmpty) ...[
              SizedBox(height: compact ? 16.0 : 32.0),
              ThunderStateActions(actions: actions),
            ],
          ],
        );
    }
  }
}
