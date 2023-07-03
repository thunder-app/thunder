String? is50xError(String errorMessage) {
  final regex = RegExp(r'\b50\d\b');

  final match = regex.firstMatch(errorMessage);

  if (match != null) {
    final errorCode = match.group(0);
    return errorCode;
  } else {
    return null;
  }
}
