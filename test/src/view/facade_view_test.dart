import 'package:flutter_test/flutter_test.dart';
import 'package:graphify/src/view/implements/facade.dart';

void main() {
  testWidgets('[GraphifyView] throws when built on an unsupported platform', (
    tester,
  ) async {
    await tester.pumpWidget(const GraphifyView());

    expect(tester.takeException(), isA<UnimplementedError>());
  });
}
