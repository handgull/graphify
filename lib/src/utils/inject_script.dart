import 'package:web/web.dart';

/// Runs [source] in the host page once: later calls with the same [id] do
/// nothing.
void injectScript(String id, String source) {
  if (document.getElementById(id) != null) {
    return;
  }
  document.body?.append(
    HTMLScriptElement()
      ..id = id
      ..text = source,
  );
}
