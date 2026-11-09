import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:graphify_example/main.dart';

void main() {
  group('[MyApp]', () {
    testWidgets('lists every example chart', (tester) async {
      await tester.pumpWidget(const MyApp());

      for (final title in MyApp.charts.keys) {
        await tester.scrollUntilVisible(find.text(title), 100);
        expect(find.text(title), findsOneWidget);
      }
    });

    testWidgets('links the source code and pub.dev', (tester) async {
      await tester.pumpWidget(const MyApp());

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.text('Open Source Code'), findsOneWidget);
      expect(find.text('Pub.dev'), findsOneWidget);
    });
  });
}
