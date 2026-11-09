import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:graphify/src/controller/implements/mobile.dart';
import 'package:graphify/src/controller/js_methods.dart';
import 'package:graphify/src/resources/dependencies.js.dart';
import 'package:graphify/src/resources/index.html.dart';
import 'package:graphify/src/resources/lib/echarts.gl.min.dart';
import 'package:graphify/src/view/_interface.dart' as g_view;
import 'package:webview_flutter/webview_flutter.dart';

/// Renders a chart in a WebView, on `dart:io` platforms.
class GraphifyView extends g_view.GraphifyView {
  /// Creates a chart view.
  const GraphifyView({
    super.key,
    super.controller,
    super.initialOptions,
    super.onConsoleMessage,
    super.onCreated,
    super.theme,
    super.renderer,
    super.echartsGl,
  });

  @override
  State<GraphifyView> createState() => _GraphifyViewState();
}

class _GraphifyViewState extends State<GraphifyView> {
  final _webView = WebViewController();
  late final _controller =
      (widget.controller ?? GraphifyController()) as GraphifyController;
  // Built once, so parent rebuilds skip the platform view subtree.
  late final Widget _view = WebViewWidget(controller: _webView);

  @override
  void initState() {
    super.initState();
    _controller.connector = _webView;
    // Fire and forget, one by one: a call a platform lacks must not stop the
    // page from loading.
    unawaited(_webView.setJavaScriptMode(JavaScriptMode.unrestricted));
    unawaited(_webView.setBackgroundColor(const Color(0x00000000)));
    unawaited(_webView.setOnConsoleMessage(widget.onConsoleMessage ?? (_) {}));
    unawaited(
      _webView.addJavaScriptChannel(
        JsMethods.eventChannel,
        onMessageReceived: (message) =>
            _controller.onChartClick(message.message),
      ),
    );
    unawaited(
      _webView.setNavigationDelegate(
        NavigationDelegate(onPageFinished: _onPageFinished),
      ),
    );
    unawaited(
      _webView.loadHtmlString(
        indexHtml(
          id: _controller.uid,
          dependencies: [
            '<script>$dependencies</script>',
            if (widget.loadsEchartsGl) '<script>$echartsGlMin</script>',
          ].join(),
          theme: widget.theme,
          renderer: widget.renderer,
        ),
      ),
    );
  }

  void _onPageFinished(String _) {
    widget.onCreated?.call();
    _controller.onPageLoaded(
      widget.initialOptions,
      echartsGl: widget.loadsEchartsGl,
    );
  }

  @override
  Widget build(BuildContext context) => _view;

  @override
  void dispose() {
    if (widget.controller == null) _controller.dispose();
    unawaited(_webView.clearLocalStorage());
    unawaited(_webView.clearCache());
    super.dispose();
  }
}
