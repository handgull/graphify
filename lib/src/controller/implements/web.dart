import 'dart:convert';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:graphify/src/controller/interface.dart' as controller_interface;
import 'package:graphify/src/controller/js_methods.dart';
import 'package:web/web.dart';

/// The controller for the web: it calls the chart functions `GraphifyView`
/// installs on the host page's `window`.
class GraphifyController extends controller_interface.GraphifyController {
  @override
  Future<void> applyOptions(Map<String, dynamic>? options) async {
    window.callMethod(
      JsMethods.updateChart.toJS,
      uid.toJS,
      jsonEncode(options ?? {}).toJS,
    );
  }

  @override
  Future<void> disposeChart() async {
    window.callMethod(JsMethods.disposeChart.toJS, uid.toJS);
  }
}
