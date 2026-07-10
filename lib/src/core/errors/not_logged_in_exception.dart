/// Thrown when a repository method requires an authenticated account.
class NotLoggedInException implements Exception {
  NotLoggedInException(this.message);

  final String message;

  @override
  String toString() => message;
}
