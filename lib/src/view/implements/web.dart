import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:ui_web';

import 'package:flutter/widgets.dart';
import 'package:graphify/src/controller/implements/web.dart';
import 'package:graphify/src/controller/interface.dart' as controller_interface;
import 'package:graphify/src/resources/dependencies.js.dart';
import 'package:graphify/src/resources/index.html.dart';
import 'package:graphify/src/resources/lib/echarts.gl.min.dart';
import 'package:graphify/src/utils/inject_script.dart';
import 'package:graphify/src/view/_interface.dart' as g_view;
import 'package:web/web.dart';

/// Renders a chart in an iframe, on the web.
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
  late final controller_interface.GraphifyController _controller =
      widget.controller ?? GraphifyController();

  // Built once, so parent rebuilds skip the platform view subtree.
  late final Widget _view = HtmlElementView(viewType: _uid);

  String get _uid => _controller.uid;

  // Declared by chartScripts: the iframes run their charts in this page.
  JSObject get _handlers => globalContext['graphify_handlers']! as JSObject;

  @override
  void initState() {
    super.initState();
    injectScript('graphify-chart-dependency', dependencies);
    // Before the iframe exists: echarts-gl must load before its chart.
    if (widget.loadsEchartsGl) {
      injectScript('graphify-chart-gl', echartsGlMin);
    }
    _handlers[_uid] = (JSString message) {
      _controller.onChartClick(message.toDart);
    }.toJS;
    platformViewRegistry.registerViewFactory(_uid, _createIFrame);
    widget.onCreated?.call();
  }

  @override
  Widget build(BuildContext context) => _view;

  HTMLIFrameElement _createIFrame(int _) => HTMLIFrameElement()
    ..id = 'graphify_$_uid'
    ..style.width = '100%'
    ..style.height = '100%'
    ..style.border = 'none'
    ..srcdoc = indexHtml(
      id: _uid,
      theme: widget.theme,
      renderer: widget.renderer,
    ).toJS
    ..onLoad.listen(
      (_) => _controller.onPageLoaded(
        widget.initialOptions,
        echartsGl: widget.loadsEchartsGl,
      ),
    )
    ..onError.listen(widget.onConsoleMessage);

  @override
  void dispose() {
    _handlers.delete(_uid.toJS);
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }
}
