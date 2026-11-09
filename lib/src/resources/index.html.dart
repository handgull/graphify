// The page must start with its doctype.
// ignore_for_file: leading_newlines_in_multiline_strings

import 'dart:convert';

import 'package:graphify/src/controller/js_methods.dart';
import 'package:graphify/src/view/graphify_renderer.dart';

/// The page hosting the chart [id], drawn with [theme] and [renderer], with
/// [dependencies] inlined if given.
String indexHtml({
  required String id,
  String? dependencies,
  Object? theme = 'dark',
  GraphifyRenderer renderer = GraphifyRenderer.canvas,
}) {
  return '''<!DOCTYPE html>
    <html>
    <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=0">
      <style>
        html, body {
          background-color: transparent;
          height: -webkit-fill-available;
          box-sizing: content-box;
          margin: 0;
          overflow: hidden;
          width: 100%;
          height: 100%;
        }
        #chart { height: -webkit-fill-available; }
      </style>
    </head>
    <body>
      <div id="chart"></div>
      ${dependencies ?? ''}
      <script>
          const dom = document.getElementById('chart');
          const context = (window.parent && window.parent.window) || window || {};
          const chart = context.echarts.init(dom, ${jsonEncode(theme)}, { renderer: '${renderer.name}', useDirtyRect: false });
          context.${JsMethods.initChart}('$id', chart, {});
          window.addEventListener('resize', chart.resize);
      </script>
    </body>
    </html>
''';
}
