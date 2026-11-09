/// How echarts draws a chart.
enum GraphifyRenderer {
  /// Draws on a canvas: the better fit for large data sets.
  canvas,

  /// Draws SVG: sharper and lighter on memory for small charts.
  svg,
}
