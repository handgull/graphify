@TestOn('vm')
library;

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:graphify/src/controller/implements/mobile.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../helpers/fake_webview_platform.dart';

void main() {
  late FakeWebViewController webView;
  late GraphifyController controller;

  setUp(() {
    final platform = registerFakeWebViewPlatform();
    controller = GraphifyController()..connector = WebViewController();
    webView = platform.controllers.single;
  });

  String updateScript(String json) =>
      'window.updateChart("${controller.uid}", $json)';

  group('[GraphifyController.update]', () {
    group('before the page has loaded', () {
      test('runs nothing', () async {
        unawaited(controller.update({'a': 1}));
        await pumpEventQueue();

        expect(webView.scripts, isEmpty);
      });

      test(
        'waits for it, then runs after the initial options, in order',
        () async {
          final updates = [
            controller.update({'a': 1}),
            controller.update({'b': 2}),
          ];

          controller.onPageLoaded({'initial': true});
          await Future.wait(updates);

          expect(webView.scripts, [
            updateScript('{"initial":true}'),
            updateScript('{"a":1}'),
            updateScript('{"b":2}'),
          ]);
        },
      );
    });

    group('once the page has loaded', () {
      setUp(() => controller.onPageLoaded(null));

      test(
        'calls updateChart with the quoted uid and the JSON options',
        () async {
          await controller.update({
            'title': {'text': 'a "quoted" title'},
          });

          expect(
            webView.scripts.last,
            updateScript(r'{"title":{"text":"a \"quoted\" title"}}'),
          );
        },
      );

      test('sends empty options for null', () async {
        await controller.update(null);

        expect(webView.scripts, [updateScript('{}'), updateScript('{}')]);
      });

      test('completes once the WebView has run the script', () async {
        var ran = false;
        webView.onRunJavaScript = (_) async {
          await Future<void>.delayed(Duration.zero);
          ran = true;
        };

        await controller.update(null);

        expect(ran, isTrue);
      });

      test('fails the future with the WebView error', () async {
        webView.onRunJavaScript = (_) async => throw StateError('no page');

        await expectLater(controller.update(null), throwsStateError);
      });

      test('keeps going after a failed call', () async {
        webView.onRunJavaScript = (js) async {
          if (js.contains('"fail"')) {
            throw StateError('boom');
          }
        };

        await expectLater(controller.update({'fail': 1}), throwsStateError);
        await controller.update({'ok': 1});

        expect(webView.scripts.last, updateScript('{"ok":1}'));
      });
    });

    group('with echarts-gl options', () {
      final options = {
        'series': [
          {'type': 'bar3D'},
        ],
      };

      test('fails when the page did not load echarts-gl', () async {
        controller.onPageLoaded(null);

        await expectLater(
          controller.update(options),
          throwsA(
            isA<StateError>().having(
              (e) => e.message,
              'message',
              contains('echartsGl: true'),
            ),
          ),
        );
        expect(webView.scripts, [updateScript('{}')]);
      });

      test('applies them when it did', () async {
        controller.onPageLoaded(null, echartsGl: true);

        await controller.update(options);

        expect(
          webView.scripts.last,
          updateScript('{"series":[{"type":"bar3D"}]}'),
        );
      });
    });

    test('reports the errors of updates nobody awaits', () async {
      controller.onPageLoaded(null);
      webView.onRunJavaScript = (_) async => throw StateError('boom');
      final errors = <Object>[];

      await runZonedGuarded(() async {
        unawaited(controller.update({'a': 1}));
        await pumpEventQueue();
      }, (error, _) => errors.add(error));

      expect(errors, [isA<StateError>()]);
    });
  });

  group('[GraphifyController.onPageLoaded]', () {
    test('reapplies the initial options on every load', () async {
      controller
        ..onPageLoaded({'v': 1})
        ..onPageLoaded({'v': 1});
      await pumpEventQueue();

      expect(webView.scripts, [
        updateScript('{"v":1}'),
        updateScript('{"v":1}'),
      ]);
    });
  });

  group('[GraphifyController.chartClickedEvent]', () {
    test('streams every JSON object the page posts', () async {
      final events = <Map<String, dynamic>>[];
      controller.chartClickedEvent.listen(events.add);

      controller
        ..onChartClick('{"seriesName":"a","dataIndex":2}')
        ..onChartClick('{"chartZoomed":true}');
      await pumpEventQueue();

      expect(events, [
        {'seriesName': 'a', 'dataIndex': 2},
        {'chartZoomed': true},
      ]);
    });

    test('drops messages that are not JSON objects', () async {
      final events = <Map<String, dynamic>>[];
      controller.chartClickedEvent.listen(events.add);

      controller
        ..onChartClick('not json')
        ..onChartClick('[1, 2]')
        ..onChartClick('"text"');
      await pumpEventQueue();

      expect(events, isEmpty);
    });

    test('closes on dispose and ignores late messages', () async {
      final done = expectLater(controller.chartClickedEvent, emitsDone);

      controller
        ..dispose()
        ..onChartClick('{"late":true}');

      await done;
    });
  });

  group('[GraphifyController.dispose]', () {
    test(
      'calls disposeChart with the quoted uid, after pending updates',
      () async {
        unawaited(controller.update({'a': 1}));
        controller
          ..dispose()
          ..onPageLoaded(null);
        await pumpEventQueue();

        expect(webView.scripts, [
          updateScript('{}'),
          updateScript('{"a":1}'),
          'window.disposeChart("${controller.uid}")',
        ]);
      },
    );
  });

  group('[GraphifyController.connector]', () {
    test('can only be attached once', () {
      expect(
        () => controller.connector = WebViewController(),
        throwsA(isA<Error>()),
      );
    });
  });
}
