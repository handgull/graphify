import 'package:flutter_test/flutter_test.dart';
import 'package:graphify/src/utils/echarts_gl.dart';

void main() {
  group('[needsEchartsGl]', () {
    test('is false for no options', () {
      expect(needsEchartsGl(null), isFalse);
      expect(needsEchartsGl({}), isFalse);
    });

    test('is false for plain echarts options', () {
      expect(
        needsEchartsGl({
          'xAxis': {'type': 'category'},
          'series': [
            {'type': 'bar'},
            {'type': 'line'},
          ],
        }),
        isFalse,
      );
    });

    for (final component in [
      'grid3D',
      'xAxis3D',
      'yAxis3D',
      'zAxis3D',
      'geo3D',
      'globe',
      'mapbox3D',
      'maptalks3D',
    ]) {
      test('is true for the $component component', () {
        expect(needsEchartsGl({component: <String, dynamic>{}}), isTrue);
      });
    }

    for (final type in [
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
    ]) {
      test('is true for a $type series', () {
        expect(
          needsEchartsGl({
            'series': [
              {'type': 'line'},
              {'type': type},
            ],
          }),
          isTrue,
        );
      });
    }

    test('reads a single series given as a map', () {
      expect(
        needsEchartsGl({
          'series': {'type': 'scatterGL'},
        }),
        isTrue,
      );
    });

    test('reads timeline base options and option sets', () {
      expect(
        needsEchartsGl({
          'baseOption': {'globe': <String, dynamic>{}},
        }),
        isTrue,
      );
      expect(
        needsEchartsGl({
          'options': [
            {'title': 'plain'},
            {
              'series': [
                {'type': 'bar3D'},
              ],
            },
          ],
        }),
        isTrue,
      );
    });

    test('ignores series entries that are not maps', () {
      expect(
        needsEchartsGl({
          'series': ['bar3D', 3, null],
        }),
        isFalse,
      );
    });
  });
}
