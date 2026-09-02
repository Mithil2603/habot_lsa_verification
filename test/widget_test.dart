import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habot_lsa_verification/core/app_theme.dart';
import 'package:habot_lsa_verification/main.dart';

void main() {
  testWidgets('LSA Verification Screen smoke test, inputs, and theme toggle',
      (WidgetTester tester) async {
    // Reset to light mode initially
    AppTheme.themeModeNotifier.value = ThemeMode.light;

    await tester.pumpWidget(const MyApp());

    expect(find.text('LSA Verification'), findsOneWidget);
    expect(find.text('LSA Onboarding Gate'), findsOneWidget);
    expect(find.text('Verify & Submit'), findsOneWidget);

    // Verify hint texts
    expect(find.text('Enter LSA ID'), findsOneWidget);
    expect(find.text('Enter consent code'), findsOneWidget);
    expect(find.text('Enter predecessor ID'), findsOneWidget);

    // Enter text in all fields to verify they are editable
    final textFields = find.byType(TextFormField);
    expect(textFields, findsNWidgets(3));

    await tester.enterText(textFields.at(0), 'MY-LSA-123');
    await tester.enterText(textFields.at(1), 'CONSENT-456');
    await tester.enterText(textFields.at(2), 'PRED-789');
    await tester.pumpAndSettle();

    expect(find.text('MY-LSA-123'), findsOneWidget);
    expect(find.text('CONSENT-456'), findsOneWidget);
    expect(find.text('PRED-789'), findsOneWidget);

    // Verify dark mode toggle button exists
    expect(find.byIcon(Icons.dark_mode_rounded), findsOneWidget);

    // Tap dark mode toggle
    await tester.tap(find.byIcon(Icons.dark_mode_rounded));
    await tester.pumpAndSettle();

    // Verify switched to light mode toggle icon
    expect(AppTheme.themeModeNotifier.value, ThemeMode.dark);
    expect(find.byIcon(Icons.light_mode_rounded), findsOneWidget);

    // Tap light mode toggle
    await tester.tap(find.byIcon(Icons.light_mode_rounded));
    await tester.pumpAndSettle();

    expect(AppTheme.themeModeNotifier.value, ThemeMode.light);
    expect(find.byIcon(Icons.dark_mode_rounded), findsOneWidget);
  });
}
