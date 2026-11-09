import 'package:flutter/widgets.dart';
import 'package:graphify/src/view/_interface.dart' as g_view;

/// The view for platforms that have neither `dart:io` nor `dart:js_interop`:
/// building it throws.
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
  @override
  Widget build(BuildContext context) =>
      throw UnimplementedError('GraphifyView is not implemented here');
}
