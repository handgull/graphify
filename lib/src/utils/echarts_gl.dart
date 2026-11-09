const _glComponents = {
  'grid3D',
  'xAxis3D',
  'yAxis3D',
  'zAxis3D',
  'geo3D',
  'globe',
  'mapbox3D',
  'maptalks3D',
};

const _glSeries = {
  'bar3D',
  'line3D',
  'scatter3D',
  'lines3D',
  'map3D',
  'surface',
  'polygons3D',
  'scatterGL',
  'graphGL',
  'flowGL',
  'linesGL',
};

/// Whether [options] use an echarts-gl component or series, which only work
/// once echarts-gl is loaded.
bool needsEchartsGl(Map<String, dynamic>? options) {
  if (options == null) {
    return false;
  }
  if (options.keys.any(_glComponents.contains)) {
    return true;
  }
  final series = switch (options['series']) {
    final List<dynamic> list => list,
    final single => [single],
  };
  if (series.any((s) => s is Map && _glSeries.contains(s['type']))) {
    return true;
  }
  // Timeline options nest whole option sets.
  final nested = [
    options['baseOption'],
    if (options['options'] case final List<dynamic> list) ...list,
  ];
  return nested.any((o) => o is Map<String, dynamic> && needsEchartsGl(o));
}
