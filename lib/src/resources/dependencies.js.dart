import 'package:graphify/src/controller/js_methods.dart';
import 'package:graphify/src/resources/lib/echarts.min.dart';

/// Every script a chart page needs: echarts and [chartScripts]. echarts-gl
/// comes on top, only for the charts that use it.
const dependencies = '$echartsMin $chartScripts';

/// The chart registry and the [JsMethods] functions acting on it.
const String chartScripts =
    """
    
    const graphify_charts = {};

    // Web only: the event handler each GraphifyView registers, by chart id.
    var graphify_handlers = {};

    const graphify_click_keys = [
      'componentType', 'componentSubType', 'componentIndex',
      'seriesType', 'seriesIndex', 'seriesId', 'seriesName',
      'name', 'dataIndex', 'dataType', 'data', 'value', 'color',
    ];
    
    function ${JsMethods.initChart}(chart_id, chart, option) {
      option = ${JsMethods.normalizeJson}(option);
      chart.setOption(option);
      graphify_charts[chart_id] = { chart, option };
      chart.on('click', function (params) {
        const event = {};
        graphify_click_keys.forEach(function (key) {
          if (params[key] !== undefined) event[key] = params[key];
        });
        postChartEvent(chart_id, event);
      });
    }

    // Mobile pages host one chart and post on the WebView channel; on the
    // web every chart shares the host page, so events go by chart id.
    function postChartEvent(chart_id, event) {
      const message = JSON.stringify(event);
      if (window.${JsMethods.eventChannel}) {
        window.${JsMethods.eventChannel}.postMessage(message);
      } else if (graphify_handlers[chart_id]) {
        graphify_handlers[chart_id](message);
      }
    }
    
    function ${JsMethods.updateChart}(chart_id, option) {
      if (!graphify_charts[chart_id]) return;
      const chart = graphify_charts[chart_id].chart;
      option = ${JsMethods.normalizeJson}(option);
      chart.setOption(option);
      graphify_charts[chart_id].option = option;
    }
    
    function ${JsMethods.disposeChart} (chart_id) {
      const chart = graphify_charts[chart_id]?.chart;
      if (!chart) return;
      chart.dispose();
      delete graphify_charts[chart_id];
    }
    
    function ${JsMethods.normalizeJson}(option) {
      if (typeof option === 'object') return option;
      if (option instanceof String && option.length === 0 || option == null) return {};
      return JSON.parse(option);
    }
    
""";
