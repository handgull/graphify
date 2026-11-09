import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:graphify/graphify.dart';

void main() {
  const red = Color(0xFFFF0000);
  const blue = Color(0xFF0000FF);
  const stops = [
    GraphifyGradientColorStop(offset: 0, color: red),
    GraphifyGradientColorStop(offset: 1, color: blue),
  ];
  const stopsJson = [
    {'offset': 0, 'color': 'rgba(255, 0, 0, ${1.0})'},
    {'offset': 1, 'color': 'rgba(0, 0, 255, ${1.0})'},
  ];

  group('[GraphifyGradientColorStop.toJson]', () {
    test('serializes the offset and the color as CSS rgba', () {
      expect(
        const GraphifyGradientColorStop(offset: 0.25, color: red).toJson(),
        {'offset': 0.25, 'color': 'rgba(255, 0, 0, ${1.0})'},
      );
    });
  });

  group('[GraphifyLinearGradient]', () {
    test('runs left to right with no stops by default', () {
      expect(const GraphifyLinearGradient().toJson(), {
        'type': 'linear',
        'colorStops': <Object>[],
        'global': false,
        'x': 0,
        'y': 0,
        'x2': 1,
        'y2': 0,
      });
    });

    test('serializes every field it is given', () {
      expect(
        const GraphifyLinearGradient(
          x: 0.1,
          y: 0.2,
          x2: 0.3,
          y2: 0.4,
          colorStops: stops,
          global: true,
          id: 7,
        ).toJson(),
        {
          'id': 7,
          'type': 'linear',
          'colorStops': stopsJson,
          'global': true,
          'x': 0.1,
          'y': 0.2,
          'x2': 0.3,
          'y2': 0.4,
        },
      );
    });
  });

  group('[GraphifyRadialGradient]', () {
    test('is centered with a half radius and no stops by default', () {
      expect(const GraphifyRadialGradient().toJson(), {
        'type': 'radial',
        'colorStops': <Object>[],
        'global': false,
        'x': 0.5,
        'y': 0.5,
        'r': 0.5,
      });
    });

    test('serializes every field it is given', () {
      expect(
        const GraphifyRadialGradient(
          x: 0.1,
          y: 0.2,
          r: 0.3,
          colorStops: stops,
          global: true,
          id: 3,
        ).toJson(),
        {
          'id': 3,
          'type': 'radial',
          'colorStops': stopsJson,
          'global': true,
          'x': 0.1,
          'y': 0.2,
          'r': 0.3,
        },
      );
    });
  });

  group('[GraphifyGradient.addColorStop]', () {
    test('appends to a growable stop list, in order', () {
      final gradient =
          GraphifyLinearGradient(colorStops: List.empty(growable: true))
            ..addColorStop(0, red)
            ..addColorStop(1, blue);

      expect(gradient.toJson()['colorStops'], stopsJson);
    });

    test('throws on the default constant stop list', () {
      expect(
        () => const GraphifyRadialGradient().addColorStop(0, red),
        throwsUnsupportedError,
      );
    });
  });
}
