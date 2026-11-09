@TestOn('browser')
library;

import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:flutter_test/flutter_test.dart';
import 'package:graphify/src/controller/implements/web.dart';

void main() {
  late List<List<String>> calls;
  late GraphifyController controller;

  setUp(() {
    calls = [];
    globalContext['updateChart'] = (JSString id, JSString options) {
      calls.add(['updateChart', id.toDart, options.toDart]);
    }.toJS;
    globalContext['disposeChart'] = (JSString id) {
      calls.add(['disposeChart', id.toDart]);
    }.toJS;
    controller = GraphifyController();
  });

  group('[GraphifyController.update] on the web', () {
    test(
      'waits for the page, then calls window.updateChart in order',
      () async {
        final update = controller.update({
          'series': [1, 2],
        });
        await pumpEventQueue();
        expect(calls, isEmpty);

        controller.onPageLoaded(null);
        await update;

        expect(calls, [
          ['updateChart', controller.uid, '{}'],
          ['updateChart', controller.uid, '{"series":[1,2]}'],
        ]);
      },
    );
  });

  group('[GraphifyController.dispose] on the web', () {
    test('calls window.disposeChart once the page has loaded', () async {
      controller
        ..onPageLoaded(null)
        ..dispose();
      await pumpEventQueue();

      expect(calls.last, ['disposeChart', controller.uid]);
    });

    test('calls nothing for a page that never loaded', () async {
      controller.dispose();
      await pumpEventQueue();

      expect(calls, isEmpty);
    });
  });
}
