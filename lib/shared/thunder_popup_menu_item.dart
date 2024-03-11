import 'package:flutter/material.dart';

/// Defines a custom [PopupMenuItem] that can be used throughout the app
class ThunderPopupMenuItem extends PopupMenuItem {
  final IconData icon;
  final String title;
  final bool? checkboxValue;
  final void Function()? onCheckboxValueToggled;

  ThunderPopupMenuItem({
    super.key,
    required super.onTap,
    required this.icon,
    required this.title,
    this.checkboxValue,
    this.onCheckboxValueToggled,
  }) : super(
          child: ListTile(
              dense: true,
              horizontalTitleGap: 5,
              leading: Icon(icon, size: 20),
              title: Text(title),
              trailing: checkboxValue == null ? null : Checkbox(value: checkboxValue, onChanged: (_) => onCheckboxValueToggled?.call())),
        );
}
