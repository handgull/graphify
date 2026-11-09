## 2.0.0

### Breaking

* Apache ECharts 6.1 (from 5.5) and echarts-gl 2.1. ECharts 6 restyles the
  default and `dark` themes, and the light theme is now named `default`.
* Require Dart 3.10 / Flutter 3.38 (`webview_flutter` 4.14).
* `GraphifyController.update` returns a `Future` on every platform.
* jQuery is no longer bundled: it was unused, and on the web it was injected
  into the host page as a global `$`.
* echarts-gl is no longer bundled into every chart, only into those whose
  `initialOptions` use a 3D or GL component or series. A chart that gets them
  later through `update` needs `GraphifyView(echartsGl: true)`; without it the
  update fails with a `StateError` saying so.
* Windows is no longer listed as supported: `webview_flutter` has no Windows
  implementation, so charts crashed there. Apps can add a `webview_flutter`
  implementation for Windows or Linux themselves.

### Added

* `GraphifyController.chartClickedEvent`: a stream of the chart's clicks, plus
  any JSON object the page posts on the `ClickEventChannel` WebView channel.
* `GraphifyView.theme` (a theme name, a theme object or `null`; `'dark'` by
  default), `GraphifyView.renderer` (`GraphifyRenderer.canvas` or `.svg`) and
  `GraphifyView.echartsGl`.

### Fixed

* Updates sent before the chart page had loaded were silently dropped: they
  now wait for it and apply in order, after the initial options.
* Fix gradient colors: `toRGBA` multiplied the 0-255 channels by 255, so every
  non-zero channel was sent as fully saturated (e.g. grey `#808080` rendered
  white). Colors in other color spaces (e.g. Display P3) are now converted to
  sRGB instead of being sent as-is.
* Mobile: listen for the page load before starting it, closing a race where
  `onCreated` and the initial options could be missed.

### Internal

* Remove the unused native plugin scaffolding (android, ios, macos, linux,
  windows): graphify never registered a native plugin.
* Lint with `very_good_analysis`; full test suite for VM and browser.

## 1.2.0

* 31 refactor colorutil by @warioddly in https://github.com/warioddly/graphify/pull/33
* refactor GraphifyController and update dependencies by @warioddly in https://github.com/warioddly/graphify/pull/36
* refactor: update plugin paths and improve Graphify interface structure by @warioddly in https://github.com/warioddly/graphify/pull/37
* bump version to 1.2.0 in pubspec.yaml by @warioddly in https://github.com/warioddly/graphify/pull/38
**Full Changelog**: https://github.com/warioddly/graphify/compare/v1.1.1...v1.2.0

## 1.1.1

* Fix bug in old versions Flutter "Try changing the name to the name of an existing improvement, or identify an improvement, or a field named "r"."

## 1.1.0

* Fix bug with background color
* Optimize render

## 1.0.9

* Add linear, radial gradient support for charts

## 1.0.8

* Optimize and refactor the code

## 0.0.2

* Add support update chart 
* Adding example of how to use graphify

