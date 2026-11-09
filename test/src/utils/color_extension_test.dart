import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:graphify/src/utils/color_extension.dart';

// Alphas are interpolated: the VM prints `1.0` where the web prints `1`.
void main() {
  group('[ColorExtension.toRGBA]', () {
    test('serializes an opaque color with 0-255 channels', () {
      expect(const Color(0xFF102030).toRGBA, 'rgba(16, 32, 48, ${1.0})');
    });

    test('keeps mid-range channels mid-range', () {
      expect(const Color(0xFF808080).toRGBA, 'rgba(128, 128, 128, ${1.0})');
    });

    test('serializes the extremes', () {
      expect(const Color(0xFFFFFFFF).toRGBA, 'rgba(255, 255, 255, ${1.0})');
      expect(const Color(0x00000000).toRGBA, 'rgba(0, 0, 0, ${0.0})');
    });

    test('writes the alpha as a 0-1 fraction', () {
      expect(const Color(0x80FF0000).toRGBA, 'rgba(255, 0, 0, ${128 / 255})');
    });

    test('clamps channels outside the sRGB range', () {
      const color = Color.from(
        alpha: 1,
        red: 1.5,
        green: -0.5,
        blue: 0.5,
        colorSpace: ColorSpace.extendedSRGB,
      );

      expect(color.toRGBA, 'rgba(255, 0, 128, ${1.0})');
    });
  });
}
