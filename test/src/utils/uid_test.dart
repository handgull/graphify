import 'package:flutter_test/flutter_test.dart';
import 'package:graphify/src/utils/uid.dart';

void main() {
  group('[UID.generate]', () {
    test('defaults to 10 characters', () {
      expect(UID.generate(), hasLength(10));
    });

    test('honors the requested length', () {
      expect(UID.generate(1), hasLength(1));
      expect(UID.generate(64), hasLength(64));
    });

    test('returns an empty id for a zero length', () {
      expect(UID.generate(0), isEmpty);
    });

    test('only uses characters safe inside a quoted JS string', () {
      expect(UID.generate(1000), matches(RegExp(r'^[a-zA-Z0-9]+$')));
    });

    test('does not repeat itself', () {
      final ids = List.generate(1000, (_) => UID.generate());

      expect(ids.toSet(), hasLength(ids.length));
    });
  });
}
