import 'package:flutter_test/flutter_test.dart';
import 'package:graphify/src/controller/implements/facade.dart';

void main() {
  group('[GraphifyController] on an unsupported platform', () {
    final controller = GraphifyController();

    for (final (name, call) in <(String, void Function())>[
      ('update', () => controller.update(null)),
      ('dispose', controller.dispose),
      ('applyOptions', () => controller.applyOptions(null)),
      ('disposeChart', controller.disposeChart),
    ]) {
      test('throws on $name', () {
        expect(call, throwsA(isA<UnimplementedError>()));
      });
    }
  });
}
