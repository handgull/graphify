import 'dart:convert';

import 'package:graphify/src/controller/interface.dart' as controller_interface;
import 'package:graphify/src/controller/js_methods.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// The controller for `dart:io` platforms: it talks to the chart page
/// through the [WebViewController] `GraphifyView` hands it.
class GraphifyController extends controller_interface.GraphifyController {
  late final WebViewController _connector;

  /// The WebView hosting the chart; set once, by `GraphifyView`.
  // A setter, not a field: subclasses override it to grab the WebView.
  // ignore: avoid_setters_without_getters
  set connector(WebViewController connector) => _connector = connector;

  @override
  Future<void> applyOptions(Map<String, dynamic>? options) =>
      _call(JsMethods.updateChart, [jsonEncode(options ?? {})]);

  @override
  Future<void> disposeChart() => _call(JsMethods.disposeChart, const []);

  Future<void> _call(String method, List<String> args) =>
      _connector.runJavaScript(
        'window.$method(${[jsonEncode(uid), ...args].join(', ')})',
      );
}
