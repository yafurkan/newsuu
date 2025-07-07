import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Basic app test', (WidgetTester tester) async {
    // Build a simple test widget
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Center(child: Text('Test'))),
      ),
    );

    // Verify that the widget is rendered
    expect(find.text('Test'), findsOneWidget);
  });
}
