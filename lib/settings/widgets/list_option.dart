import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ListOption<T> extends StatelessWidget {
  // Appearance
  final IconData icon;

  // General
  final String description;
  final T value;
  final List<T> options;

  // Callback
  final Function(T) onChanged;

  final String Function(T)? labelTransformer;

  const ListOption({
    super.key,
    required this.description,
    required this.value,
    required this.options,
    required this.icon,
    required this.onChanged,
    this.labelTransformer,
  });

  String _transformLabel(T value) {
    if (labelTransformer != null) {
      return labelTransformer!(value);
    } else {
      return value.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon),
            const SizedBox(width: 8.0),
            Text(description, style: theme.textTheme.bodyMedium),
          ],
        ),
        DropdownButton(
          borderRadius: const BorderRadius.all(Radius.circular(8.0)),
          underline: Container(),
          value: value,
          items: options.map<DropdownMenuItem<T>>((T value) {
            return DropdownMenuItem<T>(
              value: value,
              child: Text(_transformLabel(value)),
            );
          }).toList(),
          onChanged: (T? value) {
            HapticFeedback.lightImpact();
            onChanged(value ?? this.value);
          },
        )
      ],
    );
  }
}
