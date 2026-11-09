/// Names of the chart functions defined in `chartScripts`.
abstract final class JsMethods {
  /// Registers an echarts instance under a chart id.
  static const initChart = 'initChart';

  /// Replaces the options of a registered chart.
  static const updateChart = 'updateChart';

  /// Disposes a registered chart and forgets it.
  static const disposeChart = 'disposeChart';

  /// Turns an option payload (object or JSON string) into an object.
  static const normalizeJson = 'normalizeJson';

  /// The mobile WebView channel chart events are posted on.
  static const eventChannel = 'ClickEventChannel';
}
