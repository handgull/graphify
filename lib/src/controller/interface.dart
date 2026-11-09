import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:graphify/src/utils/echarts_gl.dart';
import 'package:graphify/src/utils/uid.dart';

/// Drives one chart: pushes new options to it, reports its events and
/// releases it.
abstract class GraphifyController {
  /// Creates a controller bound to a fresh, random [uid].
  GraphifyController() : uid = UID.generate();

  /// Identifies the chart instance on the JavaScript side.
  final String uid;

  final _loaded = Completer<void>();
  var _echartsGl = false;
  final _events = StreamController<Map<String, dynamic>>.broadcast();

  /// The chart's events: every click, with the fields echarts reports
  /// (`componentType`, `seriesName`, `dataIndex`, `value`...), plus any JSON
  /// object the page posts itself.
  Stream<Map<String, dynamic>> get chartClickedEvent => _events.stream;

  /// Replaces the chart options; `null` stands for an empty option set.
  ///
  /// Updates sent before the chart page has loaded wait for it, in order.
  /// Options using echarts-gl fail unless the chart loaded it: see
  /// `GraphifyView.echartsGl`.
  Future<void> update(Map<String, dynamic>? options) async {
    await _loaded.future;
    if (!_echartsGl && needsEchartsGl(options)) {
      throw StateError(
        'These options use echarts-gl, which this chart did not load: '
        'create its GraphifyView with echartsGl: true.',
      );
    }
    await applyOptions(options);
  }

  /// Releases the chart instance and closes [chartClickedEvent].
  void dispose() {
    unawaited(_loaded.future.then((_) => disposeChart()));
    unawaited(_events.close());
  }

  /// Called by `GraphifyView` each time the chart page loads, telling
  /// whether it loaded echarts-gl: applies [initialOptions], then, the first
  /// time, the updates waiting for the page.
  void onPageLoaded(
    Map<String, dynamic>? initialOptions, {
    bool echartsGl = false,
  }) {
    _echartsGl = echartsGl;
    // Each call sends its script at once: the initial options go out before
    // the waiting updates, which only resume once the page is marked loaded.
    unawaited(applyOptions(initialOptions));
    if (!_loaded.isCompleted) {
      _loaded.complete();
    }
  }

  /// Called by `GraphifyView` with each message the chart page posts:
  /// anything but a JSON object is dropped.
  void onChartClick(String message) {
    final Object? event;
    try {
      event = jsonDecode(message);
    } on FormatException {
      return;
    }
    if (event is Map<String, dynamic> && !_events.isClosed) {
      _events.add(event);
    }
  }

  /// Sends [options] to the loaded chart, starting the call synchronously so
  /// calls reach the page in the order they were made.
  @protected
  Future<void> applyOptions(Map<String, dynamic>? options);

  /// Disposes the loaded chart.
  @protected
  Future<void> disposeChart();
}
