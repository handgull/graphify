import 'package:graphify/src/controller/interface.dart' as controller_interface;

/// The controller for platforms that have neither `dart:io` nor
/// `dart:js_interop`: every call throws.
class GraphifyController extends controller_interface.GraphifyController {
  @override
  Future<void> update(Map<String, dynamic>? options) {
    throw UnimplementedError('update() is not implemented');
  }

  @override
  void dispose() {
    throw UnimplementedError('dispose() is not implemented');
  }

  @override
  Future<void> applyOptions(Map<String, dynamic>? options) {
    throw UnimplementedError('applyOptions() is not implemented');
  }

  @override
  Future<void> disposeChart() {
    throw UnimplementedError('disposeChart() is not implemented');
  }
}
