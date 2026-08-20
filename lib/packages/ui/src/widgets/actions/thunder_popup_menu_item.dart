import 'package:flutter/material.dart';

/// Standardized popup menu item with a leading icon and optional trailing widget.
class ThunderPopupMenuItem<T> extends PopupMenuItem<T> {
  /// Creates a [PopupMenuItem] with Thunder list-tile styling.
  ThunderPopupMenuItem({super.key, super.value, required void Function() onTap, required IconData icon, required String title, Widget? trailing})
    : super(
        onTap: onTap,
        child: ListTile(dense: true, horizontalTitleGap: 5.0, leading: Icon(icon, size: 20.0), title: Text(title), trailing: trailing),
      );
}
