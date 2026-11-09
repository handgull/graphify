import 'dart:ui';
import 'package:graphify/src/utils/color_extension.dart';

/// An echarts gradient fill, serialized by [toJson].
abstract class GraphifyGradient {
  /// Creates a gradient through [colorStops].
  const GraphifyGradient({
    this.colorStops = const [],
    this.global = false,
    this.id,
  });

  /// The echarts gradient type.
  String get type;

  /// Optional echarts id of the gradient.
  final num? id;

  /// The colors the gradient passes through.
  final List<GraphifyGradientColorStop> colorStops;

  /// Whether the coordinates are in pixels rather than 0-1 fractions.
  final bool global;

  /// Appends a color stop; [colorStops] must be a growable list, not the
  /// default constant one.
  void addColorStop(num offset, Color color) {
    colorStops.add(GraphifyGradientColorStop(offset: offset, color: color));
  }

  /// The gradient as an echarts color object.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      if (id != null) 'id': id,
      'type': type,
      'colorStops': colorStops.map((e) => e.toJson()).toList(),
      'global': global,
    };
  }
}

/// One color of a [GraphifyGradient], at [offset] along it.
class GraphifyGradientColorStop {
  /// Creates a color stop.
  const GraphifyGradientColorStop({required this.offset, required this.color});

  /// Position along the gradient, from 0 to 1.
  final num offset;

  /// The color at [offset].
  final Color color;

  /// The stop as an echarts color stop.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{'offset': offset, 'color': color.toRGBA};
  }
}
