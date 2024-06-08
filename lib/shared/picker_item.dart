import 'package:flutter/material.dart';

class PickerItem<T> extends StatelessWidget {
  final String label;
  final String? subtitle;
  final Widget? subtitleWidget;
  final Widget? labelWidget;
  final IconData? icon;
  final Widget? leading;
  final IconData? trailingIcon;
  final void Function()? onSelected;
  final bool? isSelected;
  final TextTheme? textTheme;
  final bool softWrap;

  const PickerItem({
    super.key,
    required this.label,
    this.subtitle,
    this.subtitleWidget,
    this.labelWidget,
    required this.icon,
    required this.onSelected,
    this.isSelected,
    this.trailingIcon,
    this.leading,
    this.textTheme,
    this.softWrap = false,
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
            title: labelWidget ??
                Text(
                  label,
                  style: (textTheme?.bodyMedium ?? theme.textTheme.bodyMedium)?.copyWith(
                    color: (textTheme?.bodyMedium ?? theme.textTheme.bodyMedium)?.color?.withOpacity(onSelected == null ? 0.5 : 1),
                  ),
                  textScaler: TextScaler.noScaling,
                ),
            subtitle: subtitleWidget ??
                (subtitle != null
                    ? Text(
                        subtitle!,
                        style: (textTheme?.bodyMedium ?? theme.textTheme.bodyMedium)?.copyWith(
                          color: (textTheme?.bodyMedium ?? theme.textTheme.bodyMedium)?.color?.withOpacity(0.5),
                        ),
                        softWrap: softWrap,
                        overflow: TextOverflow.fade,
                      )
                    : null),
            leading: icon != null ? Icon(icon) : this.leading,
            trailing: trailingIcon != null ? Icon(trailingIcon) : null,
          ),
        ),
      ),
    );
  }
}
