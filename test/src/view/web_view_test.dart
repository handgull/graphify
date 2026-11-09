@TestOn('browser')
library;

import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:graphify/src/controller/implements/web.dart';
import 'package:graphify/src/resources/dependencies.js.dart';
import 'package:graphify/src/resources/lib/echarts.gl.min.dart';
import 'package:graphify/src/view/implements/web.dart';
import 'package:web/web.dart';

void main() {
  NodeList dependencyScripts() =>
      document.querySelectorAll('#graphify-chart-dependency');

  group('[GraphifyView] on the web', () {
    testWidgets('loads the chart scripts into the page once', (tester) async {
      await tester.pumpWidget(
        const Row(
          textDirection: TextDirection.ltr,
          children: [
            Expanded(child: GraphifyView()),
            Expanded(child: GraphifyView()),
          ],
        ),
      );

      expect(dependencyScripts().length, 1);
      expect(
        (dependencyScripts().item(0)! as HTMLScriptElement).text,
        dependencies,
      );
      expect(dependencyScripts().item(0)!.parentElement, document.body);
    });

    // echarts-gl stays in the page once loaded: the plain case runs first.
    testWidgets('does not load echarts-gl for a plain chart', (tester) async {
      await tester.pumpWidget(const GraphifyView(initialOptions: {'a': 1}));

      expect(document.getElementById('graphify-chart-gl'), isNull);
    });

    testWidgets('loads echarts-gl into the page once, for 3D charts', (
      tester,
    ) async {
      await tester.pumpWidget(
        const Row(
          textDirection: TextDirection.ltr,
          children: [
            Expanded(child: GraphifyView(echartsGl: true)),
            Expanded(
              child: GraphifyView(
                initialOptions: {'globe': <String, dynamic>{}},
              ),
            ),
          ],
        ),
      );

      final scripts = document.querySelectorAll('#graphify-chart-gl');
      expect(scripts.length, 1);
      expect((scripts.item(0)! as HTMLScriptElement).text, echartsGlMin);
    });

    testWidgets('renders the platform view registered under its uid', (
      tester,
    ) async {
      final controller = GraphifyController();

      await tester.pumpWidget(GraphifyView(controller: controller));

      expect(
        tester.widget<HtmlElementView>(find.byType(HtmlElementView)).viewType,
        controller.uid,
      );
    });

    testWidgets('reports the chart created once, on first build', (
      tester,
    ) async {
      var created = 0;

      await tester.pumpWidget(GraphifyView(onCreated: () => created++));
      await tester.pumpWidget(GraphifyView(onCreated: () => created++));

      expect(created, 1);
    });

    group('when disposed', () {
      JSAny? handler(String uid) =>
          (globalContext['graphify_handlers']! as JSObject)[uid];

      testWidgets('stops routing events to its controller', (tester) async {
        final controller = GraphifyController();
        await tester.pumpWidget(GraphifyView(controller: controller));
        expect(handler(controller.uid), isNotNull);

        await tester.pumpWidget(const SizedBox());

        expect(handler(controller.uid), isNull);
      });

      testWidgets('leaves a given controller to its owner', (tester) async {
        final controller = GraphifyController();
        final events = <Map<String, dynamic>>[];
        controller.chartClickedEvent.listen(events.add);
        await tester.pumpWidget(GraphifyView(controller: controller));

        await tester.pumpWidget(const SizedBox());
        controller.onChartClick('{"still":"open"}');
        await tester.pump();

        expect(events, [
          {'still': 'open'},
        ]);
      });
    });
  });

  group('[chartScripts] in the page', () {
    late List<JSAny?> options;
    late int disposals;
    late JSObject chart;
    late Map<String, JSFunction> listeners;

    JSObject fakeChart(Map<String, JSFunction> listeners) => JSObject()
      ..['setOption'] = (JSAny? option) {
        options.add(option);
      }.toJS
      ..['dispose'] = () {
        disposals++;
      }.toJS
      ..['on'] = (JSString event, JSFunction listener) {
        listeners[event.toDart] = listener;
      }.toJS;

    setUp(() {
      options = [];
      disposals = 0;
      listeners = {};
      chart = fakeChart(listeners);
    });

    Future<void> loadScripts(WidgetTester tester) =>
        tester.pumpWidget(const GraphifyView());

    void call(String method, List<JSAny?> args) =>
        globalContext.callMethodVarArgs(method.toJS, args);

    testWidgets('initChart applies the initial options', (tester) async {
      await loadScripts(tester);

      call('initChart', ['init'.toJS, chart, '{"a":1}'.toJS]);

      expect(options.map((o) => o.dartify()), [
        {'a': 1},
      ]);
    });

    testWidgets('updateChart applies JSON options to a registered chart', (
      tester,
    ) async {
      await loadScripts(tester);
      call('initChart', ['update'.toJS, chart, JSObject()]);

      call('updateChart', ['update'.toJS, '{"b":[1,2]}'.toJS]);

      expect(options.map((o) => o.dartify()), [
        <Object?, Object?>{},
        {
          'b': [1, 2],
        },
      ]);
    });

    testWidgets('updateChart takes object options as they are', (tester) async {
      await loadScripts(tester);
      call('initChart', ['object'.toJS, chart, JSObject()]);
      final option = JSObject()..['c'] = 3.toJS;

      call('updateChart', ['object'.toJS, option]);

      expect(options.last, same(option));
    });

    testWidgets('updateChart ignores an unknown chart', (tester) async {
      await loadScripts(tester);

      call('updateChart', ['nobody'.toJS, '{}'.toJS]);

      expect(options, isEmpty);
    });

    testWidgets('disposeChart disposes and forgets the chart', (tester) async {
      await loadScripts(tester);
      call('initChart', ['dispose'.toJS, chart, JSObject()]);

      call('disposeChart', ['dispose'.toJS]);
      call('disposeChart', ['dispose'.toJS]);
      call('updateChart', ['dispose'.toJS, '{}'.toJS]);

      expect(disposals, 1);
      expect(options, hasLength(1));
    });

    testWidgets('initChart routes clicks to the clicked chart controller', (
      tester,
    ) async {
      final first = GraphifyController();
      final second = GraphifyController();
      final events = <String, List<Map<String, dynamic>>>{
        'first': [],
        'second': [],
      };
      first.chartClickedEvent.listen(events['first']!.add);
      second.chartClickedEvent.listen(events['second']!.add);
      await tester.pumpWidget(
        Row(
          textDirection: TextDirection.ltr,
          children: [
            Expanded(child: GraphifyView(controller: first)),
            Expanded(child: GraphifyView(controller: second)),
          ],
        ),
      );
      final secondListeners = <String, JSFunction>{};
      call('initChart', [first.uid.toJS, chart, JSObject()]);
      call('initChart', [second.uid.toJS, fakeChart(secondListeners), null]);

      secondListeners['click']!.callAsFunction(
        null,
        {
          'componentType': 'series',
          'seriesName': 'b',
          'dataIndex': 1,
          'value': [1, 2],
          'event': 'not forwarded',
        }.jsify(),
      );
      await tester.pump();

      expect(events['first'], isEmpty);
      expect(events['second'], [
        {
          'componentType': 'series',
          'seriesName': 'b',
          'dataIndex': 1,
          'value': [1, 2],
        },
      ]);
    });

    testWidgets('disposeChart ignores an unknown chart', (tester) async {
      await loadScripts(tester);

      call('disposeChart', ['nobody'.toJS]);

      expect(disposals, 0);
    });
  });
}
