import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ActionColor {
  static const String orange = '0xFFF57C00'; // Colors.orange.shade700
  static const String blue = '0xFF1976D2'; // Colors.blue.shade700
  static const String purple = '0xFF7B1FA2'; // Colors.purple.shade700
  static const String teal = '0xFF4DB6AC'; // Colors.teal.shade300
  static const String green = '0xFF388E3C'; // Colors.green.shade700
  static const String red = '0xFFD32F2F'; // Colors.red.shade700

  final String colorRaw;

  Color get color => Color(int.parse(colorRaw));

  const ActionColor.fromString({required this.colorRaw});

  @override
  String toString() => color.value.toString();

  String label(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return switch (colorRaw) {
      orange => l10n.orange,
      blue => l10n.blue,
      purple => l10n.purple,
      teal => l10n.teal,
      green => l10n.green,
      red => l10n.red,
      _ => throw Exception('Unknown color'),
    };
  }

  static List<ActionColor> getPossibleValues(ActionColor currentValue) {
    return [
      currentValue.colorRaw == orange ? currentValue : const ActionColor.fromString(colorRaw: ActionColor.orange),
      currentValue.colorRaw == blue ? currentValue : const ActionColor.fromString(colorRaw: ActionColor.blue),
      currentValue.colorRaw == purple ? currentValue : const ActionColor.fromString(colorRaw: ActionColor.purple),
      currentValue.colorRaw == teal ? currentValue : const ActionColor.fromString(colorRaw: ActionColor.teal),
      currentValue.colorRaw == green ? currentValue : const ActionColor.fromString(colorRaw: ActionColor.green),
      currentValue.colorRaw == red ? currentValue : const ActionColor.fromString(colorRaw: ActionColor.red),
    ];
  }
}
