@TestOn('vm')
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:graphify/graphify.dart';
import 'package:graphify/src/controller/implements/mobile.dart' as mobile;
import 'package:graphify/src/view/implements/mobile.dart' as mobile;

void main() {
  group('[graphify] on dart:io platforms', () {
    test('exports the WebView controller', () {
      expect(GraphifyController(), isA<mobile.GraphifyController>());
    });

    test('exports the WebView view', () {
      expect(const GraphifyView(), isA<mobile.GraphifyView>());
    });

    test('exports the renderers', () {
      expect(GraphifyRenderer.values, [
        GraphifyRenderer.canvas,
        GraphifyRenderer.svg,
      ]);
    });
  });
}
