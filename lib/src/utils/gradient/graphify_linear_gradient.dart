import 'package:graphify/src/utils/gradient/graphify_gradient.dart';

/// A linear gradient from (x, y) to (x2, y2); left to right by default.
class GraphifyLinearGradient extends GraphifyGradient {
  /// Creates a linear gradient.
  const GraphifyLinearGradient({
    this.x = 0,
    this.y = 0,
    this.x2 = 1,
    this.y2 = 0,
    super.colorStops,
    super.global,
    super.id,
  });

  @override
  String get type => 'linear';

  /// Start x.
  final num x;

  /// Start y.
  final num y;

  /// End x.
  final num x2;

  /// End y.
  final num y2;

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      ...super.toJson(),
      'x': x,
      'y': y,
      'x2': x2,
      'y2': y2,
    };
  }
}
