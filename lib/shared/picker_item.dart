import 'package:flutter/material.dart';

class PickerItem<T> extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Widget? leading;
  final IconData? trailingIcon;
  final void Function()? onSelected;
  final bool? isSelected;
  final TextTheme? textTheme;

  const PickerItem({
    super.key,
    required this.label,
    required this.icon,
    required this.onSelected,
    this.isSelected,
    this.trailingIcon,
    this.leading,
    this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: Material(
        borderRadius: BorderRadius.circular(50),
        color: isSelected == true ? theme.colorScheme.primaryContainer.withOpacity(0.25) : Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(50),
          onTap: onSelected,
          child: ListTile(
            title: Text(
              label,
              style: (textTheme?.bodyMedium ?? theme.textTheme.bodyMedium)?.copyWith(
                color: (textTheme?.bodyMedium ?? theme.textTheme.bodyMedium)?.color?.withOpacity(onSelected == null ? 0.5 : 1),
              ),
              textScaler: TextScaler.noScaling,
            ),
            leading: icon != null ? Icon(icon) : this.leading,
            trailing: Icon(trailingIcon),
          ),
        ),
      ),
    );
  }
}
