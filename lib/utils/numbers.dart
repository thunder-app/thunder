import 'package:intl/intl.dart';

final NumberFormat _compactFormatter = NumberFormat.compact();
final NumberFormat _longFormatter =
    NumberFormat.decimalPatternDigits(decimalDigits: 0);

String formatNumberToK(int number) => _compactFormatter.format(number);

String formatLongNumber(int number) => _longFormatter.format(number);
