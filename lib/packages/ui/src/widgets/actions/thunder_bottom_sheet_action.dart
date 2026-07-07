import 'package:flutter/material.dart';

import 'package:thunder/packages/ui/src/theme/thunder_theme.dart';

/// Defines an action tile that can be used in a [BottomSheet].
///
/// Can provide optional [leading] and [trailing] widgets. When tapped, calls [onTap].
@immutable
class ThunderBottomSheetAction extends StatelessWidget {
  const ThunderBottomSheetAction({
    super.key,
    required this.leading,
    this.trailing,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.onLongPress,
  });

  /// The leading widget.
  final Widget leading;

  /// The trailing widget.
  final Widget? trailing;

  /// The title of the action.
  final String title;

  /// The subtitle of the action.
  final String? subtitle;

  /// Called when the action is tapped.
  final void Function() onTap;

  /// Called when the action is long-pressed.
  final void Function()? onLongPress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final thunderTheme = ThunderTheme.of(context);

    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      customBorder: const StadiumBorder(),
      child: ListTile(
        leading: leading,
        trailing: trailing,
        title: Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500)),
        subtitle: subtitle != null
            ? Text(
                subtitle ?? '',
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.textTheme.bodyMedium?.color?.withValues(alpha: thunderTheme.settingsTileSubtitleAlpha)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            : null,
      ),
    );
  }
}
