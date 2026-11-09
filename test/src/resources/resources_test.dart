import 'package:flutter_test/flutter_test.dart';
import 'package:graphify/graphify.dart' show GraphifyRenderer;
import 'package:graphify/src/controller/js_methods.dart';
import 'package:graphify/src/resources/dependencies.js.dart';
import 'package:graphify/src/resources/index.html.dart';
import 'package:graphify/src/resources/lib/echarts.gl.min.dart';
import 'package:graphify/src/resources/lib/echarts.min.dart';

void main() {
  group('[JsMethods]', () {
    test('names the functions chartScripts defines', () {
      for (final method in [
        JsMethods.initChart,
        JsMethods.updateChart,
        JsMethods.disposeChart,
        JsMethods.normalizeJson,
      ]) {
        expect(chartScripts, contains('function $method'));
      }
    });
  });

  group('[chartScripts]', () {
    // Downstream controllers hook the chart registry directly.
    test('keeps every chart in the graphify_charts registry', () {
      expect(chartScripts, contains('const graphify_charts = {};'));
      expect(
        chartScripts,
        contains('graphify_charts[chart_id] = { chart, option };'),
      );
    });

    test('reports clicks through postChartEvent', () {
      expect(chartScripts, contains("chart.on('click', function (params) {"));
      expect(chartScripts, contains('postChartEvent(chart_id, event);'));
    });

    // The braintex_client fork hooks these names: keep them stable.
    test('keeps the contract downstream controllers rely on', () {
      expect(chartScripts, contains('window.ClickEventChannel.postMessage'));
      expect(chartScripts, contains('var graphify_handlers = {};'));
      expect(
        indexHtml(id: 'chart-id'),
        contains("initChart('chart-id', chart, {})"),
      );
    });

    test('normalizes the options before every setOption', () {
      expect(
        'option = ${JsMethods.normalizeJson}(option);'.allMatches(chartScripts),
        hasLength(2),
      );
    });
  });

  group('[dependencies]', () {
    test('chains echarts and chartScripts, leaving echarts-gl out', () {
      expect(dependencies, '$echartsMin $chartScripts');
      expect(dependencies, isNot(contains(echartsGlMin)));
    });

    test('bundles echarts 6', () {
      expect(echartsMin, contains('version="6.1.0"'));
    });
  });

  group('[indexHtml]', () {
    final html = indexHtml(id: 'abc');

    test('starts with the doctype', () {
      expect(html, startsWith('<!DOCTYPE html>'));
    });

    test('registers an empty chart under its id', () {
      expect(html, contains("context.initChart('abc', chart, {});"));
    });

    test('renders a dark canvas chart in the #chart element by default', () {
      expect(html, contains('<div id="chart"></div>'));
      expect(
        html,
        contains(
          'context.echarts.init(dom, "dark", '
          "{ renderer: 'canvas', useDirtyRect: false });",
        ),
      );
    });

    test('takes a theme name, a theme object or no theme', () {
      String init(Object? theme) => RegExp(
        r'echarts\.init\(dom, (.*), \{ renderer',
      ).firstMatch(indexHtml(id: 'abc', theme: theme))!.group(1)!;

      expect(init('default'), '"default"');
      expect(init(null), 'null');
      expect(
        init({
          'color': ['#f00'],
        }),
        '{"color":["#f00"]}',
      );
    });

    test('quotes theme names safely', () {
      expect(
        indexHtml(id: 'abc', theme: 'x", alert(1), "'),
        contains(r'echarts.init(dom, "x\", alert(1), \"", {'),
      );
    });

    test('draws with the requested renderer', () {
      expect(
        indexHtml(id: 'abc', renderer: GraphifyRenderer.svg),
        contains("{ renderer: 'svg', useDirtyRect: false }"),
      );
    });

    test('resizes the chart with the window', () {
      expect(
        html,
        contains("window.addEventListener('resize', chart.resize);"),
      );
    });

    test('runs echarts from the parent page when it has one', () {
      expect(
        html,
        contains(
          'const context = '
          '(window.parent && window.parent.window) || window || {};',
        ),
      );
    });

    test('inlines the dependencies before the chart script', () {
      final inlined = indexHtml(
        id: 'abc',
        dependencies: '<script>deps</script>',
      );

      expect(
        inlined.indexOf('<script>deps</script>'),
        allOf(isPositive, lessThan(inlined.indexOf('context.initChart'))),
      );
    });

    test('inlines nothing without dependencies', () {
      expect(html, indexHtml(id: 'abc', dependencies: ''));
    });

    test('keeps the background transparent', () {
      expect(html, contains('background-color: transparent;'));
    });
  });
}
