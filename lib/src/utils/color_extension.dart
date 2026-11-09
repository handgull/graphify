import 'dart:ui' show Color, ColorSpace;

/// CSS serialization of [Color], the form echarts expects.
extension ColorExtension on Color {
  /// The color as sRGB `rgba(r, g, b, a)`: channels 0-255, alpha 0-1.
  String get toRGBA {
    // The conversion maps other color spaces into sRGB, clamping as it goes.
    final c = withValues(colorSpace: ColorSpace.sRGB);
    return 'rgba(${_byte(c.r)}, ${_byte(c.g)}, ${_byte(c.b)}, ${c.a})';
  }

  static int _byte(double channel) => (channel * 255).round();
}
