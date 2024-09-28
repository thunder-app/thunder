import 'dart:async';
import 'dart:io';

import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:thunder/shared/thunder_popup_menu_item.dart';
import 'package:thunder/utils/links.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class WebView extends StatefulWidget {
  final String url;
  const WebView({super.key, required this.url});

  @override
  State<WebView> createState() => _WebViewState();
}

class _WebViewState extends State<WebView> {
  late final WebViewController _controller;

  // Keeps track of the URL that we are currently viewing, not necessarily the original
  String? currentUrl;

  @override
  void initState() {
    super.initState();

    late final PlatformWebViewControllerCreationParams params;

    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final WebViewController controller = WebViewController.fromPlatformCreationParams(params);

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate())
      ..loadRequest(Uri.parse(widget.url))
      ..setNavigationDelegate(NavigationDelegate(
        onNavigationRequest: (navigationRequest) {
          if (!kIsWeb && Platform.isAndroid) {
            Uri? uri = Uri.tryParse(navigationRequest.url);

            // Check if the scheme is not https, in which case the in-app browser can't handle it
            if (uri != null && uri.scheme != 'https') {
              // Although a non-https scheme is an indication that this link is intended for another app,
              // we actually have to change it back to https in order for the intent to be properly passed to another app.
              launchUrl(uri.replace(scheme: 'https'), mode: LaunchMode.externalApplication);

              // Finally, navigate back to the previous URL.
              return NavigationDecision.prevent;
            }
          }
          return NavigationDecision.navigate;
        },
        onUrlChange: (urlChange) => setState(() => currentUrl = urlChange.url),
      ));

    if (controller.platform is AndroidWebViewController) {
      (controller.platform as AndroidWebViewController).setMediaPlaybackRequiresUserGesture(false);
    }
    _controller = controller;

    BackButtonInterceptor.add(_handleBack);
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(_handleBack);
    super.dispose();
  }

  FutureOr<bool> _handleBack(bool stopDefaultButtonEvent, RouteInfo info) async {
    if (await _controller.canGoBack()) {
      _controller.goBack();
      return true;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.wait([_controller.getTitle(), _controller.currentUrl()]),
      builder: (context, snapshot) => Scaffold(
        appBar: AppBar(
          toolbarHeight: 70.0,
          titleSpacing: 0,
          title: ListTile(
            title: Text(snapshot.data?[0] ?? '', maxLines: 1, overflow: TextOverflow.ellipsis),
            subtitle: Text(snapshot.data?[1]?.replaceFirst('https://', '').replaceFirst('www.', '') ?? '', maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
          actions: <Widget>[
            NavigationControls(
              webViewController: _controller,
              url: currentUrl ?? widget.url,
            )
          ],
        ),
        body: WebViewWidget(controller: _controller),
      ),
    );
  }
}

class NavigationControls extends StatelessWidget {
  const NavigationControls({super.key, required this.webViewController, required this.url});

  final WebViewController webViewController;
  final String url;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return FutureBuilder(
      future: Future.wait([webViewController.canGoBack(), webViewController.canGoForward()]),
      builder: (context, snapshot) {
        return Row(
          children: <Widget>[
            IconButton(
              icon: Icon(
                Icons.arrow_back_rounded,
                semanticLabel: l10n.back,
              ),
              onPressed: snapshot.hasData && snapshot.data![0] == true ? () async => await webViewController.goBack() : null,
            ),
            IconButton(
              icon: Icon(
                Icons.arrow_forward_rounded,
                semanticLabel: l10n.forward,
              ),
              onPressed: snapshot.hasData && snapshot.data![1] == true ? () async => await webViewController.goForward() : null,
            ),
            PopupMenuButton(
              itemBuilder: (BuildContext context) => [
                ThunderPopupMenuItem(
                  onTap: () async => await webViewController.reload(),
                  icon: Icons.replay_rounded,
                  title: l10n.refresh,
                ),
                ThunderPopupMenuItem(
                  onTap: () => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
                  icon: Icons.open_in_browser_rounded,
                  title: l10n.openInBrowser,
                ),
                ThunderPopupMenuItem(
                  onTap: () => Share.share(url),
                  icon: Icons.share_rounded,
                  title: l10n.share,
                ),
                ThunderPopupMenuItem(
                  onTap: () {
                    handleLinkLongPress(
                      context,
                      url,
                      url,
                      initialPage: LinkBottomSheetPage.alternateLinks,
                      customNavigation: (url) => webViewController.loadRequest(Uri.parse(url)),
                    );
                  },
                  icon: Icons.link_rounded,
                  title: l10n.alternateSources,
                ),
              ],
            ),
            const SizedBox(width: 8.0),
          ],
        );
      },
    );
  }
}
