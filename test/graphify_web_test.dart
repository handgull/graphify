@TestOn('browser')
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:graphify/graphify.dart';
import 'package:graphify/src/controller/implements/web.dart' as web;
import 'package:graphify/src/view/implements/web.dart' as web;

void main() {
  group('[graphify] on the web', () {
    test('exports the iframe controller', () {
      expect(GraphifyController(), isA<web.GraphifyController>());
    });

    test('exports the iframe view', () {
      expect(const GraphifyView(), isA<web.GraphifyView>());
    });

    test('exports the renderers', () {
      expect(GraphifyRenderer.values, [
        GraphifyRenderer.canvas,
        GraphifyRenderer.svg,
      ]);
    });
  });
}
