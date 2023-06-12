String formatNumberToK(int number) {
  if (number.abs() > 999) {
    return '${(number.sign * number.abs() / 1000).toStringAsFixed(1)}K';
  } else {
    return (number.sign * number.abs()).toString();
  }
}
