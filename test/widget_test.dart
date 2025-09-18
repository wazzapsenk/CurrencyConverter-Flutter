// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:currencyconverter/main.dart';

void main() {
  setUp(() async {
    // Set up SharedPreferences to skip onboarding in tests
    SharedPreferences.setMockInitialValues({'onboarding_completed': true});
  });

  testWidgets('App loads with currency converter screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const CurrencyCalculatorApp());
    await tester.pump();
    await tester.pump(const Duration(seconds: 1)); // Wait for animations

    // Verify that currency converter screen is loaded by default
    expect(find.text('Currency Converter'), findsOneWidget);
    expect(find.text('Amount'), findsOneWidget);
    expect(find.text('From'), findsOneWidget);
    expect(find.text('To'), findsOneWidget);

    // Verify bottom navigation is present
    expect(find.text('Converter'), findsOneWidget);
    expect(find.text('Calculator'), findsOneWidget);
    expect(find.text('Tutorial'), findsOneWidget);
  });

  testWidgets('Bottom navigation switches screens', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const CurrencyCalculatorApp());
    await tester.pump();
    await tester.pump(const Duration(seconds: 1)); // Wait for animations

    // Initially on converter screen
    expect(find.text('Currency Converter'), findsOneWidget);

    // Tap calculator tab
    await tester.tap(find.text('Calculator'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500)); // Wait for navigation animation

    // Verify calculator screen is now shown by checking for calculator-specific elements
    expect(find.text('C'), findsOneWidget); // Clear button
    expect(find.text('='), findsOneWidget); // Equals button
    expect(find.text('1'), findsOneWidget); // Number button
  });

  testWidgets('Onboarding shows on first launch', (WidgetTester tester) async {
    // Reset SharedPreferences to simulate first launch
    SharedPreferences.setMockInitialValues({});

    // Build our app and trigger a frame.
    await tester.pumpWidget(const CurrencyCalculatorApp());
    await tester.pump();
    await tester.pump(const Duration(seconds: 1)); // Wait for animations

    // Verify that onboarding screen is shown
    expect(find.text('Welcome to Currency Calculator'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);
  });
}
