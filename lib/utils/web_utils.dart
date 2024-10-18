import 'package:webview_flutter/webview_flutter.dart';
import 'package:xayn_readability/xayn_readability.dart';

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

class CustomWebViewController implements IWebController {
  final WebViewController controller;

  CustomWebViewController.fromWebViewController(this.controller);

  @override
  Future<bool> canGoBack() => controller.canGoBack();

  @override
  Future<bool> canGoForward() => controller.canGoForward();

  @override
  Future<void> goBack() => controller.goBack();

  @override
  Future<void> goForward() => controller.goForward();

  @override
  Future<void> reload() => controller.reload();

  @override
  Future<String?> getTitle() => controller.getTitle();

  @override
  Future<String?> currentUrl() => controller.currentUrl();

  @override
  Future<void> loadRequest(Uri uri) => controller.loadRequest(uri);
}

class CustomReaderModeController implements IWebController {
  final ReaderModeController controller;

  CustomReaderModeController.fromReaderModeController(this.controller);

  @override
  Future<bool> canGoBack() => Future.value(controller.canGoBack);

  @override
  Future<bool> canGoForward() => Future.value(controller.canGoForward);

  @override
  Future<void> goBack() async => controller.back();

  @override
  Future<void> goForward() async => controller.forward();

  @override
  Future<void> reload() {
    return Future.value(() {
      if (controller.uri != null) controller.loadUri(controller.uri!);
    }());
  }

  @override
  Future<String?> getTitle() => Future.value(controller.uri?.host.replaceFirst('www.', ''));

  @override
  Future<String?> currentUrl() => Future.value(controller.uri?.toString());

  @override
  Future<void> loadRequest(Uri uri) async => controller.loadUri(uri);
}
