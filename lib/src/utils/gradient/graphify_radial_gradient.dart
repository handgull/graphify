import 'package:graphify/src/utils/gradient/graphify_gradient.dart';

/// A radial gradient centered on (x, y) with radius r.
class GraphifyRadialGradient extends GraphifyGradient {
  /// Creates a radial gradient.
  const GraphifyRadialGradient({
    this.x = .5,
    this.y = .5,
    this.r = .5,
    super.colorStops,
    super.global,
    super.id,
  });

  @override
  String get type => 'radial';

  /// Center x.
  final num x;

  /// Center y.
  final num y;

  /// Radius.
  final num r;

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{...super.toJson(), 'x': x, 'y': y, 'r': r};
  }
}
