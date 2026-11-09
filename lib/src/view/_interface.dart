import 'package:flutter/widgets.dart';
import 'package:graphify/src/controller/interface.dart';
import 'package:graphify/src/utils/echarts_gl.dart';
import 'package:graphify/src/view/console_message.dart';
import 'package:graphify/src/view/graphify_renderer.dart';

/// The constructor contract every platform's `GraphifyView` shares.
abstract class GraphifyView extends StatefulWidget {
  /// Creates a chart view.
  const GraphifyView({
    super.key,
    this.controller,
    this.initialOptions,
    this.onConsoleMessage,
    this.onCreated,
    this.theme = 'dark',
    this.renderer = GraphifyRenderer.canvas,
    this.echartsGl = false,
  });

  /// Drives the chart; when `null` the view creates and disposes its own.
  final GraphifyController? controller;

  /// The echarts options applied once the chart page has loaded.
  final Map<String, dynamic>? initialOptions;

  /// Receives the chart page's console messages (mobile) or errors (web).
  final OnConsoleMessage? onConsoleMessage;

  /// Called once the chart is ready to be driven by [controller].
  final VoidCallback? onCreated;

  /// The echarts theme: a registered theme name (`'dark'`, `'default'`), a
  /// theme object, or `null` for the default theme.
  final Object? theme;

  /// How echarts draws the chart.
  final GraphifyRenderer renderer;

  /// Whether to load echarts-gl, for 3D and GL components and series.
  ///
  /// [initialOptions] using them load it on their own: this is only needed
  /// when they arrive later, through `GraphifyController.update`, since
  /// echarts-gl must be loaded before the chart is created.
  final bool echartsGl;

  /// Whether this chart loads echarts-gl.
  bool get loadsEchartsGl => echartsGl || needsEchartsGl(initialOptions);
}
