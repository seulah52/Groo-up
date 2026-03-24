import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('스모크: 기본 위젯 렌더', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Text('Groo-up'),
        ),
      ),
    );
    expect(find.text('Groo-up'), findsOneWidget);
  });
}
