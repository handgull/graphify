import 'package:flutter/widgets.dart';
import 'package:webview_flutter_platform_interface/'
    'webview_flutter_platform_interface.dart';

/// A `webview_flutter` platform that loads nothing and records every call,
/// so a test can assert on how `GraphifyView` drives its WebView.
///
/// Calls the fake does not override hit the platform interface's defaults,
/// which throw: an unexpected WebView call fails the test.
class FakeWebViewPlatform extends WebViewPlatform {
  /// Every controller created, in creation order.
  final controllers = <FakeWebViewController>[];

  @override
  PlatformWebViewController createPlatformWebViewController(
    PlatformWebViewControllerCreationParams params,
  ) {
    final controller = FakeWebViewController(params);
    controllers.add(controller);
    return controller;
  }

  @override
  PlatformWebViewWidget createPlatformWebViewWidget(
    PlatformWebViewWidgetCreationParams params,
  ) => _FakeWebViewWidget(params);

  @override
  PlatformNavigationDelegate createPlatformNavigationDelegate(
    PlatformNavigationDelegateCreationParams params,
  ) => FakeNavigationDelegate(params);
}

/// Registers a fresh [FakeWebViewPlatform] and returns it.
FakeWebViewPlatform registerFakeWebViewPlatform() {
  final platform = FakeWebViewPlatform();
  WebViewPlatform.instance = platform;
  return platform;
}

/// A WebView controller recording what it was asked to do.
class FakeWebViewController extends PlatformWebViewController {
  /// Creates a recording controller.
  FakeWebViewController(super.params) : super.implementation();

  /// The name of every call, in call order.
  final calls = <String>[];

  /// Every script run, in run order.
  final scripts = <String>[];

  /// Runs on every script, after it is recorded: lets a test delay or fail
  /// [runJavaScript].
  Future<void> Function(String javaScript)? onRunJavaScript;

  /// The last JavaScript mode set.
  JavaScriptMode? javaScriptMode;

  /// The last background color set.
  Color? backgroundColor;

  /// The last console message handler set.
  void Function(JavaScriptConsoleMessage)? onConsoleMessage;

  /// The last HTML loaded.
  String? html;

  /// The last navigation delegate set.
  FakeNavigationDelegate? navigationDelegate;

  /// Every JavaScript channel added, by name.
  final channels = <String, JavaScriptChannelParams>{};

  @override
  Future<void> setJavaScriptMode(JavaScriptMode javaScriptMode) async {
    calls.add('setJavaScriptMode');
    this.javaScriptMode = javaScriptMode;
  }

  @override
  Future<void> setBackgroundColor(Color color) async {
    calls.add('setBackgroundColor');
    backgroundColor = color;
  }

  @override
  Future<void> setOnConsoleMessage(
    void Function(JavaScriptConsoleMessage) onConsoleMessage,
  ) async {
    calls.add('setOnConsoleMessage');
    this.onConsoleMessage = onConsoleMessage;
  }

  @override
  Future<void> addJavaScriptChannel(JavaScriptChannelParams params) async {
    calls.add('addJavaScriptChannel');
    channels[params.name] = params;
  }

  /// Posts [message] on the channel [name], as the page's JavaScript does.
  void postMessage(String name, String message) =>
      channels[name]!.onMessageReceived(JavaScriptMessage(message: message));

  @override
  Future<void> loadHtmlString(String html, {String? baseUrl}) async {
    calls.add('loadHtmlString');
    this.html = html;
  }

  @override
  Future<void> setPlatformNavigationDelegate(
    PlatformNavigationDelegate handler,
  ) async {
    calls.add('setPlatformNavigationDelegate');
    navigationDelegate = handler as FakeNavigationDelegate;
  }

  @override
  Future<void> clearLocalStorage() async => calls.add('clearLocalStorage');

  @override
  Future<void> clearCache() async => calls.add('clearCache');

  @override
  Future<void> runJavaScript(String javaScript) async {
    scripts.add(javaScript);
    await onRunJavaScript?.call(javaScript);
  }

  /// Fires the page-finished callback, as a real WebView does on load.
  void finishPageLoad() => navigationDelegate!.onPageFinished!('about:blank');
}

/// A navigation delegate keeping the callbacks it was handed.
class FakeNavigationDelegate extends PlatformNavigationDelegate {
  /// Creates a recording delegate.
  FakeNavigationDelegate(super.params) : super.implementation();

  /// The page-finished callback, once set.
  PageEventCallback? onPageFinished;

  @override
  Future<void> setOnPageFinished(PageEventCallback onPageFinished) async {
    this.onPageFinished = onPageFinished;
  }
}

class _FakeWebViewWidget extends PlatformWebViewWidget {
  _FakeWebViewWidget(super.params) : super.implementation();

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
