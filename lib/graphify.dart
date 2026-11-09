/// Apache ECharts charts for Flutter, rendered in a WebView on mobile and
/// in an iframe on the web.
library;

export 'src/controller/implements/facade.dart'
    if (dart.library.io) 'src/controller/implements/mobile.dart'
    if (dart.library.js_interop) 'src/controller/implements/web.dart';
export 'src/utils/gradient/_gradient.dart';
export 'src/view/graphify_renderer.dart';
export 'src/view/implements/facade.dart'
    if (dart.library.io) 'src/view/implements/mobile.dart'
    if (dart.library.js_interop) 'src/view/implements/web.dart';
