import 'package:flutter/material.dart';

/// Defines a widget that can be used in a [BottomSheet]. Can provide optional [leading] and [trailing] widgets.
///
/// When tapped, will call the [onTap] callback.
class BottomSheetAction extends StatelessWidget {
  const BottomSheetAction({super.key, required this.leading, this.trailing, required this.title, this.subtitle, required this.onTap});

  /// The leading widget
  final Widget leading;

  /// The trailing widget
  final Widget? trailing;

  /// The title of the category
  final String title;

  /// The subtitle of the category
  final String? subtitle;

  /// Callback function to be called when the category is tapped
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      customBorder: const StadiumBorder(),
      child: ListTile(
        leading: leading,
        trailing: trailing,
        title: Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle ?? '',
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            : null,
      ),
    );
  }
}
