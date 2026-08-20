import 'package:flutter/foundation.dart';

/// Action button configuration for [ThunderStateView].
@immutable
class ThunderStateAction {
  const ThunderStateAction({required this.label, required this.onPressed, this.loading = false, this.primary = false});

  /// Button label text.
  final String label;

  /// Called when the action button is pressed.
  final void Function() onPressed;

  /// When true, shows a progress indicator and disables the button.
  final bool loading;

  /// When true, renders as an elevated button instead of a text button.
  final bool primary;
}
