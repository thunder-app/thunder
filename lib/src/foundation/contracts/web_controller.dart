/// Defines an interface which can perform web controlling operations
abstract interface class IWebController {
  Future<bool> canGoBack();
  Future<bool> canGoForward();
  Future<void> goBack();
  Future<void> goForward();
  Future<void> reload();
  Future<String?> getTitle();
  Future<String?> currentUrl();
  Future<void> loadRequest(Uri uri);
}
