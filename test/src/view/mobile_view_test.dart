@TestOn('vm')
library;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:graphify/graphify.dart' show GraphifyRenderer;
import 'package:graphify/src/controller/implements/mobile.dart';
import 'package:graphify/src/resources/dependencies.js.dart';
import 'package:graphify/src/resources/index.html.dart';
import 'package:graphify/src/resources/lib/echarts.gl.min.dart';
import 'package:graphify/src/view/implements/mobile.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../helpers/fake_webview_platform.dart';

void main() {
  late FakeWebViewPlatform platform;

  setUp(() => platform = registerFakeWebViewPlatform());

  FakeWebViewController webView() => platform.controllers.single;

  group('[GraphifyView] on mobile', () {
    testWidgets('renders a WebView', (tester) async {
      await tester.pumpWidget(const GraphifyView());

      expect(find.byType(WebViewWidget), findsOneWidget);
    });

    testWidgets('keeps one WebView widget however often it rebuilds', (
      tester,
    ) async {
      WebViewWidget view() => tester.widget(find.byType(WebViewWidget));
      await tester.pumpWidget(const GraphifyView());
      final first = view();

      await tester.pumpWidget(const GraphifyView(initialOptions: {'a': 1}));

      expect(platform.controllers, hasLength(1));
      expect(view(), same(first));
    });

    testWidgets('enables JavaScript on a transparent background', (
      tester,
    ) async {
      await tester.pumpWidget(const GraphifyView());

      expect(webView().javaScriptMode, JavaScriptMode.unrestricted);
      expect(webView().backgroundColor, const Color(0x00000000));
    });

    testWidgets('loads the chart page for its controller with every script '
        'inlined', (tester) async {
      final controller = GraphifyController();

      await tester.pumpWidget(GraphifyView(controller: controller));

      expect(
        webView().html,
        indexHtml(
          id: controller.uid,
          dependencies: '<script>$dependencies</script>',
        ),
      );
    });

    group('loads echarts-gl', () {
      const bar3D = {
        'series': [
          {'type': 'bar3D'},
        ],
      };

      testWidgets('not for a plain chart', (tester) async {
        await tester.pumpWidget(const GraphifyView(initialOptions: {'a': 1}));

        expect(webView().html, isNot(contains(echartsGlMin)));
      });

      for (final (name, view) in [
        ('for 3D initial options', const GraphifyView(initialOptions: bar3D)),
        ('when asked to', const GraphifyView(echartsGl: true)),
      ]) {
        testWidgets('$name, after echarts and before the chart', (
          tester,
        ) async {
          await tester.pumpWidget(view);
          final html = webView().html!;

          expect(
            html.indexOf(echartsGlMin),
            allOf(
              greaterThan(html.indexOf(dependencies)),
              lessThan(html.indexOf('echarts.init(')),
            ),
          );
        });
      }

      testWidgets('and lets the controller apply 3D options', (tester) async {
        final controller = GraphifyController();
        await tester.pumpWidget(
          GraphifyView(controller: controller, echartsGl: true),
        );
        webView().finishPageLoad();

        await controller.update(bar3D);

        expect(webView().scripts.last, contains('bar3D'));
      });
    });

    testWidgets('draws the chart with the given theme and renderer', (
      tester,
    ) async {
      final controller = GraphifyController();

      await tester.pumpWidget(
        GraphifyView(
          controller: controller,
          theme: null,
          renderer: GraphifyRenderer.svg,
        ),
      );

      expect(
        webView().html,
        indexHtml(
          id: controller.uid,
          dependencies: '<script>$dependencies</script>',
          theme: null,
          renderer: GraphifyRenderer.svg,
        ),
      );
    });

    testWidgets('listens for the page load before starting it', (tester) async {
      await tester.pumpWidget(const GraphifyView());

      expect(webView().calls, [
        'setJavaScriptMode',
        'setBackgroundColor',
        'setOnConsoleMessage',
        'addJavaScriptChannel',
        'setPlatformNavigationDelegate',
        'loadHtmlString',
      ]);
    });

    testWidgets('drives the WebView through the given controller', (
      tester,
    ) async {
      final controller = GraphifyController();
      await tester.pumpWidget(GraphifyView(controller: controller));
      webView().finishPageLoad();

      await controller.update({'a': 1});

      expect(
        webView().scripts.last,
        'window.updateChart("${controller.uid}", {"a":1})',
      );
    });

    testWidgets('runs nothing until the page has loaded', (tester) async {
      await tester.pumpWidget(const GraphifyView(initialOptions: {'a': 1}));

      expect(webView().scripts, isEmpty);
    });

    testWidgets('applies updates sent before the page loaded once it has', (
      tester,
    ) async {
      final controller = GraphifyController();
      await tester.pumpWidget(GraphifyView(controller: controller));
      final update = controller.update({'early': 1});

      webView().finishPageLoad();
      await tester.runAsync(() => update);

      expect(webView().scripts, [
        'window.updateChart("${controller.uid}", {})',
        'window.updateChart("${controller.uid}", {"early":1})',
      ]);
    });

    testWidgets('streams the events the page posts on its channel', (
      tester,
    ) async {
      final controller = GraphifyController();
      final events = <Map<String, dynamic>>[];
      controller.chartClickedEvent.listen(events.add);
      await tester.pumpWidget(GraphifyView(controller: controller));

      webView().postMessage('ClickEventChannel', '{"seriesName":"a"}');
      await tester.pump();

      expect(events, [
        {'seriesName': 'a'},
      ]);
    });

    group('once the page has loaded', () {
      testWidgets('reports the chart created, once', (tester) async {
        var created = 0;
        await tester.pumpWidget(GraphifyView(onCreated: () => created++));

        webView().finishPageLoad();

        expect(created, 1);
      });

      for (final (options, json) in [
        (const {'a': 1}, '{"a":1}'),
        (null, '{}'),
      ]) {
        testWidgets('applies the initial options $options', (tester) async {
          final controller = GraphifyController();
          await tester.pumpWidget(
            GraphifyView(controller: controller, initialOptions: options),
          );

          webView().finishPageLoad();
          await tester.pump();

          expect(webView().scripts, [
            'window.updateChart("${controller.uid}", $json)',
          ]);
        });
      }

      testWidgets('reports creation before applying the options', (
        tester,
      ) async {
        late int scriptsWhenCreated;
        await tester.pumpWidget(
          GraphifyView(
            initialOptions: const {'a': 1},
            onCreated: () => scriptsWhenCreated = webView().scripts.length,
          ),
        );

        webView().finishPageLoad();
        await tester.pump();

        expect(scriptsWhenCreated, 0);
        expect(webView().scripts, hasLength(1));
      });

      testWidgets('uses the latest widget configuration', (tester) async {
        final controller = GraphifyController();
        var created = '';
        await tester.pumpWidget(
          GraphifyView(
            controller: controller,
            initialOptions: const {'v': 1},
            onCreated: () => created = 'first',
          ),
        );
        await tester.pumpWidget(
          GraphifyView(
            controller: controller,
            initialOptions: const {'v': 2},
            onCreated: () => created = 'second',
          ),
        );

        webView().finishPageLoad();
        await tester.pump();

        expect(created, 'second');
        expect(webView().scripts.single, contains('{"v":2}'));
      });
    });

    group('with console messages', () {
      const message = JavaScriptConsoleMessage(
        level: JavaScriptLogLevel.error,
        message: 'boom',
      );

      testWidgets('forwards them to onConsoleMessage', (tester) async {
        final received = <Object>[];
        await tester.pumpWidget(GraphifyView(onConsoleMessage: received.add));

        webView().onConsoleMessage!(message);

        expect(received, [message]);
      });

      testWidgets('swallows them without onConsoleMessage', (tester) async {
        await tester.pumpWidget(const GraphifyView());

        webView().onConsoleMessage!(message);

        expect(tester.takeException(), isNull);
      });
    });

    group('when disposed', () {
      testWidgets('disposes the chart it created itself', (tester) async {
        await tester.pumpWidget(const GraphifyView());
        webView().finishPageLoad();

        await tester.pumpWidget(const SizedBox());
        await tester.pump();

        expect(webView().scripts.last, startsWith('window.disposeChart("'));
      });

      testWidgets('runs nothing for a page that never loaded', (tester) async {
        await tester.pumpWidget(const GraphifyView());

        await tester.pumpWidget(const SizedBox());
        await tester.pump();

        expect(webView().scripts, isEmpty);
      });

      testWidgets('leaves a given controller to its owner, clearing the '
          'WebView storage and cache', (tester) async {
        await tester.pumpWidget(GraphifyView(controller: GraphifyController()));

        await tester.pumpWidget(const SizedBox());

        expect(webView().scripts, isEmpty);
        expect(
          webView().calls,
          containsAllInOrder(['clearLocalStorage', 'clearCache']),
        );
      });
    });
  });
}
