// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:currencyconverter/main.dart';

void main() {
  testWidgets('App loads with currency converter screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const CurrencyCalculatorApp());

    // Verify that currency converter screen is loaded by default
    expect(find.text('Currency Converter'), findsOneWidget);
    expect(find.text('Amount'), findsOneWidget);
    expect(find.text('From'), findsOneWidget);
    expect(find.text('To'), findsOneWidget);

    // Verify bottom navigation is present
    expect(find.text('Converter'), findsOneWidget);
    expect(find.text('Calculator'), findsOneWidget);
  });

  testWidgets('Bottom navigation switches screens', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const CurrencyCalculatorApp());

    // Initially on converter screen
    expect(find.text('Currency Converter'), findsOneWidget);

    // Tap calculator tab
    await tester.tap(find.text('Calculator'));
    await tester.pumpAndSettle();

    // Verify calculator screen is now shown by checking for calculator-specific elements
    expect(find.text('C'), findsOneWidget); // Clear button
    expect(find.text('='), findsOneWidget); // Equals button
    expect(find.text('1'), findsOneWidget); // Number button
  });
}
